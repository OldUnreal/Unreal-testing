//=============================================================================
// DemoRecSpectator - spectator for demo recordings to replicate ClientMessages
//=============================================================================
class DemoRecSpectator extends Spectator
	transient;

replication
{
	reliable if ( bDemoRecording )
		RepClientMessage, RepClientPlaySound, RepTeamMessage, RepClientVoiceMessage, RepClientSetHUD;
}

event PreBeginPlay()
{
	Super(Actor).PreBeginPlay();
	if ( bDeleteMe )
		return;

	// Set instigator to self.
	Instigator = Self;
	EyeHeight = BaseEyeHeight;
}
function PostBeginPlay()
{
	local PlayerPawn P;

	If (MainFOV < 90.0 || MainFOV >170.0)
		MainFOV = 90.0;
	DefaultFOV = MainFOV;
	//bIsPlayer = False;
	
	if( !Level.bIsDemoPlayback )
	{
		if( Level.Game!=None )
			RepClientSetHUD(Level.Game.HUDType, Level.Game.ScoreboardType);
		else
		{
			P = GetLocalPlayerPawn();
			if( P!=None && P!=Self )
				RepClientSetHUD(P.HUDType, P.ScoringType);
		}
	}
	
	if (PlayerReplicationInfoClass != None)
		PlayerReplicationInfo = Spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
	else
		PlayerReplicationInfo = Spawn(class'PlayerReplicationInfo', Self,,vect(0,0,0),rot(0,0,0));
	PlayerReplicationInfo.bIsSpectator = true;
	PlayerReplicationInfo.PlayerName = "Demo Spectator";
}
function PostNetBeginPlay();

function ClientMessage( coerce string S, optional name Type, optional bool bBeep )
{
	if( Level.bIsDemoPlayback )
		Super.ClientMessage(S, Type, bBeep);
	else RepClientMessage( S, Type, bBeep );
}

function ClientPlaySound(sound ASound, optional ESoundSlot SlotType)
{
	if( Level.bIsDemoPlayback )
		Super.ClientPlaySound(ASound, SlotType);
	else RepClientPlaySound(ASound);
}

function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type )
{
	if( Level.bIsDemoPlayback )
		Super.TeamMessage(PRI, S, Type);
	else RepTeamMessage( PRI, S, Type );
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	if( Level.bIsDemoPlayback )
		Super.ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
	else RepClientVoiceMessage(Sender, Recipient, messagetype, messageID);
}

function Typing( bool bTyping );

//==== Called during demo playback ============================================

event PreRender( canvas Canvas )
{
	local PlayerPawn P;
	
	if( HUDType!=None && (myHud==None || myHud.Class!=HUDType) )
	{
		if( myHud!=None )
			myHud.Destroy();
		myHUD = spawn(HUDType, self);
	}
	else if( HUDType==None )
	{
		// We are playing a demo from a server, find local player HUD type.
		foreach AllActors(class'PlayerPawn',P)
			if( P.HUDType!=None )
			{
				HUDType = P.HUDType;
				ScoringType = P.ScoringType;
				break;
			}
	}
	Super.PreRender(Canvas);
}

simulated function RepClientMessage( coerce string S, optional name Type, optional bool bBeep )
{
	if( Level.bIsDemoPlayback )
		GetLocalPlayerPawn().ClientMessage( S, Type, bBeep );
}

simulated function RepClientPlaySound(sound ASound)
{
	if( Level.bIsDemoPlayback )
		GetLocalPlayerPawn().ClientPlaySound( ASound );
}

simulated function RepTeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type )
{
	if( Level.bIsDemoPlayback )
		GetLocalPlayerPawn().TeamMessage( PRI, S, Type );
}

simulated function RepClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	if( Level.bIsDemoPlayback )
		GetLocalPlayerPawn().ClientVoiceMessage(Sender, Recipient, messagetype, messageID);
}

