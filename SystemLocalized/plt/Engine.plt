[Public]
; EN: Object=(Name=Engine.Console,Class=Class,MetaClass=Engine.Console,Description="Standard (Deprecated)")
Object=(Name=Engine.Console,Class=Class,MetaClass=Engine.Console,Description="Standard (Przestarzałe)")
Object=(Name=Engine.ServerCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Engine.LinkerUpdateCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Engine.SHAUpdateCommandlet,Class=Class,MetaClass=Core.Commandlet)
; Main roots
; Localized string here goes in LangCaption, e.g. Langcaption="Avanzado" (spanish)
Preferences=(Caption="Advanced",Parent="Advanced Options",Langcaption="Zaawansowane")
; Localized string here goes in LangCaption, e.g. Langcaption="Reproducción" (spanish)
Preferences=(Caption="Rendering",Parent="Advanced Options",Langcaption="Rendering")
; Localized string here goes in LangCaption, e.g. Langcaption="Sonido" (spanish)
Preferences=(Caption="Audio",Parent="Advanced Options",Langcaption="Dźwięk")
; Localized string here goes in LangCaption, e.g. Langcaption="Juego en Red" (spanish)
Preferences=(Caption="Networking",Parent="Advanced Options",Langcaption="Obsługa Sieci")
; Localized string here goes in LangCaption, e.g. Langcaption="Tipos de Juego" (spanish)
Preferences=(Caption="Game Types",Parent="Advanced Options",Langcaption="Tryby Gry")
; Localized string here goes in LangCaption, e.g. Langcaption="Imagen" (spanish)
Preferences=(Caption="Display",Parent="Advanced Options",Langcaption="Wyświetlanie")
; Localized string here goes in LangCaption, e.g. Langcaption="Mando" (spanish)
Preferences=(Caption="Joystick",Parent="Advanced Options",Langcaption="Joystick")
; Localized string here goes in LangCaption, e.g. Langcaption="Controladores" (spanish)
Preferences=(Caption="Drivers",Parent="Advanced Options",Langcaption="Sterowniki",Class=Engine.Engine,Immediate=False,Category=Drivers)
; Localized string here goes in LangCaption, e.g. Langcaption="Opciones de Juego" (spanish)
Preferences=(Caption="Game Settings",Parent="Advanced Options",Langcaption="Ustawienia Gry",Class=Engine.GameInfo,Immediate=True)
; Localized string here goes in LangCaption, e.g. Langcaption="Marcas" (spanish)
Preferences=(Caption="Decals",Parent="Advanced Options",Langcaption="Efekty Wizualne")
; Advanced
; Localized string here goes in LangCaption, e.g. Langcaption="Configuración de Motor de Juego" (spanish)
Preferences=(Caption="Game Engine Settings",Parent="Advanced",Langcaption="Ustawienia Silnika",Class=Engine.GameEngine,Category=Settings,Immediate=True)
; Localized string here goes in LangCaption, e.g. Langcaption="Macros para Asignaciones" (spanish)
Preferences=(Caption="Key Aliases",Parent="Advanced",Langcaption="Aliasy Klawiszy",Class=Engine.Input,Immediate=True,Category=Aliases)
; Localized string here goes in LangCaption, e.g. Langcaption="Asignaciones de Botones" (spanish)
Preferences=(Caption="Raw Key Bindings",Parent="Advanced",Langcaption="Konfiguracja Klawiszy",Class=Engine.Input,Immediate=True,Category=RawKeys)
; Networking
; Localized string here goes in LangCaption, e.g. Langcaption="Info. Pública de Servidor" (spanish)
Preferences=(Caption="Public Server Information",Parent="Networking",Langcaption="Publiczne Dane Serwera",Class=Engine.GameReplicationInfo,Immediate=True)
; Localized string here goes in LangCaption, e.g. Langcaption="Canal de Descargas" (spanish)
Preferences=(Caption="Channel Download",Parent="Networking",Langcaption="Pobieranie Kanałów",Class=Engine.ChannelDownload)
; Localized string here goes in LangCaption, e.g. Langcaption="Notificaciones de Conexión" (spanish)
Preferences=(Caption="Connection Notifications",Parent="Networking",Langcaption="Powiadomienia o Połączeniach",Class=Engine.Gameinfo,Category=Networking,Immediate=True)
; Localized string here goes in LangCaption, e.g. Langcaption="Listas de Mapas" (spanish)
Preferences=(Caption="Map Lists",Parent="Networking",Langcaption="Listy Map")
; Decals
; Localized string here goes in LangCaption, e.g. Langcaption="Sangre" (spanish)
Preferences=(Caption="Blood",Parent="Decals",Langcaption="Krew")
; Localized string here goes in LangCaption, e.g. Langcaption="Sombra de Personaje" (spanish)
Preferences=(Caption="Pawn Shadow",Parent="Decals",Langcaption="Cienie Postaci",Class=Engine.PawnShadow,Immediate=True)
; Localized string here goes in LangCaption, e.g. Langcaption="Sombra de Decoración" (spanish)
Preferences=(Caption="Decoration Shadow",Parent="Decals",Langcaption="Cienie Dekoracji",Class=Engine.DecoShadow,Immediate=True)
; Localized string here goes in LangCaption, e.g. Langcaption="Sombra de Proyectil" (spanish)
Preferences=(Caption="Projectile Shadow",Parent="Decals",Langcaption="Cienie Pocisków",Class=Engine.ProjectileShadow,Immediate=True)
; Blood
; Localized string here goes in LangCaption, e.g. Langcaption="Servidor" (spanish)
Preferences=(Caption="Server",Parent="Blood",Langcaption="Serwer",Class=Engine.GameInfo,Category=BloodServer,Immediate=True)

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

