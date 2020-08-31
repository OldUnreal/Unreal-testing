[Public]
Object=(Name=Engine.Console,Class=Class,MetaClass=Engine.Console)
Object=(Name=Engine.ServerCommandlet,Class=Class,MetaClass=Core.Commandlet)
Preferences=(Caption="Avancé",Parent="Options avancées")
Preferences=(Caption="Paramètres moteur",Parent="Avancé",Class=Engine.GameEngine,Category=Paramètres,Immediate=True)
Preferences=(Caption="Paramètres clavier",Parent="Avancé",Class=Engine.Input,Immediate=True,Category=Aliases)
Preferences=(Caption="Raccourcis claviers basiques",Parent="Avancé",Class=Engine.Input,Immediate=True,Category=RawKeys)
Preferences=(Caption="Pilotes",Parent="Options avancées",Class=Engine.Engine,Immediate=False,Category=Drivers)
Preferences=(Caption="Informations publiques du serveur",Parent="Réseau",Class=Engine.GameReplicationInfo,Immediate=True)
Preferences=(Caption="Paramètres du jeu",Parent="Options avancées",Class=Engine.GameInfo,Immediate=True)
Preferences=(Caption="Sprites",Parent="Options avancées")
Preferences=(Caption="Sang",Parent="Sprites")
Preferences=(Caption="Serveur",Parent="Sang",Class=Engine.GameInfo,Category=Bloodserver,Immediate=True)
Preferences=(Caption="Ombres des personnages",Parent="Sprites",Class=Engine.PawnShadow,Immediate=True)
Preferences=(Caption="Ombres des décorations",Parent="Sprites",Class=Engine.DecoShadow,Immediate=True)
Preferences=(Caption="Ombres des projectiles",Parent="Sprites",Class=Engine.ProjectileShadow,Immediate=True)
Preferences=(Caption="Compression d'envoi",Parent="Réseau",Class=Engine.ChannelDownload)

[PlayerPawn]
QuickSaveString="Sauvegarde rapide"
NoPauseMessage="Le jeu ne peut pas être mis en pause"
ViewingFrom="Suivi du point de vue de "
OwnCamera="Caméra libre"
FailedView="Impossible de changer de vue."
CantChangeNameMsg="Vous ne pouvez pas changer de nom pendant un match."

[Pawn]
NameArticle=" un "

[Console]
LoadingMessage="CHARGEMENT"
SavingMessage="SAUVEGARDE"
ConnectingMessage="CONNEXION EN COURS"
PausedMessage="PAUSE"
PrecachingMessage="PRECHARGEMENT"
ClassCaption=Console Unreal Standard
ChatChannel="CHAT) "
TeamChannel="EQP) "

[Menu]
MenuList=
HelpMessage=
HelpMessage[1]="Ce menu n'existe pas encore."
LeftString="Gauche"
RightString="Droite"
CenterString="Centre"
EnabledString="Activé"
DisabledString="Désactivé"
YesString="oui"
NoString="non"

[Inventory]
PickupMessage="Attraper un objet"
ItemArticle="un"
M_Activated=" activé"
M_Selected=" selectionné"
M_Deactivated=" désactivé"

[GameInfo]
SwitchLevelMessage="Changement de niveau"
DefaultPlayerName="Player"
LeftMessage=" a quitté la partie."
FailedSpawnMessage="Impossible de générer un acteur joueur"
FailedPlaceMessage="Impossible de trouver un point de départ (il n'y a peut-être pas d'actor PlayerStart)"
FailedTeamMessage="Impossible d'assigner une équipe au joueur"
NameChangedMessage="Nom changé en "
EnteredMessage=" a rejoint la partie."
GameName="Partie"
MaxedOutMessage="Le serveur est déjà plein."
WrongPassword="Le mot de passe saisi est incorrect."
NeedPassword="Vous devez saisir un mot de passe pour rejoindre cette partie."

[LevelInfo]
Title="Sans titre"

[Weapon]
MessageNoAmmo=" est sans munitions."
DeathMessage="%o a été tué par le %w de %k."
PickupMessage="Vous avez trouvé une arme."
ItemName="Arme"
DeathMessage[0]=%o a été tué par le %w de %k.
DeathMessage[1]=%o a été tué par le %w de %k.
DeathMessage[2]=%o a été tué par le %w de %k.
DeathMessage[3]=%o a été tué par le %w de %k.

