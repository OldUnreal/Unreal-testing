[Public]
; Shared commandlets
Object=(Name=Editor.MasterCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.MakeCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.ConformCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.BatchExportCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.PackageFlagCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.DataRipCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.UpdateUModCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.ChecksumPackageCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.StripSourceCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.DumpIntCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.ExportPackageCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.CompareIntCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.ListObjectsCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.DumpMeshInfoCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.CheckUnicodeCommandlet,Class=Class,MetaClass=Core.Commandlet)
; Unreal-exclusive commandlets
Object=(Name=Editor.PS2ConvertCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.AudioPackageCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.DumpTextureInfoCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.MusicPackagesCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.ReduceTexturesCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.SaveEmbeddedCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.BatchMeshExportCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.RebuildImportsCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.ProdigiosumInParvoCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.FullBatchExportCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.FontPageDiffCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.RipAndTearCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.TextureMergerCommandlet,Class=Class,MetaClass=Core.Commandlet)
Object=(Name=Editor.FontExporter,Class=Class,MetaClass=Core.Exporter)
; "Editor" tree
Preferences=(Caption="Editor",Parent="Advanced Options")
Preferences=(Caption="Advanced (Editor)",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=Advanced)
Preferences=(Caption="Colors",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=Colors)
Preferences=(Caption="Grid",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=Grid)
Preferences=(Caption="Rotation Grid",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=RotationGrid)
; "Commandlets and Exporters" subtree
Preferences=(Caption="Commandlets and Exporters",Parent="Editor")
Preferences=(Caption="AudioPackage Commandlet",Parent="Commandlets and Exporters",Class=Editor.AudioPackageCommandlet,Immediate=True)
Preferences=(Caption="BatchMeshExport Commandlet",Parent="Commandlets and Exporters",Class=Editor.BatchMeshExportCommandlet,Immediate=True)
Preferences=(Caption="FullBatchExport Commandlet",Parent="Commandlets and Exporters",Class=Editor.FullBatchExportCommandlet,Immediate=True)
Preferences=(Caption="MusicPackages Commandlet",Parent="Commandlets and Exporters",Class=Editor.MusicPackagesCommandlet,Immediate=True)
Preferences=(Caption="RebuildImports Commandlet",Parent="Commandlets and Exporters",Class=Editor.RebuildImportsCommandlet,Immediate=True)
Preferences=(Caption="SkeletalAnim (PSA) Exporter",Parent="Commandlets and Exporters",Class=Editor.SkeletalAnimExpPSA,Immediate=True)

[MasterCommandlet]
HelpCmd=master
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Build master installer files"
HelpOneLiner="Tworzy glówne pliki instalacyjne."
; EN: HelpUsage="master [-option...] [parm=value]..."
HelpUsage="master [-opcja...] [parametr=wartość]..."
HelpParm[0]="MasterPath"
; EN: HelpDesc[0]="Root directory to copy source files from."
HelpDesc[0]="Folder glówny, z którego kopiowane beda pliki."
HelpParm[1]="SrcPath"
; EN: HelpDesc[1]="Root directory to copy source (release) files to."
HelpDesc[1]="Folder glówny, do którego zostana skopiowane pliki zródlowe."
HelpParm[2]="RefPath"
; EN: HelpDesc[2]="Path for delta-compressed path reference."
HelpDesc[2]="Sciezka odniesienia dla plików z delta-kompresja."

[MakeCommandlet]
HelpCmd=make
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Rebuild UnrealScript packages."
HelpOneLiner="Kompiluje ponownie pliki z kodem UnrealScript."
; EN: HelpUsage="make [-option...] [parm=value]..."
HelpUsage="make [-opcja...] [parametr=wartość]..."
HelpParm[0]="Silent"
; EN: HelpDesc[0]="No prompts; assume 'yes' to all questions."
HelpDesc[0]="Bez pytan, domyslna odpowiedz na kazde zapytanie bedzie twierdzaca."
HelpParm[1]="NoBind"
; EN: HelpDesc[1]="Don't force native functions to be bound to DLLs."
HelpDesc[1]="Bez wymuszania powiazania funkcji natywnych do bibliotek DLL."
HelpParm[2]="All"
; EN: HelpDesc[2]="Clean rebuild (otherwise rebuild is incremental)."
HelpDesc[2]="Rekompilacja na czysto (w przeciwnym razie przeprowadza sie kompilacje uzupelniajaca)."

