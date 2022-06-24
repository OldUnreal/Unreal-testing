[Setup]
LocalProduct="Unreal Gold"
DefaultFolder="C:\Program Files (x86)\UnrealGold"
ReadMe="Help\227ReleaseNotes.pdf"
; EN: SetupWindowTitle="Unreal Gold Setup"
SetupWindowTitle="Instalator Unreal Gold"
; EN: AutoplayWindowTitle="Unreal Gold Options"
AutoplayWindowTitle="Opcje Unreal Gold"
ProductURL="https://www.oldunreal.com/"
VersionURL="https://www.oldunreal.com"
; EN: Developer="Epic Games, Inc. - 227 by Oldunreal"
Developer="Epic Games, Inc. - 227 autorstwa Oldunreal"
DeveloperURL="https://www.oldunreal.com/"
Logo="Help\Logo.bmp"

[UnrealRequirement]
LocalProduct="Unreal Gold"
ProductURL="https://www.epicgames.com/"
VersionURL="https://www.epicgames.com/"
; EN: Developer="Epic Games, Inc. - 227 by Oldunreal"
Developer="Epic Games, Inc. - 227 autorstwa Oldunreal"
DeveloperURL="https://www.oldunreal.com/"

[LinuxGroup]
; EN: Caption="Linux native files"
Caption="Pliki rodzime dla Linux"
; EN: Description="Copies all files required to run and play Unreal natively in Linux. There is no Advanced Options menu yet, but all settings are noted and can be edited in the UnrealLinux.ini in the System folder. The level editor UnrealED 2.2 is not available in Linux yet. If you have trouble starting the game, there is more information and a FAQ inside the ReleaseNotes in the Help directory. If your system doesn't provide all libraries, there is a package called lin_convenience_libs.tar.bz2 in the Help folder which should contain all the necessary files."
Description="Zawiera pliki wymagane do uruchomienia gry Unreal w systemie Linux. Obecnie nie zawiera menu Opcji Zaawansowanych, ale wszystkie ustawienia można zmienić poprzez edycję pliku UnrealLinux.ini. UnrealEd 2.2 nie jest dostępny dla systemu Linux. Jeżeli wystąpią problemy z uruchomieniem gry, dodatkowe informacje można znaleźć w pliku ReleaseNotes w folderze Help. Jeżeli w systemie Linux nie ma wymaganych bibliotek, w folderze Help znajduje się archiwum lin_convenience_libs.tar.bz2, które zawiera wszystkie wymagane pliki."

[OldWeaponsGroup]
; EN: Caption="Old Weapons"
Caption="Klasyczny oręż"
; EN: Description="Copies the Old Weapons mutator files. These files allow you to play with the weapons of Unreal version 200. Details can be found in the OldWeaponsReadme.txt in the help folder."
Description="Zawiera mutator "Klasyczny oręż", który przywraca broń z kompilacji 200 gry. Więcej informacji zawarto w pliku OldWeaponsReadme.txt w folderze Help."

[LinuxARMGroup]
; EN: Caption="Linux ARM (64-bit) version files"
Caption="Pliki dla 64-bitowej wersji Linux ARM"
; EN: Description="64-bit Linux ARM version of the game (Cortex-A72 CPU and compatible). The files will be installed in the Unreal/SystemARM folder."
Description="Pliki gry dla 64-bitowej wersji systemu Linux ARM (procesor Cortex-A72 i kompatybilny). Pliki zostaną zainstalowane w folderze Unreal/SystemARM."

[Linux64Group]
; EN: Caption="Linux 64-bit version files"
Caption="Pliki dla 64-bitowej wersji Linuksa"
; EN: Description="64-bit Linux version of the game. The files will be installed in the Unreal/System64 folder. The 64-bit version will not use any ini settings from the 32-bit version."
Description="Pliki gry dla 64-bitowej wersji systemu Linux. Pliki zostaną zainstalowane w folderze Unreal/System64. Wersja 64-bitowa nie będzie używać żadnych ustawień ini z wersji 32-bitowej."

[Windows64Group]
; EN: Caption="Windows 64-bit version files"
Caption="Pliki dla 64-bitowej wersji Windows"
; EN: Description="64-bit Windows version of the game. The files will be installed in the Unreal/System64 folder. The 64-bit version will not use any ini settings from the 32-bit version."
Description="Pliki gry dla 64-bitowej wersji systemu Windows. Pliki zostaną zainstalowane w folderze Unreal/System64. Wersja 64-bitowa nie będzie używać żadnych ustawień ini z wersji 32-bitowej."

[GameGroup]
; EN: Caption="Unreal Game"
Caption="Unreal Gra"
; EN: Description="Unreal game. Installation is required."
Description="Unreal Gra. Wymagana jest instalacja."

[EditorGroup]
; EN: Caption="Unreal Editor"
Caption="Edytor Unreal"
; EN: Description="Unreal world editor, for creating your own 3D Unreal environments. For advanced users; installation is optional."
Description="Edytor poziomów Unreal, umożliwiający tworzenie własnych środowisk 3D Unreal. Dla zaawansowanych użytkowników jego instalacja jest opcjonalna."

[Editor64Group]
; EN: Caption="Unreal Editor (64-bit)"
Caption="Edytor Unreal (64-bitowy)"
; EN: Description="Unreal world editor (64-bit version), for creating your own 3D Unreal environments. For advanced users; installation is optional."
Description="Edytor poziomów Unreal (wersja 64-bitowa), umożliwiający tworzenie własnych środowisk 3D Unreal. Dla zaawansowanych użytkowników jego instalacja jest opcjonalna."

[PlayShortcut]
; EN: Caption="Play Unreal"
Caption="Graj Unreal"

[Play64Shortcut]
; EN: Caption="Play Unreal (64-bit)"
Caption="Graj Unreal (64 bity)"

[FactoryResetGroup]
; EN: Caption="Reset all settings"
Caption="Zresetuj wszystkie ustawienia"
; EN: Description="Recommended! Reset all ini settings back to default. Keeping your old ini settings may cause problems with this version; this setting is optional."
Description="Zalecane! Ustaw wszystkie osobiste ustawienia Unreal na ich wartości domyślne. Zachowanie starych wartości może powodować problemy w tej wersji; ta opcja jest opcjonalna."

[ConsoleGroup]
; EN: Caption="Classic Menu"
Caption="Klasyczne Menu"
; EN: Description="Use the classic UBrowser menu instead of UMenu. For the classic experience, this original menu is keyboard based and the standard console before UMenu was introduced in Unreal Gold/Unreal Tournament."
Description="Użyj klasycznego menu UBrowser zamiast UMenu, aby uzyskać klasyczne wrażenia. To menu jest oparte na klawiaturze i było domyślnym menu do czasu wprowadzenia UMenu w Unreal Gold/Unreal Tournament."

[RTNPGroup]
; EN: Caption="Return to Na Pali Expansion Support"
Caption="Wsparcie dla rozszerzenia Return to Na Pali"
; EN: Description="This installs support for the Return to Na Pali expansion pack. This pack was sold separately and later included in Unreal Gold and Unreal Anthology versions. Do not install if you have the classic version only (226f)."
Description="Ta opcja instaluje obsługę dodatku Return to Na Pali. To rozszerzenie było sprzedawane oddzielnie, a następnie dołączone do wersji Unreal Gold i Unreal Anthology. Nie instaluj, jeśli masz zainstalowaną tylko grę podstawową (226f)."
