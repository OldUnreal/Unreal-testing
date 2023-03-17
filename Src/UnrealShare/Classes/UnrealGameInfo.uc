//=============================================================================
// UnrealGameInfo.
//
// default game info is normal single player
//
//=============================================================================
class UnrealGameInfo extends GameInfo
	NoUserCreate;

#exec AUDIO IMPORT FILE="Sounds\Generic\land1.wav" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\lsplash.wav" NAME="LSplash" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Pickups\genwep1.wav" NAME="WeaponPickup" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Generic\teleport1.wav" NAME="Teleport1" GROUP="Generic"
#exec OBJ LOAD FILE="Models\ErrMesh.usm" PACKAGE="UnrealShare"

var(DeathMessage) localized string DeathMessage[32];    // Player name, or blank if none.
var(DeathMessage) localized string DeathModifier[5];
var(DeathMessage) localized string MajorDeathMessage[8];
var(DeathMessage) localized string HeadLossMessage[2];
var(DeathMessage) localized string DeathVerb;
var(DeathMessage) localized string DeathPrep;
var(DeathMessage) localized string DeathTerm;
var(DeathMessage) localized string ExplodeMessage;
var(DeathMessage) localized string SuicideMessage;
var(DeathMessage) localized string FallMessage;
var(DeathMessage) localized string DrownedMessage;
var(DeathMessage) localized string BurnedMessage;
var(DeathMessage) localized string CorrodedMessage;
var(DeathMessage) localized string HackedMessage,BleededMessage;

var(DeathMessage) localized array<string> FemDeathMessages,FemHeadLossMessages,FemMajorDeathMessages;
var(DeathMessage) localized string	FemExplodeMessage,FemSuicideMessage,FemFallMessage,
					FemDrownedMessage,FemBurnedMessage,FemCorrodedMessage,
					FemHackedMessage,FemBleededMessage;
var(DeathMessage) localized bool bGenderMessages;

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if (injured.Region.Zone.bNeutralZone)
		return 0;

	if ( instigatedBy == None)
		return Damage;
	//skill level modification
	if ( instigatedBy.bIsPlayer )
	{
		if ( injured == instigatedby )
		{
			if ( instigatedby.skill == 0 )
				Damage = 0.25 * Damage;
			else if ( instigatedby.skill == 1 )
				Damage = 0.5 * Damage;
		}
		else if ( !injured.bIsPlayer )
			Damage = float(Damage) * (1.1 - 0.1 * injured.skill);
	}
	else if ( injured.bIsPlayer )
		Damage = Damage * (0.4 + 0.2 * instigatedBy.skill);
	return (Damage * instigatedBy.DamageScaling);
}

function float PlaySpawnEffect(inventory Inv)
{
	Inv.Spawn( class 'ReSpawn',,,, rot(0,0,0), None);
	return 0.3;
}

function bool ShouldRespawn(Actor Other)
{
	return false;
}