[ConformCommandlet]
HelpCmd=conform
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Generate conforming binary files"
HelpOneLiner="Dostosowuje nowy plik do poprzedniej wersji celem zgodnosci w grze wieloosobowej"
; EN: HelpUsage="conform existing_file.ext old_file.ext"
HelpUsage="conform istniejący_plik.ext stary_plik.ext"
; EN: HelpParm[0]="existing_file.ext"
HelpParm[0]="istniejący_plik.ext"
; EN: HelpDesc[0]="Existing binary file to load, conform, and save."
HelpDesc[0]="Nowa wersja pliku, która jest przedmiotem operacji."
; EN: HelpParm[1]="old_file.ext"
HelpParm[1]="stary_plik.ext"
; EN: HelpDesc[1]="Old file to make source file binary compatible with."
HelpDesc[1]="Stara wersja pliku, z która ma byc zgodny nowy plik."

[BatchExportCommandlet]
HelpCmd=batchexport
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Export objects in bulk."
HelpOneLiner="Masowo eksportuje obiekty."
; EN: HelpUsage="batchexport package.ext classname export_ext [path]"
HelpUsage="batchexport package.ext nazwaKlasy export_ext [ścieżka]"
; EN: HelpParm[0]="package.ext"
HelpParm[0]="package.ext"
; EN: HelpDesc[0]="Package whose objects you wish to export."
HelpDesc[0]="Plik, z którego eksportowane beda obiekty."
; EN: HelpParm[1]="classname"
HelpParm[1]="nazwaKlasy"
; EN: HelpDesc[1]="Class of object to export. It can be one of the following:"
HelpDesc[1]="Klasa obiektu do wyeksportowania. Może to być jeden z następujących:"
HelpParm[2]="   "
HelpDesc[2]="   class, texture, sound, music, level, model, polys, textbuffer"
; EN: HelpParm[3]="export_ext"
HelpParm[3]="export_ext"
; EN: HelpDesc[3]="File extension to export to. The accepted file extensions per class are as follows:"
HelpDesc[3]="Rozszerzenie pliku do eksportu. Akceptowane rozszerzenia plików według klas są następujące
HelpParm[4]="   "
HelpDesc[4]="   class: uc, h"
HelpParm[5]="   "
HelpDesc[5]="   texture: bmp, pcx"
HelpParm[6]="   "
HelpDesc[6]="   sound: wav"
HelpParm[7]="   "
; EN: HelpDesc[7]="   music: s3m, xm, it or any other tracker format"
HelpDesc[7]="   music: s3m, xm, it lub jakikolwiek inny format trackera"
HelpParm[8]="   "
HelpDesc[8]="   level: t3d"
HelpParm[9]="   "
HelpDesc[9]="   model: t3d"
HelpParm[10]="   "
HelpDesc[10]="   polys: t3d"
HelpParm[11]="   "
HelpDesc[11]="   textbuffer: txt"
; EN: HelpParm[12]="path"
HelpParm[12]="ścieżka"
; EN: HelpDesc[12]="Path to export files to, like C:\MyPath."
HelpDesc[12]="Sciezka do folderu, do którego eksportowane beda pliki, np. C:\MójFolder."

[PackageFlagCommandlet]
HelpCmd=packageflag
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Set package flags in package files."
HelpOneLiner="Ustawia znaczniki w plikach."
; EN: HelpUsage="packageflag src.ext [<+|->flag [<+|->flag] ...]"
HelpUsage="pakietflag src.ext [<+|->flaga [<+|->flaga] ...]"
; EN: HelpParm[0]="src.ext"
HelpParm[0]="src.ext"
; EN: HelpDesc[0]="Existing package file to load."
HelpDesc[0]="Plik, który bedzie modyfikowany."
; EN: HelpParm[1]="flag"
HelpParm[1]="flaga"
; EN: HelpDesc[1]="+ to set a flag, or - to remove a flag, followed by one of:"
HelpDesc[1]="+ aby ustawic znacznik, lub - aby usunac znacznik, jeden z ponizszych:"
HelpParm[2]="   AllowDownload"
; EN: HelpDesc[2]="   Clients are allowed to download this package from the server."
HelpDesc[2]="   Klienci mogą pobierać ten pakiet z serwera."
HelpParm[3]="   ClientOptional"
; EN: HelpDesc[3]="   Clients can choose to skip downloading this package from the server."
HelpDesc[3]="   Klienci mogą pominąć pobieranie tego pakietu z serwera."
HelpParm[4]="   ServerSideOnly"
; EN: HelpDesc[4]="   The package has no network relevancy on a server."
HelpDesc[4]="   Pakiet nie ma związku z siecią na serwerze."
HelpParm[5]="   BrokenLinks"
; EN: HelpDesc[5]="   The package can be loaded with missing links."
HelpDesc[5]="   Pakiet może zostać załadowany z brakującymi linkami."
HelpParm[6]="   Unsecure"
; EN: HelpDesc[6]="   Unused."
HelpDesc[6]="   Nie używany."

