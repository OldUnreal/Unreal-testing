//=============================================================================
// CoopGame.
//=============================================================================
class CoopGame extends UnrealGameInfo
	NoUserCreate;

var() config bool	bNoFriendlyFire;
var bool	bSpecialFallDamage;
var() config bool		bInstantWeaponRespawn;
var() config bool		bInstantItemRespawn;
var() config bool		bHighFlareAndSeedRespawn;// if true, you can set a custom time with FlareAndSeedRespawnTime
var() config float		FlareAndSeedRespawnTime;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	bClassicDeathMessages = True;
	
	// hack to skip end game in coop play
	if( string(Outer.Name) ~= "EndGame" )
		SetTimer(80,false,'SkipEndGame');
}

function SkipEndGame()
{
	Level.ServerTravel( "Vortex2", False);
}

function bool IsRelevant(actor Other)
{
	// hide all playerpawns

	if ( Other.IsA('PlayerPawn') && !Other.IsA('Spectator') )
	{
		Other.SetCollision(false,false,false);
		Other.bHidden = true;
	}
	return Super.IsRelevant(Other);
}

function float PlaySpawnEffect(inventory Inv)
{
	if ( Weapon(Inv)!=None && Weapon(Inv).bWeaponStay )
		Return 0;
	return Super.PlaySpawnEffect(Inv);
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn      NewPlayer;

	NewPlayer =  Super.Login(Portal, Options, Error, SpawnClass);
	if ( NewPlayer != None )
	{
		if ( !NewPlayer.IsA('Spectator') )
		{
			NewPlayer.bHidden = false;
			NewPlayer.SetCollision(true,true,true);
		}
		//log("Logging in to "$Level.Title);
		if ( Level.Title ~= "The Source Antechamber" )
		{
			bSpecialFallDamage = true;
			//log("reduce fall damage");
		}
	}
	return NewPlayer;
}

function NavigationPoint FindPlayerStart( byte Team, optional string incomingName )
{
	local PlayerStart Dest,Best;
	local int Score,BestScore;
	local Pawn P;
	local LevelInfo L;
	
	L = (SpawnLevel!=None) ? SpawnLevel : Level;

	while( true )
	{
		//choose candidates
		foreach L.AllActors( class 'PlayerStart', Dest )
		{
			Score = Rand(100); // Randomize base scoring.
			if( !Dest.bEnabled )
				Score-=10000;
			if( !Dest.bSinglePlayerStart && !Dest.bCoopStart )
				Score-=1000;
			if( Dest.Region.Zone.bWaterZone )
				Score-=1500;

			foreach L.RadiusActors(class'Pawn',P,100,Dest.Location)
				if( P.bIsPlayer && P.Health>0 && P.bBlockActors )
					Score-=100;
			if( Best==None || Score>BestScore )
			{
				Best = Dest;
				BestScore = Score;
			}
		}
		if( Best!=None || L==Level )
			break;
		L = Level;
	}

	if( Best==None )
		return Level.NavigationPointList; // Attempt to recover.
	return Best;
} 

function int ReduceDamage(int Damage, name DamageType, pawn injured, pawn instigatedBy)
{
	if ( bNoFriendlyFire && (instigatedBy != None)
			&& instigatedBy.bIsPlayer && injured.bIsPlayer && (instigatedBy != injured) )
		return 0;

	if ( (DamageType == 'Fell') && bSpecialFallDamage )
		return Min(Damage, 5);

	return Super.ReduceDamage(Damage, DamageType, injured, instigatedBy);
}

function bool ShouldRespawn(Actor Other)
{
	if ( Inventory(Other).RespawnTime<=0 )
		Return False;

	if ( bInstantWeaponRespawn && Weapon(Other)!=None )
	{
		Weapon(other).RespawnTime = 0.1;
		Weapon(other).bWeaponStay = False;//Needed for "quick" respawns!
		return true;
	}
	else if (bInstantItemRespawn && Pickup(Other)!=None )
	{
		Inventory(Other).RespawnTime = 0.1;

		if ( bHighFlareAndSeedRespawn && (other.isa('Seeds') || other.isa('Flare')) )
			Inventory(Other).RespawnTime = FlareAndSeedRespawnTime;
		return true;
	}
	else if ( Other.IsA('Weapon') && !Weapon(Other).bHeldItem )
	{
		Inventory(Other).ReSpawnTime = 1.0;
		return true;
	}
	return false;
}

function SendPlayer( PlayerPawn aPlayer, string URL )
{
	local GameRules G;

	if ( GameRules!=None )
	{
		for ( G=GameRules; G!=None; G=G.NextRules )
			if ( G.bHandleMapEvents && !G.CanCoopTravel(aPlayer,URL) )
				return;
	}
	// hack to skip end game in coop play
	/*if ( left(URL,7) ~= "endgame")
	{
		Level.ServerTravel( "Vortex2", False);
		return;
	}*/
	/*if ( left(URL,11) ~= "extremeDGen")//change to fixed map instead
	{
		if(DynamicLoadObject("EXTREMEDarkGen.MyLevel",class'Level') != None)
		{
			Level.ServerTravel( "EXTREMEDarkGen", True);
			return;
		}
	}*/
	Level.ServerTravel( URL, true );
}

function PlayTeleportEffect( actor Incoming, bool bOut, bool bSound)
{
}

function Killed(pawn killer, pawn Other, name damageType)
{
	super.Killed(killer, Other, damageType);
	if ( Killer!=None && Killer.PlayerReplicationInfo!=None && (Other.bIsPlayer || Other.IsA('Nali')) )
		killer.PlayerReplicationInfo.Score -= 2;
}

function AddDefaultInventory(Pawn Player)
{
	if (Player.IsA('Spectator'))
		return;
	Player.JumpZ = Player.default.JumpZ * PlayerJumpZScaling();
	if (Level.DefaultGameType != class'VRikersGame')
		AddPlayerDefaultWeapon(Player);
	AddPlayerDefaultPickup(Player, class'Translator');
	ModifyPlayerWithGameRules(Player);
}

defaultproperties
{
	bNoFriendlyFire=True
	FlareAndSeedRespawnTime=10.000000
	bHumansOnly=True
	bRestartLevel=False
	bPauseable=False
	bCoopWeaponMode=False
	bClassicDeathmessages=True
	ScoreBoardType=Class'UnrealShare.UnrealScoreBoard'
	GameMenuType=Class'UnrealShare.UnrealCoopGameOptions'
	RulesMenuType="UMenu.UMenuCoopGameRulesSClient"
	SettingsMenuType="UMenu.UMenuCoopGameSettingsSClient"
	BotMenuType=""
	BeaconName="Coop"
	GameName="Coop Game"
}
