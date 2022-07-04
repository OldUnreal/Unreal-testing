﻿[Public]
Object=(Name=Engine.ServerCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Engine.LinkerUpdateCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Engine.SHAUpdateCommandlet,Class=Class,MetaClass=Core.Commandlet)
; Main roots
Preferences=(Caption="Advanced",Parent="Advanced Options",LangCaption="Zaawansowane")
Preferences=(Caption="Rendering",Parent="Advanced Options",LangCaption="Rendering")
Preferences=(Caption="Audio",Parent="Advanced Options",LangCaption="Dźwięk")
Preferences=(Caption="Networking",Parent="Advanced Options",LangCaption="Obsługa Sieci")
Preferences=(Caption="Game Types",Parent="Advanced Options",LangCaption="Tryby Gry")
Preferences=(Caption="Display",Parent="Advanced Options",LangCaption="Wyświetlanie")
Preferences=(Caption="Joystick",Parent="Advanced Options",LangCaption="Joystick")
Preferences=(Caption="Drivers",Parent="Advanced Options",LangCaption="Sterowniki",Class=Engine.Engine,Immediate=False,Category=Drivers)
Preferences=(Caption="Game Settings",Parent="Advanced Options",LangCaption="Ustawienia Gry",Class=Engine.GameInfo,Immediate=True)
Preferences=(Caption="Decals",Parent="Advanced Options",LangCaption="Efekty Wizualne")
; Advanced
Preferences=(Caption="Game Engine Settings",Parent="Advanced",LangCaption="Ustawienia Silnika",Class=Engine.GameEngine,Category=Settings,Immediate=True)
Preferences=(Caption="Key Aliases",Parent="Advanced",LangCaption="Aliasy Klawiszy",Class=Engine.Input,Immediate=True,Category=Aliases)
Preferences=(Caption="Raw Key Bindings",Parent="Advanced",LangCaption="Konfiguracja Klawiszy",Class=Engine.Input,Immediate=True,Category=RawKeys)
; Networking
Preferences=(Caption="Public Server Information",Parent="Networking",LangCaption="Publiczne Dane Serwera",Class=Engine.GameReplicationInfo,Immediate=True)
Preferences=(Caption="Channel Download",Parent="Networking",LangCaption="Pobieranie Kanałów",Class=Engine.ChannelDownload)
Preferences=(Caption="Connection Notifications",Parent="Networking",LangCaption="Powiadomienia o Połączeniach",Class=Engine.Gameinfo,Category=Networking,Immediate=True)
Preferences=(Caption="Map Lists",Parent="Networking",LangCaption="Listy Map")
; Decals
Preferences=(Caption="Blood",Parent="Decals",LangCaption="Krew")
Preferences=(Caption="Pawn Shadow",Parent="Decals",LangCaption="Cienie Postaci",Class=Engine.PawnShadow,Immediate=True)
Preferences=(Caption="Decoration Shadow",Parent="Decals",LangCaption="Cienie Dekoracji",Class=Engine.DecoShadow,Immediate=True)
Preferences=(Caption="Projectile Shadow",Parent="Decals",LangCaption="Cienie Pocisków",Class=Engine.ProjectileShadow,Immediate=True)
; Blood
Preferences=(Caption="Server",Parent="Blood",LangCaption="Serwer",Class=Engine.GameInfo,Category=BloodServer,Immediate=True)

[PlayerPawn]
; EN: QuickSaveString="Quick Saving"
QuickSaveString="Szybki zapis w toku"
; EN: NoPauseMessage="Game is not pauseable"
NoPauseMessage="Brak możliwości zatrzymania gry"
; EN: ViewingFrom="Now viewing from "
ViewingFrom="Widok z kamery: "
; EN: OwnCamera="own camera"
OwnCamera="własnej"
; EN: FailedView="Failed to change view."
FailedView="Brak możliwości zmiany widoku."
; EN: CantChangeNameMsg="You can't change your name during a global logged game."
CantChangeNameMsg="Podczas rozgrywki globalnej, której przebieg jest zapisywany, nie ma możliwości zmiany imienia."

[Pawn]
; EN: NameArticle=" a "
NameArticle=" "

[Inventory]
; EN: PickupMessage="Snagged an item"
PickupMessage="Podniesiono przedmiot"
; EN: ItemArticle="a"
ItemArticle=" "
; EN: M_Activated=" activated."
M_Activated=" włączony."
; EN: M_Selected=" selected."
M_Selected=" gotowy do użycia."
; EN: M_Deactivated=" deactivated."
M_Deactivated=" wyłączony."

