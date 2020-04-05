
enum map_types {
	MAP_HALF_LIFE = 0,
	MAP_OPPOSING_FORCE = 1,
	MAP_BLUE_SHIFT = 2,
}

void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

CCVar@ cvar_mode;
CCVar@ cvar_skill;
CCVar@ cvar_fastmove;

dictionary classic_maps;
dictionary op4_maps;
dictionary bshift_maps;
dictionary ignore_maps;

bool isClassicMap = false;
int mapType = MAP_HALF_LIFE;

enum MODES {
	MODE_AUTO = -1,
	MODE_ALWAYS_OFF = 0,
	MODE_ALWAYS_ON = 1
}

bool g_basic_mode = false;
bool brokenInstall = false;

const float DEFAULT_MAX_SPEED_SVEN = 270;
const float DEFAULT_MAX_SPEED_HL = 320;

string plugin_path = "scripts/plugins/ClassicModeDeluxe/";
string skill_default_file = "skill_sven50.cfg";
string skill1_file = "skill_sven30_normal.cfg";
string skill2_file = "skill_hl_hard.cfg";

// load default skill settings so this plugin doesn't override any custom map skill settings
dictionary default_skill_settings;
dictionary skill1_settings;
dictionary skill2_settings;

dictionary loadMapList(string fpath)
{
	dictionary maps;
	File@ f = g_FileSystem.OpenFile( fpath, OpenFile::READ );
	if (f is null or !f.IsOpen())
	{
		println("ClassicModeDeluxe: Failed to open " + fpath);
		return maps;
	}
	
	int mapCount = 0;
	string line;
	while( !f.EOFReached() )
	{
		f.ReadLine(line);
		line.Trim();
		line.Trim("\t");
		if (line.Length() == 0 or line.Find("//") == 0)
			continue;
		maps[line] = true;
		mapCount++;
	}
	//println("ClassicModeDeluxe: Loaded " + mapCount + " maps from " + fpath);
	return maps;
}

dictionary loadSkillSettings(string fpath)
{
	dictionary settings;
	File@ f = g_FileSystem.OpenFile( fpath, OpenFile::READ );
	if (f is null or !f.IsOpen())
	{
		println("ClassicModeDeluxe: Failed to open " + fpath);
		return settings;
	}
	
	string line;
	while( !f.EOFReached() )
	{
		f.ReadLine(line);
		line.Trim();
		if (line.Length() == 0 or line.Find("sk_") != 0)
			continue;
			
		array<string> parts = line.Split("\"");
		if (parts.size() < 2)
			continue;
			
		string skill = parts[0];
		string value = parts[1];
		skill.Trim();
		value.Trim();
		skill.Trim("\t");
		value.Trim("\t");
			
		settings[skill] = atof(value);
	}
	return settings;
}

void execClassicSkillSettings()
{	
	dictionary classic_skill_settings = skill1_settings;
	if (cvar_skill.GetInt() == 2)
		classic_skill_settings = skill2_settings;
	array<string> keys = classic_skill_settings.getKeys();
	for (uint i = 0; i < keys.size(); i++)
	{
		float classicValue = -1;
		float defaultValue = -1;
		float currentValue = g_EngineFuncs.CVarGetFloat(keys[i]);
		default_skill_settings.get(keys[i], defaultValue);
		classic_skill_settings.get(keys[i], classicValue);
		if (!default_skill_settings.exists(keys[i]))
			println("Missing default skill value for " + keys[i]);
		
		if (currentValue == defaultValue) {
			g_EngineFuncs.ServerCommand(keys[i] + " " + classicValue + ";");
		}
	}
	g_EngineFuncs.ServerExecute();
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "w00tguy" );
	g_Module.ScriptInfo.SetContactInfo( "w00tguy123 - forums.svencoop.com" );
	
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClassicModeDeluxeSay );
	
	@cvar_mode = CCVar("mode", -1, "0 = off, 1 = on, -1 = auto", ConCommandFlag::AdminOnly);
	@cvar_skill = CCVar("skill", 1, "0 = SC 5.0, 1 = SC 3.0, 2 = HL", ConCommandFlag::AdminOnly);
	@cvar_fastmove = CCVar("fastmove", 1, "1 = enable Half-Life movement speed (320)", ConCommandFlag::AdminOnly);
	
	default_skill_settings = loadSkillSettings(plugin_path + skill_default_file);
	skill1_settings = loadSkillSettings(plugin_path + skill1_file);
	skill2_settings = loadSkillSettings(plugin_path + skill2_file);
	
	classic_maps = loadMapList(plugin_path + "classic_maps.txt");
	op4_maps = loadMapList(plugin_path + "op4_maps.txt");
	bshift_maps = loadMapList(plugin_path + "bshift_maps.txt");
	ignore_maps = loadMapList(plugin_path + "ignore_maps.txt");
	//println("ClassicModeDeluxe: Map lists loaded");
}

