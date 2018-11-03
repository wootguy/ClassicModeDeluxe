// TODO:
// replace sci model for ba_yard4
// if any map has a custom satchel but not a custom satchel_radio then the MAP WILL CRASH

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
	
	// themed weapons for specific maps
	dictionary op4_weapons;
	dictionary bshift_weapons;
	
	// force model replacements for these
	dictionary force_replace;
	dictionary bshift_force_replace;
	
	string replacementModelPath = "models/AutoClassicMode/";
	string replacementSpritePath = "sprites/AutoClassicMode/";
	string replacementSoundPath = "AutoClassicMode/";
	
	array<uint64> lastWeapons; // weapon states for all players (have/not have)
	array<array<EHandle>> satchels; // active satchel
	
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
		modelReplacements["models/otis.mdl"] = "models/AutoClassicMode/otis.mdl";
		modelReplacements["models/otisf.mdl"] = "models/AutoClassicMode/otisf.mdl";
		modelReplacements["models/zombie_barney.mdl"] = "models/AutoClassicMode/zombie_barney.mdl";
		modelReplacements["models/zombie_soldier.mdl"] = "models/AutoClassicMode/zombie_soldier.mdl";
		modelReplacements["models/hgrunt_medic.mdl"] = "models/AutoClassicMode/hgrunt_medic.mdl";
		modelReplacements["models/hgrunt_medicf.mdl"] = "models/AutoClassicMode/hgrunt_medicf.mdl";
		modelReplacements["models/hgrunt_opfor.mdl"] = "models/AutoClassicMode/hgrunt_opfor.mdl";
		modelReplacements["models/hgrunt_opforf.mdl"] = "models/AutoClassicMode/hgrunt_opforf.mdl";
		modelReplacements["models/hgrunt_torch.mdl"] = "models/AutoClassicMode/hgrunt_torch.mdl";
		modelReplacements["models/hgrunt_torchf.mdl"] = "models/AutoClassicMode/hgrunt_torchf.mdl";
		modelReplacements["models/massn.mdl"] = "models/AutoClassicMode/massn.mdl";
		modelReplacements["models/massnf.mdl"] = "models/AutoClassicMode/massnf.mdl";
		modelReplacements["models/rgrunt.mdl"] = "models/AutoClassicMode/rgrunt.mdl";
		modelReplacements["models/rgruntf.mdl"] = "models/AutoClassicMode/rgruntf.mdl";
		modelReplacements["models/hwgrunt.mdl"] = "models/AutoClassicMode/hwgrunt.mdl";
		modelReplacements["models/hwgruntf.mdl"] = "models/AutoClassicMode/hwgruntf.mdl";
		modelReplacements["models/osprey.mdl"] = "models/AutoClassicMode/osprey.mdl";
		modelReplacements["models/osprey2.mdl"] = "models/AutoClassicMode/osprey2.mdl";
		modelReplacements["models/ospreyf.mdl"] = "models/AutoClassicMode/ospreyf.mdl";
		modelReplacements["models/blkop_apache.mdl"] = "models/AutoClassicMode/blkop_apache.mdl";
		modelReplacements["models/blkop_osprey.mdl"] = "models/AutoClassicMode/blkop_osprey.mdl";
		modelReplacements["models/apachef.mdl"] = "models/AutoClassicMode/apachef.mdl";
		modelReplacements["models/agruntf.mdl"] = "models/AutoClassicMode/agruntf.mdl";
		modelReplacements["models/strooper.mdl"] = "models/AutoClassicMode/strooper.mdl";
		modelReplacements["models/bgman.mdl"] = "models/AutoClassicMode/bgman.mdl";
		modelReplacements["models/w_shock_rifle.mdl"] = "models/AutoClassicMode/w_shock_rifle.mdl";
		modelReplacements["models/barnabus.mdl"] = "models/AutoClassicMode/barnabus.mdl";
		modelReplacements["models/hassassinf.mdl"] = "models/AutoClassicMode/hassassinf.mdl";
		modelReplacements["models/hgruntf.mdl"] = "models/AutoClassicMode/hgruntf.mdl";
		modelReplacements["models/islavef.mdl"] = "models/AutoClassicMode/islavef.mdl";
		modelReplacements["models/player.mdl"] = "models/AutoClassicMode/player.mdl";
		modelReplacements["models/gonome.mdl"] = "models/AutoClassicMode/gonome.mdl";
		modelReplacements["models/tor.mdl"] = "models/AutoClassicMode/tor.mdl";
		modelReplacements["models/torf.mdl"] = "models/AutoClassicMode/torf.mdl";
		modelReplacements["models/hgrunt.mdl"] = "models/AutoClassicMode/hgrunt.mdl";
		modelReplacements["models/hlclassic/barney.mdl"] = "models/hlclassic/barney.mdl";
		modelReplacements["models/hlclassic/hgrunt.mdl"] = "models/hlclassic/hgrunt.mdl"; // the vanilla classic grunt is missing rpg anims
		modelReplacements["models/hlclassic/hassassin.mdl"] = "models/hlclassic/hassassin.mdl";
		modelReplacements["models/hlclassic/islave.mdl"] = "models/hlclassic/islave.mdl";
		modelReplacements["models/hlclassic/agrunt.mdl"] = "models/hlclassic/agrunt.mdl";
		
		modelReplacements["models/v_saw.mdl"] = "models/AutoClassicMode/v_saw.mdl";
		modelReplacements["models/p_saw.mdl"] = "models/AutoClassicMode/p_saw.mdl";
		modelReplacements["models/w_saw.mdl"] = "models/AutoClassicMode/w_saw.mdl";
		modelReplacements["models/v_m40a1.mdl"] = "models/AutoClassicMode/v_m40a1.mdl";
		modelReplacements["models/p_m40a1.mdl"] = "models/AutoClassicMode/p_m40a1.mdl";
		modelReplacements["models/w_m40a1.mdl"] = "models/AutoClassicMode/w_m40a1.mdl";
		modelReplacements["models/v_spore_launcher.mdl"] = "models/AutoClassicMode/v_spore_launcher.mdl";
		modelReplacements["models/p_spore_launcher.mdl"] = "models/AutoClassicMode/p_spore_launcher.mdl";
		modelReplacements["models/w_spore_launcher.mdl"] = "models/AutoClassicMode/w_spore_launcher.mdl";
		modelReplacements["models/v_displacer.mdl"] = "models/AutoClassicMode/v_displacer.mdl";
		modelReplacements["models/p_displacer.mdl"] = "models/AutoClassicMode/p_displacer.mdl";
		modelReplacements["models/w_displacer.mdl"] = "models/AutoClassicMode/w_displacer.mdl";
		modelReplacements["models/w_pipe_wrench.mdl"] = "models/AutoClassicMode/w_pipe_wrench.mdl";
		modelReplacements["models/v_pipe_wrench.mdl"] = "models/AutoClassicMode/v_pipe_wrench.mdl";
		modelReplacements["models/p_pipe_wrench.mdl"] = "models/AutoClassicMode/p_pipe_wrench.mdl";
		// TODO: dual and golden uzi models don't work (except for view model)
		modelReplacements["models/v_uzi.mdl"] = "models/AutoClassicMode/v_uzi.mdl";
		modelReplacements["models/p_uzi.mdl"] = "models/AutoClassicMode/p_uzi.mdl";
		modelReplacements["models/w_uzi.mdl"] = "models/AutoClassicMode/w_uzi.mdl";
		//modelReplacements["models/w_2uzis.mdl"] = "models/AutoClassicMode/w_2uzis.mdl";
		modelReplacements["models/p_2uzis.mdl"] = "models/AutoClassicMode/p_2uzis.mdl";
		modelReplacements["models/p_uzi_gold.mdl"] = "models/AutoClassicMode/p_uzi_gold.mdl";
		modelReplacements["models/w_uzi_gold.mdl"] = "models/AutoClassicMode/w_uzi_gold.mdl";
		modelReplacements["models/p_2uzis_gold.mdl"] = "models/AutoClassicMode/p_2uzis_gold.mdl";
		//modelReplacements["models/w_2uzis_gold.mdl"] = "models/AutoClassicMode/w_2uzis_gold.mdl";
		modelReplacements["models/v_minigun.mdl"] = "models/AutoClassicMode/v_minigun.mdl";
		modelReplacements["models/p_minigunidle.mdl"] = "models/AutoClassicMode/p_minigunidle.mdl";
		modelReplacements["models/p_minigunspin.mdl"] = "models/AutoClassicMode/p_minigunspin.mdl";
		modelReplacements["models/w_minigun.mdl"] = "models/AutoClassicMode/w_minigun.mdl";
		modelReplacements["models/v_desert_eagle.mdl"] = "models/AutoClassicMode/v_desert_eagle.mdl";
		modelReplacements["models/w_desert_eagle.mdl"] = "models/AutoClassicMode/w_desert_eagle.mdl";
		modelReplacements["models/p_desert_eagle.mdl"] = "models/AutoClassicMode/p_desert_eagle.mdl";
		modelReplacements["models/v_bgrap.mdl"] = "models/AutoClassicMode/v_bgrap.mdl";
		modelReplacements["models/p_bgrap.mdl"] = "models/AutoClassicMode/p_bgrap.mdl";
		modelReplacements["models/w_bgrap.mdl"] = "models/AutoClassicMode/w_bgrap.mdl";
		modelReplacements["models/v_shock.mdl"] = "models/AutoClassicMode/v_shock.mdl";
		modelReplacements["models/p_shock.mdl"] = "models/AutoClassicMode/p_shock.mdl";
		modelReplacements["models/w_uzi_clip.mdl"] = "models/AutoClassicMode/w_uzi_clip.mdl";
		modelReplacements["models/w_saw_clip.mdl"] = "models/AutoClassicMode/w_saw_clip.mdl";
		modelReplacements["models/w_m40a1clip.mdl"] = "models/AutoClassicMode/w_m40a1clip.mdl";
		
		modelReplacements["models/p_357.mdl"] = "models/hlclassic/p_357.mdl";
		modelReplacements["models/v_357.mdl"] = "models/hlclassic/v_357.mdl";
		modelReplacements["models/w_357.mdl"] = "models/hlclassic/w_357.mdl";
		modelReplacements["models/p_9mmar.mdl"] = "models/hlclassic/p_9mmar.mdl";
		modelReplacements["models/v_9mmAR.mdl"] = "models/hlclassic/v_9mmAR.mdl";
		modelReplacements["models/w_9mmar.mdl"] = "models/hlclassic/w_9mmar.mdl";
		modelReplacements["models/p_9mmhandgun.mdl"] = "models/hlclassic/p_9mmhandgun.mdl";
		modelReplacements["models/v_9mmhandgun.mdl"] = "models/hlclassic/v_9mmhandgun.mdl";
		modelReplacements["models/w_9mmhandgun.mdl"] = "models/hlclassic/w_9mmhandgun.mdl";
		modelReplacements["models/p_crossbow.mdl"] = "models/hlclassic/p_crossbow.mdl";
		modelReplacements["models/v_crossbow.mdl"] = "models/hlclassic/v_crossbow.mdl";
		modelReplacements["models/w_crossbow.mdl"] = "models/hlclassic/w_crossbow.mdl";
		modelReplacements["models/p_crowbar.mdl"] = "models/hlclassic/p_crowbar.mdl";
		modelReplacements["models/v_crowbar.mdl"] = "models/hlclassic/v_crowbar.mdl";
		modelReplacements["models/w_crowbar.mdl"] = "models/hlclassic/w_crowbar.mdl";
		modelReplacements["models/p_egon.mdl"] = "models/hlclassic/p_egon.mdl";
		modelReplacements["models/v_egon.mdl"] = "models/hlclassic/v_egon.mdl";
		modelReplacements["models/w_egon.mdl"] = "models/hlclassic/w_egon.mdl";
		modelReplacements["models/p_gauss.mdl"] = "models/hlclassic/p_gauss.mdl";
		modelReplacements["models/v_gauss.mdl"] = "models/hlclassic/v_gauss.mdl";
		modelReplacements["models/w_gauss.mdl"] = "models/hlclassic/w_gauss.mdl";
		modelReplacements["models/p_grenade.mdl"] = "models/hlclassic/p_grenade.mdl";
		modelReplacements["models/v_grenade.mdl"] = "models/hlclassic/v_grenade.mdl";
		modelReplacements["models/w_grenade.mdl"] = "models/hlclassic/w_grenade.mdl";
		modelReplacements["models/p_hgun.mdl"] = "models/hlclassic/p_hgun.mdl";
		modelReplacements["models/v_HGun.mdl"] = "models/hlclassic/v_HGun.mdl";
		modelReplacements["models/w_hgun.mdl"] = "models/hlclassic/w_hgun.mdl";
		modelReplacements["models/p_medkit.mdl"] = "models/hlclassic/p_medkit.mdl";
		modelReplacements["models/v_medkit.mdl"] = "models/hlclassic/v_medkit.mdl";
		modelReplacements["models/w_medkit.mdl"] = "models/hlclassic/w_medkit.mdl";
		modelReplacements["models/p_rpg.mdl"] = "models/hlclassic/p_rpg.mdl";
		modelReplacements["models/v_rpg.mdl"] = "models/hlclassic/v_rpg.mdl";
		modelReplacements["models/w_rpg.mdl"] = "models/hlclassic/w_rpg.mdl";
		modelReplacements["models/p_satchel.mdl"] = "models/hlclassic/p_satchel.mdl";
		modelReplacements["models/v_satchel.mdl"] = "models/hlclassic/v_satchel.mdl";
		modelReplacements["models/w_satchel.mdl"] = "models/hlclassic/w_satchel.mdl";
		modelReplacements["models/p_satchel_radio.mdl"] = "models/hlclassic/p_satchel_radio.mdl";
		modelReplacements["models/v_satchel_radio.mdl"] = "models/hlclassic/v_satchel_radio.mdl";
		modelReplacements["models/p_shotgun.mdl"] = "models/hlclassic/p_shotgun.mdl";
		modelReplacements["models/v_shotgun.mdl"] = "models/hlclassic/v_shotgun.mdl";
		modelReplacements["models/w_shotgun.mdl"] = "models/hlclassic/w_shotgun.mdl";
		modelReplacements["models/p_squeak.mdl"] = "models/hlclassic/p_squeak.mdl";
		modelReplacements["models/v_squeak.mdl"] = "models/hlclassic/v_squeak.mdl";
		modelReplacements["models/w_sqknest.mdl"] = "models/hlclassic/w_sqknest.mdl";
		modelReplacements["models/p_tripmine.mdl"] = "models/hlclassic/p_tripmine.mdl";
		modelReplacements["models/v_tripmine.mdl"] = "models/hlclassic/v_tripmine.mdl";
		modelReplacements["models/w_tripmine.mdl"] = "models/hlclassic/w_tripmine.mdl";
		modelReplacements["models/agrunt.mdl"] = "models/hlclassic/agrunt.mdl";
		modelReplacements["models/apache.mdl"] = "models/hlclassic/apache.mdl";
		modelReplacements["models/barnacle.mdl"] = "models/hlclassic/barnacle.mdl";
		modelReplacements["models/barney.mdl"] = "models/hlclassic/barney.mdl";
		modelReplacements["models/bullsquid.mdl"] = "models/hlclassic/bullsquid.mdl";
		modelReplacements["models/garg.mdl"] = "models/hlclassic/garg.mdl";
		modelReplacements["models/gman.mdl"] = "models/hlclassic/gman.mdl";
		modelReplacements["models/grenade.mdl"] = "models/hlclassic/grenade.mdl";
		modelReplacements["models/hassassin.mdl"] = "models/hlclassic/hassassin.mdl";
		modelReplacements["models/headcrab.mdl"] = "models/hlclassic/headcrab.mdl";
		modelReplacements["models/hgrunt.mdl"] = "models/hlclassic/hgrunt.mdl";
		modelReplacements["models/holo.mdl"] = "models/hlclassic/holo.mdl";
		modelReplacements["models/houndeye.mdl"] = "models/hlclassic/houndeye.mdl";
		modelReplacements["models/icky.mdl"] = "models/hlclassic/icky.mdl";
		modelReplacements["models/islave.mdl"] = "models/hlclassic/islave.mdl";
		modelReplacements["models/osprey.mdl"] = "models/hlclassic/osprey.mdl";
		modelReplacements["models/osprey_bodygibs.mdl"] = "models/hlclassic/osprey_bodygibs.mdl";
		modelReplacements["models/osprey_enginegibs.mdl"] = "models/hlclassic/osprey_enginegibs.mdl";
		modelReplacements["models/osprey_tailgibs.mdl"] = "models/hlclassic/osprey_tailgibs.mdl";
		modelReplacements["models/player.mdl"] = "models/hlclassic/player.mdl";
		modelReplacements["models/roach.mdl"] = "models/hlclassic/roach.mdl";
		modelReplacements["models/rpgrocket.mdl"] = "models/hlclassic/rpgrocket.mdl";
		modelReplacements["models/scientist.mdl"] = "models/hlclassic/scientist.mdl";
		modelReplacements["models/scigun.mdl"] = "models/hlclassic/scigun.mdl";
		modelReplacements["models/shell.mdl"] = "models/hlclassic/shell.mdl";
		modelReplacements["models/shotgunshell.mdl"] = "models/hlclassic/shotgunshell.mdl";
		modelReplacements["models/tentacle2.mdl"] = "models/hlclassic/tentacle2.mdl";
		modelReplacements["models/w_357ammo.mdl"] = "models/hlclassic/w_357ammo.mdl";
		modelReplacements["models/w_357ammobox.mdl"] = "models/hlclassic/w_357ammobox.mdl";
		modelReplacements["models/w_9mmarclip.mdl"] = "models/hlclassic/w_9mmarclip.mdl";
		modelReplacements["models/w_9mmclip.mdl"] = "models/hlclassic/w_9mmclip.mdl";
		modelReplacements["models/w_argrenade.mdl"] = "models/hlclassic/w_argrenade.mdl";
		modelReplacements["models/w_battery.mdl"] = "models/hlclassic/w_battery.mdl";
		modelReplacements["models/w_chainammo.mdl"] = "models/hlclassic/w_chainammo.mdl";
		modelReplacements["models/w_crossbow_clip.mdl"] = "models/hlclassic/w_crossbow_clip.mdl";
		modelReplacements["models/w_gaussammo.mdl"] = "models/hlclassic/w_gaussammo.mdl";
		modelReplacements["models/w_longjump.mdl"] = "models/hlclassic/w_longjump.mdl";
		modelReplacements["models/w_pmedkit.mdl"] = "models/hlclassic/w_pmedkit.mdl";
		modelReplacements["models/w_rpgammo.mdl"] = "models/hlclassic/w_rpgammo.mdl";
		modelReplacements["models/w_shotbox.mdl"] = "models/hlclassic/w_shotbox.mdl";
		modelReplacements["models/w_shotshell.mdl"] = "models/hlclassic/w_shotshell.mdl";
		modelReplacements["models/w_squeak.mdl"] = "models/hlclassic/w_squeak.mdl";
		modelReplacements["models/w_suit.mdl"] = "models/hlclassic/w_suit.mdl";
		modelReplacements["models/w_tripmine.mdl"] = "models/hlclassic/w_tripmine.mdl";
		modelReplacements["models/w_weaponbox.mdl"] = "models/hlclassic/w_weaponbox.mdl";
		modelReplacements["models/zombie.mdl"] = "models/hlclassic/zombie.mdl";
		
		soundReplacements["monster_barney"] = "../AutoClassicMode/barney.txt";
		soundReplacements["monster_bodyguard"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_grunt_ally_repel"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_grunt_repel"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_human_assassin"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_human_grunt"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_human_grunt_ally"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_hwgrunt"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_hwgrunt_repel"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_male_assassin"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_robogrunt"] = "../AutoClassicMode/weapons.txt";
		soundReplacements["monster_robogrunt_repel"] = "../AutoClassicMode/weapons.txt";
		
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
		defaultWeaponModels["weapon_9mmAR"] = "9mmar";
		defaultWeaponModels["weapon_shotgun"] = "shotgun";
		defaultWeaponModels["weapon_crossbow"] = "crossbow";
		defaultWeaponModels["weapon_rpg"] = "rpg";
		defaultWeaponModels["weapon_gauss"] = "gauss";
		defaultWeaponModels["weapon_egon"] = "egon";
		defaultWeaponModels["weapon_handgrenade"] = "grenade";
		defaultWeaponModels["weapon_satchel"] = "satchel";
		defaultWeaponModels["weapon_tripmine"] = "tripmine";
		defaultWeaponModels["weapon_snark"] = "squeak";
		defaultWeaponModels["weapon_hornetgun"] = "hgun";
		
		classicItems["weapon_crowbar"] = "crowbar";
		classicItems["weapon_medkit"] = "medkit";
		classicItems["weapon_9mmhandgun"] = "9mmhandgun";
		classicItems["weapon_357"] = "357";
		classicItems["weapon_9mmAR"] = "9mmar";
		classicItems["weapon_shotgun"] = "shotgun";
		classicItems["weapon_crossbow"] = "crossbow";
		classicItems["weapon_rpg"] = "rpg";
		classicItems["weapon_gauss"] = "gauss";
		classicItems["weapon_egon"] = "egon";
		classicItems["weapon_handgrenade"] = "grenade";
		classicItems["weapon_hornetgun"] = "grenade";
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
		
		op4_weapons["weapon_9mmAR"] = true;
		op4_weapons["weapon_9mmhandgun"] = true;
		op4_weapons["weapon_357"] = true;
		op4_weapons["weapon_medkit"] = true;
		op4_weapons["weapon_shotgun"] = true;
		op4_weapons["weapon_crossbow"] = true;
		op4_weapons["weapon_rpg"] = true;
		op4_weapons["weapon_egon"] = true;
		op4_weapons["weapon_handgrenade"] = true;
		op4_weapons["weapon_satchel"] = true;
		op4_weapons["weapon_tripmine"] = true;
		op4_weapons["weapon_snark"] = true;
		op4_weapons["weapon_displacer"] = true;
		op4_weapons["weapon_eagle"] = true;
		op4_weapons["weapon_sniperrifle"] = true;
		op4_weapons["weapon_sporelauncher"] = true;
		op4_weapons["weapon_m249"] = true;
		op4_weapons["weapon_pipewrench"] = true;
		op4_weapons["weapon_minigun"] = true;
		
		bshift_weapons["weapon_9mmAR"] = true;
		bshift_weapons["weapon_9mmhandgun"] = true;
		bshift_weapons["weapon_357"] = true;
		bshift_weapons["weapon_crowbar"] = true;
		bshift_weapons["weapon_medkit"] = true;
		bshift_weapons["weapon_shotgun"] = true;
		bshift_weapons["weapon_crossbow"] = true;
		bshift_weapons["weapon_rpg"] = true;
		bshift_weapons["weapon_egon"] = true;
		bshift_weapons["weapon_handgrenade"] = true;
		bshift_weapons["weapon_satchel"] = true;
		bshift_weapons["weapon_tripmine"] = true;
		bshift_weapons["weapon_snark"] = true;
		
		bshift_force_replace["models/hlclassic/scientist.mdl"] = replacementModelPath + "bshift/scientist.mdl";
		bshift_force_replace["models/bshift/scientist.mdl"] = replacementModelPath + "bshift/scientist.mdl";
		bshift_force_replace["models/hlclassic/barney.mdl"] = replacementModelPath + "bshift/barney.mdl";
		bshift_force_replace["models/hlclassic/houndeye.mdl"] = replacementModelPath + "bshift/houndeye.mdl";
		bshift_force_replace["models/bshift/barney.mdl"] = replacementModelPath + "bshift/barney.mdl";
		bshift_force_replace["models/bshift/gordon_scientist.mdl"] = replacementModelPath + "bshift/gordon_scientist.mdl";
		bshift_force_replace["models/hlclassic/hgrunt.mdl"] = replacementModelPath + "bshift/hgrunt.mdl";
		bshift_force_replace["models/bshift/hgrunt.mdl"] = replacementModelPath + "bshift/hgrunt.mdl";
		bshift_force_replace["models/bshift/scientist_cower.mdl"] = replacementModelPath + "bshift/scientist_cower.mdl";
		bshift_force_replace["models/bshift/civ_coat_scientist.mdl"] = replacementModelPath + "bshift/civ_coat_scientist.mdl";
		bshift_force_replace["models/bshift/civ_paper_scientist.mdl"] = replacementModelPath + "bshift/civ_paper_scientist.mdl";
		bshift_force_replace["models/bshift/console_civ_scientist.mdl"] = replacementModelPath + "bshift/console_civ_scientist.mdl";
		bshift_force_replace["models/bshift/civ_scientist.mdl"] = replacementModelPath + "bshift/civ_scientist.mdl";
		bshift_force_replace["models/bshift/wrangler.mdl"] = replacementModelPath + "bshift/wrangler.mdl";
		bshift_force_replace["models/hlclassic/zombie.mdl"] = replacementModelPath + "bshift/zombie.mdl";
		bshift_force_replace["models/hlclassic/gman.mdl"] = "models/hlclassic/gman.mdl";
		
		classicFriendlies["monster_barney"] = replacementModelPath + "barnabus.mdl";
		classicFriendlies["monster_barney_dead"] = replacementModelPath + "barnabus.mdl";
		classicFriendlies["monster_human_grunt"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_hgrunt_dead"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_grunt_repel"] = replacementModelPath + "hgruntf.mdl";
		classicFriendlies["monster_human_assassin"] = replacementModelPath + "hassassinf.mdl";
		classicFriendlies["monster_alien_slave"] = replacementModelPath + "islavef.mdl";
		classicFriendlies["monster_alien_grunt"] = replacementModelPath + "agruntf.mdl";
		
		autoReplacements["models/hlclassic/agrunt.mdl"] = "models/agrunt.mdl";
		autoReplacements["models/hlclassic/apache.mdl"] = "models/apache.mdl";
		autoReplacements["models/hlclassic/barnacle.mdl"] = "models/barnacle.mdl";
		autoReplacements["models/hlclassic/barney.mdl"] = "models/barney.mdl";
		autoReplacements["models/hlclassic/bullsquid.mdl"] = "models/bullsquid.mdl";
		autoReplacements["models/hlclassic/garg.mdl"] = "models/garg.mdl";
		autoReplacements["models/hlclassic/gman.mdl"] = "models/gman.mdl";
		autoReplacements["models/hlclassic/grenade.mdl"] = "models/grenade.mdl";
		autoReplacements["models/hlclassic/hassassin.mdl"] = "models/hassassin.mdl";
		autoReplacements["models/hlclassic/headcrab.mdl"] = "models/headcrab.mdl";
		autoReplacements["models/hlclassic/hgrunt.mdl"] = "models/hgrunt.mdl";
		autoReplacements["models/hlclassic/holo.mdl"] = "models/holo.mdl";
		autoReplacements["models/hlclassic/houndeye.mdl"] = "models/houndeye.mdl";
		autoReplacements["models/hlclassic/icky.mdl"] = "models/icky.mdl";
		autoReplacements["models/hlclassic/islave.mdl"] = "models/islave.mdl";
		autoReplacements["models/hlclassic/osprey.mdl"] = "models/osprey.mdl";
		autoReplacements["models/hlclassic/osprey_bodygibs.mdl"] = "models/osprey_bodygibs.mdl";
		autoReplacements["models/hlclassic/osprey_enginegibs.mdl"] = "models/osprey_enginegibs.mdl";
		autoReplacements["models/hlclassic/osprey_tailgibs.mdl"] = "models/osprey_tailgibs.mdl";
		autoReplacements["models/hlclassic/player.mdl"] = "models/player.mdl";
		autoReplacements["models/hlclassic/p_357.mdl"] = "models/p_357.mdl";
		autoReplacements["models/hlclassic/p_9mmar.mdl"] = "models/p_9mmar.mdl";
		autoReplacements["models/hlclassic/p_9mmhandgun.mdl"] = "models/p_9mmhandgun.mdl";
		autoReplacements["models/hlclassic/p_crossbow.mdl"] = "models/p_crossbow.mdl";
		autoReplacements["models/hlclassic/p_crowbar.mdl"] = "models/p_crowbar.mdl";
		autoReplacements["models/hlclassic/p_egon.mdl"] = "models/p_egon.mdl";
		autoReplacements["models/hlclassic/p_gauss.mdl"] = "models/p_gauss.mdl";
		autoReplacements["models/hlclassic/p_glock.mdl"] = "models/p_glock.mdl";
		autoReplacements["models/hlclassic/p_grenade.mdl"] = "models/p_grenade.mdl";
		autoReplacements["models/hlclassic/p_hgun.mdl"] = "models/p_hgun.mdl";
		autoReplacements["models/hlclassic/p_medkit.mdl"] = "models/p_medkit.mdl";
		autoReplacements["models/hlclassic/p_rpg.mdl"] = "models/p_rpg.mdl";
		autoReplacements["models/hlclassic/p_satchel.mdl"] = "models/p_satchel.mdl";
		autoReplacements["models/hlclassic/p_satchel_radio.mdl"] = "models/p_satchel_radio.mdl";
		autoReplacements["models/hlclassic/p_shotgun.mdl"] = "models/p_shotgun.mdl";
		autoReplacements["models/hlclassic/p_squeak.mdl"] = "models/p_squeak.mdl";
		autoReplacements["models/hlclassic/p_tripmine.mdl"] = "models/p_tripmine.mdl";
		autoReplacements["models/hlclassic/roach.mdl"] = "models/roach.mdl";
		autoReplacements["models/hlclassic/rpgrocket.mdl"] = "models/rpgrocket.mdl";
		autoReplacements["models/hlclassic/scientist.mdl"] = "models/scientist.mdl";
		autoReplacements["models/hlclassic/scigun.mdl"] = "models/scigun.mdl";
		autoReplacements["models/hlclassic/shell.mdl"] = "models/shell.mdl";
		autoReplacements["models/hlclassic/shotgunshell.mdl"] = "models/shotgunshell.mdl";
		autoReplacements["models/hlclassic/tentacle2.mdl"] = "models/tentacle2.mdl";
		autoReplacements["models/hlclassic/v_357.mdl"] = "models/v_357.mdl";
		autoReplacements["models/hlclassic/v_9mmAR.mdl"] = "models/v_9mmAR.mdl";
		autoReplacements["models/hlclassic/v_9mmhandgun.mdl"] = "models/v_9mmhandgun.mdl";
		autoReplacements["models/hlclassic/v_crossbow.mdl"] = "models/v_crossbow.mdl";
		autoReplacements["models/hlclassic/v_crowbar.mdl"] = "models/v_crowbar.mdl";
		autoReplacements["models/hlclassic/v_egon.mdl"] = "models/v_egon.mdl";
		autoReplacements["models/hlclassic/v_gauss.mdl"] = "models/v_gauss.mdl";
		autoReplacements["models/hlclassic/v_grenade.mdl"] = "models/v_grenade.mdl";
		autoReplacements["models/hlclassic/v_HGun.mdl"] = "models/v_HGun.mdl";
		autoReplacements["models/hlclassic/v_medkit.mdl"] = "models/v_medkit.mdl";
		autoReplacements["models/hlclassic/v_rpg.mdl"] = "models/v_rpg.mdl";
		autoReplacements["models/hlclassic/v_satchel.mdl"] = "models/v_satchel.mdl";
		autoReplacements["models/hlclassic/v_satchel_radio.mdl"] = "models/v_satchel_radio.mdl";
		autoReplacements["models/hlclassic/v_shotgun.mdl"] = "models/v_shotgun.mdl";
		autoReplacements["models/hlclassic/v_squeak.mdl"] = "models/v_squeak.mdl";
		autoReplacements["models/hlclassic/v_tripmine.mdl"] = "models/v_tripmine.mdl";
		autoReplacements["models/hlclassic/w_357.mdl"] = "models/w_357.mdl";
		autoReplacements["models/hlclassic/w_357ammo.mdl"] = "models/w_357ammo.mdl";
		autoReplacements["models/hlclassic/w_357ammobox.mdl"] = "models/w_357ammobox.mdl";
		autoReplacements["models/hlclassic/w_9mmar.mdl"] = "models/w_9mmar.mdl";
		autoReplacements["models/hlclassic/w_9mmarclip.mdl"] = "models/w_9mmarclip.mdl";
		autoReplacements["models/hlclassic/w_9mmclip.mdl"] = "models/w_9mmclip.mdl";
		autoReplacements["models/hlclassic/w_9mmhandgun.mdl"] = "models/w_9mmhandgun.mdl";
		autoReplacements["models/hlclassic/w_argrenade.mdl"] = "models/w_argrenade.mdl";
		autoReplacements["models/hlclassic/w_battery.mdl"] = "models/w_battery.mdl";
		autoReplacements["models/hlclassic/w_chainammo.mdl"] = "models/w_chainammo.mdl";
		autoReplacements["models/hlclassic/w_crossbow.mdl"] = "models/w_crossbow.mdl";
		autoReplacements["models/hlclassic/w_crossbow_clip.mdl"] = "models/w_crossbow_clip.mdl";
		autoReplacements["models/hlclassic/w_crowbar.mdl"] = "models/w_crowbar.mdl";
		autoReplacements["models/hlclassic/w_egon.mdl"] = "models/w_egon.mdl";
		autoReplacements["models/hlclassic/w_gauss.mdl"] = "models/w_gauss.mdl";
		autoReplacements["models/hlclassic/w_gaussammo.mdl"] = "models/w_gaussammo.mdl";
		autoReplacements["models/hlclassic/w_grenade.mdl"] = "models/w_grenade.mdl";
		autoReplacements["models/hlclassic/w_hgun.mdl"] = "models/w_hgun.mdl";
		autoReplacements["models/hlclassic/w_longjump.mdl"] = "models/w_longjump.mdl";
		autoReplacements["models/hlclassic/w_medkit.mdl"] = "models/w_medkit.mdl";
		autoReplacements["models/hlclassic/w_pmedkit.mdl"] = "models/w_pmedkit.mdl";
		autoReplacements["models/hlclassic/w_rpg.mdl"] = "models/w_rpg.mdl";
		autoReplacements["models/hlclassic/w_rpgammo.mdl"] = "models/w_rpgammo.mdl";
		autoReplacements["models/hlclassic/w_satchel.mdl"] = "models/w_satchel.mdl";
		autoReplacements["models/hlclassic/w_shotbox.mdl"] = "models/w_shotbox.mdl";
		autoReplacements["models/hlclassic/w_shotgun.mdl"] = "models/w_shotgun.mdl";
		autoReplacements["models/hlclassic/w_shotshell.mdl"] = "models/w_shotshell.mdl";
		autoReplacements["models/hlclassic/w_sqknest.mdl"] = "models/w_sqknest.mdl";
		autoReplacements["models/hlclassic/w_squeak.mdl"] = "models/w_squeak.mdl";
		autoReplacements["models/hlclassic/w_suit.mdl"] = "models/w_suit.mdl";
		autoReplacements["models/hlclassic/w_tripmine.mdl"] = "models/w_tripmine.mdl";
		autoReplacements["models/hlclassic/w_weaponbox.mdl"] = "models/w_weaponbox.mdl";
		autoReplacements["models/hlclassic/zombie.mdl"] = "models/zombie.mdl";
		
		autoReplacementMonsters["monster_agrunt"] = true;
		autoReplacementMonsters["monster_apache"] = true;
		autoReplacementMonsters["monster_barnacle"] = true;
		autoReplacementMonsters["monster_barney"] = true;
		autoReplacementMonsters["monster_bullsquid"] = true;
		autoReplacementMonsters["monster_gargantua"] = true;
		autoReplacementMonsters["monster_gman"] = true;
		autoReplacementMonsters["monster_human_assassin"] = true;
		autoReplacementMonsters["monster_headcrab"] = true;
		autoReplacementMonsters["monster_human_grunt"] = true;
		autoReplacementMonsters["monster_human_grunt"] = true;
		autoReplacementMonsters["monster_houndeye"] = true;
		autoReplacementMonsters["monster_ichthyosaur"] = true;
		autoReplacementMonsters["monster_alien_slave"] = true;
		autoReplacementMonsters["monster_osprey"] = true;
		autoReplacementMonsters["monster_cockroach"] = true;
		autoReplacementMonsters["monster_scientist"] = true;
		autoReplacementMonsters["monster_sitting_scientist"] = true;
		autoReplacementMonsters["monster_tentacle"] = true;
		autoReplacementMonsters["monster_zombie"] = true;

		array<string> keys = modelReplacements.getKeys();
		for (uint i = 0; i < keys.size(); i++)
		{
			string replacement;
			modelReplacements.get(keys[i], replacement);
			g_Game.PrecacheModel(replacement);
		}
			
		keys = autoReplacements.getKeys();
		for (uint i = 0; i < keys.size(); i++)
		{
			string model;
			autoReplacements.get(keys[i], model);			
			g_Game.PrecacheModel(model);
		}
		
		if (mapType != MAP_HALF_LIFE)
		{
			dictionary weps = op4_weapons;
			string subfolder = "op4/";
			if (mapType == MAP_BLUE_SHIFT)
			{
				subfolder = "bshift/";
				weps = bshift_weapons;
				force_replace = bshift_force_replace;
				
				g_Game.PrecacheModel("models/AutoClassicMode/bshift/v_satchel_radio.mdl");
			}
			if (mapType == MAP_OPPOSING_FORCE)
			{
				g_Game.PrecacheModel("models/AutoClassicMode/op4/v_satchel_radio.mdl");
			}
				
			keys = weps.getKeys();
			for (uint i = 0; i < keys.size(); i++)
			{				
				string defaultModelName;
				defaultWeaponModels.get(keys[i], defaultModelName);
				string vmodel = replacementModelPath + subfolder + "v_" + defaultModelName + ".mdl";
				g_Game.PrecacheModel(vmodel);
			}
			
			keys = force_replace.getKeys();
			for (uint i = 0; i < keys.size(); i++)
			{				
				string replacement;
				force_replace.get(keys[i], replacement);
				g_Game.PrecacheModel(replacement);
			}
		}
		
		g_Game.PrecacheModel(replacementSpritePath + "640hud1.spr");
		g_Game.PrecacheModel(replacementSpritePath + "640hud4.spr");
		g_Game.PrecacheGeneric(replacementSpritePath + "weapon_9mmar.txt");
		
		// somehow the built-in classic mode prevents these models from precaching, even if there is a monster_ entity for it.
		// There's no way to know if this is going to spawn from a squadmaker or something, so better just always precache it.
		g_Game.PrecacheModel("models/blkop_apache.mdl");
		g_Game.PrecacheModel("models/w_shock.mdl");
		
		// precache weapon sound replacements for monsters
		PrecacheSound(replacementSoundPath + "sniper_fire.wav");
		PrecacheSound(replacementSoundPath + "uzi_fire_both1.wav");
		PrecacheSound(replacementSoundPath + "uzi_fire_both2.wav");
		PrecacheSound("hlclassic/hgrunt/gr_mgun1.wav");
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
				println("Undoing model replacement: " + mon.pev.model + " --> " + originalModel);
				int idx = g_Game.PrecacheModel(originalModel);

				int oldBody = mon.pev.body;
				Vector mins = mon.pev.mins;
				Vector maxs = mon.pev.maxs;
				g_EntityFuncs.SetModel(mon, originalModel);
				g_EntityFuncs.SetSize(mon.pev, mins, maxs);
				mon.pev.body = oldBody;
				
				if (mapType == MAP_OPPOSING_FORCE)
				{
					// of1a5 scientist has broken neck without this. No idea what the proper way to fix this is,
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
			bool isBarney = int(cname.Find("barney")) != -1;
		
			string replacement;
			if (should_force_replace)
			{
				force_replace.get(mon.pev.model, replacement);
				if (mapType == MAP_BLUE_SHIFT and cname == "monster_scientist_dead")
					mon.pev.sequence += 1; // TODO: edit the model you lazy fuck
			}
			else
			{
				if (classicFriendlies.exists(cname))
				{
					if ((isBarney and mon.IRelationshipByClass(CLASS_PLAYER) > R_NO) or
						(!isBarney and mon.IRelationshipByClass(CLASS_PLAYER) < R_NO))
						classicFriendlies.get(mon.pev.classname, replacement);
					else if (isGrunt and !isDead)
						modelReplacements.get(model, replacement); // still want to replace the default model since its missing anims
					else
						return; // classic mode already replaced the model
				}
				else
					modelReplacements.get(model, replacement);
			}
			
			
			// update body groups
			int newBody = 0;
			int mdlIndex = g_ModelFuncs.ModelIndex(replacement);
			for (int i = 0; i < 8; i++)
				newBody |= g_ModelFuncs.SetBodygroup(mdlIndex, newBody, i, mon.GetBodygroup(i));
			
			if (mon.pev.classname == "monster_human_grunt") // grunt uses diff bodys for things, but somehow works without scripts
			{
				if (mon.pev.weapons & 1 != 0)
					newBody |= g_ModelFuncs.SetBodygroup( mdlIndex, newBody, 2, 4); // mp5
				if (mon.pev.weapons & 64 != 0)
					newBody |= g_ModelFuncs.SetBodygroup( mdlIndex, newBody, 2, 3); // rpg
				if (mon.pev.weapons & 128 != 0)
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
			println("AutoClassicMode(f): Replacing " + ent.pev.model + " -> " + replacement);
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
					println("Undoing model replacement for " + originalModel);
					int idx = g_Game.PrecacheModel(originalModel);
					g_EntityFuncs.SetModel(ent, originalModel);
				}
			}
			if (modelReplacements.exists(ent.pev.model))
			{
				string replacement;
				modelReplacements.get(ent.pev.model, replacement);				
				println("AutoClassicMode(g): Replacing " + ent.pev.model + " -> " + replacement);
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
			println("Failed to load default weapon models for " + cname);
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
		
		bool shouldForceThemedWeapon = false;
		if (mapType != MAP_HALF_LIFE)
		{
			dictionary weps = op4_weapons;
			if (mapType == MAP_BLUE_SHIFT)
				weps = bshift_weapons;
			
			shouldForceThemedWeapon = weps.exists(cname);
		}
		
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
		
		println("Replacement models are " + vmodel + " " + pmodel + " " +  wmodel);
		
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
		if (activeWep.entindex() == wep.entindex())
		{
			if (vmodel.Length() > 0)
				plr.pev.viewmodel = vmodel;
			if (pmodel.Length() > 0)
				plr.pev.weaponmodel = pmodel;
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
				wep.KeyValue("CustomSpriteDir", "AutoClassicMode");
			g_Scheduler.SetTimeout("ProcessWeapon", 0, EHandle(ent));
			return HOOK_CONTINUE;
		}
		
		g_Scheduler.SetTimeout("ProcessGeneric", 0, EHandle(ent));
		
		return HOOK_CONTINUE;
	}
	
	void MapInit(CBaseEntity@ caller, CBaseEntity@ activator, USE_TYPE useType, float value)
	{
		g_Hooks.RegisterHook( Hooks::Game::EntityCreated, @EntityCreated );
		
		int mapInfo = caller.pev.rendermode;
		isClassicMap = mapInfo & 1 != 0;
		mapType = mapInfo >> 1;
		
		println("MAP SETTINGS " + isClassicMap + " " + mapType);
		
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
			g_ClassicMode.SetEnabled(isClassicMap);
			g_EngineFuncs.ChangeLevel(g_Engine.mapname);
			return;
		}
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
							if (int(string(plr.pev.weaponmodel).Find("AutoClassicMode")) != -1)
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