[DataRipCommandlet]
HelpCmd=datarip
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Create a package with Texture, Music and Sound data ripped out."
HelpOneLiner="Tworzy plik z usunietymi teksturami, muzyka i dzwiekiem."
; EN: HelpUsage="datarip srcpackage.ext dstpackage.ext"
HelpUsage="datarip srcpackage.ext dstpackage.ext"
; EN: HelpParm[0]="srcpackage.ext"
HelpParm[0]="srcpackage.ext"
; EN: HelpDesc[0]="Source Package."
HelpDesc[0]="Plik zródlowy."
; EN: HelpParm[1]="dstpackage.ext"
HelpParm[1]="dstpackage.ext"
; EN: HelpDesc[1]="Destination Package."
HelpDesc[1]="Plik docelowy."

[UpdateUModCommandlet]
HelpCmd=updateumod
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Add, delete, replace or extract files from an umod."
HelpOneLiner="Dodaje, usuwa, zastepuje lub wypakowuje pliki z archiwum .umod."
; EN: HelpUsage="updateumod UmodFile Command [Filename]"
HelpUsage="updateumod UmodFile Komenda [Nazwa pliku]"
; EN: HelpParm[0]="UmodFile"
HelpParm[0]="UmodFile"
; EN: HelpDesc[0]="The umod file to change or view."
HelpDesc[0]="Nazwa pliku .umod, na którym wykonywana bedzie operacja."
; EN: HelpParm[1]="Command"
HelpParm[1]="Komenda"
; EN: HelpDesc[1]="Can be one of the following:"
HelpDesc[1]="Może być jedną z następujących:"
HelpParm[2]="   EXTRACT"
; EN: HelpDesc[2]="   File extraction"
HelpDesc[2]="   Wyodrębnia plik."
HelpParm[3]="   ADD"
; EN: HelpDesc[3]="   File addition"
HelpDesc[3]="   Dodaje plik."
HelpParm[4]="   DELETE"
; EN: HelpDesc[4]="   File deletion"
HelpDesc[4]="   Usuwa plik."
HelpParm[5]="   REPLACE"
; EN: HelpDesc[5]="   File replacement"
HelpDesc[5]="   Zastępuje plik."
HelpParm[6]="   LIST"
; EN: HelpDesc[6]="   File listing"
HelpDesc[6]="   Wyświetla wszystkie pliki."
; EN: HelpParm[7]="Filename"
HelpParm[7]="Nazwa pliku"
; EN: HelpDesc[7]="The file to EXTRACT, ADD, DELETE or REPLACE."
HelpDesc[7]="Nazwa pliku, który jest przedmiotem polecenia EXTRACT, ADD, DELETE lub REPLACE."

[ChecksumPackageCommandlet]
HelpCmd=checksumpackage
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Display checksum for package file."
HelpOneLiner="Wyswietla sume kontrolna dla wybranego pliku."
; EN: HelpUsage="checksumpackage packagename"
HelpUsage="checksumpackage nazwaPakietu"
; EN: HelpParm[0]="packagename"
HelpParm[0]="nazwaPakietu"
; EN: HelpDesc[0]="The name of the package to checksum."
HelpDesc[0]="Nazwa pliku, którego sume kontrolna chcesz poznac."