[Ammo]
; EN: PickupMessage="You picked up some ammo"
PickupMessage="Podnosisz amunicję"
; EN: ItemName="Ammo"
ItemName="Amunicja"

[LevelInfo]
; EN: Title="Untitled"
Title="Mapa bez tytułu"

[Spectator]
; EN: MenuName="Spectator"
MenuName="Widz"

[Counter]
; EN: CountMessage="Only %i more to go..."
CountMessage="Pozostało: %i..."
; EN: CompleteMessage="Completed!"
CompleteMessage="Gotowe!"

[Progress]
; EN: CancelledConnect="Cancelled Connect Attempt"
CancelledConnect="Próba połączenia anulowana"
; EN: RunningNet="%ls: %ls (%i players)"
RunningNet="%ls: %ls (liczba graczy: %i)"
; EN: NetReceiving="Receiving %ls: %i/%i"
NetReceiving="Trwa pobieranie pliku %ls: %i/%i"
; EN: NetReceiveOk="Successfully received %ls"
NetReceiveOk="Plik „%ls” został pobrany pomyślnie"
; EN: NetSend="Sending %ls"
NetSend="Trwa wysyłanie pliku %ls"
; EN: NetSending="Sending %ls: %i/%i"
NetSending="Trwa wysyłanie pliku %ls: %i/%i"
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
; EN: ReceiveFile="Receiving %ls (F10 Cancels)"
ReceiveFile="Trwa pobieranie pliku %ls (użyj klawisza F10, aby anulować)"
; EN: ReceiveOptionalFile="Receiving optional file %ls (Press F10 to Skip)"
ReceiveOptionalFile="Trwa pobieranie opcjonalnego pliku %ls (użyj klawisza F10, aby pominąć plik)"
; EN: ReceiveSize="Size %iK, Complete %3.1f%% = %iK, %i Packages remaining"
ReceiveSize="Rozmiar %iK, Ukończono %3.1f%% = %iK, pozostało plików: %i"
; EN: ConnectingText="Connecting (F10 Cancels):"
ConnectingText="Łączenie w toku (użyj klawisza F10, aby anulować):"
ConnectingURL="unreal://%ls/%ls"

