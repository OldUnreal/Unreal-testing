[Public]
Object=(Name=Game.Game,Class=Class,MetaClass=UnrealShare.SinglePlayer,Description="Intro1;UPak.Return;Return to Na Pali")
Object=(Name=upak.CrashSiteGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.UPakSinglePlayer,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.UPakTransitionInfo,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.UPakGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.CloakMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.UPakCoopGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.DuskFallsGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.CloakGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.MarineMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.GravityMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.TestGameInfo,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.TerranWeaponMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.UPakIntro,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.CreditsGame,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=upak.GrenadeLauncher,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=upak.RocketLauncher,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=upak.CARifle,Class=Class,MetaClass=Engine.Weapon)
Preferences=(Caption="Cloak Match",Parent="Game Types",Class=UPak.CloakMatch,Immediate=True)
Preferences=(Caption="Gravity Match",Parent="Game Types",Class=UPak.GravityMatch,Immediate=True)
Preferences=(Caption="Marine Match",Parent="Game Types",Class=UPak.MarineMatch,Immediate=True)
Preferences=(Caption="Terran Weapon Match",Parent="Game Types",Class=UPak.TerranWeaponMatch,Immediate=True)

[TransitionNullHUD]
; EN: Statheader="Kill Statistics: "
Statheader="Statistiques des Frags: "
; EN: CARStat="Combat Assault Rifle"
CARStat="Fusil d'Assaut"
; EN: RLStat="UMS Rocket Launcher"
RLStat="Lance-missiles UMS"
; EN: GLStat="UMS Grenade Launcher"
GLStat="Lance-grenades UMS"
; EN: ASMDStat="ASMD"
ASMDStat="ASMD"
; EN: AutomagStat="Automag"
AutomagStat="Automag"
; EN: DispersionStat="Dispersion Pistol"
DispersionStat="Pistolet à Dispersion"
; EN: EightballStat="Eightball"
EightballStat="Lance-roquettes"
; EN: FlakCannonStat="Flak Cannon"
FlakCannonStat="Canon Flak"
; EN: GESBioRifleStat="GES BioRifle"
GESBioRifleStat="Fusil Bio GES"
; EN: MinigunStat="Minigun"
MinigunStat="Minigun"
; EN: RazorjackStat="Razorjack"
RazorjackStat="Lance-lame"
; EN: RifleStat="Sniper Rifle"
RifleStat="Fusil de Précision"
; EN: StingerStat="Stinger"
StingerStat="Stinger"
; EN: TotalStat="Total Kills"
TotalStat="Total Frags"
; EN: LogEntryMsg="LOG ENTRY:"
LogEntryMsg="JOURNAL AUDIO:"

[GrenadeLauncher]
; EN: DeathMessage="%k's grenade made %o blew up."
DeathMessage="La grenade de %k a explosé dans les mains de %o."
FemDeathMessage="La grenade de %k a explosé dans les mains de %o."
FemKillMessage="La grenade de %k a explosé dans les mains de %o."
; EN: PickupMessage="You got the UMS Grenade Launcher"
PickupMessage="Vous avez le Lance-grenades UMS"
; EN: ItemName="UMS Grenade Launcher"
ItemName="Lance-grenades UMS"

[Cloak]
; EN: ExpireMessage="disengaged."
ExpireMessage="désactivé."
; EN: PickupMessage="You got the Cloaking Device"
PickupMessage="Vous avez trouvé le Système de Camouflage"
; EN: ItemName="Cloaking Device"
ItemName="Système de Camouflage"
; EN: M_Activated=" engaged"
M_Activated=" activé"
; EN: M_Deactivated=" disengaged"
M_Deactivated=" désactivé"

[UPakHUD]
; EN: MultWeapSlotMsg="Press the weapon select button to toggle weapons."
MultWeapSlotMsg="Appuyez sur le bouton de sélection d'arme pour choisir votre flingue."

[UPakSinglePlayer]
; EN: GameName="Unreal Mission Pack"
GameName="Pack de Mission pour Unreal"

[RocketLauncher]
; EN: DeathMessage="%k's rocket turned %o's body into chunks."
DeathMessage="La fusée de %k a mis en pièces %o."
FemDeathMessage="La fusée de %k a mis en pièces %o."
FemKillMessage="La fusée de %k a mis en pièces %o."
; EN: PickupMessage="You got the UMS Rocket Launcher"
PickupMessage="Vous avez trouvé le Lance-missiles UMS"
; EN: ItemName="UMS Rocket Launcher"
ItemName="Lance-missiles UMS"

[UPakChooseGameMenu]
MenuList[0]="Return to Na Pali"
MenuList[1]="Unreal"