[StripSourceCommandlet]
HelpCmd=StripSource
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Strip the script buffers from a package."
HelpOneLiner="Usuwa bufor skryptów z pliku."
; EN: HelpUsage="stripsource packagename"
HelpUsage="stripsource nazwaPakietu"
; EN: HelpParm[0]="packagename"
HelpParm[0]="nazwaPakietu"
; EN: HelpDesc[0]="The name of the package to strip sources."
HelpDesc[0]="Nazwa pliku, z którego maja zostac usuniete zródla."

[DumpIntCommandlet]
HelpCmd=DumpInt
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Dump the language text contents out of a file."
HelpOneLiner="Generuje plik .int z zawartoscia tekstowo-jezykowa danego pliku.."
; EN: HelpUsage="dumpint packagename"
HelpUsage="dumpint nazwaPakietu"
; EN: HelpParm[0]="packagename"
HelpParm[0]="nazwaPakietu"
; EN: HelpDesc[0]="The name of the package to dump language text of."
HelpDesc[0]="Nazwa pliku, do którego chcemy wygenerowac plik jezykowy."

[ExportPackageCommandlet]
HelpCmd=ExportPackage
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Simply export a package contents to .uc files in prior directory."
HelpOneLiner="Wypakowuje zródla w formacie .uc z wybranego pliku."
; EN: HelpUsage="exportpackage packagename"
HelpUsage="exportpackage nazwaPakietu"
; EN: HelpParm[0]="packagename"
HelpParm[0]="nazwaPakietu"
; EN: HelpDesc[0]="The name of the package to export UC files of."
HelpDesc[0]="Nazwa pliku, z którego maja zostac wyeksportowane zródla w formacie .uc."

[CompareIntCommandlet]
HelpCmd=CompareInt
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Compare 2 language files and delete/remove language entries that you compare with."
HelpOneLiner="Porównuje dwa pliki jezykowe i dodaje brakujace wpisy, dostosowujac nowy plik."
; EN: HelpUsage="compareint packageint miscint"
HelpUsage="Compareint pakietInt miscInt"
; EN: HelpParm[0]="packageint"
HelpParm[0]="pakietInt"
; EN: HelpDesc[0]="Main language file."
HelpDesc[0]="Glówny plik jezykowy."
; EN: HelpParm[1]="miscint"
HelpParm[1]="miscInt"
; EN: HelpDesc[1]="Secondary language file (to edit)."
HelpDesc[1]="Plik jezykowy, który bedzie zmieniany."

[ListObjectsCommandlet]
HelpCmd=listobjects
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Lists Objects in package."
HelpOneLiner="Wyświetla listę obiektów w pakiecie."
; EN: HelpUsage="listobjects [-switch1 [-switch2 [...]]] <package> [<baseclass>]"
HelpUsage="listobjects [-switch1 [-switch2 [...]]] <nazwaPakietu> [<klasaBazowa>]"
; EN: HelpParm[0]="-switch1, -switch2..."
HelpParm[0]="-switch1, -switch2 ..."
; EN: HelpDesc[0]="Option switches, can be one or more of the following:"
HelpDesc[0]="Przełączniki opcji mogą być co najmniej jednym z następujących:"
HelpParm[1]="   -cp"
; EN: HelpDesc[1]="   Prints pathname instead of name for Class."
HelpDesc[1]="   Wyświetla ścieżkę zamiast nazwy dla klasy."
HelpParm[2]="   -op"
; EN: HelpDesc[2]="   Prints pathname instead of name for Object."
HelpDesc[2]="   Wyświetla ścieżkę zamiast nazwy obiektu."
HelpParm[3]="   -na"
; EN: HelpDesc[3]="   Do not align output."
HelpDesc[3]="   Nie wyrównuj wyników."
HelpParm[4]="   -ni"
; EN: HelpDesc[4]="   Do not indent object hierarchy."
HelpDesc[4]="   Nie wciskaj hierarchii obiektów."
HelpParm[5]="   -nc"
; EN: HelpDesc[5]="   Do not display class."
HelpDesc[5]="   Nie wyświetlaj klasy."
HelpParm[6]="   -co"
; EN: HelpDesc[6]="   Just display Object Classes instead of each Object."
HelpDesc[6]="   Po prostu wyświetl klasy obiektów zamiast każdego obiektu."
; EN: HelpParm[7]="pkg"
HelpParm[7]="nazwaPakietu"
; EN: HelpDesc[7]="Package file."
HelpDesc[7]="Plik pakietu."
; EN: HelpParm[8]="baseclass"
HelpParm[8]="klasaBazowa"
; EN: HelpDesc[8]="Optional base class of listed objects."
HelpDesc[8]="Opcjonalna klasa bazowa wymienionych obiektów."

