// TODO:


// Impossible replacements:
// Player uzi shoot sound
// Player sniper shoot + reload sounds
// Monster sniper reload sound
// Uzi/Saw bullet casings
// footstep sounds
// nerf armor
// golden uzi third-person model
// muzzle-flashes (minigun?)
// disable full-auto for shotgun/mp5 on npcs
// custom soundlists for the HL grunt are ignored
// satchel models replaced with GMR AND classic mode prevents radio model from showing

namespace AutoClassicMode {

	void print(string text) { g_Game.AlertMessage( at_console, text); }
	void println(string text) { print(text + "\n"); }
	
	bool isClassicMap = false;
	bool mapUsesGMR = true;
	
	dictionary classicItems; // weapons that the built-in classic mode replaces. Value is the model name.
	dictionary defaultWeaponModels; // weapon models for the default weapons
	dictionary modelReplacements;
	dictionary classicFriendlies; // monsters that have friendly models but are also partially replaced by classic mode
	dictionary autoReplace; // models that are automatically replaced by classic mode
	dictionary autoReplaceMonsters; // monsters that classic mode replaces automatically
	dictionary blacklist; // models that shouldn't be replaced because GMR is already replacing them
	
	string replacementModelPath = "models/AutoClassicMode/";
	string replacementSpritePath = "sprites/AutoClassicMode/";
	string replacementSoundPath = "AutoClassicMode/";
	
	string spawnHookName = "AutoClassicMode_MonsterSpawn";
	string deathHookName = "AutoClassicMode_MonsterKilled";
	string damageHookName = "AutoClassicMode_MonsterDamaged"; // for monsters that drop weapons when damaged (hwgrunt)
	string breakableHookName = "AutoClassicMode_BreakableBroken"; // for func_breakables that spawn items
	
	array<int> lastAmmo; // ammo counts for all player active weapons
	array<uint64> lastWeapons; // weapon states for all players (have/not have)
	
	// keep this in sync with sound/AutoClassicMode/weapons.txt
	array<string> replacedSounds = {
		"weapons/sniper_fire.wav",
		"weapons/uzi/fire_both1.wav",
		"weapons/uzi/fire_both2.wav",
		"weapons/m16_3round.wav",
		"weapons/sbarrel1.wav",
		"weapons/scock1.wav"
	};
	