void MapInit()
{
	if (ignore_maps.exists(g_Engine.mapname)) {
		return;
	}
	
	// classic mode votes will only restart the map but not change anything. Might as well disable it.
	g_EngineFuncs.ServerCommand("mp_voteclassicmoderequired -1;\n");
	g_EngineFuncs.ServerExecute();

	isClassicMap = classic_maps.exists(g_Engine.mapname);
	
	mapType = MAP_HALF_LIFE;
	if (isClassicMap)
	{
		if (op4_maps.exists(g_Engine.mapname))
			mapType = MAP_OPPOSING_FORCE;
		else if (bshift_maps.exists(g_Engine.mapname))
			mapType = MAP_BLUE_SHIFT;
	}
		
	if (cvar_mode.GetInt() == MODE_ALWAYS_ON)
		isClassicMap = true;
	else if (cvar_mode.GetInt() == MODE_ALWAYS_OFF)
		isClassicMap = false;
	
	if (isClassicMap)
	{
		// weaponmode_mp5 breaks the GL if enabled
		g_EngineFuncs.ServerCommand("weaponmode_mp5 0;\n");
		g_EngineFuncs.ServerExecute();
		
		if (cvar_skill.GetInt() > 0)
			execClassicSkillSettings();
		
		float sv_maxspeed = g_EngineFuncs.CVarGetFloat("sv_maxspeed");
		if (cvar_fastmove.GetInt() != 0 and sv_maxspeed == DEFAULT_MAX_SPEED_SVEN)
			g_EngineFuncs.CVarSetFloat("sv_maxspeed", DEFAULT_MAX_SPEED_HL);
	}
	
	dictionary keys;
	keys["targetname"] = "ClassicModeDeluxeTrigger";
	keys["m_iszScriptFile"] = "ClassicModeDeluxe";
	keys["m_iszScriptFunctionName"] = "ClassicModeDeluxe::MapInit";
	keys["m_iMode"] = "1";
	CBaseEntity@ classicTrigger = g_EntityFuncs.CreateEntity("trigger_script", keys, true);
	int mapInfo = (isClassicMap ? 1 : 0) + (mapType << 1);
	classicTrigger.pev.rendermode = mapInfo;
	
	classicTrigger.Think();
	g_EntityFuncs.FireTargets("ClassicModeDeluxeTrigger", classicTrigger, classicTrigger, USE_ON, 0.0f);
	
	brokenInstall = classicTrigger.pev.renderfx != 1;
	if (brokenInstall) {
		println("ClassicModeDeluxe: Map script failed to load. Did you install the custom default_map_settings.cfg?");
	}
	
	g_EntityFuncs.Remove(classicTrigger);
}

void MapActivate()
{
	if (isClassicMap and !g_basic_mode)
	{
		dictionary keys;
		keys["targetname"] = "ClassicModeDeluxeTrigger";
		keys["m_iszScriptFile"] = "ClassicModeDeluxe";
		keys["m_iszScriptFunctionName"] = "ClassicModeDeluxe::MapActivate";
		keys["m_iMode"] = "1";
		CBaseEntity@ classicTrigger = g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		
		classicTrigger.Think();
		g_EntityFuncs.FireTargets("ClassicModeDeluxeTrigger", classicTrigger, classicTrigger, USE_ON, 0.0f);
		g_EntityFuncs.Remove(classicTrigger);
		
		keys["targetname"] = "game_playerspawn";
		keys["m_iszScriptFunctionName"] = "ClassicModeDeluxe::PlayerSpawn";
		g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		
		keys["targetname"] = "game_playerdie";
		keys["m_iszScriptFunctionName"] = "ClassicModeDeluxe::PlayerDie";
		g_EntityFuncs.CreateEntity("trigger_script", keys, true);
	}
}