[Ammo]
PickupMessage="Vous avez ramassé des munitions."

[Counter]
CountMessage="Plus que %i ..."
CompleteMessage="Réussi !"

[Spectator]
MenuName="Spectateur"

[DamageType]
Name="tué"
AltName="abattu"
NameFem="tuée"
AltNameFem="abattue"

[AdminAccessManager]
AdminLoginText="Administrateur %s connecté."
AdminLogoutText="Administrateur %s déconnecté."
CheatUsedStr="%s a utilisé une commande de triche ou d'administration : %c"

[Fonts]
WhiteFont=UnrealShare.WhiteFont
MedFont=Engine.MedFont
LargeFont=Engine.LargeFont
BigFont=Engine.BigFont

[Errors]
NetOpen=Erreur à l'ouverture du fichier.
NetWrite=Erreur lors de l'écriture du fichier.
NetRefused=Le serveur refuse d'envoyer '%s'
NetClose=Erreur à la fermeture du fichier.
NetSize=Taille du fichier non conforme.
NetMove=Erreur lors du déplacement du fichier.
NetInvalid=Requête de fichier invalide à la réception.
NoDownload=Le package '%s' ne peut pas être téléchargé.
DownloadFailed=téléchargement de '%s' interrompu : %s
RequestDenied=Reqête de fichier demandé par le niveau en attente refusé.
ConnectionFailed=Connexion échouée.
Banned=Vous avez été banni.
TempBanned=Vous avez été temporairement banni.
Kicked=Vous avez été éjecté.
ChAllocate=Attribution de canal impossible.
NetAlready=Déjà en réseau.
NetListen=Ecoute impossible: pas de contexte linker disponible.
LoadEntry=Chargement de Entry impossible : %s
InvalidUrl=Mauvaise URL : %s
InvalidLink=Mauvais lien : %s
FailedBrowse=Impossible de rejoindre %s : %s
Listen=Ecoute impossible: %s
AbortToEntry=Echec; renvoi à Entry.
ServerOpen=Les serveurs ne peuvent pas ouvrir les URLs réseau.
ServerListen=Les serveurs dédiés ne peuvent pas écouter: %s
Pending=Connexion en cours à '%s' interrompue; %s
LoadPlayerClass=Impossible de charger la classe du joueur.
ServerOutdated=Le serveur n'est pas à jour.

[Progress]
CancelledConnect=Tentative de connexion interrompue
RunningNet=%s: %s (%i joueurs)
NetReceiving=Réception de '%s': %i/%i
NetReceiveOk=Réception réussie '%s'
NetSend=Sending '%s'
NetSending=Envoi de '%s': %i/%i
Connecting=Connexion...
Listening=Ecoute des clients...
Loading=Chargement
Saving=Sauvegarde
Paused=Mis en pause par %s
ReceiveFile=Reception de '%s' (F10 pour annuler)
ReceiveOptionalFile=Réception du fichier optionnel '%s' (F10 pour passer)
ReceiveSize=Taille : %iK, terminé %3.1f%% = %iK, %i Packages restants
ConnectingText=Connexion (F10 pour annuler):
ConnectingURL=unreal://%s/%s

[General]
Upgrade=La connexion à ce serveur nécessite la mise à jour gratuite disponible sur OldUnreal à :
UpgradeURL=http://www.oldunreal.com/oldunrealpatches.html
UpgradeQuestion=Voulez-vous lancer votre navigateur pour vous procurer la mise à jour ?
Version=Version %i

[WarpZoneInfo]
OtherSideURL=

[Pickup]
ExpireMessage=

[SpecialEvent]
DamageString=

[ServerCommandlet]
HelpCmd=Serveur
HelpOneLiner=Serveur de jeu en ligne
HelpUsage=Serveur map.unr[?game=mode_de_jeu][-option...][paramètre=valeur_ou_nom_du_paramètre]...
HelpWebLink=http://wiki.oldunreal.com
HelpParm[0]=Log
HelpDesc[0]=Spécifier le fichier log à générer
HelpParm[1]=Administration totale
HelpDesc[1]=Donne les privilège d'administration à tous les joueurs