[public]
Object=(Name=UWindow.UWindowWin95LookAndFeel,Class=Class,MetaClass=UWindow.UWindowLookAndFeel,Description="Win 95")

[UWindowMessageBoxCW]
; EN: YesText="Yes"
YesText="Tak"
; EN: NoText="No"
NoText="Nie"
; EN: OKText="OK"
OKText="OK"
; EN: CancelText="Cancel"
CancelText="Anuluj"

[UWindowConsoleWindow]
; EN: WindowTitle="System Console"
WindowTitle="Konsola systemowa"

[UWindowSmallCloseButton]
; EN: CloseText="Close"
CloseText="Zamknij"

[UWindowSmallCancelButton]
; EN: CancelText="Cancel"
CancelText="Anuluj"

[UWindowSmallOKButton]
; EN: OKText="OK"
OKText="OK"

[UWindowConsoleClientWindow]
; EN: ShowColorsText="Show console messages in colours"
ShowColorsText="Wyświetl wiadomości konsoli w różnych kolorach"
; EN: ShowChatText="Log only chat messages"
ShowChatText="Zapisuj wyłącznie treść konwersacji"
; EN: ShowWarningText="Log script errors"
ShowWarningText="Błędy skryptu dziennika"

[AdminGUIPlayersGrid]
; EN: PlayerID="ID#"
PlayerID="ID#"
; EN: PlayerName="Player Name"
PlayerName="Imię gracza"
; EN: PlayerIP="IP-Address"
PlayerIP="Adres IP"
; EN: PlayerClientID="Client ID"
PlayerClientID="ID klienta"
; EN: MaxLengthExceeded="Maximum player list length exceeded %i"
MaxLengthExceeded="Maksymalna długość listy graczy przekroczona o %i"
; EN: IDMismatchedStr="Response ID mismatched: %i/%j"
IDmismatchedStr="Otrzymano niezgodne ID: %i/%j"
; EN: ClientReceivedStr="Received client %ls."
ClientReceivedStr="Otrzymano ID klienta %ls."
; EN: GettingInfoStr="Getting player list from server, if nothing happens you may not be logged in as admin."
GettingInfoStr="Trwa pobieranie listy graczy z serwera. Jeżeli nic się nie pojawi, prawdopodobnie nie posiadasz uprawnień administracyjnych."

[AdminGUIBanLGrid]
; EN: LengthExceeded="Maximum player list length exceeded %i"
LengthExceeded="Maksymalna długość listy graczy przekroczona o %i"
; EN: ResponseMismatch="Response ID mismatched: %i/%j"
ResponseMismatch="Otrzymano niezgodne ID: %i/%j"
; EN: ReceiveBanText="Received ban %ls."
ReceiveBanText="Otrzymano bana %ls."
; EN: GettingBanListText="Getting banlist from server, if nothing happens you may not be logged in as admin (or there are no bans on server)."
GettingBanListText="Trwa pobieranie listy banów z serwera. Jeżeli nic się nie pojawi, prawdopodobnie nie posiadasz uprawnień administracyjnych (lub lista banów na serwerze jest pusta)."

[MMMusicListGrid]
; EN: MusicNameStr="Music name"
MusicNameStr="Tytuł utworu"
; EN: MusicPackStr="Music package"
MusicPackStr="Nazwa pliku"
; EN: FailedToPlayStr="Failed to play: Music %ls was not found or failed to load."
FailedToPlayStr="Odtwarzanie nieudane: nie znaleziono pliku %ls, lub jest on uszkodzony."
; EN: StartedPlayStr="Started playing music %ls with section %i."
StartedPlayStr="Rozpoczęto odtwarzanie %ls, sekcji %i."
; EN: NullErrorStr="Failed to add: NULL is not a valid song."
NullErrorStr="Dodanie do listy nieudane: NULL nie jest obsługiwany."
; EN: FailedLoadStr="Failed to add: Music %ls file could not be found or loaded."
FailedLoadStr="Dodanie do listy nieudane: nie znaleziono pliku %ls, lub jest on uszkodzony."
; EN: ConfirmInsertDuplicateTitle="Adding an already listed track"
ConfirmInsertDuplicateTitle="Dodawanie już wymienionego utworu"
; EN: ConfirmInsertDuplicateText="Such a track is already included in the playlist. Insert it anyway?"
ConfirmInsertDuplicateText="Taki utwór znajduje się już na liście odtwarzania. Wstawić mimo to?"
; EN: AddedStr="Added music %ls (%i)."
AddedStr="Dodano plik %ls (%i)."
; EN: RemoveSongStr="Removed song #%i."
RemoveSongStr="Usunięto plik #%i z listy."
; EN: ClearListStr="Removed all tracks from the playlist."
ClearListStr="Usunięto wszystkie utwory z listy odtwarzania."
; EN: AddAllStr="Added all musics to the list."
AddAllStr="Dodano wszystkie utwory muzyczne do listy."
; EN: ConfirmClearListTitle="Confirm clearing the playlist"
ConfirmClearListTitle="Potwierdź wyczyszczenie listy odtwarzania"
; EN: ConfirmClearListText="Do you want to clear the playlist?"
ConfirmClearListText="Czy chcesz wyczyścić listę odtwarzania?"
; EN: BadIndexStr="Failed to remove: Bad remove index."
BadIndexStr="Usunięcie z listy nieudane: niepoprawny numer indeksu."

