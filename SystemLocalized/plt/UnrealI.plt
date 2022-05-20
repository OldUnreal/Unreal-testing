[Public]
Object=(Name=UnrealI.KingOfTheHill,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UnrealI.DarkMatch,Class=Class,MetaClass=Engine.GameInfo)
Object=(Name=UnrealI.FlakCannon,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=UnrealI.Rifle,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=UnrealI.Minigun,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=UnrealI.GESBioRifle,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=UnrealI.RazorJack,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=UnrealI.QuadShot,Class=Class,MetaClass=Engine.Weapon)
Object=(Name=UnrealI.PeaceMaker,Class=Class,MetaClass=Engine.Weapon)
; EN: Object=(Name=UnrealI.FemaleTwo,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Female 2")
Object=(Name=Unreali.FemaleTwo,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Kobieta 2")
; EN: Object=(Name=UnrealI.MaleOne,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Male 1")
Object=(Name=Unreali.MaleOne,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Mężczyzna 1")
; EN: Object=(Name=UnrealI.MaleTwo,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Male 2")
Object=(Name=Unreali.MaleTwo,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Mężczyzna 2")
; EN: Object=(Name=UnrealI.SkaarjPlayer,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Skaarj Trooper")
Object=(Name=UnrealI.SkaarjPlayer,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Szturmowiec Skaarj")
; EN: Object=(Name=UnrealI.FemaleTwoBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Female 2")
Object=(Name=Unreali.FemaleTwoBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Kobieta 2")
; EN: Object=(Name=UnrealI.MaleOneBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Male 1")
Object=(Name=Unreali.MaleOneBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Mężczyzna 1")
; EN: Object=(Name=UnrealI.MaleTwoBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Male 2")
Object=(Name=Unreali.MaleTwoBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Mężczyzna 2")
; EN: Object=(Name=UnrealI.SkaarjPlayerBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Skaarj Trooper")
Object=(Name=UnrealI.SkaarjPlayerBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Szturmowiec Skaarj")
; EN: Object=(Name=UnrealI.NaliPlayer,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Nali")
Object=(Name=UnrealI.NaliPlayer,Class=Class,MetaClass=UnrealShare.UnrealiPlayer,Description="Nali")
; EN: Object=(Name=UnrealI.NaliPlayerBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Nali")
Object=(Name=UnrealI.NaliPlayerBot,Class=Class,MetaClass=UnrealShare.Bots,Description="Nali")
Preferences=(Caption="Darkmatch",Parent="Game Types",Class=UnrealI.DarkMatch,Immediate=True)
Preferences=(Caption="King Of The Hill",Parent="Game Types",Class=UnrealI.KingOfTheHill,Immediate=True)
Preferences=(Caption="Darkmatch Maps",Parent="Map Lists",Class=UnrealI.DkMapList,Immediate=True)

[IntroNullHud]
; EN: ESCMessage="Press ESC to begin"
ESCMessage="Wciśnij klawisz Esc, aby rozpocząć"

[Queen]
; EN: NameArticle=" the "
NameArticle=" "
; EN: MenuName="Queen"
MenuName="Królowa"
MenuNameDative="Królową"

[SkaarjPlayer]
; EN: MenuName="Skaarj Trooper"
MenuName="Szturmowiec Skaarj"

[SkaarjPlayerBot]
; EN: MenuName="Skaarj Trooper"
MenuName="Szturmowiec Skaarj"

[WarLord]
; EN: NameArticle=" the "
NameArticle=" "
; EN: MenuName="WarLord"
MenuName="Władca"
MenuNameDative="Władcę"

[SearchLight]
; EN: ExpireMessage="The Search Light batteries have died."
ExpireMessage="Baterie Reflektora wyczerpane."
; EN: PickupMessage="You picked up the Search Light"
PickupMessage="Podnosisz Reflektor"
; EN: ItemName="Search Light"
ItemName="Reflektor"
ItemArticle=" "
M_Activated=" włączony."
M_Deactivated=" wyłączony."
M_Selected=" gotowy do użycia."

[RazorAmmo]
; EN: PickupMessage="You picked up Razor Blades"
PickupMessage="Podnosisz Paczkę Ostrzy"
; EN: ItemName="Razor Blades"
ItemName="Paczkę Ostrzy"

[FlakBox]
; EN: PickupMessage="You picked up 10 Flak Shells"
PickupMessage="Podnosisz 10 Ładunków do Garłacza"
; EN: ItemName="Flak Shells"
ItemName="Ładunków do Garłacza"

[MaleOne]
; EN: MenuName="Male 1"
MenuName="Mężczyzna 1"

[MaleOneBot]
; EN: MenuName="Male 1"
MenuName="Mężczyzna 1"

[RifleAmmo]
; EN: PickupMessage="You got 8 Rifle Rounds"
PickupMessage="Podnosisz 8 Nabojów do Karabinu Snajperskiego"
; EN: ItemName="Rifle Rounds"
ItemName="Nabojów do Karabinu Snajperskiego"

[Seeds]
; EN: PickupMessage="You got the Nali Fruit Seeds"
PickupMessage="Podnosisz Nasiono Owocu Nali"
; EN: ItemName="Nali Fruit Seeds"
ItemName="Nasiono Owocu Nali"
ItemArticle=" "
M_Activated=" zostało posiane."
M_Selected=" jest gotowe do posiania."

[JumpBoots]
; EN: ExpireMessage="The Jump Boots have drained."
ExpireMessage="Buty Antygrawitacyjne wyczerpane."
; EN: PickupMessage="You picked up the Jump Boots"
PickupMessage="Podnosisz Buty Antygrawitacyjne"
; EN: ItemName="Jump Boots"
ItemName="Buty Antygrawitacyjne"
ItemArticle=" "
M_Activated=" włączone."
M_Deactivated=" wyłączone."
M_Selected=" gotowe do użycia."

[ForceField]
; EN: M_NoRoom="No room to activate the Force Field."
M_NoRoom="Brak miejsca na pole siłowe. Rozstawienie pola niemożliwe."
; EN: PickupMessage="You picked up the Force Field"
PickupMessage="Podnosisz Generator Pola Siłowego"
; EN: ItemName="Force Field"
ItemName="Generator Pola Siłowego"
ItemArticle=" "
M_Activated=" włączony. Pole siłowe zostało rozstawione."
M_Deactivated=" wyłączony."
M_Selected=" gotowy do użycia."

[FemaleTwo]
; EN: MenuName="Female 2"
MenuName="Kobieta 2"

[FemaleTwoBot]
; EN: MenuName="Female 2"
MenuName="Kobieta 2"

[MaleTwo]
; EN: MenuName="Male 2"
MenuName="Mężczyzna 2"

[MaleTwoBot]
; EN: MenuName="Male 2"
MenuName="Mężczyzna 2"

[Sludge]
; EN: PickupMessage="You picked up 25 Kilos of Tarydium Biosludge"
PickupMessage="Podnosisz 25kg Odpadów Tarydowych"
; EN: ItemName="Tarydium Biosludge"
ItemName="Odpadów Tarydowych"

[Invisibility]
; EN: ExpireMessage="Invisibility has worn off."
ExpireMessage="Kamuflaż wyczerpany."
; EN: PickupMessage="You have Invisibility"
PickupMessage="Podnosisz kamuflaż"
; EN: ItemName="Invisibility"
ItemName="Kamuflaż"
ItemArticle=" "
M_Activated=" włączony."
M_Deactivated=" wyłączony."
M_Selected=" gotowy do użycia."

[DarkMatch]
; EN: ClassCaption="DarkMatch"
ClassCaption="DarkMatch"
; EN: GameName="DarkMatch"
GameName="DarkMatch"

[FlakShellAmmo]
; EN: PickupMessage="You got a Flak Shell"
PickupMessage="Podnosisz Ładunek do Garłacza"
; EN: ItemName="Flak Shell"
ItemName="Ładunek do Garłacza"

[AsbestosSuit]
; EN: PickupMessage="You picked up the Asbestos Suit"
PickupMessage="Podnosisz kombinezon azbestowy"
; EN: ItemName="Asbestos Suit"
ItemName="Kombinezon azbestowy"

[Dampener]
; EN: ExpireMessage="Acoustic dampener has run out."
ExpireMessage="Tłumik wyczerpany."
; EN: PickupMessage="You got the Acoustic Dampener"
PickupMessage="Podnosisz Tłumik"
; EN: ItemName="Acoustic Dampener"
ItemName="Tłumik"
ItemArticle=" "
M_Activated=" włączony."
M_Deactivated=" wyłączony."
M_Selected=" gotowy do użycia."

[ToxinSuit]
; EN: PickupMessage="You picked up the Toxin Suit"
PickupMessage="Podnosisz Kombinezon Antytoksynowy"
; EN: ItemName="Toxin Suit"
ItemName="Kombinezon Antytoksynowy"

[PowerShield]
; EN: PickupMessage="You got the Power Shield"
PickupMessage="Podnosisz Pas Pola Siłowego"
; EN: ItemName="Power Shield"
ItemName="Pas Pola Siłowego"

[RifleRound]
; EN: PickupMessage="You got a Rifle Round"
PickupMessage="Podnosisz Nabój do Karabinu Snajperskiego"
; EN: ItemName="Rifle Round"
ItemName="Nabój do Karabinu Snajperskiego"

[Behemoth]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Behemoth"
MenuName="Behemot"
MenuNameDative="Behemota"

[Blob]
; EN: NameArticle=" a "
NameArticle=" a "
; EN: MenuName="Blob"
MenuName="Blob"

[Bloblet]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Bloblet"
MenuName="Bańka"
MenuNameDative="Bańkę"
BlobKillMessage="został rozpuszczony przez bańkę"
BlobKillMessageFem="została rozpuszczona przez bańkę"

[Gasbag]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Gasbag"
MenuName="Ogniomiot"
MenuNameDative="Ogniomiota"

[GiantGasbag]
; EN: NameArticle=" the "
NameArticle=" "
; EN: MenuName="Giant Gasbag"
MenuName="Ogniomiot olbrzymi"
MenuNameDative="Ogniomiota olbrzymiego"

[GiantManta]
; EN: NameArticle=" the "
NameArticle=" "
; EN: MenuName="Giant Manta"
MenuName="Manta olbrzymia"
MenuNameDative="Mantę olbrzymią"

[IceSkaarj]
; EN: NameArticle=" an "
NameArticle=" "
; EN: MenuName="Ice Skaarj"
MenuName="Wojownik arktyczny Skaarj"
MenuNameDative="Wojownika arktycznego Skaarj"

[Krall]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Krall"
MenuName="Krall"
MenuNameDative="Kralla"

[KrallElite]
; EN: NameArticle=" an "
NameArticle=" "
; EN: MenuName="Elite Krall"
MenuName="Dowódca Krallów"
MenuNameDative="Dowódcę Krallów"

[LeglessKrall]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Legless Krall"
MenuName="Beznogi Krall"
MenuNameDative="Beznogiego Kralla"

[Mercenary]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Mercenary"
MenuName="Najemnik"
MenuNameDative="Najemnika"

[MercenaryElite]
; EN: NameArticle=" an "
NameArticle=" "
; EN: MenuName="Elite Mercenary"
MenuName="Dowódca najemników"
MenuNameDative="Dowódcę najemników"

[Pupae]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Pupae"
MenuName="Młode"
MenuNameDative="Młode"

[SkaarjAssassin]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Skaarj Assassin"
MenuName="Zabójca Skaarj"
MenuNameDative="Zabójcę Skaarj"

[SkaarjBerserker]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Skaarj Berserker"
MenuName="Oszalały Skaarj"
MenuNameDative="Oszalałego Skaarj"

[SkaarjGunner]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Skaarj Gunner"
MenuName="Kanonier Skaarj"
MenuNameDative="Kanoniera Skaarj"

[SkaarjInfantry]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Skaarj Infantry"
MenuName="Żołnierz piechoty Skaarj"
MenuNameDative="Żołnierza piechoty Skaarj"

[SkaarjLord]
; EN: NameArticle=" the "
NameArticle=" "
; EN: MenuName="Skaarj Lord"
MenuName="Wódz Skaarj"
MenuNameDative="Wodza Skaarj"

[SkaarjOfficer]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Skaarj Officer"
MenuName="Oficer Skaarj"
MenuNameDative="Oficera Skaarj"

[SkaarjSniper]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Skaarj Sniper"
MenuName="Strzelec wyborowy Skaarj"
MenuNameDative="Strzelca wyborowego Skaarj"

[SkaarjTrooper]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Skaarj Trooper"
MenuName="Szturmowiec Skaarj"
MenuNameDative="Szturmowca Skaarj"

[Titan]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Titan"
MenuName="Tytan"
MenuNameDative="Tytana"

[StoneTitan]
; EN: NameArticle=" the "
NameArticle=" "
; EN: MenuName="Stone Titan"
MenuName="Kamienny Tytan"
MenuNameDative="Kamiennego Tytana"

[EndgameHud]
; EN: Message1="The Skaarj escape pod has broken free from the planet's gravitational pull... barely. Yet, it's fuel reserve has been depleted, and you drift aimlessly."
Message1="Kapsuła ratunkowa Skaarj wyrwała się z pola grawitacyjnego planety... w ostatniej chwili. Jednakże, rezerwy paliwa wyczerpały się i teraz dryfujesz bez celu."
; EN: Message2="From where many have died, you have escaped. You laugh to yourself; so much has happened, but so little has changed."
Message2="Udało ci się uciec z miejsca, gdzie wielu straciło życie. Śmiejesz się do siebie; tak wiele się wydarzyło, a skutek tak niewielki."
; EN: Message3="Before the crash landing, you were trapped in a cramped cell. Now, once again you are confined in a prison."
Message3="Przed kraksą, twoją pułapką była ciasna cela więzienna. Obecnie, po raz kolejny znajdujesz się w więzieniu."
; EN: Message4="But, you feel confident that someone will come upon your small vessel... eventually."
Message4="Mimo to, masz pewność, że ktoś ostatecznie natrafi na niewielką kapsułę, w której się znajdujesz."
; EN: Message5="Until then, you drift and hope."
Message5="Do tego czasu, pozostaje ci dryfować samotnie przez przestrzeń, z nadzieją w sercu."
; EN: Message6="To Be Continued..."
Message6="Ciąg dalszy nastąpi..."
; EN: Message7="Press fire to restart"
Message7="Naciśnij klawisz [Strzał], aby rozpocząć od nowa."

[KingOfTheHill]
; EN: ClassCaption="King of the Hill"
ClassCaption="Król na Wzgórzu"
; EN: KingMessage=" is the new king of the hill!"
KingMessage=" zostaje Królem!"
; EN: GameName="King of the Hill"
GameName="Król na Wzgórzu"
; EN: NewKingMessage="%k is the new king of the hill!"
NewKingMessage="%k zostaje Królem!"
; EN: NewQueenMessage="%k is the new queen of the hill!"
NewQueenMessage="%k jest nową królową wzgórza!"

[ParentBlob]
; EN: BlobKillMessage="was corroded by a Blob"
BlobKillMessage="został rozpuszczony przez bańkę"
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Blob"
MenuName="Bańka"
FemBlobKillMessage="została rozpuszczona przez bańkę"
MenuNameDative="Bańkę"

[FlakCannon]
; EN: DeathMessage="%o was ripped to shreds by %k's %w."
DeathMessage="%o - %k rozrywa cię na strzępy Garłaczem."
; EN: PickupMessage="You got the Flak Cannon"
PickupMessage="Podnosisz Garłacza"
; EN: ItemName="Flak Cannon"
ItemName="Garłacz"
FemDeathMessage="%o - %k rozrywa cię na strzępy Garłaczem."
FemKillMessage="%o - %k rozrywa cię na strzępy Garłaczem."

[Rifle]
; EN: DeathMessage="%k put a bullet through %o's head."
DeathMessage="%o - %k posłał ci kulkę w sam łeb."
; EN: PickupMessage="You got the Rifle"
PickupMessage="Podnosisz Karabin Snajperski"
; EN: ItemName="Sniper Rifle"
ItemName="Karabin Snajperski"
FemDeathMessage="%o - %k posłał ci kulkę w sam łeb."
FemKillMessage="%o - %k posłał ci kulkę w sam łeb."

[Minigun]
; EN: DeathMessage="%k's %w turned %o into a leaky piece of meat."
DeathMessage="%o - %k zamienia cię w krwawy durszlak mięsny serią z miniguna."
; EN: PickupMessage="You got the Minigun"
PickupMessage="Podnosisz Minigun"
; EN: ItemName="Minigun"
ItemName="Minigun"
FemDeathMessage="%o - %k zamienia cię w krwawy durszlak mięsny serią z miniguna."
FemKillMessage="%o - %k zamienia cię w krwawy durszlak mięsny serią z miniguna."

[GESBioRifle]
; EN: DeathMessage="%o drank a glass of %k's dripping green load."
DeathMessage="%o - %k właśnie spuścił ci do gardła cały ładunek ścieków."
; EN: PickupMessage="You got the GES BioRifle"
PickupMessage="Podnosisz Karabin Odpadowy GES"
; EN: ItemName="GES Bio Rifle"
ItemName="Karabin Odpadowy GES"
FemDeathMessage="%o - %k właśnie spuścił ci do gardła cały ładunek ścieków."
FemKillMessage="%o - %k właśnie spuścił ci do gardła cały ładunek ścieków."

[RazorJack]
; EN: DeathMessage="%k took a bloody chunk out of %o with the %w."
DeathMessage="%o daje ciała %k za sprawą Rozpruwacza."
; EN: PickupMessage="You got the RazorJack"
PickupMessage="Podnosisz Rozpruwacza"
; EN: ItemName="Razorjack"
ItemName="Rozpruwacz"
FemDeathMessage="%o daje ciała %k za sprawą Rozpruwacza."
FemKillMessage="%o daje ciała %k za sprawą Rozpruwacza."

[Fell]
; EN: Name="fell"
Name="spadł"
FemName="spadła"
; EN: AltName="fell"
AltName="spadł"
FemAltName="spadła"

[Drowned]
; EN: Name="drowned"
Name="utonął"
FemName="utonęła"
; EN: AltName="drowned"
AltName="utonął"
FemAltName="utonęła"

[Decapitated]
; EN: Name="beheaded"
Name="stracił głowę"
FemName="straciła głowę"
; EN: AltName="decapitated"
AltName="stracił głowę"
FemAltName="straciła głowę"

[Corroded]
; EN: Name="corroded"
Name="rozpuszczony"
FemName="rozpuszczona"
; EN: AltName="slimed"
AltName="rozpuszczony"
FemAltName="rozpuszczona"

[Burned]
; EN: Name="burned"
Name="przypieczony"
FemName="przypieczona"
; EN: AltName="flame-broiled"
AltName="przypieczony"
FemAltName="przypieczona"

[QuadShot]
; EN: DeathMessage="%o was blasted to bits by %k's %w."
DeathMessage="%o - %k rozrywa cię na części pierwsze czterolufowym obrzynem."
; EN: PickupMessage="You got the Quad-Barreled Shotgun"
PickupMessage="Podnosisz Czterolufowego Obrzyna"
; EN: ItemName="Quad-Barreled Shotgun"
ItemName="Czterolufowego Obrzyn"
FemDeathMessage="="%o - %k rozrywa cię na części pierwsze czterolufowym obrzynem."
FemKillMessage="="%o - %k rozrywa cię na części pierwsze czterolufowym obrzynem."

[NaliPlayer]
; EN: MenuName="Nali"
MenuName="Nali"

[NaliPlayerBot]
; EN: MenuName="Nali"
MenuName="Nali"

[Squid]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Squid"
MenuName="Mątwa"
MenuNameDative="Mątwę"

[Chameleon]
; EN: NameArticle=" a "
NameArticle=" "
; EN: MenuName="Chameleon"
MenuName="Kameleon"
MenuNameDative="Kameleona"

[PeaceMaker]
; EN: DeathMessage="One of %k's %w missiles blew up %o."
DeathMessage="%o - usypiacz %k właśnie zrobił z ciebie sito."
FemDeathMessage="%o - usypiacz %k właśnie zrobił z ciebie sito."
FemKillMessage="%o - usypiacz %k właśnie zrobił z ciebie sito."
; EN: PickupMessage="You got the Peacemaker"
PickupMessage="Podnosisz Usypiacza"
; EN: ItemName="Peacemaker"
ItemName="Usypiacz"

[PeaceAmmo]
; EN: PickupMessage="You got Peacemaker ammo"
PickupMessage="Podnosisz Amunicję do Usypiacza"
; EN: ItemName="Peacemaker ammo"
ItemName="Amunicję do Usypiacz"

[WoodruffSeeds]
; EN: PickupMessage="You got the Woodruff seeds"
PickupMessage="Masz Nasiona Marzankia"
; EN: ItemName="Woodruff seeds"
ItemName="Nasiona Marzanki"