; LEAVE THIS SECTION UNTRANSLATED - it was decided by consensus.
[ServerCommandlet]
HelpCmd=server
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
HelpOneLiner="Network game server."
HelpUsage="server map.unr[?game=gametype] [-option...] [parm=value]..."
HelpParm[0]="Log"
HelpDesc[0]="Specify the log file to generate."
HelpParm[1]="AllAdmin"
HelpDesc[1]="Give all players admin privileges."

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

[Console]
; EN: ClassCaption="Standard (Deprecated)"
ClassCaption="Standard (Przestarzałe)"
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
FailedPlaceMessage="Nie znaleziono punktu początkowego. Najprawdopodobniej, mapa nie zawiera aktora PlayerStart."
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

[Weapon]
; EN: MessageNoAmmo=" has no ammo."
MessageNoAmmo=" nie ma amunicji."
; EN: DeathMessage="%o was killed by %k's %w."
DeathMessage="%o - %k zabija cię %w."
; EN: PickupMessage="You got a weapon"
PickupMessage="Podnosisz broń"
; EN: ItemName="Weapon"
ItemName="Broń"
; If bGenderMessages=True in UnrealShare, section [UnrealGameInfo]
FemDeathMessage="%o - %k zabija cię %w."
FemKillMessage="%o - %k zabija cię %w."

[DamageType]
; EN: Name="killed"
Name="zabity"
; EN: AltName="killed"
AltName="zabity"
; If bGenderMessages=True in UnrealShare, section [UnrealGameInfo]
FemName="zabity"
AltFemName="zabity"

[Errors]
; EN: NetOpen="Error opening file"
NetOpen="Błąd odczytu pliku"
; EN: NetWrite="Error writing to file"
NetWrite="Błąd zapisu pliku"
; EN: NetRefused="Server refused to send %ls"
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
; EN: DownloadFailed="Downloading package %ls failed: %ls"
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
; EN: Pending="Pending connect to %ls failed; %ls"
Pending="Oczekujące połączenie z %ls nieudane; %ls"
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
; EN: Upgrade="To enter this server, you need the latest free update to Unreal available from OldUnreal's Web site:"
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
CheatUsedStr="%ls używa polecenia administracyjnego lub oszustwa: %c"

[AutosaveTrigger]
; EN: AutoSaveString="Auto Saving"
AutoSaveString="Autozapisywanie"

; BEWARE WHEN MODIFYING THIS SECTION. This only accepts "package.texture" keys. Make sure you enter the right ones.
; At any doubt, ask in the forums or Discord.
[Fonts]
WhiteFont=UWindowFonts.Tahoma10
MedFont=UWindowFonts.Tahoma10
LargeFont=UWindowFonts.Tahoma30
BigFont=Engine.BigFont
SmallFont=Engine.SmallFont

; LEAVE THIS SECTION UNTRANSLATED - it was decided by consensus.
[LinkerUpdateCommandlet]
HelpCmd=linkerupdate
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
HelpOneLiner="Adds all checksums of the files within the directory automatically to the file SHALinkerCache.ini. Used by the UnrealIntegrity anticheat."
HelpUsage="linkerupdate <filename>"
HelpParm[0]="<filename>"
HelpDesc[0]="The file to calculate the checksum for posterior storage."

; LEAVE THIS SECTION UNTRANSLATED - it was decided by consensus.
[SHAUpdateCommandlet]
HelpCmd=shaupdate
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
HelpOneLiner="Adds all SHA256 checksums of the files within the directory automatically to the file SHALinkerCache.ini. Used by the UnrealIntegrity anticheat."
HelpUsage="shaupdate <filename>"
HelpParm[0]="<filename>"
HelpDesc[0]="The file to calculate the SHA256 checksum for posterior storage."