[DumpMeshInfoCommandlet]
HelpCmd=dumpmeshinfo
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Dumps information about meshes."
HelpOneLiner="Zrzuca informacje o siatkach."
; EN: HelpUsage="dumpmeshinfo <pkg>"
HelpUsage="dumpmeshinfo <nazwaPakietu>"

[CheckUnicodeCommandlet]
HelpCmd=checkunicode
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpUsage="Checks if the contents of a text file contains Unicode characters."
HelpUsage="Sprawdza, czy zawartość pliku tekstowego zawiera znaki Unicode."
; EN: HelpOneLiner="checkunicode <filewildcard>"
HelpOneLiner="checkunicode <Plik wieloznaczny>"
; EN: HelpDesc[0]="<filewildcard>"
HelpDesc[0]="<Plik wieloznaczny>"
; EN: HelpParm[0]="The files to check for Unicode characters. Can accept wildcards such as "*" and "?"."
HelpParm[0]="Pliki do sprawdzenia, czy występują znaki Unicode. Można akceptować symbole wieloznaczne, takie jak „*” i „?”."

[AudioPackageCommandlet]
HelpCmd=audiopackage
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Create an audio package out of a directory."
HelpOneLiner="Utwórz pakiet audio z katalogu."
; EN: HelpUsage="audiopackage <input directory>"
HelpUsage="audiopackage <katalog wejściowy>"

[DumpTextureInfoCommandlet]
HelpCmd=dumptextureinfo
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Dumps information about textures."
HelpOneLiner="Zrzuca informacje o teksturach."
; EN: HelpUsage="dumptextureinfo <pkg>"
HelpUsage="dumptextureinfo <nazwaPakietu>"

[MusicPackagesCommandlet]
HelpCmd=musicpackages
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Creates music packages out of a directory."
HelpOneLiner="Tworzy pakiety muzyczne z katalogu."
; EN: HelpUsage="musicpackages <input directory>"
HelpUsage="musicpackages <katalog wejściowy>"

[ReduceTexturesCommandlet]
HelpCmd=reducetextures
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Purges unneeded uncompressed mipmaps."
HelpOneLiner="Usuwa niepotrzebne nieskompresowane mipmapy."
; EN: HelpUsage="reducetextures <inpkg> <outpkg>"
HelpUsage="reducetextures <inpkg> <outpkg>"

[SaveEmbeddedCommandlet]
HelpCmd=saveembedded
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Saves an embedded package to a separate file."
HelpOneLiner="Zapisuje osadzony pakiet w oddzielnym pliku."
; EN: HelpUsage="saveembedded <pkg> <embpkg> <outfile>"
HelpUsage="saveembedded <nazwaPakietu> <embpkg> <outfile>"
HelpParm[0]="   "
HelpDesc[0]="   "
HelpParm[1]="   "
HelpDesc[1]="   "

[BatchMeshExportCommandlet]
HelpCmd=batchmeshexport
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Batch exports meshes."
HelpOneLiner="Siatki eksportu zbiorczego."
; EN: HelpUsage="batchmeshexport <pkg> <format> <outpath>"
HelpUsage="batchmeshexport <nazwaPakietu> <format> <outpath>"

[RebuildImportsCommandlet]
HelpCmd=rebuildimports
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Rebuilds import script for a package."
HelpOneLiner="Odbudowuje skrypt importu dla pakietu."
; EN: HelpUsage="rebuildimports <pkg> [-upkg]"
HelpUsage="rebuildimports <nazwaPakietu> [-upkg]"
HelpParm[0]="-upkg"
; EN: HelpDesc[0]="Switches output to upkg format. Default is uc."
HelpDesc[0]="Przełącza wyjście na format upkg. Domyślnie jest to uc."

[ProdigiosumInParvoCommandlet]
HelpCmd=prodigiosuminparvo
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Batch exports all mip map levels."
HelpOneLiner="Batch eksportuje wszystkie poziomy map mip."
; EN: HelpUsage="prodigiosuminparvo <pkg> <format> <outpath>"
HelpUsage="prodigiosuminparvo <nazwaPakietu> <format> <outpath>"

