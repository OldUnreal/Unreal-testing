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
; EN: Preferences=(Caption="Editor",Parent="Advanced Options")
Preferences=(Caption="Editeur",Parent="Options avancées")
; EN: Preferences=(Caption="Advanced (Editor)",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=Advanced)
Preferences=(Caption="Avancées (Editeur)",Parent="Editeur",Class=Editor.EditorEngine,Immediate=True,Category=Advanced)
; EN: Preferences=(Caption="Colors",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=Colors)
Preferences=(Caption="Couleurs",Parent="Editeur",Class=Editor.EditorEngine,Immediate=True,Category=Colors)
; EN: Preferences=(Caption="Grid",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=Grid)
Preferences=(Caption="Grille",Parent="Editeur",Class=Editor.EditorEngine,Immediate=True,Category=Grid)
; EN: Preferences=(Caption="Rotation Grid",Parent="Editor",Class=Editor.EditorEngine,Immediate=True,Category=RotationGrid)
Preferences=(Caption="Grille de rotation",Parent="Editeur",Class=Editor.EditorEngine,Immediate=True,Category=RotationGrid)
; "Commandlets and Exporters" subtree
; EN: Preferences=(Caption="Commandlets and Exporters",Parent="Editor")
Preferences=(Caption="Applicommandes et Exportateurs",Parent="Éditeur")
; EN: Preferences=(Caption="AudioPackage Commandlet",Parent="Commandlets and Exporters",Class=Editor.AudioPackageCommandlet,Immediate=True)
Preferences=(Caption="Applicommande AudioPackage",Parent="Applicommandes et Exportateurs",Class=Editor.AudioPackageCommandlet,Immediate=True)
; EN: Preferences=(Caption="BatchMeshExport Commandlet",Parent="Commandlets and Exporters",Class=Editor.BatchMeshExportCommandlet,Immediate=True)
Preferences=(Caption="Applicommande BatchMeshExport",Parent="Applicommandes et Exportateurs",Class=Editor.BatchMeshExportCommandlet,Immediate=True)
; EN: Preferences=(Caption="FullBatchExport Commandlet",Parent="Commandlets and Exporters",Class=Editor.FullBatchExportCommandlet,Immediate=True)
Preferences=(Caption="Applicommande FullBatchExport",Parent="Applicommandes et Exportateurs",Class=Editor.FullBatchExportCommandlet,Immediate=True)
; EN: Preferences=(Caption="MusicPackages Commandlet",Parent="Commandlets and Exporters",Class=Editor.MusicPackagesCommandlet,Immediate=True)
Preferences=(Caption="Applicommande MusicPackages",Parent="Applicommandes et Exportateurs",Class=Editor.MusicPackagesCommandlet,Immediate=True)
; EN: Preferences=(Caption="RebuildImports Commandlet",Parent="Commandlets and Exporters",Class=Editor.RebuildImportsCommandlet,Immediate=True)
Preferences=(Caption="Applicommande RebuildImports",Parent="Applicommandes et Exportateurs",Class=Editor.RebuildImportsCommandlet,Immediate=True)
; EN: Preferences=(Caption="SkeletalAnim (PSA) Exporter",Parent="Commandlets and Exporters",Class=Editor.SkeletalAnimExpPSA,Immediate=True)
Preferences=(Caption="Exportateur SkeletalAnim (PSA)",Parent="Applicommandes et Exportateurs",Class=Editor.SkeletalAnimExpPSA,Immediate=True)

[MasterCommandlet]
HelpCmd=master
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Build master installer files"
HelpOneLiner="Créer master installer."
; EN: HelpUsage="master [-option...] [parm=value]..."
HelpUsage="master [-option...] [parm=valeur] ..."
HelpParm[0]="MasterPath"
; EN: HelpDesc[0]="Root directory to copy source files from."
HelpDesc[0]="Dossier racine dont seront extraites les sources."
HelpParm[1]="SrcPath"
; EN: HelpDesc[1]="Root directory to copy source (release) files to."
HelpDesc[1]="Dossier racine où enregistrer les sources."
HelpParm[2]="RefPath"
; EN: HelpDesc[2]="Path for delta-compressed path reference."
HelpDesc[2]="Chemin des références avec compression delta."

