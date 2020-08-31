[Public]

Object=(Name=Engine.Console,Class=Class,MetaClass=Engine.Console)

Object=(Name=Engine.ServerCommandlet,Class=Class,MetaClass=Core.Commandlet)

Preferences=(Caption="Zaawansowane",Parent="Opcje zaawansowane")

Preferences=(Caption="Ustawienia silnika",Parent="Zaawansowane",Class=Engine.GameEngine,Category=Settings,Immediate=True)

Preferences=(Caption="Aliasy klawiszy",Parent="Zaawansowane",Class=Engine.Input,Immediate=True,Category=Aliases)

Preferences=(Caption="Konfiguracja klawiszy",Parent="Zaawansowane",Class=Engine.Input,Immediate=True,Category=RawKeys)

Preferences=(Caption="Sterowniki",Parent="Opcje zaawansowane",Class=Engine.Engine,Immediate=False,Category=Drivers)

Preferences=(Caption="Publiczne Dane Serwera",Parent="Obsluga sieci",Class=Engine.GameReplicationInfo,Immediate=True)

Preferences=(Caption="Ustawienia gry",Parent="Opcje zaawansowane",Class=Engine.GameInfo,Immediate=True)

Preferences=(Caption="Efekty wizualne",Parent="Opcje zaawansowane")

Preferences=(Caption="Krew",Parent="Efekty wizualne")

Preferences=(Caption="Serwer",Parent="Krew",Class=Engine.GameInfo,Category=BloodServer,Immediate=True)

Preferences=(Caption="Cienie postaci",Parent="Efekty wizualne",Class=Engine.PawnShadow,Immediate=True)

Preferences=(Caption="Cienie dekoracji",Parent="Efekty wizualne",Class=Engine.DecoShadow,Immediate=True)

Preferences=(Caption="Cienie pocisków",Parent="Efekty wizualne",Class=Engine.ProjectileShadow,Immediate=True)

Preferences=(Caption="Pobieranie kanalów",Parent="Obsluga sieci",Class=Engine.ChannelDownload)

Preferences=(Caption="Powiadomienia o polaczeniach",Parent="Obsluga sieci",Category=Networking,Class=Engine.Gameinfo,Immediate=True)


[PlayerPawn]

QuickSaveString="Szybki zapis w toku."

NoPauseMessage="Brak mozliwosci zatrzymania gry."

ViewingFrom="Widok z kamery: "

OwnCamera="wlasnej"

FailedView="Brak mozliwosci zmiany widoku."

CantChangeNameMsg="Podczas rozgrywki globalnej, której przebieg jest zapisywany, nie ma mozliwosci zmiany imienia."


[Pawn]

NameArticle=" "


[Console]

LoadingMessage="WCZYTYWANIE W TOKU"

SavingMessage="ZAPISYWANIE W TOKU"

ConnectingMessage="LACZENIE W TOKU"

PausedMessage="GRA ZATRZYMANA"

PrecachingMessage="BUFOROWANIE W TOKU"

ClassCaption=Konsola domyslna Unreal

ChatChannel="(OGÓL.) "

TeamChannel="(DRUZ.) "


[Menu]

MenuList=

HelpMessage=

HelpMessage[1]="Menu niedostepne."

LeftString="Lewo"

RightString="Prawo"

CenterString="Srodek"

EnabledString="wl."

DisabledString="wyl."

YesString="tak"

NoString="nie"


[Inventory]

PickupMessage="Podniesiono przedmiot."

ItemArticle=" "

M_Activated=" wlaczony."

M_Selected=" gotowy do uzycia."

M_Deactivated=" wylaczony."


[GameInfo]

SwitchLevelMessage="Trwa zmiana mapy"

DefaultPlayerName="Gracz"

LeftMessage=" opuszcza rozgrywke."

FailedSpawnMessage="Nie udalo sie utworzyc postaci gracza."

FailedPlaceMessage="Nie znaleziono punktu poczatkowego. Najprawdopodobniej, mapa nie zawiera aktora 'PlayerStart'."

FailedTeamMessage="Nie znaleziono druzyny, do której moznaby przydzielic gracza."

NameChangedMessage="Nowe imie: "

EnteredMessage=" dolacza do gry."

GameName="Gra"

MaxedOutMessage="Brak wolnych miejsc na serwerze."

WrongPassword="Wprowadzone haslo jest bledne."

NeedPassword="Aby dolaczyc do wybranej rozgrywki, nalezy wprowadzic haslo."


[LevelInfo]

Title="Mapa bez tytulu"


[Weapon]

MessageNoAmmo=" nie ma amunicji."

DeathMessage="%o - %k zabija cie %w."

PickupMessage="Podnosisz bron"

ItemName="Bron"

DeathMessage[0]=%o - %k zabija cie %w.

DeathMessage[1]=%o - %k zabija cie %w.

DeathMessage[2]=%o - %k zabija cie %w.