[AdminGUIClientWindow]
; EN: PlayersListTxt="Clients List"
PlayersListTxt="Lista klientów"
; EN: BanListTxt="Banned Clients"
BanListTxt="Lista klientów zbanowanych"
; EN: TempBanListTxt="Session Banned Clients"
TempBanListTxt="Lista klientów zbanowanych na sesję"

[AdminGUIManBanClientW]
; EN: PlayerNameTxt="Client name (for banlisting purposes only):"
PlayerNameTxt="Nazwa klienta (do listy banów):"
; EN: PlayerIpTxt="Client IP address (or IP range if desired):"
PlayerIpTxt="Adres IP (lub zakres wielu adresów):"
; EN: InsertBanTxt="Insert ban"
InsertBanTxt="Wymierz bana"

[MMMainWindow]
; EN: WindowTitle="Music Menu"
WindowTitle="Odtwarzacz muzyczny"

[UWindowNetErrorClientWindow]
; EN: ReconnectText="Reconnect to server"
ReconnectText="Połącz się ponownie"
; EN: KickNetworkText="KICKED!|You have been kicked from this server by an administrator for remainder of the game.\\"
KickNetworkText="WYRZUCONO CIĘ!|Administrator usunął cię z tego serwera na czas rozgrywki.\\"
; EN: BanNetworkText="BANNED!|You have been banned from this server by an administrator for bad behaviour.\\\\If you feel like you don't deserve this ban, contact the administrator at: "
BanNetworkText="ZBANOWANO CIĘ!|Administrator zbanował cię na tym serwerze za złe zachowanie.\\\\Jeżeli uważasz, że ban był niezasłużony, skontaktuj się z administratorem: "
; EN: TempBanNetworkText="SESSION BANNED!|You have been temporarily banned from this server for remainder of the map.\\"
TempBanNetworkText="ZBANOWANO CIĘ NA CZAS SESJI!|Administrator zbanował cię tymczasowo na tym serwerze do czasu zmiany mapy.\\"

[MMControlsClient]
; EN: MusicVolumeText="Music Volume"
MusicVolumeText="Głośność muzyki"
; EN: BrowseText="Browse"
BrowseText="Przeglądaj pliki muzyczne"
; EN: BrowseHint="Browse music files"
BrowseHint="Przeglądaj pliki muzyczne"
; EN: AddAllText="Add All"
AddAllText="Dodaj wszystko"
; EN: AddAllHint="This will search through entire music directory and add all audio tracks to playlist."
AddAllHint="Spowoduje to przeszukanie całego katalogu muzycznego i dodanie wszystkich ścieżek audio do listy odtwarzania."
; EN: AddAllWinHdr="WARNING: Add all songs?"
AddAllWinHdr="OSTRZEŻENIE: Dodać wszystkie utwory?"
; EN: AddAllWarningText="This operation will be slow and will add every possible song to your playlist, proceed?"
AddAllWarningText="Ta operacja będzie powolna i doda każdą możliwą piosenkę do listy odtwarzania, kontynuować?"
; EN: AddMusicText="Add Music"
AddMusicText="Dodaj utwór"
; EN: AddMusicHint="Add music with the specified name"
AddMusicHint="Dodaj muzykę o określonej nazwie"
; EN: TimeLimitText="Time Limit"
TimeLimitText="Limit czasu"
; EN: TimeLimitHint="Select music playtime in minutes (0 = no time limit)"
TimeLimitHint="Określ czas odtwarzania (0 = odtwarzanie bez końca)"
; EN: SectionText="Song Section"
SectionText="Sekcja Piosenki"
; EN: SectionHint="Set initial music section (0 - 254)"
SectionHint="Wybierz sekcję utworu (0-255, zależy od utworu)"
; EN: MusicStoppedText="Music player was stopped."
MusicStoppedText="Odtwarzacz muzyczny został zatrzymany."
; EN: PlayTrackHint="Play track"
PlayTrackHint="Odtwarzaj utwór"
; EN: StopTrackHint="Stop track"
StopTrackHint="Zatrzymaj utwór"
; EN: PriorTrackHint="Prior track"
PriorTrackHint="Wcześniejszy utwór"
; EN: NextTrackHint="Next track"
NextTrackHint="Następny utwór"
; EN: ShuffleText="Shuffle playlist"
ShuffleText="Wymieszaj listę odtwarzania"
; EN: ShuffleHint="Next track is always selected at random."
ShuffleHint="Następny utwór jest zawsze wybierany losowo."