[MakeCommandlet]
HelpCmd=make
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Rebuild UnrealScript packages."
HelpOneLiner="Compile les packages UnrealScript."
; EN: HelpUsage="make [-option...] [parm=value]..."
HelpUsage="make [-option...] [parm=valeur] ..."
HelpParm[0]="Silent"
; EN: HelpDesc[0]="No prompts; assume 'yes' to all questions."
HelpDesc[0]="Pas de questions, répondra automatiquement "oui" à toute les questions."
HelpParm[1]="NoBind"
; EN: HelpDesc[1]="Don't force native functions to be bound to DLLs."
HelpDesc[1]="Ne force pas les fonctions natives à êtres liées aux DLLs."
HelpParm[2]="All"
; EN: HelpDesc[2]="Clean rebuild (otherwise rebuild is incremental)."
HelpDesc[2]="Compilation propre (Sinon, les compilations sont incrémentées)."

[ConformCommandlet]
HelpCmd=conform
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Generate conforming binary files"
HelpOneLiner="Génère des binaires conformes."
; EN: HelpUsage="conform existing_file.ext old_file.ext"
HelpUsage="conform Fichier_Existant.ext Ancien_Fichier.ext"
; EN: HelpParm[0]="existing_file.ext"
HelpParm[0]="Fichier_Existant.ext"
; EN: HelpDesc[0]="Existing binary file to load, conform, and save."
HelpDesc[0]="Binaire existant à charger, conformer et sauver."
; EN: HelpParm[1]="old_file.ext"
HelpParm[1]="Ancien_Fichier.ext"
; EN: HelpDesc[1]="Old file to make source file binary compatible with."
HelpDesc[1]="Ancien Fichier avec lequel lequel le binaire doit être compatible."

[BatchExportCommandlet]
HelpCmd=batchexport
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Export objects in bulk."
HelpOneLiner="Export d'objets en masse."
; EN: HelpUsage="batchexport package.ext classname export_ext [path]"
HelpUsage="batchexport package.ext nomDeClasse export_ext [chemin]"
; EN: HelpParm[0]="package.ext"
HelpParm[0]="package.ext"
; EN: HelpDesc[0]="Package whose objects you wish to export."
HelpDesc[0]="Package dont vous souhaitez exporter un item."
; EN: HelpParm[1]="classname"
HelpParm[1]="nomDeClasse"
; EN: HelpDesc[1]="Class of object to export. It can be one of the following:"
HelpDesc[1]="Classe d'objet à exporter. Il peut s'agir de l'un des éléments suivants:"
HelpParm[2]="   "
HelpDesc[2]="   class, texture, sound, music, level, model, polys, textbuffer"
; EN: HelpParm[3]="export_ext"
HelpParm[3]="export_ext"
; EN: HelpDesc[3]="File extension to export to. The accepted file extensions per class are as follows:"
HelpDesc[3]="Extension de fichier vers laquelle exporter. Les extensions de fichier acceptées par classe sont les suivantes:"
HelpParm[4]="   "
HelpDesc[4]="   class: uc, h"
HelpParm[5]="   "
HelpDesc[5]="   texture: bmp, pcx"
HelpParm[6]="   "
HelpDesc[6]="   sound: wav"
HelpParm[7]="   "
; EN: HelpDesc[7]="   music: s3m, xm, it or any other tracker format"
HelpDesc[7]="   music: s3m, xm, it ou tout autre format de tracker"
HelpParm[8]="   "
HelpDesc[8]="   level: t3d"
HelpParm[9]="   "
HelpDesc[9]="   model: t3d"
HelpParm[10]="   "
HelpDesc[10]="   polys: t3d"
HelpParm[11]="   "
HelpDesc[11]="   textbuffer: txt"
; EN: HelpParm[12]="path"
HelpParm[12]="chemin"
; EN: HelpDesc[12]="Path to export files to, like C:\MyPath."
HelpDesc[12]="Chemin d'exportation, exemple: c:\MonChemin."