[LevelInfo]
; EN: Title="Untitled"
Title="Mapa bez tytułu"

[Weapon]
; EN: MessageNoAmmo=" has no ammo."
MessageNoAmmo=" nie ma amunicji."
; EN: DeathMessage="%o was killed by %k's %w."
DeathMessage="%o - %k zabija cię %w."
; EN: PickupMessage="You got a weapon"
PickupMessage="Podnosisz broń"
; EN: ItemName="Weapon"
ItemName="Broń"
FemDeathMessage="%o - %k zabija cię %w."
FemKillMessage="%o - %k zabija cię %w."

[Ammo]
; EN: PickupMessage="You picked up some ammo"
PickupMessage="Podnosisz amunicję"
; EN: ItemName="Ammo"
ItemName="Amunicja"

[Counter]
; EN: CountMessage="Only %i more to go..."
CountMessage="Pozostało: %i..."
; EN: CompleteMessage="Completed!"
CompleteMessage="Gotowe!"

[Spectator]
; EN: MenuName="Spectator"
MenuName="Widz"

[DamageType]
; EN: Name="killed"
Name="zabity"
; EN: AltName="killed"
AltName="zabity"

[Progress]
; EN: CancelledConnect="Cancelled Connect Attempt"
CancelledConnect="Próba połączenia anulowana"
; EN: RunningNet="%ls: %ls (%i players)"
RunningNet="%ls: %ls (liczba graczy: %i)"
; EN: NetReceiving="Receiving „%ls”: %i/%i"
NetReceiving="Trwa pobieranie pliku „%ls”: %i/%i"
; EN: NetReceiveOk="Successfully received „%ls”"
NetReceiveOk="Plik „%ls” został pobrany pomyślnie"
; EN: NetSend="Sending „%ls”"
NetSend="Trwa wysyłanie pliku „%ls”"
; EN: NetSending="Sending „%ls”: %i/%i"
NetSending="Trwa wysyłanie pliku „%ls”: %i/%i"
; EN: Connecting="Connecting..."
Connecting="Łączenie w toku..."
; EN: Listening="Listening for clients..."
Listening="Nasłuch klientów w toku..."
; EN: Loading="Loading"
Loading="Trwa wczytywanie"
; EN: Saving="Saving"
Saving="Trwa zapisywanie"
; EN: Paused="Paused by %ls"
Paused="Zatrzymane przez %ls"
; EN: ReceiveFile="Receiving „%ls” (F10 Cancels)"
ReceiveFile="Trwa pobieranie pliku „%ls” (użyj klawisza F10, aby anulować)"
; EN: ReceiveOptionalFile="Receiving optional file „%ls” (Press F10 to Skip)"
ReceiveOptionalFile="Trwa pobieranie opcjonalnego pliku „%ls” (użyj klawisza F10, aby pominąć plik)"
; EN: ReceiveSize="Size %iK, Complete %3.1f%% = %iK, %i Packages remaining"
ReceiveSize="Rozmiar %iK, Ukończono %3.1f%% = %iK, pozostało plików: %i"
; EN: ConnectingText="Connecting (F10 Cancels):"
ConnectingText="Łączenie w toku (użyj klawisza F10, aby anulować):"
ConnectingURL="unreal://%ls/%ls"

[WarpZoneInfo]
OtherSideURL=""

[Pickup]
ExpireMessage=""

[SpecialEvent]
DamageString=""

[ServerCommandlet]
HelpCmd=server
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Network game server."
HelpOneLiner="Serwer gry sieciowej."
; EN: HelpUsage="server map.unr[?game=gametype] [-option...] [parm=value]..."
HelpUsage="server map.unr[?game=TypyGier] [-option...] [parm=value]..."
HelpParm[0]="Log"
; EN: HelpDesc[0]="Specify the log file to generate."
HelpDesc[0]="Wprowadza nazwę pliku dziennika, który będzie utworzony."
HelpParm[1]="AllAdmin"
; EN: HelpDesc[1]="Give all players admin privileges."
HelpDesc[1]="Nadaje wszystkim graczom uprawnienia administracyjne."

[Console]
; EN: LoadingMessage="LOADING"
LoadingMessage="WCZYTYWANIE W TOKU"
; EN: SavingMessage="SAVING"
SavingMessage="ZAPISYWANIE W TOKU"
; EN: ConnectingMessage="CONNECTING"
ConnectingMessage="ŁĄCZENIE W TOKU"
; EN: PausedMessage="PAUSED"
PausedMessage="GRA ZATRZYMANA"
; EN: PrecachingMessage="PRECACHING"
PrecachingMessage="BUFOROWANIE W TOKU"

