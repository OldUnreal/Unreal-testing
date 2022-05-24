//=============================================================================
// Spectator.
//=============================================================================
class Spectator extends PlayerPawn;

var bool bChaseCam;

function InitPlayerReplicationInfo()
{
	Super.InitPlayerReplicationInfo();
	PlayerReplicationInfo.bIsSpectator = true;
}

event FootZoneChange(ZoneInfo newFootZone)
{
}

event HeadZoneChange(ZoneInfo newHeadZone)
{
}

exec function Walk()
{
}

exec function ActivateItem()
{
	if (!bCanChangeBehindView)
		return;
	bBehindView = !bBehindView;
	bChaseCam = bBehindView;
}

exec function ActivateInventoryItem(class InvItem);

exec function BehindView( Bool B )
{
	if (Level.NetMode == NM_Client && ShouldForwardUserCommands())
	{
		ForwardUserCommand("BehindView" @ B);
		return;
	}
	if (!bCanChangeBehindView)
		return;
	bBehindView = B;
	bChaseCam = bBehindView;
}

function ChangeTeam( int N )
{
	Level.Game.ChangeTeam(self, N);
}

exec function Taunt( name Sequence )
{
}

exec function CallForHelp()
{
}

exec function ThrowWeapon()
{
}

exec function Suicide()
{
}

exec function Fly()
{
	UnderWaterTime = -1;
	SetCollision(false, false, false);
	bCollideWorld = true;
	GotoState('CheatFlying');

	ClientRestart();
}

function ServerChangeSkin( coerce string SkinName, coerce string FaceName, byte TeamNum )
{
}

function ClientReStart()
{
	//log("client restart");
	Velocity = vect(0,0,0);
	Acceleration = vect(0,0,0);
	BaseEyeHeight = Default.BaseEyeHeight;
	EyeHeight = BaseEyeHeight;

	GotoState('CheatFlying');
}

function PlayerTimeOut()
{
	if (Health > 0)
		Died(None, 'dropped', Location);
}

exec function Grab()
{
}

// Send a message to all players.
exec function Say( string S )
{
	local GameRules G;

	if ( !Level.Game.bMuteSpectators )
	{
		if ( Level.Game.GameRules!=None )
		{
			for ( G=Level.Game.GameRules; G!=None; G=G.NextRules )
				if ( G.bNotifyMessages && !G.AllowChat(Self,S) )
					Return;
		}
		BroadcastMessage( PlayerReplicationInfo.PlayerName$":"@S, true );
	}
}
exec function TeamSay( string S )
{
	local Pawn P;
	local GameRules G;

	if ( !Level.Game.bMuteSpectators )
	{
		if ( Level.Game.GameRules!=None )
		{
			for ( G=Level.Game.GameRules; G!=None; G=G.NextRules )
				if ( G.bNotifyMessages && !G.AllowChat(Self,S) )
					Return;
		}
		S = PlayerReplicationInfo.PlayerName@"(spectators):"@S;

		// Message all spectators only.
		foreach AllActors(class'Pawn',P,'Player')
			if( P.PlayerReplicationInfo!=None && P.PlayerReplicationInfo.bIsSpectator )
				P.ClientMessage( S,, true );
	}
}

//=============================================================================
// functions.

exec function RestartLevel()
{
}

// This pawn was possessed by a player.
function Possess()
{
	bIsPlayer = true;
	DodgeClickTime = FMin(0.3, DodgeClickTime);
	EyeHeight = BaseEyeHeight;
	NetPriority = 8;
	Weapon = None;
	Inventory = None;
	Fly();
	DefaultFOV = FClamp(MainFOV, 90, 170);
	DesiredFOV = DefaultFOV;
}

function PostBeginPlay()
{
	if (Level.LevelEnterText != "" )
		ClientMessage(Level.LevelEnterText);
	bIsPlayer = true;
	FlashScale = vect(1,1,1);
	if ( Level.NetMode != NM_Client )
		ScoringType = Level.Game.ScoreboardType;
}

//=============================================================================
// Inventory-related input notifications.

// The player wants to switch to weapon group numer I.
exec function SwitchWeapon (byte F )
{
}

exec function GetWeapon(class<Weapon> NewWeaponClass);

exec function NextItem()
{
}

exec function PrevItem()
{
}

exec function Fire( optional float F )
{
	if (Role == ROLE_Authority)
	{
		ViewPlayerNum(-1);
		bBehindView = bChaseCam && ViewTarget != none;
	}
}

// The player wants to alternate-fire.
exec function AltFire( optional float F )
{
	if (Role == ROLE_Authority)
		Level.Game.SetViewTarget(self, none);
}


//=================================================================================

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
					 Vector momentum, name damageType)
{
}

// To be returned for player info on serverlist.
function GetPlayerModelInfo( out string MeshName, out string SkinName )
{
	MeshName = MenuName;
	SkinName = string('None');
}

function bool CanInteractWithWorld()
{
	return false;
}

defaultproperties
{
	Visibility=0
	AttitudeToPlayer=ATTITUDE_Friendly
	bHidden=true
	bChaseCam=true
	bCollideActors=False
	bCollideWorld=False
	bBlockActors=False
	bBlockPlayers=False
	bProjTarget=False
	bIsAmbientCreature=True
	bTravel=False
	Menuname="Spectator"
	Health=0
	bOnlyOwnerRelevant=true
	bIsSpectatorClass=true
}