[PackageFlagCommandlet]
HelpCmd=packageflag
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Set package flags in package files."
HelpOneLiner="Modifie les flags du package."
; EN: HelpUsage="packageflag src.ext [<+|->flag [<+|->flag] ...]"
HelpUsage="packageflag src.ext [<+|->indicateur [<+|->indicateur] ...]"
; EN: HelpParm[0]="src.ext"
HelpParm[0]="src.ext"
; EN: HelpDesc[0]="Existing package file to load."
HelpDesc[0]="Package existant à charger."
; EN: HelpParm[1]="flag"
HelpParm[1]="indicateur"
; EN: HelpDesc[1]="+ to set a flag, or - to remove a flag, followed by one of:"
HelpDesc[1]="+ pour mettre, ou - pour enlever un flag, suivi par:"
HelpParm[2]="   AllowDownload"
; EN: HelpDesc[2]="   Clients are allowed to download this package from the server."
HelpDesc[2]="   Les clients sont autorisés à télécharger ce package à partir du serveur."
HelpParm[3]="   ClientOptional"
; EN: HelpDesc[3]="   Clients can choose to skip downloading this package from the server."
HelpDesc[3]="   Les clients peuvent choisir de ne pas télécharger ce package à partir du serveur."
HelpDesc[4]="   ServerSideOnly"
; EN: HelpDesc[4]="   The package has no network relevancy on a server."
HelpDesc[4]="   Le package n'a aucune pertinence réseau sur un serveur."
HelpParm[5]="   BrokenLinks"
; EN: HelpDesc[5]="   The package can be loaded with missing links."
HelpDesc[5]="   Le package peut être chargé avec des liens manquants."
HelpParm[6]="   Unsecure"
; EN: HelpDesc[6]="   Unused."
HelpDesc[6]="   Inutilisé."

[DataRipCommandlet]
HelpCmd=datarip
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Create a package with Texture, Music and Sound data ripped out."
HelpOneLiner="Créé un package de textures, musiques et sons extraits."
; EN: HelpUsage="datarip srcpackage.ext dstpackage.ext"
HelpUsage="datarip srcpackage.ext dstpackage.ext"
; EN: HelpParm[0]="srcpackage.ext"
HelpParm[0]="srcpackage.ext"
; EN: HelpDesc[0]="Source Package."
HelpDesc[0]="Paquet source."
; EN: HelpParm[1]="dstpackage.ext"
HelpParm[1]="dstpackage.ext"
; EN: HelpDesc[1]="Destination Package."
HelpDesc[1]="Paquet de destination."

[UpdateUModCommandlet]
HelpCmd=updateumod
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Add, delete, replace or extract files from an umod."
HelpOneLiner="Ajoute, enlève, remplace ou extrait les fichiers d'un .umod."
; EN: HelpUsage="updateumod UmodFile Command [Filename]"
HelpUsage="updateumod FichierUmod Commande [Nom du fichier]"
; EN: HelpParm[0]="UmodFile"
HelpParm[0]="FichierUmod"
; EN: HelpDesc[0]="The umod file to change or view."
HelpDesc[0]="Le fichier .umod à explorer ou changer."
; EN: HelpParm[1]="Command"
HelpParm[1]="Commande"
; EN: HelpDesc[1]="Can be one of the following:"
HelpDesc[1]="Il peut s'agir de l'un des éléments suivants:"
HelpParm[2]="   EXTRACT"
; EN: HelpDesc[2]="   File extraction"
HelpDesc[2]="   Extrait un fichier."
HelpParm[3]="   ADD"
; EN: HelpDesc[3]="   File addition"
HelpDesc[3]="   Ajoute un fichier."
HelpParm[4]="   DELETE"
; EN: HelpDesc[4]="   File deletion"
HelpDesc[4]="   Supprime un fichier."
HelpParm[5]="   REPLACE"
; EN: HelpDesc[5]="   File replacement"
HelpDesc[5]="   Remplace un fichier."
HelpParm[6]="   LIST"
; EN: HelpDesc[6]="   File listing"
HelpDesc[6]="   Répertorie tous les fichiers."
; EN: HelpParm[7]="Filename"
HelpParm[7]="Nom du fichier"
; EN: HelpDesc[7]="The file to EXTRACT, ADD, DELETE or REPLACE."
HelpDesc[7]="Le fichier à EXTRACT, ADD, DELETE ou REPLACE."

