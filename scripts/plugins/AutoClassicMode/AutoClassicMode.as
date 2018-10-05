
void print(string text) { g_Game.AlertMessage( at_console, text); }
void println(string text) { print(text + "\n"); }

dictionary classic_maps;

bool isClassicMap = false;

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
	isClassicMap = classic_maps.exists(g_Engine.mapname);
	
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
	
	if (isClassicMap)
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
	if (isClassicMap)
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