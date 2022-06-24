[Setup]
LocalProduct="Unreal Gold"
DefaultFolder="C:\Program Files (x86)\UnrealGold"
ReadMe="Help\227ReleaseNotes.pdf"
; EN: SetupWindowTitle="Unreal Gold Setup"
SetupWindowTitle="Installation d'Unreal Gold"
; EN: AutoplayWindowTitle="Unreal Gold Options"
AutoplayWindowTitle="Options d'Unreal Gold"
ProductURL="https://www.oldunreal.com/"
VersionURL="https://www.oldunreal.com"
; EN: Developer="Epic Games, Inc. - 227 by Oldunreal"
Developer="Epic Games, Inc. - 227 par Oldunreal"
DeveloperURL="https://www.oldunreal.com/"
Logo="Help\Logo.bmp"

[UnrealRequirement]
LocalProduct="Unreal Gold"
ProductURL="https://www.epicgames.com/"
VersionURL="https://www.epicgames.com/"
; EN: Developer="Epic Games, Inc. - 227 by Oldunreal"
Developer="Epic Games, Inc. - 227 par Oldunreal"
DeveloperURL="https://www.oldunreal.com/"

[LinuxGroup]
; EN: Caption="Linux native files"
Caption="Fichiers de compatibilité Linux"
; EN: Description="Copies all files required to run and play Unreal natively in Linux. There is no Advanced Options menu yet, but all settings are noted and can be edited in the UnrealLinux.ini in the System folder. The level editor UnrealED 2.2 is not available in Linux yet. If you have trouble starting the game, there is more information and a FAQ inside the ReleaseNotes in the Help directory. If your system doesn't provide all libraries, there is a package called lin_convenience_libs.tar.bz2 in the Help folder which should contain all the necessary files."
Description="Copie tous les fichiers nécessaires pour le fonctionnement d'Unreal sous Linux. Les Options Avancées ne sont pas disponibles dans le menu mais peuvent être modifiées manuellement en éditant le fichier UnrealLinux.ini. UnrealEd 2.2 n'est pas disponible sous Linux. Si vous rencontrez des problèmes, des informations et une FAQ sont disponibles dans les ReleaseNotes du dossier Help. Si votre système ne possède pas les librairies requises, une archive lin_convenience_libs.tar.bz2 dans le dossier Help devrait contenir tous les fichiers nécessaires."

[OldWeaponsGroup]
; EN: Caption="Old Weapons"
Caption="Anciennes Armes"
; EN: Description="Copies the Old Weapons mutator files. These files allow you to play with the weapons of Unreal version 200. Details can be found in the OldWeaponsReadme.txt in the help folder."
Description="Installe les fichiers du mutator OldWeapons. Ces fichiers permettent de jouer en utilisant les armes de la version 200 d'Unreal. Les détails sont disponibles dans OldWeaponsReadme.txt, situé dans le dossier Help."

[LinuxARMGroup]
; EN: Caption="Linux ARM (64-bit) version files"
Caption="Fichiers de la version Linux ARM 64 bits"
; EN: Description="64-bit Linux ARM version of the game (Cortex-A72 CPU and compatible). The files will be installed in the Unreal/SystemARM folder."
Description="Fichiers de jeu pour la version 64 bits de Linux ARM (processeur Cortex-A72 et compatible). Les fichiers seront installés dans le dossier Unreal/SystemARM."

[Linux64Group]
; EN: Caption="Linux 64-bit version files"
Caption="Fichiers de la version Linux 64 bits"
; EN: Description="64-bit Linux version of the game. The files will be installed in the Unreal/System64 folder. The 64-bit version will not use any ini settings from the 32-bit version."
Description="Fichiers de jeu pour la version 64 bits de Linux. Les fichiers seront installés dans le dossier Unreal/System64. La version 64 bits n'utilisera aucun paramètre ini de la version 32 bits."

[Windows64Group]
; EN: Caption="Windows 64-bit version files"
Caption="Fichiers de la version Windows 64 bits"
; EN: Description="64-bit Windows version of the game. The files will be installed in the Unreal/System64 folder. The 64-bit version will not use any ini settings from the 32-bit version."
Description="Fichiers de jeu pour la version 64 bits de Windows. Les fichiers seront installés dans le dossier Unreal/System64. La version 64 bits n'utilisera aucun paramètre ini de la version 32 bits."

[GameGroup]
; EN: Caption="Unreal Game"
Caption="Jeu Unreal"
; EN: Description="Unreal game. Installation is required."
Description="Jeu Unreal. L'installation est requise."

[EditorGroup]
; EN: Caption="Unreal Editor"
Caption="Éditeur Unreal"
; EN: Description="Unreal world editor, for creating your own 3D Unreal environments. For advanced users; installation is optional."
Description="Éditeur de niveau Unreal, pour pouvoir créer vos propres environnements 3D Unreal. Pour les utilisateurs avancés, son installation est facultative."

[Editor64Group]
; EN: Caption="Unreal Editor (64-bit)"
Caption="Éditeur Unreal (64 bits)"
; EN: Description="Unreal world editor (64-bit version), for creating your own 3D Unreal environments. For advanced users; installation is optional."
Description="Unreal level éditeur (version 64-bit), pour pouvoir créer vos propres environnements 3D Unreal. Pour les utilisateurs avancés, son installation est facultative."

[PlayShortcut]
; EN: Caption="Play Unreal"
Caption="Jouer Unreal"

[Play64Shortcut]
; EN: Caption="Play Unreal (64-bit)"
Caption="Jouer Unreal (64-bit)"

[FactoryResetGroup]
; EN: Caption="Reset all settings"
Caption="Réinitialiser Paramètres"
; EN: Description="Recommended! Reset all ini settings back to default. Keeping your old ini settings may cause problems with this version; this setting is optional."
Description="Recommandé! Définissez tous vos paramètres Unreal personnels sur leurs valeurs par défaut. Conserver les anciennes valeurs peut causer des problèmes avec cette version; cette option est facultative."

[ConsoleGroup]
; EN: Caption="Classic Menu"
Légende="Menu Classique"
; EN: Description="Use the classic UBrowser menu instead of UMenu. For the classic experience, this original menu is keyboard based and the standard console before UMenu was introduced in Unreal Gold/Unreal Tournament."
Description="Utilisez le menu UBrowser classique au lieu de UMenu pour obtenir l'expérience classique. Ce menu est basé sur le clavier et était le menu par défaut jusqu'à l'introduction de UMenu dans Unreal Gold/Unreal Tournament."

[RTNPGroup]
; EN: Caption="Return to Na Pali Expansion Support"
Caption="Compatibilité avec l'extension Return to Na Pali"
; EN: Description="This installs support for the Return to Na Pali expansion pack. This pack was sold separately and later included in Unreal Gold and Unreal Anthology versions. Do not install if you have the classic version only (226f)."
Description="Cette option installe la prise en charge du pack d'extension Return to Na Pali. Cette extension était vendue séparément, puis incluse dans les versions Unreal Gold et Unreal Anthology. Ne l'installez pas si vous n'avez installé que le jeu de base (226f)."