[ChecksumPackageCommandlet]
HelpCmd=checksumpackage
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Display checksum for package file."
HelpOneLiner="Afficher une somme de contrôle (checksum) pour le package."
; EN: HelpUsage="checksumpackage packagename"
HelpUsage="checksumpackage NomDuPackage"
; EN: HelpParm[0]="packagename"
HelpParm[0]="NomDuPackage"
; EN: HelpDesc[0]="The name of the package to checksum."
HelpDesc[0]="Le nom du package à controler."

[StripSourceCommandlet]
HelpCmd=StripSource
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Strip the script buffers from a package."
HelpOneLiner="Supprimez les tampons de script d'un package."
; EN: HelpUsage="stripsource packagename"
HelpUsage="stripsource nomDuPaquet"
; EN: HelpParm[0]="packagename"
HelpParm[0]="nomDuPaquet"
; EN: HelpDesc[0]="The name of the package to strip sources."
HelpDesc[0]="Le nom du package pour supprimer les sources."

[DumpIntCommandlet]
HelpCmd=DumpInt
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Dump the language text contents out of a file."
HelpOneLiner="Videz le contenu du texte de la langue d'un fichier."
; EN: HelpUsage="dumpint packagename"
HelpUsage="dumpint nomDuPaquet"
; EN: HelpParm[0]="packagename"
HelpParm[0]="nomDuPaquet"
; EN: HelpDesc[0]="The name of the package to dump language text of."
HelpDesc[0]="Le nom du package dont le texte de langue doit être vidé."

[ExportPackageCommandlet]
HelpCmd=ExportPackage
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Simply export a package contents to .uc files in prior directory."
HelpOneLiner="Exportez simplement le contenu d'un package vers des fichiers .uc dans le répertoire précédent."
; EN: HelpUsage="exportpackage packagename"
HelpUsage="exportpackage nomDuPaquet"
; EN: HelpParm[0]="packagename"
HelpParm[0]="nomDuPaquet"
; EN: HelpDesc[0]="The name of the package to export UC files of."
HelpDesc[0]="Le nom du package pour lequel exporter les fichiers UC."

[CompareIntCommandlet]
HelpCmd=CompareInt
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Compare 2 language files and delete/remove language entries that you compare with."
HelpOneLiner="Comparez 2 fichiers de langue et supprimez / supprimez les entrées de langue avec lesquelles vous comparez."
; EN: HelpUsage="compareint packageint miscint"
HelpUsage="compareint packageint miscint"
; EN: HelpParm[0]="packageint"
HelpParm[0]="packageint"
; EN: HelpDesc[0]="Main language file."
HelpDesc[0]="Fichier de langue principale."
; EN: HelpParm[1]="miscint"
HelpParm[1]="miscint"
; EN: HelpDesc[1]="Secondary language file (to edit)."
HelpDesc[1]="Fichier de langue secondaire (à modifier)."

[ListObjectsCommandlet]
HelpCmd=listobjects
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Lists Objects in package."
HelpOneLiner="Répertorie les objets dans le package."
; EN: HelpUsage="listobjects [-switch1 [-switch2 [...]]] <package> [<baseclass>]"
HelpUsage="listobjects [-switch1 [-switch2 [...]]] <paquet> [<classeBase>]"
; EN: HelpParm[0]="-switch1, -switch2..."
HelpParm[0]="-switch1, -switch2 ..."
; EN: HelpDesc[0]="Option switches, can be one or more of the following:"
HelpDesc[0]="Les commutateurs d'option peuvent être l'un ou plusieurs des éléments suivants:"
HelpParm[1]="   -cp"
; EN: HelpDesc[1]="   Prints pathname instead of name for Class."
HelpDesc[1]="   Imprime le chemin au lieu du nom de la classe."
HelpParm[2]="   -op"
; EN: HelpDesc[2]="   Prints pathname instead of name for Object."
HelpDesc[2]="   Imprime le chemin d'accès au lieu du nom de l'objet."
HelpParm[3]="   -na"
; EN: HelpDesc[3]="   Do not align output."
HelpDesc[3]="   N'alignez pas la sortie."
HelpParm[4]="   -ni"
; EN: HelpDesc[4]="   Do not indent object hierarchy."
HelpDesc[4]="   Ne mettez pas en retrait la hiérarchie des objets."
HelpParm[5]="   -nc"
; EN: HelpDesc[5]="   Do not display class."
HelpDesc[5]="   N'affichez pas la classe."
HelpParm[6]="   -co"
; EN: HelpDesc[6]="   Just display Object Classes instead of each Object."
HelpDesc[6]="   Affichez simplement les classes d'objets au lieu de chaque objet."
; EN: HelpParm[7]="package"
HelpParm[7]="paquet"
; EN: HelpDesc[7]="Package file."
HelpDesc[7]="Fichier de package."
; EN: HelpParm[8]="baseclass"
HelpParm[8]="classeBase"
; EN: HelpDesc[8]="Optional base class of listed objects."
HelpDesc[8]="Classe de base facultative des objets répertoriés."