DeathMessage[3]=%o - %k zabija cie %w.


[Ammo]

PickupMessage="Podnosisz amunicje."


[Counter]

CountMessage="Pozostalo: %i..."

CompleteMessage="Gotowe!"


[Spectator]

MenuName="Widz"


[DamageType]

Name="zabity"

AltName="zabity"

NameFem="zabita"

AltNameFem="zabita"


[AdminAccessManager]

AdminLoginText="Administrator %s zalogowany"

AdminLogoutText="Administrator %s wylogowany"

CheatUsedStr="%s uzywa polecenia administracyjnego lub 'oszustwa': %c"


[Fonts]

[Fonts]
SmallFont=UWindowFonts.Tahoma10
WhiteFont=UWindowFonts.Tahoma12
MedFont=UWindowFonts.Tahoma11
LargeFont=UWindowFonts.UTFont14B
BigFont=UWindowFonts.UTFont14B
Papyrus=UWindowFonts.Tahoma30
Chiller=UWindowFonts.Tahoma30


[Errors]

NetOpen=Blad odczytu pliku

NetWrite=Blad zapisu pliku

NetRefused=Serwer odrzuca zadanie pobrania pliku '%s'

NetClose=Blad zamykania pliku

NetSize=Niezgodnosc rozmiaru pliku

NetMove=Blad przenoszenia pliku

NetInvalid=Otrzymano nieprawidlowe zadanie pobrania pliku

NoDownload=Plik '%s' nie jest udostepniony do pobierania

DownloadFailed=Pobieranie pliku '%s' nieudane: %s

RequestDenied=Zadanie pobrania pliku powiazanego z mapa w kolejce: odrzucone

ConnectionFailed=Polaczenie nieudane

Banned=Zbanowano cie.

TempBanned=Zbanowano cie tymczasowo.

Kicked=Wyproszono cie.

ChAllocate=Zalozenie kanalu nieudane

NetAlready=Polaczenie sieciowe juz zostalo nawiazane

NetListen=Nasluch nieudany: brak laczy kontekstowych

LoadEntry=Nieudane wczytywanie mapy Entry: %s

InvalidUrl=Niewlasciwy adres URL: %s

InvalidLink=Niewlasciwe lacze: %s

FailedBrowse=Nieudane wejscie na %s: %s

Listen=Nasluch nieudany: %s

AbortToEntry=Nieudane, trwa powrót do mapy Entry

ServerOpen=Otwieranie adresów URL na serwerach niemozliwe

ServerListen=Nasluch niemozliwy na serwerze dedykowanym: %s

Pending=Oczekujace polaczenie z '%s' nieudane; %s

LoadPlayerClass=Blad wczytywania klasy postaci

ServerOutdated=Przestarzala wersja serwera


[Progress]

CancelledConnect=Próba polaczenia anulowana

RunningNet=%s: %s (liczba graczy: %i)

NetReceiving=Trwa pobieranie pliku '%s': %i/%i

NetReceiveOk=Plik '%s' zostal pobrany pomyslnie

NetSend=Trwa wysylanie pliku '%s'

NetSending=Trwa wysylanie pliku '%s': %i/%i

Connecting=Laczenie w toku...

Listening=Nasluch klientów w toku...

Loading=Trwa wczytywanie

Saving=Trwa zapisywanie

Paused=Zatrzymane przez %s

ReceiveFile=Trwa pobieranie pliku '%s' (uzyj klawisza F10, aby anulowac)

ReceiveOptionalFile=Trwa pobieranie opcjonalnego pliku '%s' (uzyj klawisza F10, aby pominac plik)

ReceiveSize=Rozmiar %iK, Ukonczono %3.1f%% = %iK, pozostalo plików: %i

ConnectingText=Laczenie w toku (uzyj klawisza F10, aby anulowac)

ConnectingURL=unreal://%s/%s


[General]

Upgrade=Aby dolaczyc do rozgrywki na wybranym serwerze, nalezy zaktualizowac Unreal przy pomocy darmowej aktualizacji dostepnej na stronie WWW OldUnreal:

UpgradeURL=http://www.oldunreal.com/oldunrealpatches.html

UpgradeQuestion=Czy chcesz uruchomic przegladarke internetowa i udac sie na witryne z aktualizacja?

Version=Wersja %i


[WarpZoneInfo]

OtherSideURL=


[Pickup]

ExpireMessage=


[SpecialEvent]

DamageString=


[ServerCommandlet]

HelpCmd=server

HelpOneLiner=Serwer gry sieciowej

HelpUsage=server map.unr[?game=gametype] [-option...] [parm=value]...

HelpWebLink=http://wiki.oldunreal.com

HelpParm[0]=Log

HelpDesc[0]=Wprowadza nazwe pliku dziennika, który bedzie utworzony

HelpParm[1]=AllAdmin

HelpDesc[1]=Nadaje wszystkim graczom uprawnienia administracyjne 