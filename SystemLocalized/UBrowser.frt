[Public]
Object=(Name=UBrowser.UBrowserConsole,Class=Class,MetaClass=Engine.Console,Description="UBrowser")
; EN: Preferences=(Caption="UBrowser",Parent="Networking",Class=UBrowser.UBrowserMainClientWindow,Immediate=True)
Preferences=(Caption="UBrowser",Parent="Réseau",Class=UBrowser.UBrowserMainClientWindow,Immediate=True)

[UBrowserServerListWindow]
; EN: InfoName="Info"
InfoName="Info"
; EN: PlayerCountName="Players"
PlayerCountName="Joueurs"
; EN: ServerCountName="Servers"
ServerCountName="Serveurs"
; EN: QueryServerText="Querying Master Server (hit F5 if nothing happens)"
QueryServerText="Requête au Master Server (Appuyez sur F5 si rien ne se passe)"
; EN: QueryFailedText="Master Server Failed: "
QueryFailedText="Echec du Master Server: "
; EN: PingingText="Pinging Servers"
PingingText="Ping des serveurs"
; EN: CompleteText="Complete"
CompleteText="Terminé"

[UBrowserGSpyLink]
; EN: ResolveFailedError="The master server could not be resolved: "
ResolveFailedError="Impossible de résoudre le Master Server: "
; EN: TimeOutError="Timeout talking to the master server"
TimeOutError="Dépassement de requète sur le Master Server"
; EN: CouldNotConnectError="Connecting to the master server timed out: "
CouldNotConnectError="Temps de connexion dépassé sur le Master Server: "

[UBrowserHTTPLink]
; EN: ResolveFailedError="The master server could not be resolved: "
ResolveFailedError="Impossible de résoudre le Master Server: "
; EN: TimeOutError="Timeout talking to the master server"
TimeOutError="Dépassement de requète sur le Master Server"
; EN: CouldNotConnectError="Connecting to the master server timed out: "
CouldNotConnectError="Temps de connexion dépassé sur le Master Server: "

[UBrowserSubsetFact]
; EN: NotFoundError="Could not find the window: "
NotFoundError="Fenêtre non disponible: "
; EN: NotReadyError="Window is not ready: "
NotReadyError="Fenêtre non prète: "

[UBrowserRulesGrid]
; EN: RuleText="Rule"
RuleText="Règles"
; EN: ValueText="Value"
ValueText="Valeur"

[UBrowserServerPing]
; EN: AdminEmailText="Admin Email"
AdminEmailText="Email Administrateur"
; EN: AdminNameText="Admin Name"
AdminNameText="Nom de l'administrateur"
; EN: ChangeLevelsText="Change Levels"
ChangeLevelsText="Changement de niveau"
; EN: MultiplayerBotsText="Bots in Multiplayer"
MultiplayerBotsText="Bots en mulijoueurs"
; EN: FragLimitText="Frag Limit"
FragLimitText="Limite de Frags"
; EN: TimeLimitText="Time Limit"
TimeLimitText="Limite de temps"
; EN: GameModeText="Game Mode"
GameModeText="Mode de jeu"
; EN: GameTypeText="Game Type"
GameTypeText="Type de jeu"
; EN: GameVersionText="Game Version"
GameVersionText="Version du jeu"
; EN: GameSubVersionText="Game SubVersion"
GameSubVersionText="Sous-Version"
; EN: WorldLogText="ngStats World Stat-Logging"
WorldLogText="Enregistrement des stats au ngStats World"
; EN: TrueString="Enabled"
TrueString="Activé"
; EN: FalseString="Disabled"
FalseString="Désactivé"
; EN: MapFileString="Map Filename"
MapFileString="Nom du niveau"
; EN: DLLString="C++ Library"
DLLString="Bibliothèque C++"
; EN: DLLVerString="%ls (ver %i)"
DLLVerString="%ls (ver %i)"
; EN: WebURLString="Website URL"
WebURLString="Adresse web"
; EN: ServerOSString="Server OS"
ServerOSString="OS du serveur"
; EN: GameClassString="Game Class"
GameClassString="Classe de jeu"

