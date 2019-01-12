
namespace ClassicModeDeluxe {

	void PrecacheSound(string snd)
	{
		g_SoundSystem.PrecacheSound(snd);
		g_Game.PrecacheGeneric("sound/" + snd);
	}

	void loadBlacklist()
	{
		string fpath = "scripts/maps/ClassicModeDeluxe/gmr/" + string(g_Engine.mapname).ToLowercase() + ".txt";
		File@ f = g_FileSystem.OpenFile( fpath, OpenFile::READ );
		if( f is null or !f.IsOpen())
		{
			println("ClassicModeDeluxe: Model blacklist not found: " + fpath);
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
		println("ClassicModeDeluxe: Loaded model replacement blacklist");
	}

	void initReplacements()
	{
		modelReplacements["models/otis.mdl"] = "models/dxclassic/otis.mdl";
		modelReplacements["models/otisf.mdl"] = "models/dxclassic/otisf.mdl";
		modelReplacements["models/zombie_barney.mdl"] = "models/dxclassic/zombie_barney.mdl";
		modelReplacements["models/zombie_soldier.mdl"] = "models/dxclassic/zombie_soldier.mdl";
		modelReplacements["models/hgrunt_medic.mdl"] = "models/dxclassic/hgrunt_medic.mdl";
		modelReplacements["models/hgrunt_medicf.mdl"] = "models/dxclassic/hgrunt_medicf.mdl";
		modelReplacements["models/hgrunt_opfor.mdl"] = "models/dxclassic/hgrunt_opfor.mdl";
		modelReplacements["models/hgrunt_opforf.mdl"] = "models/dxclassic/hgrunt_opforf.mdl";
		modelReplacements["models/hgrunt_torch.mdl"] = "models/dxclassic/hgrunt_torch.mdl";
		modelReplacements["models/hgrunt_torchf.mdl"] = "models/dxclassic/hgrunt_torchf.mdl";
		modelReplacements["models/massn.mdl"] = "models/dxclassic/massn.mdl";
		modelReplacements["models/massnf.mdl"] = "models/dxclassic/massnf.mdl";
		modelReplacements["models/rgrunt.mdl"] = "models/dxclassic/rgrunt.mdl";
		modelReplacements["models/rgruntf.mdl"] = "models/dxclassic/rgruntf.mdl";
		modelReplacements["models/hwgrunt.mdl"] = "models/dxclassic/hwgrunt.mdl";
		modelReplacements["models/hwgruntf.mdl"] = "models/dxclassic/hwgruntf.mdl";
		modelReplacements["models/osprey.mdl"] = "models/dxclassic/osprey.mdl";
		modelReplacements["models/osprey2.mdl"] = "models/dxclassic/osprey2.mdl";
		modelReplacements["models/ospreyf.mdl"] = "models/dxclassic/ospreyf.mdl";
		modelReplacements["models/blkop_apache.mdl"] = "models/dxclassic/blkop_apache.mdl";
		modelReplacements["models/blkop_osprey.mdl"] = "models/dxclassic/blkop_osprey.mdl";
		modelReplacements["models/apachef.mdl"] = "models/dxclassic/apachef.mdl";
		modelReplacements["models/agruntf.mdl"] = "models/dxclassic/agruntf.mdl";
		modelReplacements["models/strooper.mdl"] = "models/dxclassic/strooper.mdl";
		modelReplacements["models/bgman.mdl"] = "models/dxclassic/bgman.mdl";
		modelReplacements["models/w_shock_rifle.mdl"] = "models/dxclassic/w_shock_rifle.mdl";
		modelReplacements["models/barnabus.mdl"] = "models/dxclassic/barnabus.mdl";
		modelReplacements["models/hassassinf.mdl"] = "models/dxclassic/hassassinf.mdl";
		modelReplacements["models/hgruntf.mdl"] = "models/dxclassic/hgruntf.mdl";
		modelReplacements["models/islavef.mdl"] = "models/dxclassic/islavef.mdl";
		modelReplacements["models/player.mdl"] = "models/dxclassic/player.mdl";
		modelReplacements["models/gonome.mdl"] = "models/dxclassic/gonome.mdl";
		modelReplacements["models/tor.mdl"] = "models/dxclassic/tor.mdl";
		modelReplacements["models/Torf.mdl"] = "models/dxclassic/Torf.mdl";
		modelReplacements["models/hgrunt.mdl"] = "models/dxclassic/hgrunt.mdl";
		modelReplacements["models/hlclassic/barney.mdl"] = "models/hlclassic/barney.mdl";
		modelReplacements["models/hlclassic/hgrunt.mdl"] = "models/dxclassic/hgrunt.mdl"; // the vanilla classic grunt is missing rpg anims
		modelReplacements["models/hlclassic/hassassin.mdl"] = "models/hlclassic/hassassin.mdl";
		modelReplacements["models/hlclassic/islave.mdl"] = "models/hlclassic/islave.mdl";
		modelReplacements["models/hlclassic/agrunt.mdl"] = "models/hlclassic/agrunt.mdl";
		
		modelReplacements["models/v_saw.mdl"] = "models/dxclassic/v_saw.mdl";
		modelReplacements["models/p_saw.mdl"] = "models/dxclassic/p_saw.mdl";
		modelReplacements["models/w_saw.mdl"] = "models/dxclassic/w_saw.mdl";
		modelReplacements["models/v_m40a1.mdl"] = "models/dxclassic/v_m40a1.mdl";
		modelReplacements["models/p_m40a1.mdl"] = "models/dxclassic/p_m40a1.mdl";
		modelReplacements["models/w_m40a1.mdl"] = "models/dxclassic/w_m40a1.mdl";
		modelReplacements["models/v_spore_launcher.mdl"] = "models/dxclassic/v_spore_launcher.mdl";
		modelReplacements["models/p_spore_launcher.mdl"] = "models/dxclassic/p_spore_launcher.mdl";
		modelReplacements["models/w_spore_launcher.mdl"] = "models/dxclassic/w_spore_launcher.mdl";
		modelReplacements["models/v_displacer.mdl"] = "models/dxclassic/v_displacer.mdl";
		modelReplacements["models/p_displacer.mdl"] = "models/dxclassic/p_displacer.mdl";
		modelReplacements["models/w_displacer.mdl"] = "models/dxclassic/w_displacer.mdl";
		modelReplacements["models/w_pipe_wrench.mdl"] = "models/dxclassic/w_pipe_wrench.mdl";
		modelReplacements["models/v_pipe_wrench.mdl"] = "models/dxclassic/v_pipe_wrench.mdl";
		modelReplacements["models/p_pipe_wrench.mdl"] = "models/dxclassic/p_pipe_wrench.mdl";
		// TODO: dual and golden uzi models don't work (except for view model)
		modelReplacements["models/v_uzi.mdl"] = "models/dxclassic/v_uzi.mdl";
		modelReplacements["models/p_uzi.mdl"] = "models/dxclassic/p_uzi.mdl";
		modelReplacements["models/w_uzi.mdl"] = "models/dxclassic/w_uzi.mdl";
		//modelReplacements["models/w_2uzis.mdl"] = "models/dxclassic/w_2uzis.mdl";
		modelReplacements["models/p_2uzis.mdl"] = "models/dxclassic/p_2uzis.mdl";
		modelReplacements["models/p_uzi_gold.mdl"] = "models/dxclassic/p_uzi_gold.mdl";
		modelReplacements["models/w_uzi_gold.mdl"] = "models/dxclassic/w_uzi_gold.mdl";
		modelReplacements["models/p_2uzis_gold.mdl"] = "models/dxclassic/p_2uzis_gold.mdl";
		//modelReplacements["models/w_2uzis_gold.mdl"] = "models/dxclassic/w_2uzis_gold.mdl";
		modelReplacements["models/v_minigun.mdl"] = "models/dxclassic/v_minigun.mdl";
		modelReplacements["models/p_minigunidle.mdl"] = "models/dxclassic/p_minigunidle.mdl";
		modelReplacements["models/p_minigunspin.mdl"] = "models/dxclassic/p_minigunspin.mdl";
		modelReplacements["models/w_minigun.mdl"] = "models/dxclassic/w_minigun.mdl";
		modelReplacements["models/v_desert_eagle.mdl"] = "models/dxclassic/v_desert_eagle.mdl";
		modelReplacements["models/w_desert_eagle.mdl"] = "models/dxclassic/w_desert_eagle.mdl";
		modelReplacements["models/p_desert_eagle.mdl"] = "models/dxclassic/p_desert_eagle.mdl";
		modelReplacements["models/v_bgrap.mdl"] = "models/dxclassic/v_bgrap.mdl";
		modelReplacements["models/p_bgrap.mdl"] = "models/dxclassic/p_bgrap.mdl";
		modelReplacements["models/w_bgrap.mdl"] = "models/dxclassic/w_bgrap.mdl";
		modelReplacements["models/v_shock.mdl"] = "models/dxclassic/v_shock.mdl";
		modelReplacements["models/p_shock.mdl"] = "models/dxclassic/p_shock.mdl";
		modelReplacements["models/w_uzi_clip.mdl"] = "models/dxclassic/w_uzi_clip.mdl";
		modelReplacements["models/w_saw_clip.mdl"] = "models/dxclassic/w_saw_clip.mdl";
		modelReplacements["models/w_m40a1clip.mdl"] = "models/dxclassic/w_m40a1clip.mdl";
		
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
		
		soundReplacements["monster_barney"] = "../dxclassic/barney.txt";
		soundReplacements["monster_bodyguard"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_grunt_ally_repel"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_grunt_repel"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_human_assassin"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_human_grunt"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_human_grunt_ally"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_hwgrunt"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_hwgrunt_repel"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_male_assassin"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_robogrunt"] = "../dxclassic/weapons.txt";
		soundReplacements["monster_robogrunt_repel"] = "../dxclassic/weapons.txt";
		
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
		
		// sven's opfor zombie has a broken head hitbox
		op4_force_replace["models/opfor/zombie_soldier.mdl"] = replacementModelPath + "zombie_soldier.mdl";
		
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
			string subfolder;
			if (mapType == MAP_BLUE_SHIFT)
			{
				subfolder = "bshift/";
				weps = bshift_weapons;
				force_replace = bshift_force_replace;
				
				g_Game.PrecacheModel("models/dxclassic/bshift/v_satchel_radio.mdl");
			}
			if (mapType == MAP_OPPOSING_FORCE)
			{
				subfolder = "op4/";
				force_replace = op4_force_replace;
				g_Game.PrecacheModel("models/dxclassic/op4/v_satchel_radio.mdl");
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
		
		// always precache submodels or else clients crash when the parent model is used
		// TODO: recompile without submodels
		g_Game.PrecacheGeneric("models/dxclassic/agruntf01.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/agruntfT.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/apacheft.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/blkop_apachet.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/blkop_ospreyt.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/hassassinfT.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/hgrunt_medicf01.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/hgrunt_torch01.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/hgrunt_torch02.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/hgrunt_torchf01.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/hgrunt_torchf02.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/islavef01.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/islavef02.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/islavefT.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/ospreyfT.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/ospreyt.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/playert.mdl");
		g_Game.PrecacheGeneric("models/dxclassic/w_uzi_clipT.mdl");
		
		// somehow the built-in classic mode prevents these models from precaching, even if there is a monster_ entity for it.
		// There's no way to know if this is going to spawn from a squadmaker or something, so better just always precache it.
		g_Game.PrecacheModel("models/blkop_apache.mdl");
		g_Game.PrecacheModel("models/w_shock.mdl");
		
		// precache weapon sound replacements for monsters
		PrecacheSound(replacementSoundPath + "sniper_fire.wav");
		PrecacheSound(replacementSoundPath + "sniper_bolt1.wav");
		PrecacheSound(replacementSoundPath + "sniper_reload_first_seq.wav");
		PrecacheSound(replacementSoundPath + "uzi_fire_both1.wav");
		PrecacheSound(replacementSoundPath + "uzi_fire_both2.wav");
		PrecacheSound("hlclassic/hgrunt/gr_mgun1.wav");
	}
}