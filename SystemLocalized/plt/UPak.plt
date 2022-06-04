[Public]
Object=(Name=Game.Game,Class=Class,MetaClass=UnrealShare.SinglePlayer,Description="Intro1;UPak.Return;Return to Na Pali")
Object=(Name=UPak.UPakConsole,Class=Class,MetaClass=Engine.Console,Description="Unreal Gold")
Object=(Name=UPak.CrashSiteGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.UPakSinglePlayer,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.UPakTransitionInfo,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.UPakGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.CloakMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.UPakCoopGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.DuskFallsGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.CloakGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.MarineMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.GravityMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.TestGameInfo,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.TerranWeaponMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.UPakIntro,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UPak.CreditsGame,Class=Class,MetaClass=Engine.GameInfo)
; EN: Object=(Name=UPak.GrenadeLauncher,Class=Class,MetaClass=Engine.Weapon,Description="UMS Grenade Launcher")
Object=(Name=UPak.GrenadeLauncher,Class=Class,MetaClass=Engine.Weapon,Description="Wyrzutnia Granatów UMS")
; EN: Object=(Name=UPak.RocketLauncher,Class=Class,MetaClass=Engine.Weapon,Description="UMS Rocket Launcher")
Object=(Name=UPak.RocketLauncher,Class=Class,MetaClass=Engine.Weapon,Description="Wyrzutnia Rakiet UMS")
; EN: Object=(Name=UPak.CARifle,Class=Class,MetaClass=Engine.Weapon,Description="Combat Assault Rifle")
Object=(Name=UPak.CARifle,Class=Class,MetaClass=Engine.Weapon,Description="Karabin Szturmowy")
Preferences=(Caption="Cloak Match",Parent="Game Types",LangCaption="DM z Kamuflażem",Class=UPak.CloakMatch,Immediate=True)
Preferences=(Caption="Gravity Match",Parent="Game Types",LangCaption="DM z Obniżoną Grawitacją",Class=UPak.GravityMatch,Immediate=True)
Preferences=(Caption="Marine Match",Parent="Game Types",LangCaption="DM z Piechotą Morską",Class=UPak.MarineMatch,Immediate=True)
Preferences=(Caption="Terran Weapon Match",Parent="Game Types",LangCaption="DM z Orężem Ziemskim",Class=UPak.TerranWeaponMatch,Immediate=True)

[TransitionNullHUD]
; EN: Statheader="Kill Statistics: "
Statheader="Statystyki zabójstw: "
; EN: CARStat="Combat Assault Rifle"
CARStat="Karabin Szturmowy"
; EN: RLStat="UMS Rocket Launcher"
RLStat="Wyrzutnia Rakiet UMS"
; EN: GLStat="UMS Grenade Launcher"
GLStat="Wyrzutnia Granatów UMS"
; EN: ASMDStat="ASMD"
ASMDStat="ASMD"
; EN: AutomagStat="Automag"
AutomagStat="Automag"
; EN: DispersionStat="Dispersion Pistol"
DispersionStat="Pistolet Rozpryskowy"
; EN: EightballStat="Eightball"
EightballStat="Ósemka"
; EN: FlakCannonStat="Flak Cannon"
FlakCannonStat="Garłacz"
; EN: GESBioRifleStat="GES BioRifle"
GESBioRifleStat="Karabin Odpadowy GES"
; EN: MinigunStat="Minigun"
MinigunStat="Minigun"
; EN: RazorjackStat="Razorjack"
RazorjackStat="Rozpruwacz"
; EN: RifleStat="Sniper Rifle"
RifleStat="Karabin Snajperski"
; EN: StingerStat="Stinger"
StingerStat="Żądło"
; EN: TotalStat="Total Kills"
TotalStat="Ogółem"
; EN: LogEntryMsg="LOG ENTRY:"
LogEntryMsg="WPIS DO DZIENNIKA:"

