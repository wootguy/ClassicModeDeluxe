// TODO later:
// replace sci model for ba_yard4
// if any map has a custom satchel but not a custom satchel_radio then the MAP WILL CRASH (mb game does this anyway?)
// revert to old barnacle behavior
// add voting
// LD models for custom maps that were made for 4.x and later (from LD Pack)
// allow mappers to copy-paste a gmr file into "gmr" without editing it

// Impossible replacements:
// Player uzi shoot sound
// Player sniper shoot sound
// footstep sounds
// muzzle-flashes (requires GMR - not available in scripts)
// Uzi/Saw bullet casings (requires GMR - not available in scripts)
// golden uzi third-person model
// disable full-auto for shotgun/mp5 on npcs (custom npcs are missing features and will probably break sequences/triggers)
// custom soundlists for the HL grunt are ignored. AS can't get soundlist keyvalues to fix that.
// custom weapons can fix some issues/sounds but are laggy which is worse
// Health/ammo HUD

#include "ReplacementLists"

namespace ClassicModeDeluxe {

	// for models/sounds/sprites
	// Note: When changing this, remember to also change:
	//    sounds/cm_v?/weapons.txt
	//    sprites/cm_v?/weapon_9mmar.txt
	//    models/cm_v?/v_m40a1.mdl					(reload+shoot sounds)
	//    models/cm_v?/v_desert_eagle.mdl			(reload sounds)
	//    models/cm_v?/v_saw.mdl					(reload sounds)
	//    models/cm_v?/op4/v_m40a1.mdl				(reload sounds)
	//    models/cm_v?/op4/v_desert_eagle.mdl		(reload sounds)
	//    models/cm_v?/op4/v_saw.mdl				(reload sounds)
	string cm_folder = "cm_v3";

	enum map_types {
		MAP_HALF_LIFE = 0,
		MAP_OPPOSING_FORCE = 1,
		MAP_BLUE_SHIFT = 2,
	}

	void print(string text) { g_Game.AlertMessage( at_console, text); }
	void println(string text) { print(text + "\n"); }
	
	bool isClassicMap = false;
	int mapType = MAP_HALF_LIFE;
	bool mapUsesGMR = true;
	
	dictionary classicItems; // weapons that the built-in classic mode replaces. Value is the model name.
	dictionary defaultWeaponModels; // weapon models for the default weapons
	dictionary modelReplacements;
	dictionary classicFriendlies; // monsters that should have friendly models but are overridden by classic mode
	dictionary autoReplacements; // models that are automatically replaced by classic mode but maybe shouldn't be in GMR mode
	dictionary autoReplacementMonsters; // monsters that classic mode replaces automatically
	dictionary blacklist; // models that shouldn't be replaced because GMR is already replacing them
	dictionary soundReplacements; // monsters that should have their sounds replaced
	
	// weapon names used for forced replacements in themed maps (op4/bshift/etc.)
	dictionary weapon_names;
	
	// force model replacements for these
	dictionary force_replace;
	dictionary bshift_force_replace;
	dictionary op4_force_replace;
	
	string replacementModelPath = "models/" + cm_folder + "/";
	string replacementSpritePath = "sprites/" + cm_folder + "/";
	string replacementSoundPath = cm_folder + "/";
	
	array<uint64> lastWeapons; // weapon states for all players (have/not have)
	array<array<EHandle>> satchels; // active satchel
	
	// keep this in sync with sound/cm_v?/weapons.txt
	array<string> replacedSounds = {
		"weapons/sniper_fire.wav",
		"weapons/uzi/fire_both1.wav",
		"weapons/uzi/fire_both2.wav",
		"weapons/m16_3round.wav",
		"weapons/sbarrel1.wav",
		"weapons/scock1.wav"
	};
	