[CloakMatch]
; EN: GameName="Cloak Match"
GameName="Match Camouflé"

[CARifle]
; EN: DeathMessage="%k's %w turned %o into swiss cheese."
DeathMessage="Le %w de %k a transformé %o en fromage suisse."
FemDeathMessage="Le %w de %k a transformé %o en fromage suisse."
FemKillMessage="Le %w de %k a transformé %o en fromage suisse."
; EN: PickupMessage="You got the Combat Assault Rifle"
PickupMessage="Vous avez trouvé le Fusil d'Assaut"
; EN: ItemName="Combat Assault Rifle"
ItemName="Fusil d'Assaut"

[UPakScubaGear]
; EN: RechargedMessage="Marine SCUBA Gear fully recharged."
RechargedMessage="Respirateur de Marines rechargé."
; EN: LowOxygenMessage="Oxygen supply critically low"
LowOxygenMessage="La réserve d'oxygène s'épuise"
; EN: PickupMessage="You picked up the Marine SCUBA Gear"
PickupMessage="Vous avez ramassé le respirateur de Marines"
; EN: ItemName="Marine SCUBA Gear"
ItemName="Respirateur de Marines"
; EN: M_Deactivated="deactivated... Recharging."
M_Deactivated="désactivé... Rechargement en cours."

[MarineMatch]
; EN: GameName="Marine Match"
GameName="Match Marines"

[GravityMatch]
; EN: GameName="Gravity Match"
GameName="Match Gravité"

[UPakDebugger]
; EN: ItemName="UPak Debugger"
ItemName="Déboggeur UPak"

[UPakMaleOne]
; EN: MenuName="Male 1"
MenuName="Homme 1"

[UPakFemaleOne]
; EN: MenuName="Female 1"
MenuName="Femme 1"

[GLAmmo]
; EN: PickupMessage="You picked up 10 UMS Grenades"
PickupMessage="Vous avez ramassé 10 grenades UMS"
; EN: ItemName="UMS Grenades"
ItemName="Grenades UMS"

[RLAmmo]
; EN: PickupMessage="You got 10 UMS Rockets"
PickupMessage="Vous avez ramassé 10 missiles UMS"
; EN: ItemName="UMS Rockets"
ItemName="Missiles UMS"

[CARifleClip]
; EN: PickupMessage="You got a 50 bullet CAR clip"
PickupMessage="Vous avez ramassé un chargeur CAR de 50 balles"
; EN: ItemName="CAR Clip"
ItemName="Chargeur CAR"

[UPakFemaleTwo]
; EN: MenuName="Female 2"
MenuName="Femme 2"

[UPakMaleThree]
; EN: MenuName="Male 3"
MenuName="Homme 3"

[UPakMaleTwo]
; EN: MenuName="Male 2"
MenuName="Homme 2"

[TerranWeaponMatch]
; EN: GameName="Terran Weapon Match"
GameName="Match d'armes Terrans"

[CompTablet]
; EN: PickupMessage="You got the Computer Tablet"
PickupMessage="Vous avez trouvé le Tablet PC"
; EN: ItemName="Computer Tablet"
ItemName="Tablet PC"

[MarineArctic]
; EN: MenuName="UMS Arctic Marine"
MenuName="Arctique Marine UMS"

[MarineDesert]
; EN: MenuName="UMS Desert Marine"
MenuName="Désert Marine UMS"

[MarineJungle]
; EN: MenuName="UMS Jungle Marine"
MenuName="Jungle Marine UMS"

[SpaceMarine]
; EN: MenuName="UMS Space Marine"
MenuName="Espace Marine UMS"

[TransitionBrute]
; EN: NameArticle=" a "
NameArticle=" une "
; EN: MenuName="Brute"
MenuName="Brute"

[TransitionCow]
; EN: NameArticle=" a "
NameArticle=" une "
; EN: MenuName="Nali Cow"
MenuName="Vache Nali"

[NaliCopter]
; EN: NameArticle=" a "
NameArticle=" un "
; EN: MenuName="NaliCopter"
MenuName="Nalicopter"

[Predator]
; EN: NameArticle=" a "
NameArticle=" un "
; EN: MenuName="Predator"
MenuName="Prédateur"

[TransitionPredator]
; EN: NameArticle=" a "
NameArticle=" un "
; EN: MenuName="Predator"
MenuName="Prédateur"

[PackHunter]
; EN: NameArticle=" a "
NameArticle=" un "
; EN: MenuName="Pack Hunter"
MenuName="Chasseur de Groupe"

[Spinner]
; EN: NameArticle=" a "
NameArticle=" une "
; EN: MenuName="Spinner"
MenuName="Araignée"