function string KillMessage( name damageType, pawn Other )
{
	local string message;

	if( bGenderMessages && Other.bIsFemale )
	{
		switch( damageType )
		{
		case 'exploded':
			message = FemExplodeMessage;
			break;
		case 'suicided':
			message = FemSuicideMessage;
			break;
		case 'fell':
			message = FemFallMessage;
			break;
		case 'drowned':
			message = FemDrownedMessage;
			break;
		case 'Burned':
			message = FemBurnedMessage;
			break;
		case 'Corroded':
			message = FemCorrodedMessage;
			break;
		case 'Bloodloss':
			message = FemBleededMessage;
			break;
		default:
			if (Other != none && Other.Region.Zone != None && Other.Region.Zone.DamageType==damageType
			 && Other.Region.Zone.DamageString != "") //this covers both foot and normal regions.
				message = " "$Other.Region.Zone.Damagestring; //Footregion.zone can kill you before region.zone.
			else if (Other != none && Other.FootRegion.Zone != None && Other.FootRegion.Zone.DamageType==damageType
			 && Other.FootRegion.Zone.DamageString != "")// the " "$ is to make it easier for mapppers, no space requied on the DamageString
				message = " "$Other.FootRegion.Zone.Damagestring;
			else if (Other != none && Other.HeadRegion.Zone != None && Other.HeadRegion.Zone.DamageType==damageType
			 && Other.HeadRegion.Zone.DamageString != "")     //Just incase a mapper makes a lava/slime
				message = " "$Other.HeadRegion.Zone.Damagestring;// zone in the ceiling above a jumper/elevantor!
			else message = FemDeathMessages[Rand(Array_Size(FemDeathMessages))];
		}
	return message;
	}
	switch( damageType )
	{
	case 'exploded':
		message = ExplodeMessage;
		break;
	case 'suicided':
		message = SuicideMessage;
		break;
	case 'fell':
		message = FallMessage;
		break;
	case 'drowned':
		message = DrownedMessage;
		break;
	case 'Special':
		message = GetSpecialDamageString(Other);
		break;
	case 'Burned':
		message = BurnedMessage;
		break;
	case 'Corroded':
		message = CorrodedMessage;
		break;
	case 'Bloodloss':
		message = BleededMessage;
		break;
	default:
		if (Other != none && Other.Region.Zone != None && Other.Region.Zone.DamageType==damageType
			 && Other.Region.Zone.DamageString != "") //this covers both foot and normal regions.
			message = " "$Other.Region.Zone.Damagestring; //Footregion.zone can kill you before region.zone.
		else if (Other != none && Other.FootRegion.Zone != None && Other.FootRegion.Zone.DamageType==damageType
			 && Other.FootRegion.Zone.DamageString != "")// the " "$ is to make it easier for mapppers, no space requied on the DamageString
			message = " "$Other.FootRegion.Zone.Damagestring;
		else if (Other != none && Other.HeadRegion.Zone != None && Other.HeadRegion.Zone.DamageType==damageType
			 && Other.HeadRegion.Zone.DamageString != "")     //Just incase a mapper makes a lava/slime
			message = " "$Other.HeadRegion.Zone.Damagestring;// zone in the ceiling above a jumper/elevantor!
		else message = DeathVerb$DeathTerm;
	}
	return message;
}

function string CreatureKillMessage( name damageType, pawn Other )
{
	local string message;

	if( bGenderMessages && Other.bIsFemale )
	{
		switch( damageType )
		{
		case 'exploded':
			message = FemExplodeMessage;
			break;
		case 'Burned':
			message = FemBurnedMessage;
			break;
		case 'Corroded':
			message = FemCorrodedMessage;
			break;
		case 'Hacked':
			message = FemHackedMessage;
			break;
		default:
			message = FemDeathMessages[Rand(Array_Size(FemDeathMessages))];
		}
	}
	else
	{
		switch( damageType )
		{
		case 'exploded':
			message = ExplodeMessage;
			break;
		case 'Burned':
			message = BurnedMessage;
			break;
		case 'Corroded':
			message = CorrodedMessage;
			break;
		case 'Hacked':
			message = HackedMessage;
			break;
		default:
			message = DeathVerb$DeathTerm;
		}
	}

	return ( message$DeathPrep );
}