[GrenadeLauncher]
; EN: DeathMessage="%k's grenade made %o blew up."
DeathMessage="%o - %k wysadza cię w powietrze granatem."
FemDeathMessage="%o - %k wysadza cię w powietrze granatem."
FemKillMessage="%o - %k wysadza cię w powietrze granatem."
; EN: PickupMessage="You got the UMS Grenade Launcher"
PickupMessage="Podnosisz Wyrzutnia Granatów UMS"
; EN: ItemName="UMS Grenade Launcher"
ItemName="Wyrzutnia Granatów UMS"

[Cloak]
; EN: ExpireMessage="disengaged."
ExpireMessage="wyłączony."
; EN: PickupMessage="You got the Cloaking Device"
PickupMessage="Podnosisz Kamuflaż Wojskowy"
; EN: ItemName="Cloaking Device"
ItemName="Kamuflaż Wojskowy"
; EN: M_Activated=" engaged"
M_Activated=" włączony."
; EN: M_Deactivated=" disengaged"
M_Deactivated=" wyłączony."
ItemArticle=" "
M_Selected=" gotowy do użycia."

[UPakHUD]
; EN: MultWeapSlotMsg="Press the weapon select button to toggle weapons."
MultWeapSlotMsg="Wciśnij klawisz wyboru broni, aby przełączyć broń."

[UPakSinglePlayer]
GameName="Unreal Mission Pack"

[RocketLauncher]
; EN: DeathMessage="%k's rocket turned %o's body into chunks."
DeathMessage="%o - zjadasz rakietę %k. Smacznego!"
FemDeathMessage="%o - zjadasz rakietę %k. Smacznego!"
FemKillMessage="%o - zjadasz rakietę %k. Smacznego!"
; EN: PickupMessage="You got the UMS Rocket Launcher"
PickupMessage="Podnosisz Wyrzutnia Rakiet UMS"
; EN: ItemName="UMS Rocket Launcher"
ItemName="Wyrzutnia Rakiet UMS"

[UPakChooseGameMenu]
MenuList[0]="Return to Na Pali"
MenuList[1]="Unreal"

[CloakMatch]
; EN: GameName="Cloak Match"
GameName="DM z Kamuflażem"

[CARifle]
; EN: DeathMessage="%k's %w turned %o into swiss cheese."
DeathMessage="%o - %k eliminuje cię serią z karabinu szturmowego."
FemDeathMessage="%o - %k eliminuje cię serią z karabinu szturmowego."
FemKillMessage="%o - %k eliminuje cię serią z karabinu szturmowego."
; EN: PickupMessage="You got the Combat Assault Rifle"
PickupMessage="Podnosisz Karabin Szturmowy"
; EN: ItemName="Combat Assault Rifle"
ItemName="Karabin Szturmowy"

[UPakScubaGear]
; EN: RechargedMessage="ScubaGear fully recharged."
RechargedMessage="Poziom tlenu w butli: 100%."
; EN: LowOxygenMessage="Oxygen supply critically low"
LowOxygenMessage="Tlen na wykończeniu"
; EN: PickupMessage="You picked up the Marine SCUBA Gear"
PickupMessage="Podnosisz wojskowy sprzęt do nurkowania"
; EN: ItemName="Marine SCUBA Gear"
ItemName="Wojskowy sprzęt do nurkowania"
; EN: M_Deactivated="deactivated... Recharging."
M_Deactivated=" nieaktywny... Trwa uzupełnianie zapasu tlenu."
ItemArticle=" "
M_Selected=" gotowy do użycia."

[MarineMatch]
; EN: GameName="Marine Match"
GameName="DM z Piechotą Morską"

[GravityMatch]
; EN: GameName="Gravity Match"
GameName="DM z Obniżoną Grawitacją"