	void MapInit(CBaseEntity@ caller, CBaseEntity@ activator, USE_TYPE useType, float value)
	{
		int mapInfo = caller.pev.rendermode;
		isClassicMap = mapInfo & 1 != 0;
		mapType = mapInfo >> 1;
		
		// required for linux dedicated. Linux won't automatically restart for classic mode unlike windows/listen servers.
		// this unfortunately can cause restart loops, but there is a failsafe for that and it's fixable by updating
		// classic_maps.txt or ignore_maps.txt.
		g_ClassicMode.SetShouldRestartOnChange(true);
		
		if (isClassicMap)
		{
			g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );
			g_Hooks.RegisterHook( Hooks::Player::PlayerTakeDamage, @PlayerTakeDamage );
			
			g_ClassicMode.EnableMapSupport();
		
			array<ItemMapping@> itemMappings = { 
				ItemMapping( "weapon_m16", "weapon_9mmAR" ),
				ItemMapping( "ammo_556", "ammo_9mmbox" )
			};
			g_ClassicMode.SetItemMappings( @itemMappings );
			
			initReplacements();
			loadBlacklist();
		}
		
		if (isClassicMap != g_ClassicMode.IsEnabled())
		{
			g_ClassicMode.ResetState();
			g_ClassicMode.SetEnabled(isClassicMap);
		}
		