function string PlayerKillMessage( name damageType, pawn Other )
{
	local string message;
	local float decision;

	decision = FRand();

	if( bGenderMessages && Other.bIsFemale )
	{
		if ( (Other.Health < - 25) && (decision < 0.3) )
			message = FemMajorDeathMessages[Rand(Array_Size(FemMajorDeathMessages))];
		else if ( DamageType == 'Decapitated' )
			message = FemHeadLossMessages[Rand(Array_Size(FemHeadLossMessages))];
		else message = FemDeathMessages[Rand(Array_Size(FemDeathMessages))];
	}
	else if ( (Other.Health < - 25) && (decision < 0.3) )
	{
		decision = FRand();
		if ( decision < 0.35 )
			message = MajorDeathMessage[0];
		else if ( decision < 0.7 )
			message = MajorDeathMessage[1];
		else
			message = MajorDeathMessage[2];
	}
	else
	{
		if ( DamageType == 'Decapitated' )
		{
			if ( FRand() < 0.4 )
				message = HeadLossMessage[1];
			else
				message = HeadLossMessage[0];
		}
		else
			message = DeathMessage[Rand(32)];

		decision = Other.Health * FRand();
		if ( decision < -35 )
			message = DeathModifier[4]$message;
		else if ( decision < -30 )
			message = DeathModifier[3]$message;
		else if ( decision < -30 )
			message = DeathModifier[3]$message;
		else if ( decision < -22 )
			message = DeathModifier[2]$message;
		else if ( decision < -15 )
			message = DeathModifier[1]$message;
		else if ( decision < -8 )
			message = DeathModifier[0]$message;

		message = DeathVerb$message;
	}

	return ( message$DeathPrep );
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
	local PawnTeleportEffect PTE;

	if ( Incoming.bIsPawn && bSound )
	{
		PTE = Incoming.Spawn(class'PawnTeleportEffect');
		PTE.Initialize(Pawn(Incoming), bOut);
		if ( Incoming.IsA('PlayerPawn') )
			PlayerPawn(Incoming).SetFOVAngle(170);
		Incoming.PlaySound(sound'Teleport1',, 10.0);
	}
}

defaultproperties
{
	deathmessage(0)="killed"
	deathmessage(1)="ruled"
	deathmessage(2)="smoked"
	deathmessage(3)="slaughtered"
	deathmessage(4)="annihilated"
	deathmessage(5)="put down"
	deathmessage(6)="splooged"
	deathmessage(7)="perforated"
	deathmessage(8)="shredded"
	deathmessage(9)="destroyed"
	deathmessage(10)="whacked"
	deathmessage(11)="canned"
	deathmessage(12)="busted"
	deathmessage(13)="creamed"
	deathmessage(14)="smeared"
	deathmessage(15)="shut out"
	deathmessage(16)="beaten down"
	deathmessage(17)="smacked down"
	deathmessage(18)="pureed"
	deathmessage(19)="sliced"
	deathmessage(20)="diced"
	deathmessage(21)="ripped"
	deathmessage(22)="blasted"
	deathmessage(23)="torn up"
	deathmessage(24)="spanked"
	deathmessage(25)="eviscerated"
	deathmessage(26)="neutered"
	deathmessage(27)="whipped"
	deathmessage(28)="shafted"
	deathmessage(29)="trashed"
	deathmessage(30)="smashed"
	deathmessage(31)="trounced"
	DeathModifier(0)="thoroughly "
	DeathModifier(1)="completely "
	DeathModifier(2)="absolutely "
	DeathModifier(3)="totally "
	DeathModifier(4)="utterly "
	MajorDeathMessage(0)=" ripped a new one"
	MajorDeathMessage(1)=" messed up real bad"
	MajorDeathMessage(2)=" given a new definition of pain"
	HeadLossMessage(0)="decapitated"
	HeadLossMessage(1)="beheaded"
	DeathVerb=" was "
	DeathPrep=" by "
	DeathTerm="killed"
	ExplodeMessage=" was blown up"
	SuicideMessage=" had a sudden heart attack."
	FallMessage=" left a small crater."
	DrownedMessage=" forgot to come up for air."
	BurnedMessage=" was incinerated"
	CorrodedMessage=" was slimed"
	HackedMessage=" was hacked"
	BleededMessage=" bled to death."
	DefaultWeapon=Class'UnrealShare.DispersionPistol'
	GameMenuType=Class'UnrealShare.UnrealGameOptionsMenu'
	HUDType=Class'UnrealShare.UnrealHUD'
	DefaultPlayerClass=Class'UnrealShare.MaleThree'
	WaterZoneType=Class'UnrealShare.WaterZone'	
}