[UWindowNetErrorWindow]
; EN: WindowTitle="Player Network error status"
WindowTitle="Błędy sieci graczy"

[AdminGUIMainWindow]
; EN: WindowTitle="Admin Menu"
WindowTitle="Menu administracyjne"

[AdminGUIBanLPullDown]
; EN: RemoveBanTxt="&Remove ban"
RemoveBanTxt="Z&dejmij bana"
; EN: CloseMenuTxt="&Close this menu"
CloseMenuTxt="&Zamknij menu"
; EN: RefreshTxt="&Refresh banlist"
RefreshTxt="&Odśwież listę banów"
; EN: ManualBanTxt="&Manually insert ban entry"
ManualBanTxt="&Wymierz bana ręcznie"

[MMMusListWindow]
; EN: WindowTitle="Multiple music tracks found:"
WindowTitle="Znaleziono wiele utworów muzycznych:"

[MMListPullDown]
; EN: PlaySongStr="&Play"
PlaySongStr="&Odtwarzaj utwór"
; EN: RemoveSongStr="&Remove from playlist"
RemoveSongStr="&Usuń utwór"
; EN: InsertCurrentSongStr="&Insert currently playing track"
InsertCurrentSongStr="&Wstaw aktualnie odtwarzany utwór"
; EN: ClearPlaylistStr="&Clear playlist"
ClearPlaylistStr="&Wyczyść listę odtwarzania"

[MMMusicFilesGrid]
; EN: ErrorLoadPackage="Error: Failed to load music package."
ErrorLoadPackage="Błąd: Wczytywanie pliku muzycznego nieudane."
; EN: ErrorNoMusics="Error: Failed to find any musics in this package."
ErrorNoMusics="Błąd: Wczytany plik nie zawiera utworów muzycznych."

[AdminGUIPLPullDown]
; EN: GetAliasesTxt="&Get player aliases"
GetAliasesTxt="&Pobierz aliasy gracza"
; EN: KickPlayerTxt="&Kick player"
KickPlayerTxt="&Wyrzuć gracza"
; EN: KickBanTempTxt="&Temporarily kick-ban player"
KickBanTempTxt="Wyrzuć gracza i zbanuj &tymczasowo"
; EN: KickBanTxt="Kick-&ban player"
KickBanTxt="Wyrzuć i z&banuj gracza"
; EN: CloseMenuTxt="&Close this menu"
CloseMenuTxt="&Zamknij menu"
; EN: RefreshTxt="&Refresh players list"
RefreshTxt="&Odśwież listę graczy"

[AdminGUIManualBanWnd]
; EN: WindowTitle="Insert manual ban"
WindowTitle="Wprowadź dane do bana ręcznie:"

[AdminGUITBanLGrid]
; EN: GettingBanListText="Getting temp-banlist from server, if nothing happens you may not be logged in as admin (or there are no temp-bans on server)."
GettingBanListText="Trwa pobieranie listy banów tymczasowych z serwera. Jeżeli nic się nie pojawi, prawdopodobnie nie posiadasz uprawnień administracyjnych (lub lista banów tymczasowych na serwerze jest pusta)."

[FontStyle]
SmallFont=UWindowFonts.Tahoma10
SmallFontBold=UWindowFonts.TahomaB10
MedFont=UWindowFonts.Tahoma20
MedFontBold=UWindowFonts.TahomaB20
LargeFont=UWindowFonts.Tahoma30
LargeFontBold=UWindowFonts.TahomaB30

[UWindowSmallRestartButton]
; EN: RestartText="Restart"
RestartText="Uruchom ponownie"

[WindowConsole]
; EN: WarningMessage="Something is creating script warnings..."
WarningMessage="Coś tworzy ostrzeżenia skryptu..."