[FullBatchExportCommandlet]
HelpCmd=fullbatchexport
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Extract package with directory structure."
HelpOneLiner="Rozpakuj pakiet ze strukturą katalogów."
; EN: HelpUsage="fullbatchexport <pkg> <outpath>"
HelpUsage="fullbatchexport <nazwaPakietu> <outpath>"
; EN: HelpDesc[0]="Optional, to define export format:"
HelpDesc[0]="Opcjonalnie, aby zdefiniować format eksportu:"
HelpParm[0]="   -DefaultFontExtension"
HelpParm[1]="   -DefaultMusicExtension"
HelpParm[2]="   -DefaultSoundExtension"
HelpParm[3]="   -DefaultTextureExtension"

[FontPageDiffCommandlet]
HelpCmd=fontpagediff
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Compares font pages."
HelpOneLiner="Porównuje strony z czcionkami."
; EN: HelpUsage="fontpagediff <left font> <right font>"
HelpUsage="fontpagediff <lewa czcionka> <prawa czcionka>"

[RipAndTearCommandlet]
HelpCmd=ripandtear
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpUsage="Splits MyLevel resources from a map and saves the map and its resources as separate packages."
HelpUsage="Dzieli zasoby MyLevel z mapy i zapisuje mapę i jej zasoby jako oddzielne pakiety."
; EN: HelpOneLiner="ripandtear <inputmap> <outputmap> <outputresources>"
HelpOneLiner="ripandtear <Mapa wejściowa> <Mapa wyjściowa> <Zasoby wyjściowe>"
; EN: HelpDesc[0]="<inputmap>"
HelpDesc[0]="<Mapa wejściowa>"
; EN: HelpParm[0]="The map to read MyLevel resources from."
HelpParm[0]="Mapa, z której mają być odczytywane zasoby MyLevel."
; EN: HelpDesc[1]="<outputmap>"
HelpDesc[1]="<Mapa wyjściowa>"
; EN: HelpParm[1]="The map to output the non-MyLevel'd map to."
HelpParm[1]="Mapa, do której ma zostać wyprowadzona mapa inna niż MyLevel'd."
; EN: HelpDesc[2]="<outputresources>"
HelpDesc[2]="<Zasoby wyjściowe>"
; EN: HelpParm[2]="The class of output resources to take from the input map."
HelpParm[2]="Klasa zasobów wyjściowych do pobrania z mapy wejściowej."

[TextureMergerCommandlet]
HelpCmd=texturemerger
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpUsage="Merges new high-res textures into an existing package or adds additional height- and normalmaps. Supports compressing of .bmp textures into BC1-BC7 formats during import. Can add additional footstep, clamp, detail and macrotexture information."
HelpUsage="Łączy nowe tekstury o wysokiej rozdzielczości z istniejącym pakietem lub dodaje dodatkowe mapy wysokości i mapy normalnych. Obsługuje kompresję tekstur .bmp do formatów BC1-BC7 podczas importu. Może dodać dodatkowe informacje o odgłosach kroków, zaciskach, szczegółach i makroteksturach."
; EN: HelpOneLiner="texturemerger [packagename]"
HelpOneLiner="texturemerger [nazwaPakietu]"
; EN: HelpDesc[0]="[packagename]"
HelpDesc[0]="[nazwaPakietu]"
; EN: HelpParm[0]="An optional parameter, it's the package where the textures will be saved to."
HelpParm[0]="Parametr opcjonalny, to pakiet, w którym zostaną zapisane tekstury."
HelpDesc[1]=" "
; EN: HelpParm[1]="If no PackageName is specified, the TextureMerge directory is used in order to locate the names of all subfolders in searching for corresponding packages."
HelpParm[1]="Jeśli nie określono nazwaPakietu, katalog "TextureMerge" jest używany do zlokalizowania nazw wszystkich podfolderów podczas wyszukiwania odpowiednich pakietów."

[FontExporter]
HelpCmd=FontExporter
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Exports font pages."
HelpOneLiner="Eksportuje strony czcionek."
; EN: HelpUsage="FontExporter <pkg> <outpath>"
HelpUsage="FontExporter <nazwaPakietu> <outpath>"
