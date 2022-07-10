# Unreal Release Notes

## General Information

### Official Unreal Tournament Web Sites

* [Epic Games Home Page](https://epicgames.com)
* [Unreal Engine Technology Page](https://www.unrealengine.com)

### Independent Unreal Tournament Web Sites

* [OldUnreal](https://www.oldunreal.com)

## Unreal Version 227k Release Notes (Coming Soon!)

### GUI
* Fixed LadderFonts.utx

### Maps

* DmBeyondTheSun: Sky fix applied by Shivaxi.
* EntryIII:
    * Other texture and bsp changes.
    * Patrolling Brute removed.
    * Mercenary and Brute sounds removed and set them to ignore.
    * Level origin point (0,0,0) moved inside of the level.
    * Applied code update by Marco.

### Localization

* Overall:
    * All device names shortened to just their names (e.g. "Support for OpenAL 3D" -> "OpenAL 3D").
    * Crashsite2.\*: Subtitles synchronized across all languages.
    * D3DDrv.\*: Now unavailable for Win64.
    * D3D9Drv.\*: The renderer can now be selected in UnrealEd.
    * DmStomp.\*: Fixed Title.
    * Editor.\*: By consensus (sigh), the Commandlets will be left untranslated.
    * Engine.\*:
        * "Standard Console" now has a short name for the Classic Menu.
    * Console name renamed: "Standard Unreal Console" -> "Standard (Deprecated)"
    * SetupUnrealPatch.\*: Removed UED version number.
    * UBrowser.\*: Console name renamed: "Unreal Browser Console" -> "Classic Menu"
    * UMenu.\*:
        * Inverted Mouse now has a proper description (inverts the Y axis rather than X axis).
        * Tweaked descriptions of HUD Scaling, Specular Lights, Sky Fogging, Lightmap LOD and Shadow Draw Distance.
        * Changed in Shadow Draw Distance: "Low" -> "Short"
        * New Game Menu: Improved message that shows whenever Extreme/Nightmare/Ultra-UNREAL are chosen as difficulty settings.
        * Console name renamed: "UMenu Browser Console" -> "UMenu (Windows-Like)"
        * "Console" -> "Menu Design"
    * UnrealShare.\*:
        * Unreal logo missed from the Unreal campaign.
        * Tweaked descriptions of HUD Scaling and Sky Fogging.
        * "Console" -> "Menu Design"
    * UPak.\*: Console name renamed: "Unreal Gold Console" -> "Unreal Gold (Deprecated)"
* French: OldWeapons' strings synced with UnrealI and UnrealShare.
* Spanish:
    * Localized Viewport in SDL2Drv.est and WinDrv.est.
    * Localized untranslated LevelEnterText in SkyTown.est.
    * Removed "Video" portion from XMesaGLDrv.est's name.
    * Minor fixes to Startup.est and UMenu.est.
    * All instances of "You got/picked up..." got streamlined into "Has recogido..."
* Polish:
    * Engine.plt: Replaced fonts.
    * Small corrections to Dark.plt, UGCredits.plt, UMenu.plt and UnrealShare.plt. (Thanks, yrex!)
* Portuguese: Full revision of the language by BIr4.
* Russian: (Thanks to Reborn for noting the changes)
    * Engine.rut: Replaced fonts.
    * UMenu.rut: Better lines, enlarged area in [UMenuOptionsWindow].
    * UnrealShare.rut: Better lines for Controls menu.
* Dutch: Implemented fixes to Core.nlt, Engine.nlt and UMenu.nlt by Hyper<NL> on the forums.

## Old Release Notes

The release notes for older patches released by Epic and UTPG can be found in the Help/ReleaseNotes.htm file which is included in the patch.
