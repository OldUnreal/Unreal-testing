//=============================================================================
// BotInfo.
//=============================================================================
class BotInfo extends Info
	NoUserCreate;

var() config bool	bAdjustSkill;
var() config bool	bRandomOrder;
var   config byte	Difficulty;

var() config string BotNames[32];
var() config int BotTeams[32];
var() config float BotSkills[32];
var() config float BotAccuracy[32];
var() config float CombatStyle[32];
var() config float Alertness[32];
var() config float Camping[32];
var class<Weapon> FavoriteWeapon[32]; // Obsolete!
var() config string PrefereredWeapon[32];
var	  byte ConfigUsed[32];
var() config string BotClasses[32];
var() config string BotSkins[32];
var string AvailableClasses[32], AvailableDescriptions[32], NextBotClass;
var int NumClasses, NumConfigures;

function PreBeginPlay()
{
	for ( NumConfigures=0; NumConfigures<ArrayCount(BotNames); NumConfigures++ )
		if ( Len(BotNames[NumConfigures])==0 || Len(BotClasses[NumConfigures])==0 )
			return;
}

function PostBeginPlay()
{
	local string NextBotClass, NextBotDesc;

	Super.PostBeginPlay();

	foreach IntDescIterator(string(class'Bots'),NextBotClass,NextBotDesc,true)
	{
		AvailableClasses[NumClasses] = NextBotClass;
		AvailableDescriptions[NumClasses] = NextBotDesc;
		if( ++NumClasses==ArrayCount(AvailableClasses) )
			break;
	}
}

function String GetAvailableClasses(int n)
{
	return AvailableClasses[n];
}

function int ChooseBotInfo()
{
	local int n, start;

	if ( bRandomOrder )
		n = Rand(NumConfigures);
	else
		n = 0;

	start = n;
	while ( (n < 32) && (ConfigUsed[n] == 1) )
		n++;

	if ( (n == 32) && bRandomOrder )
	{
		n = 0;
		while ( (n < start) && (ConfigUsed[n] == 1) )
			n++;
	}

	if ( n > 31 )
		n = 31;

	return n;
}

function class<Bots> GetBotClass(int n)
{
	return class<Bots>( DynamicLoadObject(GetBotClassName(n), class'Class') );
}

function Individualize(bots NewBot, int n, int NumBots)
{
	local texture NewSkin;

	if ( n<0 || n>=ArrayCount(BotSkins) )
		n = Rand(NumConfigures); // Use random entry.

	// Set bot's skin
	if ( (BotSkins[n] != "") && (BotSkins[n] != "None") )
	{
		NewSkin = texture(DynamicLoadObject(BotSkins[n], class'Texture'));
		if ( NewSkin != None )
			NewBot.Skin = NewSkin;
	}

	// Set bot's name.
	if ( Len(BotNames[n])==0 || (ConfigUsed[n] == 1) )
		BotNames[n] = "Bot";

	Level.Game.ChangeName( NewBot, BotNames[n], false );
	if ( BotNames[n] != NewBot.PlayerReplicationInfo.PlayerName )
		Level.Game.ChangeName( NewBot, ("Bot"$Level.Game.CurrentID), false);

	if ( ConfigUsed[n]==0 )
		NewBot.UsingConfigIndex = n;

	ConfigUsed[n] = 1;

	// adjust bot skill
	NewBot.Skill = FClamp(NewBot.Skill + BotSkills[n], 0, 5);
	NewBot.Accuracy = BotAccuracy[n];
	NewBot.CombatStyle = CombatStyle[n];
	NewBot.Alertness = Alertness[n];
	NewBot.CampingRate = Camping[n];
	if ( PrefereredWeapon[n]!="" && PrefereredWeapon[n]!="None" )
		NewBot.FavoriteWeapon = class<Weapon>(DynamicLoadObject(PrefereredWeapon[n], class'Class'));
	NewBot.ReSetSkill();
}

function SetBotClass(String ClassName, int n)
{
	BotClasses[n] = ClassName;
}

function SetBotName( coerce string NewName, int n )
{
	BotNames[n] = NewName;
}