[DumpMeshInfoCommandlet]
HelpCmd=dumpmeshinfo
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Dumps information about meshes."
HelpOneLiner="Vide les informations sur les maillages."
; EN: HelpUsage="dumpmeshinfo <pkg>"
HelpUsage="dumpmeshinfo <pkg>"

[CheckUnicodeCommandlet]
HelpCmd=checkunicode
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpUsage="Checks if the contents of a text file contains Unicode characters."
HelpUsage="Vérifie si le contenu d'un fichier texte contient des caractères Unicode."
; EN: HelpOneLiner="checkunicode <filewildcard>"
HelpOneLiner="checkunicode <FichierWildcard>"
; EN: HelpDesc[0]="<filewildcard>"
HelpDesc[0]="<FichierWildcard>"
; EN: HelpParm[0]="The files to check for Unicode characters. Can accept wildcards such as "*" and "?"."
HelpParm[0]="Les fichiers pour vérifier les caractères Unicode. Peut accepter des caractères génériques tels que "*" et "?"."

[AudioPackageCommandlet]
HelpCmd=audiopackage
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Create an audio package out of a directory."
HelpOneLiner="Créez un package audio à partir d'un répertoire."
; EN: HelpUsage="audiopackage <input directory>"
HelpUsage="audiopackage <répertoire d'entrée>"

[DumpTextureInfoCommandlet]
HelpCmd=dumptextureinfo
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Dumps information about textures."
HelpOneLiner="Décharge des informations sur les textures."
; EN: HelpUsage="dumptextureinfo <pkg>"
HelpUsage="dumptextureinfo <pkg>"

[MusicPackagesCommandlet]
HelpCmd=musicpackages
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Creates music packages out of a directory."
HelpOneLiner="Crée des packages musicaux à partir d'un répertoire."
; EN: HelpUsage="musicpackages <input directory>"
HelpUsage="musicpackages <répertoire d'entrée>"

[ReduceTexturesCommandlet]
HelpCmd=reducetextures
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Purges unneeded uncompressed mipmaps."
HelpOneLiner="Purge les mipmaps non compressés inutiles."
; EN: HelpUsage="reducetextures <inpkg> <outpkg>"
HelpUsage="reducetextures <inpkg> <outpkg>"

[SaveEmbeddedCommandlet]
HelpCmd=saveembedded
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Saves an embedded package to a separate file."
HelpOneLiner="Enregistre un package intégré dans un fichier séparé."
; EN: HelpUsage="saveembedded <pkg> <embpkg> <outfile>"
HelpUsage="saveembedded <pkg> <embpkg> <outfile>"
HelpParm[0]="   "
HelpDesc[0]="   "
HelpParm[1]="   "
HelpDesc[1]="   "

[BatchMeshExportCommandlet]
HelpCmd=batchmeshexport
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Batch exports meshes."
HelpOneLiner="Batch exporte les maillages."
; EN: HelpUsage="batchmeshexport <pkg> <format> <outpath>"
HelpUsage="batchmeshexport <pkg> <format> <outpath>"

[RebuildImportsCommandlet]
HelpCmd=rebuildimports
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Rebuilds import script for a package."
HelpOneLiner="Reconstruit le script d'importation pour un package."
; EN: HelpUsage="rebuildimports <pkg> [-upkg]"
HelpUsage="rebuildimports <pkg> [-upkg]"
HelpParm[0]="-upkg"
; EN: HelpDesc[0]="Switches output to upkg format. Default is uc."
HelpDesc[0]="Bascule la sortie au format upkg. La valeur par défaut est uc."