simulated function RepClientSetHUD( class<HUD> HudClass, class<Scoreboard> ScoreClass )
{
	if( Level.bIsDemoPlayback )
	{
		GetLocalPlayerPawn().HUDType = HudClass;
		GetLocalPlayerPawn().ScoringType = ScoreClass;
	}
}

exec function ViewPlayerNum(optional int num)
{
	local Pawn P,First;
	local bool bFoundTarget;

	if( ViewTarget==None || !ViewTarget.bIsPawn )
	{
		foreach AllActors(class'Pawn',P,'Player')
		{
			if ( P != self && P.PlayerReplicationInfo != none && !P.PlayerReplicationInfo.bIsSpectator )
			{
				ViewTarget = P;
				ClientMessage(ViewingFrom $ P.GetHumanName(), 'Event', true);
				return;
			}
		}
	}
	else
	{
		foreach AllActors(class'Pawn',P,'Player')
		{
			if( !bFoundTarget )
			{
				if( P==ViewTarget )
					bFoundTarget = true;
				else if( First==None && P!=self && P.PlayerReplicationInfo!=none && !P.PlayerReplicationInfo.bIsSpectator )
					First = P;
			}
			else if (P != self && P.PlayerReplicationInfo != none && !P.PlayerReplicationInfo.bIsSpectator)
			{
				ViewTarget = P;
				ClientMessage(ViewingFrom $ P.GetHumanName(), 'Event', true);
				return;
			}
		}
		if( First!=None )
		{
			ViewTarget = First;
			ClientMessage(ViewingFrom $ First.GetHumanName(), 'Event', true);
			return;
		}
	}
	ViewTarget = None;
	ClientMessage(ViewingFrom $ OwnCamera, 'Event', true);
}

exec function ViewSelf()
{
	bBehindView = false;
	ViewTarget = None;
	ClientMessage(ViewingFrom $ OwnCamera, 'Event', true);
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet )
{
	local actor Other, First;
	local bool bFound;

	First = None;
	ForEach AllActors( aClass, Other,,,true )
	{
		if ( (First == None) && (Other != self) )
		{
			First = Other;
			bFound = true;
		}
		if ( Other == ViewTarget )
			First = None;
	}

	if (bFound || ClassIsChildOf(Class, aClass))
	{
		if( Other==Self || Other==None )
		{
			bBehindView = false;
			ViewTarget = None;
			if( !bQuiet )
				ClientMessage(ViewingFrom $ OwnCamera, 'Event', true);
		}
		else
		{
			bBehindView = true;
			ViewTarget = Other;
			if( !bQuiet )
				ClientMessage(ViewingFrom $ Other.GetHumanName(), 'Event', true);
		}
	}
	else if (!bQuiet)
		ClientMessage(FailedView, 'Event', true);
}

exec function BehindView( Bool B )
{
	bBehindView = B;
	bChaseCam = bBehindView;
}

exec function AltFire( optional float F )
{
	if( ViewTarget!=None )
	{
		if( ViewTarget.bIsPawn )
		{
			if( ViewTarget.Level!=Level )
				SendToLevel(ViewTarget.Level,ViewTarget.Location);
			else SetLocation(ViewTarget.Location);
			if( Pawn(ViewTarget).ViewRotation==rot(0,0,0) )
				Pawn(ViewTarget).ViewRotation = ViewTarget.Rotation;
			ViewRotation = Pawn(ViewTarget).ViewRotation;
		}
		ViewSelf();
	}
}

exec function Say( string S );
exec function TeamSay( string S );

exec function SloMo( float T )
{
	Level.DemoTimeDilation = FClamp(T,0.1f,10.f);
}

exec function Pause()
{
	Level.bPauseDemo = !Level.bPauseDemo;
}
function bool SetPause( BOOL bPause )
{
	Level.bPauseDemo = bPause;
	return true;
}

state CheatFlying
{
	function BeginState()
	{
		Super.BeginState();
		SetCollision(false, false, false);
		bCollideWorld = false;
	}
}

defaultproperties
{
	bTickRealTime=true
	bAlwaysTick=true
}