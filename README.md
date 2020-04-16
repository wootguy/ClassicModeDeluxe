# Classic Mode Deluxe

Classic Mode was one of my favorite additions to 5.x, but I was bummed it could only be enabled in the campaign maps. This script enables Classic Mode support for _all_ maps, and adds the following features:

- Classic models and sounds for all monsters and weapons.
- Automatically enables on maps that were designed for Sven Co-op 3.0 and earlier. **1719 of 2275 known maps are classic maps - roughly 75% of everything ever made.**
- Skill settings from Half-Life and Sven Co-op 3.0.
- Faster movement speed from the original games.
- Player armor works the same as in Half-Life.


Most of the models are from the latest [LD Pack](https://forums.svencoop.com/showthread.php/44491-Working-on-a-LD-pack-of-my-own), although I edited some monsters and weapons.

# CVars
```
as_command cm.mode -1
as_command cm.skill 1
as_command cm.fastmove 1
```
`cm.mode` controls when classic mode should be enabled.  
- 0 = Never
- 1 = Always
- -1 = Automatic (enabled for maps listed in `scripts/plugins/ClassicModeDeluxe/classic_maps.txt`)  

`cm.skill` controls which skill settings to use.  
- 0 = Don't change any skill settings
- 1 = Sven Co-op 3.0 (skill 2)
- 2 = Half-Life (skill 3)  

`cm.fastmove` enables Half-Life movement speed in maps configured to use the default speed.

# Chat Commands

`.cm` = Show current mode.  
`.cm on/off/auto` = Set classic mode. Changes take effect on the next map change.  
`.cm version` = Show script version

# Known issues

- Due to limitations in the game and scripting, not everything can be replaced with a classic version:
  - Player uzi shoot sound
  - Player sniper shoot sound
  - Footstep sounds
  - Muzzle flashes (requires GMR - not available in scripts)
  - Uzi/Saw bullet casings (requires GMR - not available in scripts)
  - Golden uzi third-person model
  - Health/Ammo HUD
- Some grunts/assassins still fire their shotguns/mp5s full-auto.
- Custom soundlists for the HL grunt are ignored. AS can't get soundlist keyvalues to fix that. I don't think any classic map has given grunts custom sounds though.

Let me know if any maps should be added to classic_maps.txt. Some maps made after 4.0 might have been designed for 3.0 and released later. I tried to capture some of those.

# Installation


- Add this to default_plugins.txt:
```
	"plugin"
	{
		"name" "ClassicModeDeluxe"
		"script" "ClassicModeDeluxe/ClassicModeDeluxe"
		"concommandns" "cm"
	}
```

- Extract the archive to svencoop_addon. **If you have a custom version of default_map_settings.cfg, then don't extract mine. Instead, add this line to yours:**  
`map_script ClassicModeDeluxe/ClassicModeDeluxe`