[Menu]
MenuList=" "
HelpMessage=" "
; EN: HelpMessage[1]="This menu has not yet been implemented."
HelpMessage[1]="Menu niedostępne."
; EN: LeftString="Left"
LeftString="Lewo"
; EN: RightString="Right"
RightString="Prawo"
; EN: CenterString="Center"
CenterString="Środek"
; EN: EnabledString="Enabled"
EnabledString="wł."
; EN: DisabledString="Disabled"
DisabledString="wył."
; EN: YesString="Yes"
YesString="tak"
; EN: NoString="No"
NoString="nie"
; EN: OnString="On"
OnString="Wł."
; EN: OffString="Off"
OffString="Wył."

[GameInfo]
; EN: SwitchLevelMessage="Switching Levels"
SwitchLevelMessage="Trwa zmiana mapy"
DefaultPlayerName="Player"
; EN: LeftMessage=" left the game."
LeftMessage=" opuszcza rozgrywkę."
; EN: FailedSpawnMessage="Failed to spawn player actor"
FailedSpawnMessage="Nie udało się utworzyć postaci gracza"
; EN: FailedPlaceMessage="Could not find starting spot (level might need a "PlayerStart" actor)"
FailedPlaceMessage="Nie znaleziono punktu początkowego. Najprawdopodobniej, mapa nie zawiera aktora „PlayerStart”."
; EN: FailedTeamMessage="Could not find team for player"
FailedTeamMessage="Nie znaleziono drużyny, do której możnaby przydzielić gracza"
; EN: NameChangedMessage="Name changed to "
NameChangedMessage="Nowe imię: "
; EN: EnteredMessage=" entered the game."
EnteredMessage=" dołącza do gry."
; EN: GameName="Game"
GameName="Gra"
; EN: MaxedOutMessage="Server is already at capacity."
MaxedOutMessage="Brak wolnych miejsc na serwerze."
; EN: WrongPassword="The password you entered is incorrect."
WrongPassword="Wprowadzone hasło jest błędne."
; EN: NeedPassword="You need to enter a password to join this game."
NeedPassword="Aby dołączyć do wybranej rozgrywki, należy wprowadzić hasło."
; EN: MaleGender="his"
MaleGender="jego"
; EN: FemaleGender="her"
FemaleGender="jej"
; EN: MaxedOutSpectatorsMsg="Max spectators exceeded"
MaxedOutSpectatorsMsg="Przekroczono maksymalną liczbę widzów"

[Errors]
; EN: NetOpen="Error opening file"
NetOpen="Błąd odczytu pliku"
; EN: NetWrite="Error writing to file"
NetWrite="Błąd zapisu pliku"
; EN: NetRefused="Server refused to send „%ls”"
NetRefused="Serwer odrzuca żądanie pobrania pliku „%ls”"
; EN: NetClose="Error closing file"
NetClose="Błąd zamykania pliku"
; EN: NetSize="File size mismatch"
NetSize="Niezgodność rozmiaru pliku"
; EN: NetMove="Error moving file"
NetMove="Błąd przenoszenia pliku"
; EN: NetInvalid="Received invalid file request"
NetInvalid="Otrzymano nieprawidłowe żądanie pobrania pliku"
; EN: NoDownload="Package „%ls” is not downloadable"
NoDownload="Plik „%ls” nie jest udostępniony do pobierania"
; EN: DownloadFailed="Downloading package „%ls” failed: %ls"
DownloadFailed="Pobieranie pliku „%ls” nieudane: %ls"
; EN: RequestDenied="Server requested file from pending level: Denied"
RequestDenied="Żądanie pobrania pliku powiązanego z mapą w kolejce: odrzucone"
; EN: ConnectionFailed="Connection failed"
ConnectionFailed="Połączenie nieudane"
; EN: ChAllocate="Couldn't allocate channel"
ChAllocate="Założenie kanału nieudane"
; EN: NetAlready="Already networking"
NetAlready="Połączenie sieciowe już zostało nawiązane"
; EN: NetListen="Listen failed: No linker context available"
NetListen="Nasłuch nieudany: brak łączy kontekstowych"
; EN: LoadEntry="Can't load Entry: %ls"
LoadEntry="Nieudane wczytywanie mapy Entry: %ls"
; EN: InvalidUrl="Invalid URL: %ls"
InvalidUrl="Niewłaściwy adres URL: %ls"
; EN: InvalidLink="Invalid Link: %ls"
InvalidLink="Niewłaściwe łącze: %ls"
; EN: FailedBrowse="Failed to enter %ls: %ls"
FailedBrowse="Nieudane wejście na %ls: %ls"
; EN: Listen="Listen failed: %ls"
Listen="Nasłuch nieudany: %ls"
; EN: AbortToEntry="Failed; returning to Entry"
AbortToEntry="Nieudane, trwa powrót do mapy Entry"
; EN: ServerOpen="Servers can't open network URLs"
ServerOpen="Otwieranie adresów URL na serwerach niemożliwe"
; EN: ServerListen="Dedicated server can't listen: %ls"
ServerListen="Nasłuch niemożliwy na serwerze dedykowanym: %ls"
; EN: Pending="Pending connect to „%ls” failed; %ls"
Pending="Oczekujące połączenie z „%ls” nieudane; %ls"
; EN: LoadPlayerClass="Failed to load player class"
LoadPlayerClass="Błąd wczytywania klasy postaci"
; EN: ServerOutdated="Server's version is outdated"
ServerOutdated="Przestarzała wersja serwera"
; EN: Banned="You have been banned"
Banned="Zbanowano cię"
; EN: TempBanned="You have been temporarily banned"
TempBanned="Zbanowano cię tymczasowo"
; EN: Kicked="You have been kicked"
Kicked="Wyproszono cię"

