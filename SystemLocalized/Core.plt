[Language]

Language=Polski

LangId=21

SubLangId=1


[Public]

Preferences=(Caption="Zaawansowane",Parent="Opcje zaawansowane")

Preferences=(Caption="System plików",Parent="Zaawansowane",Class=Core.System,Immediate=True)


[HelloWorldCommandlet]

HelpCmd=HelloWorld

HelpOneLiner=Sample

HelpUsage=HelloWorld

HelpParm[0]=IntParm

HelpParm[1]=StrParm

HelpDesc[0]=Parametr liczbowy

HelpDesc[1]=Parametr slowny


[Errors]

Unknown=Nieznany blad

Aborted=Przerwano

ExportOpen=Blad eksportu %s: nie mozna otworzyc pliku '%s'

ExportWrite=Blad eksportu %s: nie mozna zapisac pliku '%s'

FileNotFound=Nie znaleziono pliku '%s'

NoTXTFile=Nie mozna wykonac pliku '%s' - nie jest to plik tekstowy (.txt)

ObjectNotFound=Nie znaleziono obiektu '%s %s.%s'

PackageNotFound=Nie znaleziono pliku '%s'

PackageResolveFailed=Nie otrzymano nazwy pliku

FilenameToPackage=Nie mozna dokonac konwersji pliku '%s' do pliku zbiorczego

Sandbox=Plik zbiorczy '%s' jest niedostepny w tym srodowisku

PackageVersion=Niezgodnosc wersji pliku '%s'

FailedLoad=Blad wczytywania '%s': %s

ConfigNotFound=Nie odnaleziono '%s' w pliku konfiguracji

LoadClassMismatch=%s nie jest klasa pochodzaca od %s.%s

NotDll='%s' nie jest biblioteka DLL; nie znaleziono funkcji eksportu '%s'

NotInDll=Nie znaleziono '%s' w pliku '%s.dll'

FailedLoadPackage=Blad wczytywania pliku: %s

FailedLoadObject=Blad wczytywania '%s %s.%s': %s

TransientImport=Zaimportowano obiekt tymczasowy: %s

FailedSavePrivate=Nie mozna zapisac %s: Wykres jest powiazany z zewnetrznym obiektem prywatnym %s

FailedImportPrivate=Nie mozna zaimportowac obiektu prywatnego %s %s

FailedCreate=Nie znaleziono %s %s: utworzenie nieudane

FailedImport=Nie znaleziono %s w pliku '%s'

FailedSaveFile=Blad zapisu pliku '%s': %s

SaveWarning=Blad zapisu '%s'

NotPackaged=Obiekt nie znajduje sie w pliku zbiorczym: %s %s

NotWithin=Obiekt %s %s zostal utworzony w %s zamiast w %s

Abstract=Tworzenie obiektu %s nieudane: klasa %s jest abstrakcyjna

NoReplace=Nie mozna zastapic %s tym: %s

NoFindImport=Nie znaleziono '%s': import nieudany

ReadFileFailed=Blad odczytu pliku '%s': import nieudany

SeekFailed=Blad wyszukiwania pliku

OpenFailed=Blad otwarcia pliku

WriteFailed=Blad zapisu pliku

ReadEof=Próba odczytu poza koncowym fragmentem pliku

IniReadOnly=Plik %s jest zabezpieczony przed zapisem; zmiany ustawien nie zostana zapisane

UrlFailed=Blad otwarcia adresu URL

Warning=Ostrzezenie

Question=Pytanie

OutOfMemory=Za malo pamieci wirtualnej. Aby rozwiazac ten problem, nalezy zwolnic miejsce na glównym dysku twardym.

History=Historia

Assert=Blad twierdzenia: %s [Plik:%s] [Linia: %i]

Debug=Blad twierdzenia debugowego: %s [Plik:%s] [Linia: %i]

LinkerExists=Lacznik dla '%s' juz istnieje

BinaryFormat=Plik '%s' zawiera nieznany rodzaj danych

SerialSize=%s: Niezgodnosc rozmiaru szeregowego: Dostepne %i, Oczekiwane %i

ExportIndex=Niewlasciwy indeks eksportu %i/%i

ImportIndex=Niewlasciwy indeks importu %i/%i

Password=Niewlasciwe haslo

Exec=Blad polecenia

BadProperty='%s': Niewlasciwa lub nieobecna wlasciwosc '%s'

MisingIni=Brak pliku .ini: %s


[Query]

OldVersion=Plik %s zapisano przy pomocy starszej wersji niezgodnej z obecna. Próba odczytu ma nikle szanse powodzenia, moze nawet wystapic awaria programu. Czy próbowac mimo to?

Name=Nazwa:

Password=Haslo:

PassPrompt=Wprowadz nazwe uzytkownika i haslo:

PassDlg=Weryfikacja tozsamosci

Overwrite=Plik '%s' nalezy zaktualizowac. Czy chcesz nadpisac obecna wersje?


[Progress]

Saving=Zapisywanie pliku %s...

Loading=Wczytywanie pliku %s...

Closing=Zamykanie


[General]

Product=Unreal

Engine=Unreal Engine

Copyright=(c) 1999 Epic Games, Inc.

True=Wl.

False=Wyl.

None=Brak

Yes=Tak

No=Nie 