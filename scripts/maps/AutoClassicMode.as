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

namespace AutoClassicMode {

	void print(string text) { g_Game.AlertMessage( at_console, text); }
	void println(string text) { print(text + "\n"); }
	
	bool isClassicMap = false;
	
	dictionary defaultWeaponModels;
	dictionary modelReplacements;
	dictionary classicFriendlies; // monsters that have friendly models but are also partially replaced by classic mode
	
	string replacementModelPath = "models/AutoClassicMode/";
	string replacementSpritePath = "sprites/AutoClassicMode/";
	string replacementSoundPath = "AutoClassicMode/";
	
	string spawnHookName = "AutoClassicMode_MonsterSpawn";
	string deathHookName = "AutoClassicMode_MonsterKilled";
	string damageHookName = "AutoClassicMode_MonsterDamaged"; // for monsters that drop weapons when damaged (hwgrunt)
	
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
		
		classicFriendlies["monster_barney"] = replacementModelPath + "barnabus.mdl";
		classicFriendlies["monster_human_grunt"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_grunt_repel"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_human_assassin"] = replacementModelPath + "hassassinf.mdl";
		classicFriendlies["monster_alien_slave"] = replacementModelPath + "islavef.mdl";
		classicFriendlies["monster_alien_grunt"] = replacementModelPath + "agruntf.mdl";
		
		array<string> modelKeys = modelReplacements.getKeys();
		for (uint i = 0; i < modelKeys.size(); i++)
			g_Game.PrecacheModel(GetReplacementModel(modelKeys[i]));
			
		g_Game.PrecacheModel(replacementSpritePath + "640hud1.spr");
		g_Game.PrecacheModel(replacementSpritePath + "640hud4.spr");
		g_Game.PrecacheGeneric(replacementSpritePath + "weapon_9mmar.txt");
		
		// precache weapon sound replacements for monsters
		PrecacheSound(replacementSoundPath + "m16_3round.wav");
		PrecacheSound(replacementSoundPath + "sniper_fire.wav");
		PrecacheSound(replacementSoundPath + "uzi/fire_both1.wav");
		PrecacheSound(replacementSoundPath + "uzi/fire_both2.wav");
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
		UpdateMonsterModels();
		