bool doCommand(CBasePlayer@ plr, const CCommand@ args)
{	
	bool isAdmin = g_PlayerFuncs.AdminLevel(plr) >= ADMIN_YES;

	if ( args.ArgC() > 0 )
	{
		if (args[0] == ".classic" or args[0] == ".cm")
		{
			if (brokenInstall)
			{
				g_PlayerFuncs.SayText(plr, "The ClassicModeDeluxe map script failed to load.\n");
				g_PlayerFuncs.SayText(plr, "Did you install the custom default_map_settings.cfg?\n");
				return true;
			}
			if (args.ArgC() > 1)
			{
				string arg = args[1].ToLowercase();
				if (arg == "version")
				{
					g_PlayerFuncs.SayText(plr, "Classic mode version: v7\n");
					return true;
				}
				if (g_PlayerFuncs.AdminLevel(plr) < ADMIN_YES)
				{
					g_PlayerFuncs.SayText(plr, "Only admins can change classic mode settings\n");
					return true;
				}
				if (arg == "1" or arg == "on")
				{
					if (cvar_mode.GetInt() != MODE_ALWAYS_ON)
						g_PlayerFuncs.SayTextAll(plr, "Classic mode is now ON. All future maps will have classic mode enabled.\n");
					else
						g_PlayerFuncs.SayText(plr, "Classic mode is already set to ON\n");
					cvar_mode.SetInt(MODE_ALWAYS_ON);
				}
				else if (arg == "0" or arg == "off")
				{
					if (cvar_mode.GetInt() != MODE_ALWAYS_OFF)
						g_PlayerFuncs.SayTextAll(plr, "Classic mode is now OFF. All future maps will have classic mode disabled.\n");
					else
						g_PlayerFuncs.SayText(plr, "Classic mode is already set to OFF\n");
					cvar_mode.SetInt(MODE_ALWAYS_OFF);
				}
				else if (arg == "-1" or arg == "auto")
				{
					if (cvar_mode.GetInt() != MODE_AUTO)
						g_PlayerFuncs.SayTextAll(plr, "Classic mode is now AUTO. Only classic maps will have classic mode enabled.\n");
					else
						g_PlayerFuncs.SayText(plr, "Classic mode is already set to AUTO\n");
					cvar_mode.SetInt(MODE_AUTO);
				}
				else
				{
					g_PlayerFuncs.SayText(plr, "Classic mode usage:\n"); 
					g_PlayerFuncs.SayText(plr, ".cm = show current mode\n");
					g_PlayerFuncs.SayText(plr, ".cm [ON/OFF/AUTO] = set classic mode behavior\n"); 
					g_PlayerFuncs.SayText(plr, ".cm version = show plugin version\n");
				}
				return true;
			}
			else
			{
				string msg = "Classic mode is ";
				switch(cvar_mode.GetInt())
				{
					case MODE_ALWAYS_OFF:
						msg += "OFF";
						break;
					case MODE_ALWAYS_ON:
						msg += "ON";
						break;
					case MODE_AUTO:
					default:
						msg += "AUTO. ";
						if (isClassicMap)
							msg += "This is a classic map.";
						else
							msg += "This is a modern map.";
				}		
				
				g_PlayerFuncs.SayText(plr, msg + "\n");
				return true;
			}
		}
	}
	return false;
}

HookReturnCode ClassicModeDeluxeSay( SayParameters@ pParams )
{
	CBasePlayer@ plr = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();	
	if (doCommand(plr, args))
	{
		pParams.ShouldHide = true;
		return HOOK_HANDLED;
	}
	return HOOK_CONTINUE;
}