function String GetBotName(int n)
{
	return BotNames[n];
}

function int GetBotTeam(int num)
{
	return BotTeams[Num];
}

function SetBotTeam(int NewTeam, int n)
{
	BotTeams[n] = NewTeam;
}

function int GetBotIndex( coerce string BotName )
{
	local int i;
	local bool found;

	found = false;
	for (i=0; i<ArrayCount(BotNames)-1; i++)
		if (BotNames[i] == BotName)
		{
			found = true;
			break;
		}

	if (!found)
		i = -1;

	return i;
}

function string GetBotSkin( int num )
{
	return BotSkins[Num];
}

function SetBotSkin( coerce string NewSkin, int n )
{
	BotSkins[n] = NewSkin;
}

function String GetBotClassName(int n)
{
	if ( (n < 0) || (n > 31) )
		return AvailableClasses[Rand(NumClasses)];

	if ( BotClasses[n] == "" )
		BotClasses[n] = AvailableClasses[Rand(NumClasses)];

	return BotClasses[n];
}

/* Should be called by GameInfo when bot leaves the game */
function ReleaseBot( Bots Other )
{
	if ( Other.UsingConfigIndex>=0 )
		ConfigUsed[Other.UsingConfigIndex] = 0; // Release bot config entry.
}

defaultproperties
{
	Difficulty=1
	bRandomOrder=True
	BotNames(0)="Dante"
	BotNames(1)="Ash"
	BotNames(2)="Rhiannon"
	BotNames(3)="Kurgan"
	BotNames(4)="Sonja"
	BotNames(5)="Bane"
	BotNames(6)="Dominator"
	BotNames(7)="Drace"
	BotNames(8)="Dregor"
	BotNames(9)="Ivan"
	BotNames(10)="Dimitra"
	BotNames(11)="Eradicator"
	BotNames(12)="Gina"
	BotNames(13)="Arcturus"
	BotNames(14)="Kristoph"
	BotNames(15)="Vindicator"
	BotNames(16)="Krige"
	BotNames(17)="Apocalypse"
	BotNames(18)="Nikita"
	BotNames(19)="Cholerae"
	BotNames(20)="Katryn"
	BotNames(21)="Terminator"
	BotNames(22)="Shiva"
	BotNames(23)="Avatar"
	BotNames(24)="Raquel"
	BotNames(25)="The Reaper"
	BotNames(26)="Sonya"
	BotTeams(0)=1
	BotTeams(2)=1
	BotTeams(4)=1
	BotTeams(6)=1
	BotTeams(8)=1
	BotTeams(10)=1
	BotTeams(12)=1
	BotTeams(14)=1
	BotTeams(16)=1
	BotTeams(18)=1
	BotTeams(20)=1
	BotTeams(22)=1
	BotTeams(24)=1
	BotTeams(26)=1
	BotSkills(1)=0.8
	BotSkills(3)=1.2
	BotSkills(6)=3.0
	BotSkills(8)=2.0
	BotSkills(14)=1.0
	BotSkills(23)=1.0
	BotSkills(25)=5.0
	BotSkills(26)=1.0
	BotAccuracy(0)=0.8
	BotAccuracy(1)=0.4
	BotAccuracy(5)=-1
	BotAccuracy(7)=-0.4
	BotAccuracy(9)=-0.2
	BotAccuracy(12)=0.2
	BotAccuracy(16)=0.4
	BotAccuracy(20)=0.6
	BotAccuracy(23)=-0.4
	BotAccuracy(25)=1
	CombatStyle(0)=8
	CombatStyle(2)=1
	CombatStyle(4)=2
	CombatStyle(6)=3
	CombatStyle(8)=7
	CombatStyle(10)=5
	CombatStyle(13)=-4
	CombatStyle(17)=-10
	CombatStyle(20)=-3
	CombatStyle(22)=-7
	CombatStyle(25)=10
	Alertness(0)=-0.8
	Alertness(2)=0.2
	Alertness(3)=0.6
	Alertness(4)=-0.6
	Alertness(6)=0.2
	Alertness(9)=-0.4
	Alertness(12)=0.6
	Alertness(16)=-0.3
	Alertness(18)=-0.6
	Alertness(20)=0.5
	Alertness(24)=0.2
	Alertness(25)=1
	Alertness(26)=-1
	Camping(0)=1
	Camping(1)=0.2
	Camping(4)=0.2
	Camping(6)=0.3
	Camping(8)=0.6
	Camping(10)=0.4
	Camping(12)=0.4
	Camping(14)=0.1
	Camping(16)=0.5
	Camping(18)=0.5
	Camping(20)=0.2
	Camping(24)=0.5
	Camping(26)=1
	PrefereredWeapon(1)="UnrealShare.Automag"
	PrefereredWeapon(7)="UnrealShare.ASMD"
	PrefereredWeapon(10)="UnrealShare.Stinger"
	PrefereredWeapon(13)="UnrealI.GESBioRifle"
	PrefereredWeapon(17)="UnrealI.Rifle"
	PrefereredWeapon(25)="UnrealI.FlakCannon"
	BotClasses(0)="UnrealShare.MaleThreeBot"
	BotClasses(1)="UnrealI.MaleTwoBot"
	BotClasses(2)="UnrealShare.FemaleOneBot"
	BotClasses(3)="UnrealI.MaleOneBot"
	BotClasses(4)="UnrealI.FemaleTwoBot"
	BotClasses(5)="UnrealShare.MaleThreeBot"
	BotClasses(6)="UnrealI.SkaarjPlayerBot"
	BotClasses(7)="UnrealShare.FemaleOneBot"
	BotClasses(8)="UnrealShare.MaleThreeBot"
	BotClasses(9)="UnrealI.MaleTwoBot"
	BotClasses(10)="UnrealI.FemaleTwoBot"
	BotClasses(11)="UnrealI.SkaarjPlayerBot"
	BotClasses(12)="UnrealShare.FemaleOneBot"
	BotClasses(13)="UnrealI.MaleOneBot"
	BotClasses(14)="UnrealI.MaleTwoBot"
	BotClasses(15)="UnrealI.SkaarjPlayerBot"
	BotClasses(16)="UnrealShare.MaleThreeBot"
	BotClasses(17)="UnrealI.MaleTwoBot"
	BotClasses(18)="UnrealShare.FemaleOneBot"
	BotClasses(19)="UnrealI.MaleOneBot"
	BotClasses(20)="UnrealI.FemaleTwoBot"
	BotClasses(21)="UnrealI.SkaarjPlayerBot"
	BotClasses(22)="UnrealShare.MaleThreeBot"
	BotClasses(23)="UnrealI.MaleTwoBot"
	BotClasses(24)="UnrealShare.FemaleOneBot"
	BotClasses(25)="UnrealI.MaleOneBot"
	BotClasses(26)="UnrealI.FemaleTwoBot"
	BotSkins(5)="Male3Skins.Bane"
	BotSkins(7)="Female1Skins.Drace"
	BotSkins(8)="Male3Skins.Dregor"
	BotSkins(9)="Male2Skins.Ivan"
	BotSkins(10)="Female2Skins.Dimitra"
	BotSkins(11)="SkTrooperSkins.T_Skaarj2"
	BotSkins(12)="Female1Skins.Gina"
	BotSkins(13)="Male1Skins.T_Green"
	BotSkins(14)="Male2Skins.Kristoph"
	BotSkins(15)="SkTrooperSkins.T_Skaarj3"
	BotSkins(16)="Male3Skins.Krige"
	BotSkins(17)="Male2Skins.Male2Gib"
	BotSkins(18)="Female1Skins.Nikita"
	BotSkins(19)="Male1Skins.T_Yellow"
	BotSkins(20)="Female2Skins.Katryn"
	BotSkins(21)="SkTrooperSkins.T_Skaarj2"
	BotSkins(22)="Male3Skins.T_Green"
	BotSkins(23)="Male2Skins.T_Yellow"
	BotSkins(24)="Female1Skins.Raquel"
	BotSkins(25)="Male1Skins.Male1Gib"
	BotSkins(26)="Female2Skins.T_Blue"
}