		lastAmmo.resize(33);
		lastWeapons.resize(33);
		MonitorPlayerAmmoDropsAndWeaponPickups();
	}
	
	bool RespawnFixedWeapon(EHandle h_wep)
	{
		CBasePlayerWeapon@ wep = cast<CBasePlayerWeapon@>(h_wep.GetEntity());
		if (wep is null)
			return false;
		
		string cname = wep.pev.classname;
		
		if (!defaultWeaponModels.exists(wep.pev.classname))
			return false; // not a swap target
		
		string vmodel = GetWeaponVModel(wep);
		string pmodel = GetWeaponPModel(wep);
		string wmodel = GetWeaponWModel(wep);
		
		//println("Current models for " + wep.pev.classname + " are " + vmodel + " " + pmodel + " " +  wmodel);
		
		bool shouldSwap = false;
		if (modelReplacements.exists(vmodel))
		{
			vmodel = GetReplacementModel(vmodel);
			shouldSwap = true;
		}
		else
			vmodel = "";
			
		if (modelReplacements.exists(pmodel))
		{
			pmodel = GetReplacementModel(pmodel);
			shouldSwap = true;
		}
		else
			pmodel = "";
			
		if (modelReplacements.exists(wmodel))
		{
			wmodel = GetReplacementModel(wmodel);
			shouldSwap = true;
		}
		else
			wmodel = "";
		
		if (!shouldSwap)
			return false; // all models are custom or have no replacements
		
		//println("Replacement models are " + vmodel + " " + pmodel + " " +  wmodel + " " + isOldMp5);
		
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
					RespawnFixedWeapon(EHandle(wep));
					if (wep.pev.classname == "weapon_9mmAR")
					{
						//wep.KeyValue("CustomSpriteDir", "AutoClassicMode");
						wep.LoadSprites(plr, "AutoClassicMode/weapon_9mmar");
					}
					if (activeWep.entindex() == wep.entindex())
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
					if (cname == "weapon_uzi")
						g_Scheduler.SetTimeout("UpdateModels", 0.0f, "ammo_uziclip");
					else if (cname == "weapon_m249")
						g_Scheduler.SetTimeout("UpdateModels", 0.0f, "ammo_556");
					else if (cname == "weapon_sniperrifle")
						g_Scheduler.SetTimeout("UpdateModels", 0.0f, "ammo_762");
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
				UpdateModels("weapon_*");
			lastWeapons[i] = weapons;
		}
		
		g_Scheduler.SetTimeout("MonitorPlayerAmmoDropsAndWeaponPickups", 0.05f);
	}
	
	void MonsterSpawned(CBaseEntity@ activator, CBaseEntity@ caller, USE_TYPE useType, float value)
	{
		println("Le monster spawned " + caller.pev.classname + " " + activator.pev.classname);
		UpdateMonsterModels();
		AddMonsterDeathHooks();
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
		if (tor is null or !tor.IsAlive())
			return;
		
		// is it spawning an agrunt
		
		if (tor.pev.sequence == 13)
		{
			if (tor.pev.bInDuck == 0)
			{
				tor.pev.bInDuck = 1;
				g_Scheduler.SetTimeout("UpdateMonsterModels", 2.5f);	
				println("TOR SPAWNING " + tor.pev.sequence + " " + tor.pev.frame);
				return;
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
				if (modelReplacements.exists(ent.pev.model))
				{
					string replacement = GetReplacementModel(ent.pev.model);					
					println("AutoClassicMode: Replacing " + ent.pev.model + " -> " + replacement);
					g_EntityFuncs.SetModel(ent, replacement);
					ent.pev.pain_finished = 0; // special minigun keyvalue that for this script
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
				println("Test " + mon.pev.model + " - " + mon.pev.classname);
				
				if (modelReplacements.exists(mon.pev.model))
				{
					string cname = ent.pev.classname;
					println("Le model replace " + cname);
					
					// sound replacement
					if (int(cname.Find("grunt")) != -1 or cname == "monster_male_assassin" or cname == "monster_assassin_repel" 
						or cname == "monster_bodyguard" or cname == "monster_barney")
					{
						if (ShouldUpdateSoundlist(mon))
						{
							println("Add soundlist to " + ent.pev.classname);
							string soundlist = "../AutoClassicMode/weapons.txt";
							if (cname == "monster_barney")
								soundlist = "../AutoClassicMode/barney.txt";
							ent.KeyValue("soundlist", soundlist);
							mon.Precache(); // updates soundlist for some reason
						}
						else
							println("Not updating monster soundlist because it already has one");
					}
					
					string replacement;
					if (classicFriendlies.exists(cname))
					{
						if ((cname == "monster_barney" and ent.IRelationshipByClass(CLASS_PLAYER) > R_NO) or
							(cname != "monster_barney" and ent.IRelationshipByClass(CLASS_PLAYER) < R_NO))
							classicFriendlies.get(ent.pev.classname, replacement);
						else if (int(cname.Find("grunt")) != -1)
							replacement = GetReplacementModel(mon.pev.model); // still want to replace the default model since its missing anims
						else
							continue; // classic mode already replaced the model
					}
					else
						replacement = GetReplacementModel(mon.pev.model);
					
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
						
					println("AutoClassicMode: Replacing " + mon.pev.model + " -> " + replacement);
					
					Vector mins = mon.pev.mins;
					Vector maxs = mon.pev.maxs;
					g_EntityFuncs.SetModel(mon, replacement);
					g_EntityFuncs.SetSize(mon.pev, mins, maxs);
				}
				else if (!checkAgainSoon and string(mon.pev.model).Length() == 0)
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
					println("GOT : " + ent.pev.classname + " " + ent.pev.targetname);
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
}