		caller.pev.renderfx = 1; // tell the plugin that the script loaded successfully
	}
	
	void MapActivate(CBaseEntity@ caller, CBaseEntity@ activator, USE_TYPE useType, float value)
	{
		if (!isClassicMap)
			return;
		
		ProcessMonstersByClass("monster_*");
		ProcessWeaponByClass("weapon_*");
		ProcessGenericByClass("ammo_*");
		ProcessGenericByClass("item_*");
		
		lastWeapons.resize(33);
		satchels.resize(33);
		MonitorPlayerWeapons();
	}
	
	string GetReplacementWeaponModel(string model, string subfolder)
	{
		return model.Replace("hlclassic/","").Replace("models/", replacementModelPath + subfolder);
	}

	bool ShouldUpdateSoundlist(CBaseMonster@ mon)
	{
		// TODO: Check ALL possible sounds, not just the ones I want to replace
		for (uint i = 0; i < replacedSounds.size(); i++)
			if (mon.SOUNDREPLACEMENT_Find(replacedSounds[i]) != replacedSounds[i])
				return false;
		
		return true;
	}
	
	void ProcessMonster(EHandle h_mon)
	{
		if (!h_mon.IsValid())
			return;
		CBaseMonster@ mon = cast<CBaseMonster@>(h_mon.GetEntity());
		
		//println("Test " + mon.pev.model + " - " + mon.pev.classname);
		string cname = mon.pev.classname;
		string model = mon.pev.model;
		
		if (cname == "monster_satchel")
		{
			CBasePlayer@ plr = cast<CBasePlayer@>(g_EntityFuncs.Instance(mon.pev.owner));
			if (plr !is null) {
				plr.pev.viewmodel = string(plr.pev.viewmodel).Replace("v_satchel.mdl", "v_satchel_radio.mdl");
				plr.pev.weaponmodel = string(plr.pev.weaponmodel).Replace("p_satchel.mdl", "p_satchel_radio.mdl");
				satchels[plr.entindex()].insertLast(h_mon);
			}
		}
		
		bool should_force_replace = (mapType != MAP_HALF_LIFE) and force_replace.exists(mon.pev.model);
		if (!should_force_replace and mapUsesGMR and autoReplacementMonsters.exists(cname))
		{
			string originalModel;
			autoReplacements.get(model, originalModel);
			
			if (blacklist.exists(originalModel))
			{
				//println("Undoing model replacement: " + mon.pev.model + " --> " + originalModel);
				int idx = g_Game.PrecacheModel(originalModel);

				int oldBody = mon.pev.body;
				Vector mins = mon.pev.mins;
				Vector maxs = mon.pev.maxs;
				g_EntityFuncs.SetModel(mon, originalModel);
				g_EntityFuncs.SetSize(mon.pev, mins, maxs);
				mon.pev.body = oldBody;
				
				if (mapType == MAP_OPPOSING_FORCE)
				{
					// of1a6 scientist has broken neck without this. No idea what the proper way to fix this is,
					// since it looks like the HL sci is missing controllers.
					mon.pev.set_controller(0,mon.pev.get_controller(0));
					mon.pev.set_controller(1,mon.pev.get_controller(0));
					mon.pev.set_controller(2,mon.pev.get_controller(0));
					mon.pev.set_controller(3,mon.pev.get_controller(0));
				}
			}
		}
		
		// sound replacement
		if (soundReplacements.exists(cname))
		{
			if (ShouldUpdateSoundlist(mon))
			{
				//println("Add soundlist to " + ent.pev.classname);
				string soundlist;
				soundReplacements.get(cname, soundlist);
				mon.KeyValue("soundlist", soundlist);
				mon.Precache(); // updates soundlist for some reason
			}
			else
				println("Not updating monster soundlist because it already has one");
		}
		
		if (should_force_replace or (modelReplacements.exists(model) and not blacklist.exists(model)))
		{
			//println("Le model replace " + cname);
			bool isDead = int(cname.Find("_dead")) != -1;
			bool isGrunt = int(cname.Find("grunt")) != -1 and cname != "monster_alien_grunt";
			bool isBarney = int(cname.Find("barney")) != -1 && int(cname.Find("barney_dead")) == -1;
		
			string replacement;
			if (should_force_replace)
			{
				force_replace.get(mon.pev.model, replacement);
				if (mapType == MAP_BLUE_SHIFT and (cname == "monster_scientist_dead" || cname == "monster_hgrunt_dead")) {
					mon.pev.sequence += 1; // TODO: edit the models you lazy fuck
					mon.pev.body = 0; // TODO: can be customized by mapper, but this works for bshift
				}
			}
			else
			{
				if (classicFriendlies.exists(cname))
				{
					// barney is the only classsic monster that spawns friendly by default
					if ((isBarney and !mon.IsPlayerAlly()) or
						(!isBarney and mon.IsPlayerAlly()))
						classicFriendlies.get(mon.pev.classname, replacement);
					else if (isGrunt and !isDead)
						modelReplacements.get(model, replacement); // still want to replace the default model since its missing anims
					else
						return; // classic mode already replaced the model
				}
				else
					modelReplacements.get(model, replacement);
			}
			
			// sven has more weapons and heads and so bodygroups are different from the hlclassic model
			if (cname == "monster_human_grunt" 
				&& (replacement == "models/" + cm_folder + "/hgrunt.mdl" ||
					replacement == "models/" + cm_folder + "/hgruntf.mdl"))
			{
				const int OLD_HEAD_GROUPS = 5;
				const int OLD_WEP_GROUPS = 3;
				const int NEW_HEAD_GROUPS = 5;
				const int NEW_WEP_GROUPS = 6;
				
				// This doesn't work. By the time the built-in classic mode replaces the model the group info is lost.
				// So, all mp5 grunts will have the gas mask.
				int oldHeadGroup = mon.pev.body / (OLD_HEAD_GROUPS+OLD_WEP_GROUPS);
				
				int headGroup = 0;
				int wepGroup = 0;
				
				// head group depends on weapons, and also sometimes the game forces head group 1 for squad leaders(?)
				if (mon.pev.weapons & 4 != 0) {
					headGroup = 3; // always has cigar
					mon.pev.skin = 1; // always black
				}
				else if (mon.pev.weapons & 8 != 0) {
					wepGroup = 1; // shotgun
					headGroup = 2; // always has ski mask
				}
				else if (mon.pev.weapons & 64 != 0) {
					wepGroup = 3; // rpg
					headGroup = 4; // always has helmet + goggles off
				}
				else if (mon.pev.weapons & 128 != 0) {
					wepGroup = 5; // sniper
					headGroup = 4; // always has helmet + goggles off
				} else {
					// mp5 grunt is the only one that respects the head set by the mapper
					headGroup = oldHeadGroup;
				}

				mon.pev.body = wepGroup*NEW_HEAD_GROUPS + headGroup;
			}
			
			//println("ClassicModeDeluxe(m): Replacing " + model + " -> " + replacement);
			
			int oldSequence = mon.pev.sequence;
			Vector mins = mon.pev.mins;
			Vector maxs = mon.pev.maxs;
			g_EntityFuncs.SetModel(mon, replacement);
			g_EntityFuncs.SetSize(mon.pev, mins, maxs);
			mon.pev.sequence = oldSequence;
			
			if (cname == "monster_human_grunt" and oldSequence == 48) {
				// fix hgrunt repel animation (for some reason all other repel monsters are ok)
				mon.pev.sequence = 50;
			}
			
			if (cname == "monster_hevsuit_dead") {
				mon.pev.sequence -= 104;
				mon.pev.body = 1;
			}
		}
	}
	
	void ProcessGeneric(EHandle h_ent)
	{
		if (!h_ent.IsValid())
			return;
		
		CBaseEntity@ ent = h_ent;		
		
		if (mapType != MAP_HALF_LIFE and force_replace.exists(ent.pev.model))
		{
			string replacement;
			force_replace.get(ent.pev.model, replacement);
			//println("ClassicModeDeluxe(f): Replacing " + ent.pev.model + " -> " + replacement);
			g_EntityFuncs.SetModel(ent, replacement);
		}
		else
		{
			if (mapUsesGMR and classicItems.exists(ent.pev.classname))
			{
				string originalModel;
				autoReplacements.get(ent.pev.model, originalModel);
				
				if (blacklist.exists(originalModel))
				{
					//println("Undoing model replacement for " + originalModel);
					int idx = g_Game.PrecacheModel(originalModel);
					g_EntityFuncs.SetModel(ent, originalModel);
				}
			}
			if (modelReplacements.exists(ent.pev.model))
			{
				string replacement;
				modelReplacements.get(ent.pev.model, replacement);				
				//println("ClassicModeDeluxe(g): Replacing " + ent.pev.model + " -> " + replacement);
				g_EntityFuncs.SetModel(ent, replacement);
				ent.pev.pain_finished = 0; // special minigun keyvalue for this script
			}
		}
		
	}
	
	void ProcessWeapon(EHandle h_wep)
	{
		if (!h_wep.IsValid())
			return;
			
		CBasePlayerWeapon@ wep = cast<CBasePlayerWeapon@>(h_wep.GetEntity());
		if (wep is null)
			return;
			
		if (wep.pev.classname == "weapon_9mmAR")
			wep.KeyValue("CustomSpriteDir", cm_folder);
			
		//println("Checking " + wep.pev.classname);
		
		string cname = wep.pev.classname;
		
		bool builtInClassicModeIsReplacingThis = classicItems.exists(wep.pev.classname);
		
		if (builtInClassicModeIsReplacingThis and !mapUsesGMR and mapType == MAP_HALF_LIFE)
			return; // classic mode will do the swapping for us. Model keyvalues on entities won't be overridden
		
		string defaultModelName;
		defaultWeaponModels.get(wep.pev.classname, defaultModelName);
		string defaultVModel = "models/v_" + defaultModelName + ".mdl";
		string defaultPModel = "models/p_" + defaultModelName + ".mdl";
		string defaultWModel = "models/w_" + defaultModelName + ".mdl";
		
		if (defaultModelName.Length() == 0)
		{
			//println("Failed to load default weapon models for " + cname);
			return;
		}
		
		if (defaultModelName == "minigun")
			defaultPModel = "models/p_minigunidle.mdl";
		if (defaultModelName == "squeak")
			defaultWModel = "models/w_sqknest.mdl";
		
		string vmodel = wep.GetV_Model(defaultVModel);
		string pmodel = wep.GetP_Model(defaultPModel);
		string wmodel = wep.GetW_Model(defaultWModel);
		
		//println("Current models for " + wep.pev.classname + " are " + vmodel + " " + pmodel + " " +  wmodel);
		
		// the GetWeaponModel funcs account for GMR, but not for classic mode.
		// If it has a custom model I need to re-apply it or else classic mode will override the custom model.
		// This isn't needed if the custom model was set on the entity, but there's no way to know if it was
		// from that or from GMR, so I need to always re-apply custom models if the map uses GMR.
		
		bool shouldForceThemedWeapon = mapType != MAP_HALF_LIFE;
		
		bool shouldSwap = false;
		if (shouldForceThemedWeapon)
		{
			string subfolder = "op4/";
			if (mapType == MAP_BLUE_SHIFT)
				subfolder = "bshift/";
			vmodel = GetReplacementWeaponModel(defaultVModel, subfolder);
			modelReplacements.get(defaultPModel, pmodel);
			modelReplacements.get(defaultWModel, wmodel);
			shouldSwap = true;
		}
		else
		{
			if (builtInClassicModeIsReplacingThis and defaultVModel != vmodel)
				shouldSwap = true;
			else if (modelReplacements.exists(vmodel))
			{
				modelReplacements.get(vmodel, vmodel);
				shouldSwap = true;
			}
			else if (builtInClassicModeIsReplacingThis and mapUsesGMR)
				vmodel = ""; // let classic mode replace it then
				
			
			if (builtInClassicModeIsReplacingThis and defaultPModel != pmodel)
				shouldSwap = true;
			else if (modelReplacements.exists(pmodel))
			{
				modelReplacements.get(pmodel, pmodel);
				shouldSwap = true;
			}
			else if (builtInClassicModeIsReplacingThis and mapUsesGMR)
				pmodel = ""; // let classic mode replace it then
			
			if (builtInClassicModeIsReplacingThis and defaultWModel != wmodel)
				shouldSwap = true;
			else if (modelReplacements.exists(wmodel))
			{
				modelReplacements.get(wmodel, wmodel);
				shouldSwap = true;
			}
			else if (builtInClassicModeIsReplacingThis and mapUsesGMR)
				wmodel = ""; // let classic mode replace it then
		}
		
		
		if (!shouldSwap)
			return; // all models are custom or have no replacements
		
		//println("Replacement models are " + vmodel + " " + pmodel + " " +  wmodel);
		
		if (vmodel.Length() > 0)
			wep.KeyValue("wpn_v_model", vmodel);
		if (pmodel.Length() > 0)
			wep.KeyValue("wpn_p_model", pmodel);
		if (wmodel.Length() > 0)
			wep.KeyValue("wpn_w_model", wmodel);
			
		g_EntityFuncs.SetModel(wep, wmodel);
		
		
		CBasePlayer@ plr = cast<CBasePlayer@>(g_EntityFuncs.Instance(wep.pev.owner));
		if (plr is null or !plr.IsConnected())
			return;

		// force model updates since the wep is already deployed
		CBasePlayerWeapon@ activeWep = cast<CBasePlayerWeapon@>(plr.m_hActiveItem.GetEntity());
		if (activeWep !is null && activeWep.entindex() == wep.entindex())
		{
			if (vmodel.Length() > 0)
				plr.pev.viewmodel = vmodel;
			if (pmodel.Length() > 0)
				plr.pev.weaponmodel = pmodel;
				
			if (!plr.IsAlive()) {
				activeWep.Holster();
			}
		}
	}
	
	void ProcessMonstersByClass(string cname)
	{
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, cname);
			if (ent !is null)
				ProcessMonster(EHandle(ent));
		} while (ent !is null);
	}
	
	void ProcessGenericByClass(string cname)
	{
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, cname);
			if (ent !is null)
				ProcessGeneric(EHandle(ent));
		} while (ent !is null);
	}
	
	void ProcessWeaponByClass(string cname)
	{
		CBaseEntity@ ent = null;
		do {
			@ent = g_EntityFuncs.FindEntityByClassname(ent, cname);
			if (ent !is null)
				ProcessWeapon(EHandle(ent));
		} while (ent !is null);
	}
	
	HookReturnCode EntityCreated(CBaseEntity@ ent)
	{
		//println("ZOMG ENT CREATED: " + ent.pev.classname);
		
		if (ent.IsMonster() and ent.pev.classname != "monster_generic")
		{
			g_Scheduler.SetTimeout("ProcessMonster", 0, EHandle(ent));
			return HOOK_CONTINUE;
		}
		
		CBasePlayerWeapon@ wep =cast<CBasePlayerWeapon@>(ent);
		if (@wep != null)
		{
			if (wep.pev.classname == "weapon_9mmAR")
				wep.KeyValue("CustomSpriteDir", cm_folder);
			g_Scheduler.SetTimeout("ProcessWeapon", 0, EHandle(ent));
			return HOOK_CONTINUE;
		}
		
		g_Scheduler.SetTimeout("ProcessGeneric", 0, EHandle(ent));
		
		return HOOK_CONTINUE;
	}
	
	HookReturnCode PlayerTakeDamage(DamageInfo@ info)
	{
		CBasePlayer@ plr = cast<CBasePlayer@>(g_EntityFuncs.Instance(info.pVictim.pev));
		entvars_t@ pevInflictor = info.pInflictor !is null ? info.pInflictor.pev : null;
		entvars_t@ pevAttacker = info.pAttacker !is null ? info.pAttacker.pev : null;
		
		if (info.pInflictor !is null and plr !is null) {
			if (plr.IRelationship(info.pInflictor) <= R_NO) {
				return HOOK_CONTINUE; // don't take damage from other players or ally monsters
			}
			
			if (!info.pInflictor.IsPlayer()) {
				CBaseEntity@ owner = g_EntityFuncs.Instance(info.pInflictor.pev.owner);
				if (plr.IRelationship(owner) <= R_NO) {
					return HOOK_CONTINUE; // don't take damage from things another player owns (e.g. hornets)
				}
			}
		}
			
		
		HalfLifeTakeDamage(plr, pevInflictor, pevAttacker, info.flDamage, info.bitsDamageType);
		info.flDamage = 0; // bypass sven's damage logic
		return HOOK_CONTINUE;
	}
	
	int HalfLifeTakeDamage(CBasePlayer@ plr, entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType)
	{
		const float ARMOR_RATIO = 0.2f; // Armor takes 80% of the damage
		const float ARMOR_BONUS = 0.5f; // Each point of armer is worth 1/x points of health
		
		const int SUIT_NEXT_IN_30SEC = 30;
		const int SUIT_NEXT_IN_1MIN	= 60;
		const int SUIT_NEXT_IN_5MIN	= 300;
		const int SUIT_NEXT_IN_10MIN = 600;
		const int SUIT_NEXT_IN_30MIN = 1800;

		float flBonus = ARMOR_BONUS;
		float flRatio = ARMOR_RATIO;
		float flHealthPrev = plr.pev.health;
		
		if (bitsDamageType & DMG_BLAST != 0)
			flBonus *= 2; // blasts damage armor more.
		
		if ( !plr.IsAlive() )
			return 0;

		// keep track of amount of damage last sustained
		plr.m_lastDamageAmount = int(flDamage);
		
		// Armor. 
		if (plr.pev.armorvalue != 0 && !(bitsDamageType & (DMG_FALL | DMG_DROWN) != 0) ) // armor doesn't protect against fall or drown damage!
		{
			float flNew = flDamage * flRatio;
			float flArmor = (flDamage - flNew) * flBonus;

			// Does this use more armor than we have?
			if (flArmor > plr.pev.armorvalue)
			{
				flArmor = plr.pev.armorvalue;
				flArmor *= (1.0f/flBonus);
				flNew = flDamage - flArmor;
				plr.pev.armorvalue = 0;
			}
			else
				plr.pev.armorvalue -= flArmor;
			
			flDamage = flNew;
		}
		
		// this cast to INT is critical!!! If a player ends up with 0.5 health, the engine will get that
		// as an int (zero) and think the player is dead! (this will incite a clientside screentilt, etc)
		float flTake = int(flDamage);
		
		if (pevInflictor !is null)
			@plr.pev.dmg_inflictor = pevInflictor.get_pContainingEntity();

		plr.pev.dmg_take += flTake;
		
		// do the damage
		plr.pev.health -= flTake;
		
		if (plr.pev.health <= 0)
		{
			if (bitsDamageType & DMG_ALWAYSGIB != 0)
				plr.Killed( pevAttacker, GIB_ALWAYS );
			else if (bitsDamageType & DMG_NEVERGIB != 0)
				plr.Killed( pevAttacker, GIB_NEVER );
			else
				plr.Killed( pevAttacker, GIB_NORMAL );
			return 0;
		}
		
		// play suit sounds
		if (g_EngineFuncs.CVarGetFloat("mp_hevsuit_voice") != 0)
		{
			bool ftrivial = (plr.pev.health > 75 || plr.m_lastDamageAmount < 5);
			bool fmajor = (plr.m_lastDamageAmount > 25);
			bool fcritical = (plr.pev.health < 30);
			bool ffound = true;
			int bitsDamage = bitsDamageType;
		
			while ((!ftrivial || (bitsDamage & DMG_TIMEBASED != 0)) && ffound && bitsDamage != 0)
			{
				ffound = false;

				if (bitsDamage & DMG_CLUB != 0)
				{
					if (fmajor)
						plr.SetSuitUpdate("!HEV_DMG4", false, SUIT_NEXT_IN_30SEC);	// minor fracture
					bitsDamage &= ~DMG_CLUB;
					ffound = true;
				}
				if (bitsDamage & (DMG_FALL | DMG_CRUSH) != 0)
				{
					if (fmajor)
						plr.SetSuitUpdate("!HEV_DMG5", false, SUIT_NEXT_IN_30SEC);	// major fracture
					else
						plr.SetSuitUpdate("!HEV_DMG4", false, SUIT_NEXT_IN_30SEC);	// minor fracture
			
					bitsDamage &= ~(DMG_FALL | DMG_CRUSH);
					ffound = true;
				}
				if (bitsDamage & DMG_BULLET != 0)
				{
					if (plr.m_lastDamageAmount > 5)
						plr.SetSuitUpdate("!HEV_DMG6", false, SUIT_NEXT_IN_30SEC);	// blood loss detected
					//else
					//	plr.SetSuitUpdate("!HEV_DMG0", false, SUIT_NEXT_IN_30SEC);	// minor laceration
					
					bitsDamage &= ~DMG_BULLET;
					ffound = true;
				}
				if (bitsDamage & DMG_SLASH != 0)
				{
					if (fmajor)
						plr.SetSuitUpdate("!HEV_DMG1", false, SUIT_NEXT_IN_30SEC);	// major laceration
					else
						plr.SetSuitUpdate("!HEV_DMG0", false, SUIT_NEXT_IN_30SEC);	// minor laceration

					bitsDamage &= ~DMG_SLASH;
					ffound = true;
				}
				if (bitsDamage & DMG_SONIC != 0)
				{
					if (fmajor)
						plr.SetSuitUpdate("!HEV_DMG2", false, SUIT_NEXT_IN_1MIN);	// internal bleeding
					bitsDamage &= ~DMG_SONIC;
					ffound = true;
				}
				if (bitsDamage & (DMG_POISON | DMG_PARALYZE) != 0)
				{
					plr.SetSuitUpdate("!HEV_DMG3", false, SUIT_NEXT_IN_1MIN);	// blood toxins detected
					bitsDamage &= ~(DMG_POISON | DMG_PARALYZE);
					ffound = true;
				}
				if (bitsDamage & DMG_ACID != 0)
				{
					plr.SetSuitUpdate("!HEV_DET1", false, SUIT_NEXT_IN_1MIN);	// hazardous chemicals detected
					bitsDamage &= ~DMG_ACID;
					ffound = true;
				}
				if (bitsDamage & DMG_NERVEGAS != 0)
				{
					plr.SetSuitUpdate("!HEV_DET0", false, SUIT_NEXT_IN_1MIN);	// biohazard detected
					bitsDamage &= ~DMG_NERVEGAS;
					ffound = true;
				}
				if (bitsDamage & DMG_RADIATION != 0)
				{
					plr.SetSuitUpdate("!HEV_DET2", false, SUIT_NEXT_IN_1MIN);	// radiation detected
					bitsDamage &= ~DMG_RADIATION;
					ffound = true;
				}
				if (bitsDamage & DMG_SHOCK != 0)
				{
					bitsDamage &= ~DMG_SHOCK;
					ffound = true;
				}
			}

			if (!ftrivial && fmajor && flHealthPrev >= 75) 
			{
				// first time we take major damage...
				// turn automedic on if not on
				plr.SetSuitUpdate("!HEV_MED1", false, SUIT_NEXT_IN_30MIN);	// automedic on

				// give morphine shot if not given recently
				plr.SetSuitUpdate("!HEV_HEAL7", false, SUIT_NEXT_IN_30MIN);	// morphine shot
			}
			
			if (!ftrivial && fcritical && flHealthPrev < 75)
			{

				// already took major damage, now it's critical...
				if (plr.pev.health < 6)
					plr.SetSuitUpdate("!HEV_HLTH3", false, SUIT_NEXT_IN_10MIN);	// near death
				else if (plr.pev.health < 20)
					plr.SetSuitUpdate("!HEV_HLTH2", false, SUIT_NEXT_IN_10MIN);	// health critical
			
				// give critical health warnings
				if (Math.RandomLong(0,3) == 0 && flHealthPrev < 50)
					plr.SetSuitUpdate("!HEV_DMG7", false, SUIT_NEXT_IN_5MIN); //seek medical attention
			}

			// if we're taking time based damage, warn about its continuing effects
			if ((bitsDamageType & DMG_TIMEBASED != 0) && flHealthPrev < 75)
			{
				if (flHealthPrev < 50)
				{
					if (Math.RandomLong(0,3) == 0)
						plr.SetSuitUpdate("!HEV_DMG7", false, SUIT_NEXT_IN_5MIN); //seek medical attention
				}
				else
					plr.SetSuitUpdate("!HEV_HLTH1", false, SUIT_NEXT_IN_10MIN);	// health dropping
			}
		}

		return 1;
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
				satchels[i] = array<EHandle>();
				break;
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
			g_Scheduler.SetTimeout("ProcessGenericByClass", 0.0f, string(wep.pev.classname));
	}
	
	// for some reason setting model on a weapon after it spawns doesn't affect the model used when dropped
	void MonitorPlayerWeapons()
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
							if (int(string(plr.pev.weaponmodel).Find(cm_folder)) != -1)
							{
								if (wep.m_fIsAkimbo)
									plr.pev.weaponmodel = replacementModelPath + "p_2uzis.mdl";
								else
									plr.pev.weaponmodel = replacementModelPath + "p_uzi.mdl";
							}
							// dropped uzi needs replacement when dual wielding
							if (!wep.m_fIsAkimbo)
								g_Scheduler.SetTimeout("ProcessGenericByClass", 0.0f, "weapon_uzi");
						}
						if (wep.pev.classname == "weapon_minigun")
						{
							if (wep.pev.pain_finished == 0)
								wep.pev.pain_finished = g_Engine.time; // remember that we just picked this up
							if (g_Engine.time - wep.pev.pain_finished > 2.0f) // deployment finished?
							{
								// primaryattack != -1 during deployment and player can spinup before it reaches -1
								if (wep.m_flNextPrimaryAttack != -1 or plr.pev.button & (IN_ATTACK|IN_ATTACK2) != 0)
									plr.pev.weaponmodel = replacementModelPath + "p_minigunspin.mdl";
								else
									plr.pev.weaponmodel = replacementModelPath + "p_minigunidle.mdl";
							}
						}
						if (wep.pev.classname == "weapon_satchel")
						{
							for (uint c = 0; c < satchels[i].size(); c++)
							{
								if (!satchels[i][c].IsValid()) {
									satchels[i].removeAt(c);
									c--;
								}
							}
							if (satchels[i].size() > 0)
							{
								plr.pev.viewmodel = string(plr.pev.viewmodel).Replace("v_satchel.mdl", "v_satchel_radio.mdl");
								plr.pev.weaponmodel = string(plr.pev.weaponmodel).Replace("p_satchel.mdl", "p_satchel_radio.mdl");
							}
						}
					}
					else
						wep.pev.colormap = 0;
					@item = cast<CBasePlayerItem@>(item.m_hNextItem.GetEntity());	
				}
			}
			if (weapons < lastWeapons[i])
				ProcessGenericByClass("weapon_*");
			lastWeapons[i] = weapons;
		}
		
		g_Scheduler.SetTimeout("MonitorPlayerWeapons", 0.05f);
	}
	
}