[UPakDebugger]
; EN: ItemName="UPak Debugger"
ItemName="Debugger dla UPak"
PickupMessage="Podnosisz debugger dla UPak. I co z tym zrobisz?"
ItemArticle=" "
M_Activated=" włączony."
M_Deactivated=" wyłączony."
M_Selected=" gotowy do użycia."

[UPakMaleOne]
; EN: MenuName="Male 1"
MenuName="Mężczyzna 1"

[UPakFemaleOne]
; EN: MenuName="Female 1"
MenuName="Kobieta 1"

[GLAmmo]
; EN: PickupMessage="You picked up 10 UMS Grenades"
PickupMessage="Podnosisz 10 Granatów UMS"
; EN: ItemName="UMS Grenades"
ItemName="Granaty UMS"

[RLAmmo]
; EN: PickupMessage="You got 10 UMS Rockets"
PickupMessage="Podnosisz 10 Rakiet UMS"
; EN: ItemName="UMS Rockets"
ItemName="Rakiety UMS"

[CARifleClip]
; EN: PickupMessage="You got a 50 bullet CAR clip"
PickupMessage="Podnosisz magazynek 50 nabojów dla karabinu szturmowego"
; EN: ItemName="CAR Clip"
ItemName="magazynek nabojów dla karabinu szturmowego"

[UPakFemaleTwo]
; EN: MenuName="Female 2"
MenuName="Kobieta 2"

[UPakMaleThree]
; EN: MenuName="Male 3"
MenuName="Mężczyzna 3"

[UPakMaleTwo]
; EN: MenuName="Male 2"
MenuName="Mężczyzna 2"

[TerranWeaponMatch]
; EN: GameName="Terran Weapon Match"
GameName="DM z Orężem Ziemskim"

[CompTablet]
; EN: PickupMessage="You got the Computer Tablet"
PickupMessage="Podnosisz Tablet"
; EN: ItemName="Computer Tablet"
ItemName="Tablet"
ExpireMessage="Tablet wyczerpany."
ItemArticle=" "
M_Activated=" włączony."
M_Deactivated=" wyłączony."
M_Selected=" gotowy do użycia."

[MarineArctic]
; EN: MenuName="UMS Arctic Marine"
MenuName="Kosmiczny komandos UMS"
MenuNameDative="kosmicznego komandosa UMS"

[MarineDesert]
; EN: MenuName="UMS Desert Marine"
MenuName="Kosmiczny komandos UMS"
MenuNameDative="kosmicznego komandosa UMS" 

[MarineJungle]
; EN: MenuName="UMS Jungle Marine"
MenuName="Kosmiczny komandos UMS"
MenuNameDative="kosmicznego komandosa UMS"

[SpaceMarine]
; EN: MenuName="UMS Space Marine"
MenuName="Kosmiczny komandos UMS"
MenuNameDative="kosmicznego komandosa UMS"

[TransitionBrute]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Brute"
MenuName="Dzikus"
MenuNameDative="Dzikusa"

[TransitionCow]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Nali Cow"
MenuName="Krowa"

[NaliCopter]
; EN: NameArticle=" a "
NameArticle=" un "
; EN: MenuName="NaliCopter"
MenuName="Helikopter Nali"

[Predator]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Predator"
MenuName="Jaszczurka"
MenuNameDative="jaszczurkę"

[TransitionPredator]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Predator"
MenuName="Jaszczurka"
MenuNameDative="jaszczurkę"

[PackHunter]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Pack Hunter"
MenuName="Stadny Skaarj"
MenuNameDative="stadnego Skaarj"

[Spinner]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Spinner"
MenuName="Pajęczak"
MenuNameDative="pajęczaka"

[PredatorPathUser]
NameArticle=" "
MenuName="Jaszczurka"
MenuNameDative="jaszczurkę"

[UPakConsole]
; EN: ClassCaption="Unreal Gold Console"
ClassCaption="Konsola z Unreal Gold"

[MarineInterestPoint]
PickupMessage=""
M_Activated=""
M_Selected=""
M_Deactivated=""