[ProdigiosumInParvoCommandlet]
HelpCmd=prodigiosuminparvo
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Batch exports all mip map levels."
HelpOneLiner="Batch exporte tous les niveaux de mip map."
; EN: HelpUsage="prodigiosuminparvo <pkg> <format> <outpath>"
HelpUsage="prodigiosuminparvo <pkg> <format> <outpath>"

[FullBatchExportCommandlet]
HelpCmd=fullbatchexport
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Extract package with directory structure."
HelpOneLiner="Extraire le package avec la structure de répertoires."
; EN: HelpUsage="fullbatchexport <pkg> <outpath>"
HelpUsage="fullbatchexport <pkg> <outpath>"

[FontPageDiffCommandlet]
HelpCmd=fontpagediff
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Compares font pages."
HelpOneLiner="Compare les pages de polices."
; EN: HelpUsage="fontpagediff <left font> <right font>"
HelpUsage="fontpagediff <police de gauche> <police de droite>"

[RipAndTearCommandlet]
HelpCmd=ripandtear
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpUsage="Splits MyLevel resources from a map and saves the map and its resources as separate packages."
HelpUsage="Divise les ressources MyLevel d'une carte et enregistre la carte et ses ressources sous forme de packages séparés."
; EN: HelpOneLiner="ripandtear <inputmap> <outputmap> <outputresources>"
HelpOneLiner="ripandtear <Carte d'entrée> <Carte de sortie> <Ressources de sortie>"
; EN: HelpDesc[0]="<inputmap>"
HelpDesc[0]="<Carte d'entrée>"
; EN: HelpParm[0]="The map to read MyLevel resources from."
HelpParm[0]="La carte à partir de laquelle lire les ressources MyLevel."
; EN: HelpDesc[1]="<outputmap>"
HelpDesc[1]="<Carte de sortie>"
; EN: HelpParm[1]="The map to output the non-MyLevel'd map to."
HelpParm[1]="La carte vers laquelle afficher la carte non MyLevel."
; EN: HelpDesc[2]="<outputresources>"
HelpDesc[2]="<Ressources de sortie>"
; EN: HelpParm[2]="The class of output resources to take from the input map."
HelpParm[2]="La classe des ressources de sortie à extraire de la carte d'entrée."

[TextureMergerCommandlet]
HelpCmd=texturemerger
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpUsage="Merges new high-res textures into an existing package or adds additional height- and normalmaps. Supports compressing of .bmp textures into BC1-BC7 formats during import. Can add additional footstep, clamp, detail and macrotexture information."
HelpUsage="Fusionne de nouvelles textures haute résolution dans un package existant ou ajoute des cartes de hauteur et des cartes normales supplémentaires. Prend en charge la compression des textures .bmp aux formats BC1-BC7 lors de l'importation. Peut ajouter des informations supplémentaires sur les pas, les pinces, les détails et les macrotextures."
; EN: HelpOneLiner="texturemerger [packagename]"
HelpOneLiner="texturemerger [nomPaquet]"
; EN: HelpDesc[0]="[packagename]"
HelpDesc[0]="[nomPaquet]"
; EN: HelpParm[0]="An optional parameter, it's the package where the textures will be saved to."
HelpParm[0]="Un paramètre facultatif, c'est le package dans lequel les textures seront enregistrées."
HelpDesc[0]=" "
; EN: HelpParm[1]="If no PackageName is specified, the TextureMerge directory is used in order to locate the names of all subfolders in searching for corresponding packages."
HelpParm[1]="Si aucun nomPaquet n'est spécifié, le répertoire TextureMerge est utilisé pour localiser les noms de tous les sous-dossiers lors de la recherche des packages correspondants." 

[FontExporter]
HelpCmd=FontExporter
HelpWebLink="https://www.oldunreal.com/wiki/index.php?title=Commandlet"
; EN: HelpOneLiner="Exports font pages."
HelpOneLiner="Exporte les pages de polices."
; EN: HelpUsage="FontExporter <pkg> <outpath>"
HelpUsage="FontExporter <pkg> <outpath>"