[UBrowserMainClientWindow]
; EN: FavoritesName="Favorites"
FavoritesName="Favoris"
; EN: NewsName="Community News"
NewsName="Communauté"
; EN: RecentName="Recent Servers"
RecentName="Derniers Servers"

[UBrowserServerGrid]
; EN: ServerName="Server"
ServerName="Serveur"
; EN: PingName="Ping"
PingName="Ping"
; EN: MapNameName="Map Name"
MapNameName="Carte"
; EN: PlayersName="Players"
PlayersName="Joueurs"
; EN: VersionName="Version"
VersionName="Version"

[UBrowserInfoMenu]
; EN: RefreshName="&Refresh Info"
RefreshName="&Actualiser Info"
; EN: AttachName="&Attach Window"
AttachName="&Attacher la Fenêtre"
; EN: CloseName="&Close Window"
CloseName="&Fermer la Fenêtre"

[UBrowserMainWindow]
; EN: WindowTitleString="Unreal Server Browser"
WindowTitleString="Navigateur de Serveurs Unreal"

[UBrowserRightClickMenu]
; EN: RefreshName="&Refresh All Servers"
RefreshName="&Actualiser tous les serveurs"
; EN: FavoritesName="Add to &Favorites"
FavoritesName="Ajouter aux &Favoris"
; EN: RemoveFavoritesName="Remove from &Favorites"
RemoveFavoritesName="&Retirer des Favoris"
; EN: RefreshServerName="&Ping This Server"
RefreshServerName="&Ping sur ce serveur"
; EN: PingAllName="Ping &All Servers"
PingAllName="Ping sur &tous les serveurs"
; EN: InfoName="&Server and Player Info"
InfoName="&Infos sur le Serveur et les joueurs"
; EN: JoinPasswordName="Join with &Password"
JoinPasswordName="Rejoindre avec &mot de passe"
; EN: JoinServerName="&Join server"
JoinServerName="Re&joindre ce serveur"
; EN: SpectateServerName="Join as &Spectator"
SpectateServerName="Rejoindre en tant que &Spectateur"
; EN: ServerWebsiteName="Show server &Website"
ServerWebsiteName="&Voir le site web"
; EN: CopyAddressName="&Copy server address"
CopyAddressName="&Copier l'adresse"

[UBrowserPlayerGrid]
; EN: NameText="Name"
NameText="Nom"
; EN: FragsText="Frags"
FragsText="Frags"
; EN: PingText="Ping"
PingText="Ping"
; EN: TeamText="Team"
TeamText="Équipe"
; EN: MeshText="Mesh"
MeshText="Modèle"
; EN: SkinText="Skin"
SkinText="Skin"
; EN: IDText="ID"
IDText="ID"

[UBrowserLibPageWindow]
; EN: DLLTitleStr="Can't connect: Missing Dynamic Link Library %ls."
DLLTitleStr="Connexion impossible: la bibliothèque dynamique %ls n'est pas disponible."
; EN: DLLVerTitleStr="Can't connect: Dynamic Link Library version mismatched %ls."
DLLVerTitleStr="Connexion impossible: incompatibilité dans la bibliothèque dynamique %ls."
; EN: InfoText[0]="To connect this server you will need additional C++ library %ls."
InfoText[0]="La connexion à ce serveur nécessire la bibliothèque C++ %ls."
; EN: InfoText[1]="For more info view the external info from below (hosted by %ls):"
InfoText[1]="Plus d'informations disponibles dans les informations externes ci-dessous (hébergées par %ls):"

[UBrowserConsole]
; EN: ClassCaption="Unreal Browser Console"
ClassCaption="Console de Navigation Unreal"

[UBrowserOpenBar]
; EN: OpenText="Open:"
OpenText="Ouvrir:"
; EN: OpenHelp="Enter a standard URL, or select one from the URL history. Press Enter to activate."
OpenHelp="Entrez une URL, ou sélectionnez une URL de l'historique. Entrer pour valider."

[UBrowserServerWebWin]
; EN: WindowTitle="Unreal Web Explorer"
WindowTitle="Navigateur web Unreal"

[UBrowserServerWebCW]
; EN: RefreshString="Refresh page"
RefreshString="Rafraîchir la page"
