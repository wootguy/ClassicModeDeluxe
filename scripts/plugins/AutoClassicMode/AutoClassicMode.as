
void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

dictionary classic_maps;

bool isClassicMap = false;

enum MODES {
	MODE_AUTO = -1,
	MODE_ALWAYS_OFF = 0,
	MODE_ALWAYS_ON = 1
}

int g_force_mode = MODE_ALWAYS_ON;
bool g_basic_mode = false;

void loadMapList(File@ f=null)
{	
	if (f is null) {
		string fpath = "scripts/plugins/AutoClassicMode/classic_maps.txt";
		@f = g_FileSystem.OpenFile( fpath, OpenFile::READ );
		if( f is null or !f.IsOpen())
		{
			println("AutoClassicMode: Failed to open " + fpath);
			return;
		}
	}

	int linesRead = 0;
	string line;
	while( !f.EOFReached() )
	{
		f.ReadLine(line);		
		classic_maps[line] = true;
	}
	
	println("AutoClassicMode: Map list loaded");
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "w00tguy" );
	g_Module.ScriptInfo.SetContactInfo( "w00tguy123 - forums.svencoop.com" );
	
	loadMapList();
}

void MapInit()
{
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
	
	// classic mode votes will only restart the map but not change anything. Might as well disable it.
	g_EngineFuncs.ServerCommand("mp_voteclassicmoderequired -1;\n");
	g_EngineFuncs.ServerExecute();
	
	isClassicMap = classic_maps.exists(g_Engine.mapname);
	if (g_force_mode == MODE_ALWAYS_ON)
		isClassicMap = true;
	else if (g_force_mode == MODE_ALWAYS_OFF)
		isClassicMap = false;
	
	println("IS CLASSIC MAP PLUGIN? " + isClassicMap); 
	
	dictionary keys;
	keys["targetname"] = "AutoClassicModeTrigger";
	keys["m_iszScriptFile"] = "AutoClassicMode";
	keys["m_iszScriptFunctionName"] = "AutoClassicMode::MapInit";
	keys["m_iMode"] = "1";
	CBaseEntity@ classicTrigger = g_EntityFuncs.CreateEntity("trigger_script", keys, true);
	classicTrigger.pev.rendermode = isClassicMap ? 1 : 0;
	
	classicTrigger.Think();
	g_EntityFuncs.FireTargets("AutoClassicModeTrigger", classicTrigger, classicTrigger, USE_ON, 0.0f);
	g_EntityFuncs.Remove(classicTrigger);
	
	if (isClassicMap and !g_basic_mode)
	{
		keys["targetname"] = "game_playerspawn";
		keys["m_iszScriptFunctionName"] = "AutoClassicMode::PlayerSpawn";
		g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		
		keys["targetname"] = "game_playerdie";
		keys["m_iszScriptFunctionName"] = "AutoClassicMode::PlayerDie";
		g_EntityFuncs.CreateEntity("trigger_script", keys, true);
	}
}

void MapActivate()
{
	if (isClassicMap and !g_basic_mode)
	{
		dictionary keys;
		keys["targetname"] = "AutoClassicModeTrigger";
		keys["m_iszScriptFile"] = "AutoClassicMode";
		keys["m_iszScriptFunctionName"] = "AutoClassicMode::MapActivate";
		keys["m_iMode"] = "1";
		CBaseEntity@ classicTrigger = g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		
		classicTrigger.Think();
		g_EntityFuncs.FireTargets("AutoClassicModeTrigger", classicTrigger, classicTrigger, USE_ON, 0.0f);
		g_EntityFuncs.Remove(classicTrigger);
	}
}

bool doCommand(CBasePlayer@ plr, const CCommand@ args)
{	
	bool isAdmin = g_PlayerFuncs.AdminLevel(plr) >= ADMIN_YES;

	if ( args.ArgC() > 0 )
	{
		if (args[0] == ".classic" or args[0] == ".cm")
		{
			if (args.ArgC() > 1)
			{
				if (args[1] == "1")
				{
					if (g_force_mode != MODE_ALWAYS_ON)
						g_PlayerFuncs.SayTextAll(plr, "Classic mode is now ON\n");
					else
						g_PlayerFuncs.SayText(plr, "Classic mode is already set to ON\n");
					g_force_mode = MODE_ALWAYS_ON;
				}
				else if (args[1] == "0")
				{
					if (g_force_mode != MODE_ALWAYS_OFF)
						g_PlayerFuncs.SayTextAll(plr, "Classic mode is now OFF\n");
					else
						g_PlayerFuncs.SayText(plr, "Classic mode is already set to OFF\n");
					g_force_mode = MODE_ALWAYS_OFF;
				}
				else if (args[1] == "2")
				{
					if (g_force_mode != MODE_AUTO)
						g_PlayerFuncs.SayTextAll(plr, "Classic mode is now AUTO.\n");
					else
						g_PlayerFuncs.SayText(plr, "Classic mode is already set to AUTO\n");
					g_force_mode = MODE_AUTO;
				}
				return true;
			}
			else
			{
				string msg = "Classic mode is ";
				switch(g_force_mode)
				{
					case MODE_ALWAYS_OFF:
						msg += "OFF";
						break;
					case MODE_ALWAYS_ON:
						msg += "ON";
						break;
					case MODE_AUTO:
					default:
						msg += "AUTO - ";
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

HookReturnCode ClientSay( SayParameters@ pParams )
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