[General]
; EN: Upgrade="To enter this server, you need the latest free update to Unreal available from OldUnreals's Web site:"
Upgrade="Aby dołączyć do rozgrywki na wybranym serwerze, należy zaktualizować Unreal przy pomocy darmowej aktualizacji dostępnej na stronie WWW OldUnreal:"
UpgradeURL="https://www.oldunreal.com/oldunrealpatches.html"
; EN: UpgradeQuestion="Do you want to launch your web browser and go to the upgrade page now?"
UpgradeQuestion="Czy chcesz uruchomić przeglądarkę internetową i udać się na witrynę z aktualizacją?"
; EN: Version="Version %i"
Version="Wersja %i"

[AdminAccessManager]
; EN: AdminLoginText="Administrator %ls logged in"
AdminLoginText="Administrator %ls zalogowany"
; EN: AdminLogoutText="Administrator %ls logged out"
AdminLogoutText="Administrator %ls wylogowany"
; EN: CheatUsedStr="%ls used admin/cheat command: %c"
CheatUsedStr="%ls używa polecenia administracyjnego lub „oszustwa”: %c"

[Fonts]
WhiteFont=UWindowFonts.Tahoma10
MedFont=UWindowFonts.Tahoma10
LargeFont=UWindowFonts.Tahoma30
BigFont=Engine.BigFont
SmallFont=Engine.SmallFont

[LinkerUpdateCommandlet]
HelpCmd=linkerupdate
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Adds all checksums of the files within the directory automatically to the file SHALinkerCache.ini. Used by the UnrealIntegrity anticheat."
HelpOneLiner="Dodaje wszystkie sumy kontrolne plików w katalogu automatycznie do pliku SHALinkerCache.ini. Używany przez anticheat UnrealIntegrity."
; EN: HelpUsage="linkerupdate <filename>"
HelpUsage="linkerupdate <NazwaPliku>"
; EN: HelpParm[0]="<filename>"
HelpParm[0]="<NazwaPliku>"
; EN: HelpDesc[0]="The file to calculate the checksum for posterior storage."
HelpDesc[0]="Plik do obliczenia sumy kontrolnej do późniejszego przechowywania."

[SHAUpdateCommandlet]
HelpCmd=shaupdate
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Adds all SHA256 checksums of the files within the directory automatically to the file SHALinkerCache.ini. Used by the UnrealIntegrity anticheat."
HelpOneLiner="Dodaje wszystkie sumy kontrolne SHA256 plików w katalogu automatycznie do pliku SHALinkerCache.ini. Używany przez anticheat UnrealIntegrity."
; EN: HelpUsage="shaupdate <filename>"
HelpUsage="shaupdate <NazwaPliku>"
; EN: HelpParm[0]="<filename>"
HelpParm[0]="<NazwaPliku>"
; EN: HelpDesc[0]="The file to calculate the SHA256 checksum for posterior storage."
HelpDesc[0]="Plik do obliczenia sumy kontrolnej SHA256 do późniejszego przechowywania. "

[AutosaveTrigger]
; EN: AutoSaveString="Auto Saving"
AutoSaveString="Autozapisywanie"