	void initModelReplacements()
	{
		modelReplacements["models/otis.mdl"] = true;
		modelReplacements["models/otisf.mdl"] = true;
		modelReplacements["models/zombie_barney.mdl"] = true;
		modelReplacements["models/zombie_soldier.mdl"] = true;
		modelReplacements["models/hgrunt_medic.mdl"] = true;
		modelReplacements["models/hgrunt_medicf.mdl"] = true;
		modelReplacements["models/hgrunt_opfor.mdl"] = true;
		modelReplacements["models/hgrunt_opforf.mdl"] = true;
		modelReplacements["models/hgrunt_torch.mdl"] = true;
		modelReplacements["models/hgrunt_torchf.mdl"] = true;
		modelReplacements["models/massn.mdl"] = true;
		modelReplacements["models/massnf.mdl"] = true;
		modelReplacements["models/rgrunt.mdl"] = true;
		modelReplacements["models/rgruntf.mdl"] = true;
		modelReplacements["models/hwgrunt.mdl"] = true;
		modelReplacements["models/hwgruntf.mdl"] = true;
		modelReplacements["models/osprey.mdl"] = true;
		modelReplacements["models/osprey2.mdl"] = true;
		modelReplacements["models/ospreyf.mdl"] = true;
		modelReplacements["models/blkop_apache.mdl"] = true;
		modelReplacements["models/blkop_osprey.mdl"] = true;
		modelReplacements["models/apachef.mdl"] = true;
		modelReplacements["models/agruntf.mdl"] = true;
		modelReplacements["models/strooper.mdl"] = true;
		modelReplacements["models/bgman.mdl"] = true;
		modelReplacements["models/w_shock_rifle.mdl"] = true;
		modelReplacements["models/barnabus.mdl"] = true;
		modelReplacements["models/hassassinf.mdl"] = true;
		modelReplacements["models/hgruntf.mdl"] = true;
		modelReplacements["models/islavef.mdl"] = true;
		modelReplacements["models/player.mdl"] = true;
		modelReplacements["models/gonome.mdl"] = true;
		modelReplacements["models/tor.mdl"] = true;
		modelReplacements["models/torf.mdl"] = true;
		modelReplacements["models/hgrunt.mdl"] = true;
		modelReplacements["models/hlclassic/barney.mdl"] = true;
		modelReplacements["models/hlclassic/hgrunt.mdl"] = true; // the vanilla classic grunt is missing rpg anims
		modelReplacements["models/hlclassic/hassassin.mdl"] = true;
		modelReplacements["models/hlclassic/islave.mdl"] = true;
		modelReplacements["models/hlclassic/agrunt.mdl"] = true;
		
		modelReplacements["models/v_saw.mdl"] = true;
		modelReplacements["models/p_saw.mdl"] = true;
		modelReplacements["models/w_saw.mdl"] = true;
		
		modelReplacements["models/v_m40a1.mdl"] = true;
		modelReplacements["models/p_m40a1.mdl"] = true;
		modelReplacements["models/w_m40a1.mdl"] = true;
		
		modelReplacements["models/v_spore_launcher.mdl"] = true;
		modelReplacements["models/p_spore_launcher.mdl"] = true;
		modelReplacements["models/w_spore_launcher.mdl"] = true;
		
		modelReplacements["models/v_displacer.mdl"] = true;
		modelReplacements["models/p_displacer.mdl"] = true;
		modelReplacements["models/w_displacer.mdl"] = true;
		
		modelReplacements["models/w_pipe_wrench.mdl"] = true;
		modelReplacements["models/v_pipe_wrench.mdl"] = true;
		modelReplacements["models/p_pipe_wrench.mdl"] = true;
		
		// TODO: dual and golden uzi models don't work (except for view model)
		modelReplacements["models/v_uzi.mdl"] = true;
		modelReplacements["models/p_uzi.mdl"] = true;
		modelReplacements["models/w_uzi.mdl"] = true;
		//modelReplacements["models/w_2uzis.mdl"] = true;
		modelReplacements["models/p_2uzis.mdl"] = true;
		modelReplacements["models/p_uzi_gold.mdl"] = true;
		modelReplacements["models/w_uzi_gold.mdl"] = true;
		modelReplacements["models/p_2uzis_gold.mdl"] = true;
		//modelReplacements["models/w_2uzis_gold.mdl"] = true;
		
		modelReplacements["models/v_minigun.mdl"] = true;
		modelReplacements["models/p_minigunidle.mdl"] = true;
		modelReplacements["models/p_minigunspin.mdl"] = true;
		modelReplacements["models/w_minigun.mdl"] = true;
		
		modelReplacements["models/v_desert_eagle.mdl"] = true;
		modelReplacements["models/w_desert_eagle.mdl"] = true;
		modelReplacements["models/p_desert_eagle.mdl"] = true;
		
		modelReplacements["models/v_bgrap.mdl"] = true;
		modelReplacements["models/p_bgrap.mdl"] = true;
		modelReplacements["models/w_bgrap.mdl"] = true;
		
		modelReplacements["models/v_shock.mdl"] = true;
		modelReplacements["models/p_shock.mdl"] = true;
		
		modelReplacements["models/w_uzi_clip.mdl"] = true;
		modelReplacements["models/w_saw_clip.mdl"] = true;
		modelReplacements["models/w_m40a1clip.mdl"] = true;
		
		defaultWeaponModels["weapon_m249"] = "saw";
		defaultWeaponModels["weapon_sniperrifle"] = "m40a1";
		defaultWeaponModels["weapon_sporelauncher"] = "spore_launcher";
		defaultWeaponModels["weapon_displacer"] = "displacer";
		defaultWeaponModels["weapon_uzi"] = "uzi";
		defaultWeaponModels["weapon_uziakimbo"] = "2uzis";
		defaultWeaponModels["weapon_eagle"] = "desert_eagle";
		defaultWeaponModels["weapon_grapple"] = "bgrap";
		defaultWeaponModels["weapon_minigun"] = "minigun";
		defaultWeaponModels["weapon_shockrifle"] = "shock";
		defaultWeaponModels["weapon_pipewrench"] = "pipe_wrench";
		defaultWeaponModels["weapon_crowbar"] = "crowbar";
		defaultWeaponModels["weapon_medkit"] = "medkit";
		defaultWeaponModels["weapon_9mmhandgun"] = "9mmhandgun";
		defaultWeaponModels["weapon_357"] = "357";
		defaultWeaponModels["weapon_9mmar"] = "9mmar";
		defaultWeaponModels["weapon_shotgun"] = "shotgun";
		defaultWeaponModels["weapon_crossbow"] = "crossbow";
		defaultWeaponModels["weapon_rpg"] = "rpg";
		defaultWeaponModels["weapon_gauss"] = "gauss";
		defaultWeaponModels["weapon_egon"] = "egon";
		defaultWeaponModels["weapon_handgrenade"] = "grenade";
		defaultWeaponModels["weapon_satchel"] = "satchel";
		defaultWeaponModels["weapon_tripmine"] = "tripmine";
		defaultWeaponModels["weapon_snark"] = "squeak";
		
		classicItems["weapon_crowbar"] = "crowbar";
		classicItems["weapon_medkit"] = "medkit";
		classicItems["weapon_9mmhandgun"] = "9mmhandgun";
		classicItems["weapon_357"] = "357";
		classicItems["weapon_9mmar"] = "9mmar";
		classicItems["weapon_shotgun"] = "shotgun";
		classicItems["weapon_crossbow"] = "crossbow";
		classicItems["weapon_rpg"] = "rpg";
		classicItems["weapon_gauss"] = "gauss";
		classicItems["weapon_egon"] = "egon";
		classicItems["weapon_handgrenade"] = "grenade";
		classicItems["weapon_satchel"] = "satchel";
		classicItems["weapon_tripmine"] = "tripmine";
		classicItems["weapon_snark"] = "squeak";
		classicItems["ammo_357"] = "357ammobox";
		classicItems["ammo_9mmar"] = "9mmarclip";
		classicItems["ammo_9mmbox"] = "chainammo";
		classicItems["ammo_9mmclip"] = "9mmclip";
		classicItems["ammo_argrenades"] = "argrenade";
		classicItems["ammo_buckshot"] = "shotbox";
		classicItems["ammo_crossbow"] = "crossbow_clip";
		classicItems["ammo_gaussclip"] = "gaussammo";
		classicItems["ammo_rpgclip"] = "rpgammo";
		classicItems["item_battery"] = "battery";
		classicItems["item_healthkit"] = "medkit";
		classicItems["item_longjump"] = "longjump";
		classicItems["item_suit"] = "suit";
		
		classicFriendlies["monster_barney"] = replacementModelPath + "barnabus.mdl";
		classicFriendlies["monster_barney_dead"] = replacementModelPath + "barnabus.mdl";
		classicFriendlies["monster_human_grunt"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_hgrunt_dead"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_grunt_repel"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_human_assassin"] = replacementModelPath + "hassassinf.mdl";
		classicFriendlies["monster_alien_slave"] = replacementModelPath + "islavef.mdl";
		classicFriendlies["monster_alien_grunt"] = replacementModelPath + "agruntf.mdl";
		
		autoReplace["models/hlclassic/agrunt.mdl"] = "models/agrunt.mdl";
		autoReplace["models/hlclassic/apache.mdl"] = "models/apache.mdl";
		autoReplace["models/hlclassic/barnacle.mdl"] = "models/barnacle.mdl";
		autoReplace["models/hlclassic/barney.mdl"] = "models/barney.mdl";
		autoReplace["models/hlclassic/bullsquid.mdl"] = "models/bullsquid.mdl";
		autoReplace["models/hlclassic/garg.mdl"] = "models/garg.mdl";
		autoReplace["models/hlclassic/gman.mdl"] = "models/gman.mdl";
		autoReplace["models/hlclassic/grenade.mdl"] = "models/grenade.mdl";
		autoReplace["models/hlclassic/hassassin.mdl"] = "models/hassassin.mdl";
		autoReplace["models/hlclassic/headcrab.mdl"] = "models/headcrab.mdl";
		autoReplace["models/hlclassic/hgrunt.mdl"] = "models/hgrunt.mdl";
		autoReplace["models/hlclassic/holo.mdl"] = "models/holo.mdl";
		autoReplace["models/hlclassic/houndeye.mdl"] = "models/houndeye.mdl";
		autoReplace["models/hlclassic/icky.mdl"] = "models/icky.mdl";
		autoReplace["models/hlclassic/islave.mdl"] = "models/islave.mdl";
		autoReplace["models/hlclassic/osprey.mdl"] = "models/osprey.mdl";
		autoReplace["models/hlclassic/osprey_bodygibs.mdl"] = "models/osprey_bodygibs.mdl";
		autoReplace["models/hlclassic/osprey_enginegibs.mdl"] = "models/osprey_enginegibs.mdl";
		autoReplace["models/hlclassic/osprey_tailgibs.mdl"] = "models/osprey_tailgibs.mdl";
		autoReplace["models/hlclassic/player.mdl"] = "models/player.mdl";
		autoReplace["models/hlclassic/p_357.mdl"] = "models/p_357.mdl";
		autoReplace["models/hlclassic/p_9mmar.mdl"] = "models/p_9mmar.mdl";
		autoReplace["models/hlclassic/p_9mmhandgun.mdl"] = "models/p_9mmhandgun.mdl";
		autoReplace["models/hlclassic/p_crossbow.mdl"] = "models/p_crossbow.mdl";
		autoReplace["models/hlclassic/p_crowbar.mdl"] = "models/p_crowbar.mdl";
		autoReplace["models/hlclassic/p_egon.mdl"] = "models/p_egon.mdl";
		autoReplace["models/hlclassic/p_gauss.mdl"] = "models/p_gauss.mdl";
		autoReplace["models/hlclassic/p_glock.mdl"] = "models/p_glock.mdl";
		autoReplace["models/hlclassic/p_grenade.mdl"] = "models/p_grenade.mdl";
		autoReplace["models/hlclassic/p_hgun.mdl"] = "models/p_hgun.mdl";
		autoReplace["models/hlclassic/p_medkit.mdl"] = "models/p_medkit.mdl";
		autoReplace["models/hlclassic/p_rpg.mdl"] = "models/p_rpg.mdl";
		autoReplace["models/hlclassic/p_satchel.mdl"] = "models/p_satchel.mdl";
		autoReplace["models/hlclassic/p_satchel_radio.mdl"] = "models/p_satchel_radio.mdl";
		autoReplace["models/hlclassic/p_shotgun.mdl"] = "models/p_shotgun.mdl";
		autoReplace["models/hlclassic/p_squeak.mdl"] = "models/p_squeak.mdl";
		autoReplace["models/hlclassic/p_tripmine.mdl"] = "models/p_tripmine.mdl";
		autoReplace["models/hlclassic/roach.mdl"] = "models/roach.mdl";
		autoReplace["models/hlclassic/rpgrocket.mdl"] = "models/rpgrocket.mdl";
		autoReplace["models/hlclassic/scientist.mdl"] = "models/scientist.mdl";
		autoReplace["models/hlclassic/scigun.mdl"] = "models/scigun.mdl";
		autoReplace["models/hlclassic/shell.mdl"] = "models/shell.mdl";
		autoReplace["models/hlclassic/shotgunshell.mdl"] = "models/shotgunshell.mdl";
		autoReplace["models/hlclassic/tentacle2.mdl"] = "models/tentacle2.mdl";
		autoReplace["models/hlclassic/v_357.mdl"] = "models/v_357.mdl";
		autoReplace["models/hlclassic/v_9mmAR.mdl"] = "models/v_9mmAR.mdl";
		autoReplace["models/hlclassic/v_9mmhandgun.mdl"] = "models/v_9mmhandgun.mdl";
		autoReplace["models/hlclassic/v_crossbow.mdl"] = "models/v_crossbow.mdl";
		autoReplace["models/hlclassic/v_crowbar.mdl"] = "models/v_crowbar.mdl";
		autoReplace["models/hlclassic/v_egon.mdl"] = "models/v_egon.mdl";
		autoReplace["models/hlclassic/v_gauss.mdl"] = "models/v_gauss.mdl";
		autoReplace["models/hlclassic/v_grenade.mdl"] = "models/v_grenade.mdl";
		autoReplace["models/hlclassic/v_HGun.mdl"] = "models/v_HGun.mdl";
		autoReplace["models/hlclassic/v_medkit.mdl"] = "models/v_medkit.mdl";
		autoReplace["models/hlclassic/v_rpg.mdl"] = "models/v_rpg.mdl";
		autoReplace["models/hlclassic/v_satchel.mdl"] = "models/v_satchel.mdl";
		autoReplace["models/hlclassic/v_satchel_radio.mdl"] = "models/v_satchel_radio.mdl";
		autoReplace["models/hlclassic/v_shotgun.mdl"] = "models/v_shotgun.mdl";
		autoReplace["models/hlclassic/v_squeak.mdl"] = "models/v_squeak.mdl";
		autoReplace["models/hlclassic/v_tripmine.mdl"] = "models/v_tripmine.mdl";
		autoReplace["models/hlclassic/w_357.mdl"] = "models/w_357.mdl";
		autoReplace["models/hlclassic/w_357ammo.mdl"] = "models/w_357ammo.mdl";
		autoReplace["models/hlclassic/w_357ammobox.mdl"] = "models/w_357ammobox.mdl";
		autoReplace["models/hlclassic/w_9mmar.mdl"] = "models/w_9mmar.mdl";
		autoReplace["models/hlclassic/w_9mmarclip.mdl"] = "models/w_9mmarclip.mdl";
		autoReplace["models/hlclassic/w_9mmclip.mdl"] = "models/w_9mmclip.mdl";
		autoReplace["models/hlclassic/w_9mmhandgun.mdl"] = "models/w_9mmhandgun.mdl";
		autoReplace["models/hlclassic/w_argrenade.mdl"] = "models/w_argrenade.mdl";
		autoReplace["models/hlclassic/w_battery.mdl"] = "models/w_battery.mdl";
		autoReplace["models/hlclassic/w_chainammo.mdl"] = "models/w_chainammo.mdl";
		autoReplace["models/hlclassic/w_crossbow.mdl"] = "models/w_crossbow.mdl";
		autoReplace["models/hlclassic/w_crossbow_clip.mdl"] = "models/w_crossbow_clip.mdl";
		autoReplace["models/hlclassic/w_crowbar.mdl"] = "models/w_crowbar.mdl";
		autoReplace["models/hlclassic/w_egon.mdl"] = "models/w_egon.mdl";
		autoReplace["models/hlclassic/w_gauss.mdl"] = "models/w_gauss.mdl";
		autoReplace["models/hlclassic/w_gaussammo.mdl"] = "models/w_gaussammo.mdl";
		autoReplace["models/hlclassic/w_grenade.mdl"] = "models/w_grenade.mdl";
		autoReplace["models/hlclassic/w_hgun.mdl"] = "models/w_hgun.mdl";
		autoReplace["models/hlclassic/w_longjump.mdl"] = "models/w_longjump.mdl";
		autoReplace["models/hlclassic/w_medkit.mdl"] = "models/w_medkit.mdl";
		autoReplace["models/hlclassic/w_pmedkit.mdl"] = "models/w_pmedkit.mdl";
		autoReplace["models/hlclassic/w_rpg.mdl"] = "models/w_rpg.mdl";
		autoReplace["models/hlclassic/w_rpgammo.mdl"] = "models/w_rpgammo.mdl";
		autoReplace["models/hlclassic/w_satchel.mdl"] = "models/w_satchel.mdl";
		autoReplace["models/hlclassic/w_shotbox.mdl"] = "models/w_shotbox.mdl";
		autoReplace["models/hlclassic/w_shotgun.mdl"] = "models/w_shotgun.mdl";
		autoReplace["models/hlclassic/w_shotshell.mdl"] = "models/w_shotshell.mdl";
		autoReplace["models/hlclassic/w_sqknest.mdl"] = "models/w_sqknest.mdl";
		autoReplace["models/hlclassic/w_squeak.mdl"] = "models/w_squeak.mdl";
		autoReplace["models/hlclassic/w_suit.mdl"] = "models/w_suit.mdl";
		autoReplace["models/hlclassic/w_tripmine.mdl"] = "models/w_tripmine.mdl";
		autoReplace["models/hlclassic/w_weaponbox.mdl"] = "models/w_weaponbox.mdl";
		autoReplace["models/hlclassic/zombie.mdl"] = "models/zombie.mdl";
		
		autoReplaceMonsters["monster_agrunt"] = true;
		autoReplaceMonsters["monster_apache"] = true;
		autoReplaceMonsters["monster_barnacle"] = true;
		autoReplaceMonsters["monster_barney"] = true;
		autoReplaceMonsters["monster_bullsquid"] = true;
		autoReplaceMonsters["monster_gargantua"] = true;
		autoReplaceMonsters["monster_gman"] = true;
		autoReplaceMonsters["monster_human_assassin"] = true;
		autoReplaceMonsters["monster_headcrab"] = true;
		autoReplaceMonsters["monster_human_grunt"] = true;
		autoReplaceMonsters["monster_human_grunt"] = true;
		autoReplaceMonsters["monster_houndeye"] = true;
		autoReplaceMonsters["monster_ichthyosaur"] = true;
		autoReplaceMonsters["monster_alien_slave"] = true;
		autoReplaceMonsters["monster_osprey"] = true;
		autoReplaceMonsters["monster_cockroach"] = true;
		autoReplaceMonsters["monster_scientist"] = true;
		autoReplaceMonsters["monster_sitting_scientist"] = true;
		autoReplaceMonsters["monster_tentacle"] = true;
		autoReplaceMonsters["monster_zombie"] = true;
		
		array<string> modelKeys = modelReplacements.getKeys();
		for (uint i = 0; i < modelKeys.size(); i++)
		{
			if (int(modelKeys[i].Find("hlclassic/")) == -1)
				g_Game.PrecacheModel(GetReplacementModel(modelKeys[i]));
		}
			
		modelKeys = autoReplace.getKeys();
		for (uint i = 0; i < modelKeys.size(); i++)
		{
			string model;
			autoReplace.get(modelKeys[i], model);
			g_Game.PrecacheModel(model);
		}
		
		g_Game.PrecacheModel(replacementSpritePath + "640hud1.spr");
		g_Game.PrecacheModel(replacementSpritePath + "640hud4.spr");
		g_Game.PrecacheGeneric(replacementSpritePath + "weapon_9mmar.txt");
		
		// precache weapon sound replacements for monsters
		PrecacheSound(replacementSoundPath + "sniper_fire.wav");
		PrecacheSound(replacementSoundPath + "uzi_fire_both1.wav");
		PrecacheSound(replacementSoundPath + "uzi_fire_both2.wav");
	}
	
	void loadBlacklist()
	{
		string fpath = "scripts/maps/AutoClassicMode/gmr/" + string(g_Engine.mapname).ToLowercase() + ".txt";
		File@ f = g_FileSystem.OpenFile( fpath, OpenFile::READ );
		if( f is null or !f.IsOpen())
		{
			println("AutoClassicMode: Model blacklist not found: " + fpath);
			return;
		}

		int linesRead = 0;
		string line;
		while( !f.EOFReached() )
		{
			f.ReadLine(line);
			string model = "models/" + line + ".mdl";		
			blacklist[model] = true;
		}
		
		mapUsesGMR = true;
		println("AutoClassicMode: Loaded model replacement blacklist");
	}
	
	void PrecacheSound(string snd)
	{
		g_SoundSystem.PrecacheSound(snd);
		g_Game.PrecacheGeneric("sound/" + snd);
	}
	
	string GetReplacementModel(string model)
	{
		return model.Replace("hlclassic/","").Replace("models/", replacementModelPath);
	}
	
	string GetWeaponVModel(CBasePlayerWeapon@ wep)
	{
		string defaultModel;
		defaultWeaponModels.get(wep.pev.classname, defaultModel);
		if (defaultModel.Length() > 0)
			defaultModel = "models/v_" + defaultModel + ".mdl";
		return wep.GetV_Model(defaultModel);
	}
	
	string GetWeaponPModel(CBasePlayerWeapon@ wep)
	{
		string defaultModel;
		defaultWeaponModels.get(wep.pev.classname, defaultModel);
		if (defaultModel == "minigun")
			defaultModel = "minigunidle";
		if (defaultModel.Length() > 0)
			defaultModel = "models/p_" + defaultModel + ".mdl";
		// TODO: golden uzi logic
		return wep.GetP_Model(defaultModel);
	}
	
	string GetWeaponWModel(CBasePlayerWeapon@ wep)
	{
		string defaultModel;
		defaultWeaponModels.get(wep.pev.classname, defaultModel);
		if (defaultModel.Length() > 0)
			defaultModel = "models/w_" + defaultModel + ".mdl";
		return wep.GetW_Model(defaultModel);
	}

	void MapInit(CBaseEntity@ caller, CBaseEntity@ activator, USE_TYPE useType, float value)
	{
		isClassicMap = caller.pev.rendermode == 1;
		
		if (isClassicMap)
		{
			g_ClassicMode.EnableMapSupport();
			g_ClassicMode.SetShouldRestartOnChange(false);	
		
			array<ItemMapping@> itemMappings = { 
				ItemMapping( "weapon_m16", "weapon_9mmAR" ),
				ItemMapping( "ammo_556", "ammo_9mmbox" )
			};
			g_ClassicMode.SetItemMappings( @itemMappings );
			
			initModelReplacements();
			loadBlacklist();
		}
		
		if (isClassicMap != g_ClassicMode.IsEnabled())
		{
			println("\nOH NO IT WASNT " + isClassicMap + " GUESS GOTTA RESTART\n");
			g_ClassicMode.SetEnabled(isClassicMap);
			g_EngineFuncs.ChangeLevel(g_Engine.mapname);
			return;
		}
	}
	
	void MapActivate(CBaseEntity@ caller, CBaseEntity@ activator, USE_TYPE useType, float value)
	{
		if (!isClassicMap)
			return;
		AddMonsterMakerHooks();
		
		if (mapUsesGMR)
			AddBreakableHooks();
		
		UpdateMonsterModels();
		UpdateModels("weapon_*");
		UpdateModels("ammo_*");
		UpdateModels("item_*");
		
		lastAmmo.resize(33);
		lastWeapons.resize(33);
		MonitorPlayerAmmoDropsAndWeaponPickups();
	}
	
	bool RespawnFixedWeapon(EHandle h_wep)
	{
		CBasePlayerWeapon@ wep = cast<CBasePlayerWeapon@>(h_wep.GetEntity());
		if (wep is null)
			return false;
			
		//println("Checking " + wep.pev.classname);
		
		string cname = wep.pev.classname;
		
		bool builtInClassicModeIsReplacingThis = classicItems.exists(wep.pev.classname);
		
		if (builtInClassicModeIsReplacingThis and !mapUsesGMR)
			return false; // classic mode will do the swapping for us. Model keyvalues on entities won't be overridden
		
		string vmodel = GetWeaponVModel(wep);
		string pmodel = GetWeaponPModel(wep);
		string wmodel = GetWeaponWModel(wep);
		
		//println("Current models for " + wep.pev.classname + " are " + vmodel + " " + pmodel + " " +  wmodel);
		
		// the GetWeaponModel funcs account for GMR, but not for classic mode.
		// If it has a custom model I need to re-apply it or else classic mode will override the custom model.
		// This isn't needed if the custom model was set on the entity, but there's no way to know if it was
		// from that or from GMR, so I need to always re-apply custom models if the map uses GMR.
		string defaultModelName;
		defaultWeaponModels.get(wep.pev.classname, defaultModelName);
		string defaultVModel = "models/v_" + defaultModelName + ".mdl";
		string defaultPModel = "models/p_" + defaultModelName + ".mdl";
		string defaultWModel = "models/w_" + defaultModelName + ".mdl";
		
		bool shouldSwap = false;
		if (builtInClassicModeIsReplacingThis and defaultVModel != vmodel)
		{
			shouldSwap = true;
		}
		else if (modelReplacements.exists(vmodel))
		{
			vmodel = GetReplacementModel(vmodel);
			shouldSwap = true;
		}
		else if (builtInClassicModeIsReplacingThis and mapUsesGMR)
			vmodel = ""; // let classic mode replace it then
			
			
		if (builtInClassicModeIsReplacingThis and defaultPModel != pmodel)
		{
			shouldSwap = true;
		}
		else if (modelReplacements.exists(pmodel))
		{
			pmodel = GetReplacementModel(pmodel);
			shouldSwap = true;
		}
		else if (builtInClassicModeIsReplacingThis and mapUsesGMR)
			pmodel = ""; // let classic mode replace it then
		
		if (builtInClassicModeIsReplacingThis and defaultWModel != wmodel)
		{
			shouldSwap = true;
		}		
		else if (modelReplacements.exists(wmodel))
		{
			wmodel = GetReplacementModel(wmodel);
			shouldSwap = true;
		}
		else if (builtInClassicModeIsReplacingThis and mapUsesGMR)
			wmodel = ""; // let classic mode replace it then
		
		if (!shouldSwap)
			return false; // all models are custom or have no replacements
		
		println("Replacement models are " + vmodel + " " + pmodel + " " +  wmodel);
		
		if (vmodel.Length() > 0)
			wep.KeyValue("wpn_v_model", vmodel);
		if (pmodel.Length() > 0)
			wep.KeyValue("wpn_p_model", pmodel);
		if (wmodel.Length() > 0)
			wep.KeyValue("wpn_w_model", wmodel);
		
		// can't update world model for some reason
		/*
		wep.KeyValue("model", wmodel);
		wep.KeyValue("weaponmodel", wmodel);
		wep.SetupModel();
		g_EntityFuncs.SetModel(wep, wmodel);
		*/
		return true;
	}
	
	void PlayerSpawn(CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE useType, float value)
	{
		if (!isClassicMap)
			return;

		CBasePlayer@ plr = cast<CBasePlayer@>(caller);
		if (plr is null)
			return;
			
		for ( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			CBasePlayer@ p = g_PlayerFuncs.FindPlayerByIndex(i);
			if (p is null or !p.IsConnected())
				continue;
			if (plr.entindex() == p.entindex())
			{
				lastWeapons[i] = 0;
				break;
			}
		}
	}
	
	void ReplacePlayerWeapons(CBasePlayer@ plr)
	{
		CBasePlayerWeapon@ activeWep = cast<CBasePlayerWeapon@>(plr.m_hActiveItem.GetEntity());;
		for (uint i = 0; i < MAX_ITEM_TYPES; i++)
		{
			CBasePlayerItem@ item = plr.m_rgpPlayerItems(i);
			while (item !is null)
			{
				CBasePlayerWeapon@ wep = cast<CBasePlayerWeapon@>(item);
				if (wep !is null)	
				{
					bool wasReplaced = RespawnFixedWeapon(EHandle(wep));
					if (wep.pev.classname == "weapon_9mmAR")
					{
						//wep.KeyValue("CustomSpriteDir", "AutoClassicMode");
						wep.LoadSprites(plr, "AutoClassicMode/weapon_9mmar");
					}
					if (wasReplaced and activeWep.entindex() == wep.entindex())
					{
						string vmodel = GetWeaponVModel(wep);
						string pmodel = GetWeaponPModel(wep);
						if (vmodel.Length() > 0)
							plr.pev.viewmodel = vmodel;
						if (pmodel.Length() > 0)
							plr.pev.weaponmodel = pmodel;
					}
				}
				
				@item = cast<CBasePlayerItem@>(item.m_hNextItem.GetEntity());	
			}
		}
	}
	
	void PlayerDie(CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE useType, float value)
	{
		CBasePlayer@ plr = cast<CBasePlayer@>(caller);
		if (plr is null)
			return;
		CBasePlayerWeapon@ wep = cast<CBasePlayerWeapon@>(plr.m_hActiveItem.GetEntity());
		if (wep !is null)
			g_Scheduler.SetTimeout("UpdateModels", 0.0f, string(wep.pev.classname));
	}
	
	void MonitorPlayerAmmoDropsAndWeaponPickups()
	{
		for ( int i = 1; i <= g_Engine.maxClients; i++ )
		{
			CBasePlayer@ plr = g_PlayerFuncs.FindPlayerByIndex(i);
			if (plr is null or !plr.IsConnected())
				continue;
				
			CBasePlayerWeapon@ activeWep = cast<CBasePlayerWeapon@>(plr.m_hActiveItem.GetEntity());
			if (activeWep is null)
			{
				lastWeapons[i] = 0;
				continue;
			}
			
			int ammoIdx = activeWep.PrimaryAmmoIndex();
			if (ammoIdx != -1)
			{
				int ammoLeft = plr.m_rgAmmo(ammoIdx);
				if (ammoLeft != lastAmmo[i])
				{
					lastAmmo[i] = ammoLeft;
					string cname = activeWep.pev.classname;
					
					if (!mapUsesGMR)
					{
						if (cname == "weapon_uzi")
							g_Scheduler.SetTimeout("UpdateModels", 0.0f, "ammo_uziclip");
						else if (cname == "weapon_m249")
							g_Scheduler.SetTimeout("UpdateModels", 0.0f, "ammo_556");
						else if (cname == "weapon_sniperrifle")
							g_Scheduler.SetTimeout("UpdateModels", 0.0f, "ammo_762");
					}
					else
					{
						if (cname == "weapon_satchel" or cname == "weapon_handgrenade" or 
							cname == "weapon_tripmine" or cname == "weapon_snark")
						{
							g_Scheduler.SetTimeout("UpdateModels", 0.0f, cname);
						}
						else
							g_Scheduler.SetTimeout("UpdateModels", 0.0f, "ammo_*");
					}
				}
			}
			
			uint64 weapons = 0;
			int idx = 0;
			for (uint64 k = 0; k < MAX_ITEM_TYPES; k++)
			{
				CBasePlayerItem@ item = plr.m_rgpPlayerItems(k);
				while (item !is null)
				{
					weapons |= (1 << idx++);
					CBasePlayerWeapon@ wep = cast<CBasePlayerWeapon@>(item);
					if (activeWep.entindex() == wep.entindex())
					{
						if (wep.m_fIsAkimbo != (wep.pev.colormap != 0))
						{
							// update uzi third-person model when toggling between dual-weild
							wep.pev.colormap = wep.m_fIsAkimbo ? 1 : 0;
							if (int(string(plr.pev.weaponmodel).Find("AutoClassicMode")) != -1)
							{
								if (wep.m_fIsAkimbo)
									plr.pev.weaponmodel = "models/AutoClassicMode/p_2uzis.mdl";
								else
									plr.pev.weaponmodel = "models/AutoClassicMode/p_uzi.mdl";
							}
							// dropped uzi needs replacement when dual wielding
							if (!wep.m_fIsAkimbo)
								g_Scheduler.SetTimeout("UpdateModels", 0.0f, "weapon_uzi");
						}
						if (wep.pev.classname == "weapon_minigun")
						{
							if (wep.pev.pain_finished == 0)
								wep.pev.pain_finished = g_Engine.time; // remember that we just picked this up
							if (g_Engine.time - wep.pev.pain_finished > 2.0f) // deployment finished?
							{
								// primaryattack != -1 during deployment and player can spinup before it reaches -1
								if (wep.m_flNextPrimaryAttack != -1 or plr.pev.button & (IN_ATTACK|IN_ATTACK2) != 0)
									plr.pev.weaponmodel = "models/AutoClassicMode/p_minigunspin.mdl";
								else
									plr.pev.weaponmodel = "models/AutoClassicMode/p_minigunidle.mdl";
							}
							
						}
					}
					else
						wep.pev.colormap = 0;
					@item = cast<CBasePlayerItem@>(item.m_hNextItem.GetEntity());	
				}
			}
			if (weapons > lastWeapons[i])
				ReplacePlayerWeapons(plr);
			else if (weapons < lastWeapons[i])
			{
				UpdateModels("weapon_*");
				UpdateModels("monster_shockroach");
			}
			lastWeapons[i] = weapons;
		}
		
		g_Scheduler.SetTimeout("MonitorPlayerAmmoDropsAndWeaponPickups", 0.05f);
	}
	
	void BreakableBroken(CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE useType, float value)
	{
		// Impossible to know which item spawned :/
		UpdateModels("weapon_*");
		UpdateModels("ammo_*");
		UpdateModels("item_*");
	}
	
	void MonsterSpawned(CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE useType, float value)
	{
		println("Le monster spawned " + caller.pev.classname + " " + activator.pev.classname);
		UpdateMonsterModels();
		AddMonsterDeathHooks();
		
		// also possible that an item was spawned
		UpdateModels("weapon_*");
		UpdateModels("ammo_*");
		UpdateModels("item_*");
	}
	
	void MonsterKilled(CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE useType, float value)
	{
		println("Le monster killed " + caller.pev.classname + " " + activator.pev.classname);
		g_Scheduler.SetTimeout("UpdateMonsterModels", 0.4f);
		g_Scheduler.SetTimeout("UpdateModels", 0.2f, "weapon_sniperrifle");
	}
	
	void MonitorHWGrunt(EHandle h_grunt)
	{
		CBaseMonster@ grunt = cast<CBaseMonster@>(h_grunt.GetEntity());
		if (grunt is null or !grunt.IsAlive())
		{
			g_Scheduler.SetTimeout("UpdateModels", 0.15f, "weapon_minigun");
			if (grunt is null)
				return;
		}
		
		// did he drop the minigun? (weapons model group changed)
		if (grunt.GetBodygroup(1) != grunt.pev.bInDuck) 
		{
			grunt.pev.bInDuck = grunt.GetBodygroup(1); // use bInDuck as a "lastWeaponState" variable
			if (grunt.pev.bInDuck != 0)
				g_Scheduler.SetTimeout("UpdateModels", 0.15f, "weapon_minigun");					
		}
		
		g_Scheduler.SetTimeout("MonitorHWGrunt", 0.1f, h_grunt);
	}
	
	void MonitorTor(EHandle h_tor)
	{
		CBaseMonster@ tor = cast<CBaseMonster@>(h_tor.GetEntity());
		if (tor is null)
			return;
		
		// is it spawning an agrunt?
		if (tor.pev.sequence == 13)
		{
			if (tor.pev.bInDuck == 0)
			{
				tor.pev.bInDuck = 1;
				g_Scheduler.SetTimeout("UpdateMonsterModels", 2.5f);
			}
		}
		else
			tor.pev.bInDuck = 0;
		
		
		g_Scheduler.SetTimeout("MonitorTor", 0.1f, h_tor);
	}
	
	void UpdateModels(string cname)
	{
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, cname);
			if (ent !is null)
			{
				if (mapUsesGMR and classicItems.exists(ent.pev.classname))
				{
					string originalModel;
					autoReplace.get(ent.pev.model, originalModel);
					
					if (blacklist.exists(originalModel))
					{
						println("Undoing model replacement for " + originalModel);
						int idx = g_Game.PrecacheModel(originalModel);
						g_EntityFuncs.SetModel(ent, originalModel);
					}
				}
				
				if (modelReplacements.exists(ent.pev.model))
				{
					string replacement = GetReplacementModel(ent.pev.model);					
					println("AutoClassicMode(u): Replacing " + ent.pev.model + " -> " + replacement);
					g_EntityFuncs.SetModel(ent, replacement);
					ent.pev.pain_finished = 0; // special minigun keyvalue for this script
				}
			}
		} while (ent !is null);
	}
		
	bool ShouldUpdateSoundlist(CBaseMonster@ mon)
	{
		// TODO: Check ALL possible sounds, not just the ones I want to replace
		for (uint i = 0; i < replacedSounds.size(); i++)
			if (mon.SOUNDREPLACEMENT_Find(replacedSounds[i]) != replacedSounds[i])
				return false;
		
		return true;
	}
		
	void UpdateMonsterModels()
	{
		bool checkAgainSoon = false;
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, "monster_*");
			CBaseMonster@ mon = cast<CBaseMonster@>(ent);
			if (mon !is null)
			{
				//println("Test " + mon.pev.model + " - " + mon.pev.classname);
				string cname = ent.pev.classname;
				string model = mon.pev.model;
				
				if (mapUsesGMR and autoReplaceMonsters.exists(cname))
				{
					string originalModel;
					autoReplace.get(model, originalModel);
					
					if (blacklist.exists(originalModel))
					{
						println("Undoing model replacement for " + originalModel);
						int idx = g_Game.PrecacheModel(originalModel);

						int oldBody = mon.pev.body;
						Vector mins = mon.pev.mins;
						Vector maxs = mon.pev.maxs;
						g_EntityFuncs.SetModel(mon, originalModel);
						g_EntityFuncs.SetSize(mon.pev, mins, maxs);
						mon.pev.body = oldBody;
					}
				}
				
				if (modelReplacements.exists(model) and not blacklist.exists(model))
				{
					//println("Le model replace " + cname);
					
					bool isGrunt = int(cname.Find("grunt")) != -1 and cname != "monster_alien_grunt";
					bool isBarney = int(cname.Find("barney")) != -1;
					// sound replacement
					if (isGrunt or cname == "monster_male_assassin" or cname == "monster_assassin_repel" 
						or cname == "monster_bodyguard" or isBarney)
					{
						if (ShouldUpdateSoundlist(mon))
						{
							//println("Add soundlist to " + ent.pev.classname);
							string soundlist = "../AutoClassicMode/weapons.txt";
							if (isBarney)
								soundlist = "../AutoClassicMode/barney.txt";
							ent.KeyValue("soundlist", soundlist);
							mon.Precache(); // updates soundlist for some reason
						}
						else
							println("Not updating monster soundlist because it already has one");
					}
					
					bool isDead = int(cname.Find("_dead")) != -1;
					
					string replacement;
					if (classicFriendlies.exists(cname))
					{
						if ((isBarney and ent.IRelationshipByClass(CLASS_PLAYER) > R_NO) or
							(!isBarney and ent.IRelationshipByClass(CLASS_PLAYER) < R_NO))
							classicFriendlies.get(ent.pev.classname, replacement);
						else if (isGrunt and !isDead)
							replacement = GetReplacementModel(model); // still want to replace the default model since its missing anims
						else
							continue; // classic mode already replaced the model
					}
					else
						replacement = GetReplacementModel(model);
					
					// update body groups
					int newBody = 0;
					int mdlIndex = g_ModelFuncs.ModelIndex(replacement);
					for (int i = 0; i < 8; i++)
						newBody |= g_ModelFuncs.SetBodygroup(mdlIndex, newBody, i, mon.GetBodygroup(i));
					
					if (ent.pev.classname == "monster_human_grunt") // grunt uses diff bodys for things, but somehow works without scripts
					{
						if (ent.pev.weapons & 1 != 0)
							newBody |= g_ModelFuncs.SetBodygroup( mdlIndex, newBody, 2, 4); // mp5
						if (ent.pev.weapons & 64 != 0)
							newBody |= g_ModelFuncs.SetBodygroup( mdlIndex, newBody, 2, 3); // rpg
						if (ent.pev.weapons & 128 != 0)
							newBody |= g_ModelFuncs.SetBodygroup( mdlIndex, newBody, 2, 5); // sniper
					}
					mon.pev.body = newBody;
						
					println("AutoClassicMode(m): Replacing " + model + " -> " + replacement);
					
					int oldSequence = mon.pev.sequence;
					Vector mins = mon.pev.mins;
					Vector maxs = mon.pev.maxs;
					g_EntityFuncs.SetModel(mon, replacement);
					g_EntityFuncs.SetSize(mon.pev, mins, maxs);
					mon.pev.sequence = oldSequence;
					
					if (cname == "monster_hevsuit_dead") {
						mon.pev.sequence -= 104;
						mon.pev.body = 1;
					}
				}
				else if (!checkAgainSoon and string(model).Length() == 0)
				{
					// monsters that repel spawn slightly later
					if (int(string(mon.pev.classname).Find("repel")) != -1)
						checkAgainSoon = true;
				}
			}
		} while (ent !is null);
		
		if (checkAgainSoon)
			g_Scheduler.SetTimeout("UpdateMonsterModels", 0.2f);
	}
	
	// monstermaker/squadmaker keyvalues can't be changed from scripts, so we'll have to update the monster mode manually
	void AddMonsterMakerHooks()
	{
		// stores the target of monstermakers that already have a target
		dictionary hookNames; 
		
		bool anyMakers = false;
		int totalEnts = 0;
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, "*"); 
			if (ent !is null)
			{
				string cname = ent.pev.classname;
				if (cname == "squadmaker" or cname == "monstermaker")
				{
					//println("GOT : " + ent.pev.classname + " " + ent.pev.targetname);
					string target = string(ent.pev.target).ToLowercase();
					if (ent.pev.target == spawnHookName)
						continue;
					if (target.Length() > 0)
						hookNames[target] = true;
					else
						ent.pev.target = spawnHookName;
					anyMakers = true;
				}
			}
			totalEnts++;
		} while (ent !is null);
		
		array<string> hookKeys = hookNames.getKeys();
		if (hookKeys.size() + totalEnts > 8000) // actual max is 8192
		{
			println("AutoClassicMode: Failed to create monstermaker hooks. Too many entities required: " + hookKeys.size());
			return;
		}
		
		if (anyMakers)
		{
			dictionary keys;
			keys["targetname"] = spawnHookName;
			keys["m_iszScriptFile"] = "AutoClassicMode";
			keys["m_iszScriptFunctionName"] = "AutoClassicMode::MonsterSpawned";
			keys["m_iMode"] = "1";
			g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		}
		
		// death
		{
			dictionary keys;
			keys["targetname"] = deathHookName;
			keys["m_iszScriptFile"] = "AutoClassicMode";
			keys["m_iszScriptFunctionName"] = "AutoClassicMode::MonsterKilled";
			keys["m_iMode"] = "1";
			g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		}
		
		// monster damage
		{
			dictionary keys;
			keys["targetname"] = damageHookName;
			keys["m_iszScriptFile"] = "AutoClassicMode";
			keys["m_iszScriptFunctionName"] = "AutoClassicMode::MonsterDamaged";
			keys["m_iMode"] = "1";
			g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		}
		
		for (uint i = 0; i < hookKeys.size(); i++)
		{
			dictionary keys;
			keys["targetname"] = hookKeys[i];
			keys["target"] = spawnHookName;
			keys["spawnflags"] = "64"; // keep !activator
			keys["triggerstate"] = "2";
			g_EntityFuncs.CreateEntity("trigger_relay", keys, true);
		}
		
		println("AutoClassicMode: created " + hookKeys.size() + " monster spawn hooks");
	}
	
	void AddMonsterDeathHooks()
	{		
		dictionary hookNames; 
		
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, "monster_*"); 
			CBaseMonster@ mon = cast<CBaseMonster@>(ent);
			if (mon !is null)
			{
				string cname = ent.pev.classname;
				if (int(cname.Find("monster_hwgrunt")) != -1)
				{
					MonitorHWGrunt(EHandle(ent));
					continue;
				}
				if (cname == "monster_alien_tor")
				{
					MonitorTor(EHandle(ent));
					continue;
				}
				
				// sniper, sniper + HG
				bool dropsWeps = cname == "monster_shocktrooper" or (cname == "monster_male_assassin" and (ent.pev.weapons == 8 or ent.pev.weapons == 10));
				if (!dropsWeps)
					continue;
				
				string target = string(mon.m_iszTriggerTarget).ToLowercase();
				if (mon.m_iszTriggerTarget == deathHookName)
					continue;
				if (target.Length() > 0)
				{
					if (mon.m_iTriggerCondition == 4)
						hookNames[target] = true;
					else
						println("Failed to add death hook for " + ent.pev.classname + " (" + target + " " + mon.m_iTriggerCondition + ")");
				}
				else
				{
					ent.pev.target = spawnHookName;
					mon.m_iszTriggerTarget = deathHookName;
					mon.m_iTriggerCondition = 4;
				}
			}
		} while (ent !is null);
		
		array<string> hookKeys = hookNames.getKeys();
		
		for (uint i = 0; i < hookKeys.size(); i++)
		{
			dictionary keys;
			keys["targetname"] = hookKeys[i];
			keys["target"] = spawnHookName;
			keys["spawnflags"] = "65"; // keep !activator and remove on fire
			keys["triggerstate"] = "2";
			CBaseEntity@ classicTrigger = g_EntityFuncs.CreateEntity("trigger_relay", keys, true);
		}
		
		println("AutoClassicMode: created " + hookKeys.size() + " monster spawn hooks");
	}

	// hooks for breakables that spawn items
	void AddBreakableHooks()
	{
		dictionary hookNames; 
		
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, "func_breakable");
			if (ent !is null)
			{
				string target = string(ent.pev.target).ToLowercase();
				if (target == breakableHookName)
					continue;
				if (target.Length() > 0)
					hookNames[target] = true;
				else
					ent.pev.target = breakableHookName;
			}
		} while (ent !is null);
		
		array<string> hookKeys = hookNames.getKeys();
		
		{
			dictionary keys;
			keys["targetname"] = breakableHookName;
			keys["m_iszScriptFile"] = "AutoClassicMode";
			keys["m_iszScriptFunctionName"] = "AutoClassicMode::BreakableBroken";
			keys["m_iMode"] = "1";
			g_EntityFuncs.CreateEntity("trigger_script", keys, true);
		}
		
		for (uint i = 0; i < hookKeys.size(); i++)
		{
			dictionary keys;
			keys["targetname"] = hookKeys[i];
			keys["target"] = breakableHookName;
			keys["spawnflags"] = "65"; // keep !activator and remove on fire
			keys["triggerstate"] = "2";
			CBaseEntity@ classicTrigger = g_EntityFuncs.CreateEntity("trigger_relay", keys, true);
		}
		
		println("AutoClassicMode: created " + hookKeys.size() + " func_breakable hooks");
	}
}