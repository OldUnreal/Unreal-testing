// Similar to DynamicCorona, but supports trigger visibility.
Class TriggerCorona extends DynamicCorona;

var float InitialFade;

var() bool bTriggerOnceOnly, bHoldTrigger;
var() float FadeTime;

var transient int numTriggerEvents;

var bool bPendingDisable,bInitialEnabled;
var transient bool bToggled,bClientToggled;

replication
{
	unreliable if ( Role==ROLE_Authority )
		bToggled;
}

simulated function BeginPlay()
{
	InitialFade = ScaleGlow;
	FadeTime = ScaleGlow / FMax(FadeTime,0.001);
	bInitialEnabled = bEnabled;
	if( !bEnabled )
	{
		ScaleGlow = 0.f;
		bPendingDisable = true;
	}
	Disable('Tick');
}

simulated function PostNetReceive()
{
	if( bClientToggled!=bToggled )
	{
		bClientToggled = bToggled;
		if( bNetBeginPlay )
		{
			bEnabled = !bEnabled;
			ScaleGlow = bEnabled ? InitialFade : 0.f;
		}
		else ToggleEnabled();
	}
}

simulated function ToggleEnabled()
{
	if( Level.NetMode!=NM_Client )
	{
		bToggled = !bToggled;
		bForceNetUpdate = true;
	}
	if( Level.NetMode!=NM_DedicatedServer )
	{
		bEnabled = true;
		bPendingDisable = !bPendingDisable;
		Enable('Tick');
	}
}

simulated function Tick( float DeltaTime )
{
	if( Level.NetMode==NM_DedicatedServer )
	{
		Disable('Tick');
		return;
	}
	if( bPendingDisable )
	{
		ScaleGlow-=(FadeTime*DeltaTime);
		if( ScaleGlow<=0.f )
		{
			ScaleGlow = 0.f;
			bEnabled = false;
			Disable('Tick');
		}
	}
	else
	{
		ScaleGlow+=(FadeTime*DeltaTime);
		if( ScaleGlow>=InitialFade )
		{
			ScaleGlow = InitialFade;
			Disable('Tick');
		}
	}
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	if( bHoldTrigger )
	{
		++numTriggerEvents;
		if( numTriggerEvents>1 )
			return;
	}
	ToggleEnabled();
	if( bTriggerOnceOnly )
		Disable('Trigger');
}
function UnTrigger( Actor Other, Pawn EventInstigator )
{
	if( bHoldTrigger )
	{
		--numTriggerEvents;
		if( numTriggerEvents==0 )
		{
			ToggleEnabled();
			if( bTriggerOnceOnly )
				Disable('UnTrigger');
		}
		else if( numTriggerEvents<0 )
			numTriggerEvents = 0;
	}
}

function Reset()
{
	if( bTriggerOnceOnly )
	{
		Enable('Trigger');
		Enable('UnTrigger');
	}
	numTriggerEvents = 0;
	Disable('Tick');

	bEnabled = bInitialEnabled;
	ScaleGlow = bInitialEnabled ? InitialFade : 0.f;
	
	if( bToggled )
	{
		bToggled = false;
		bForceNetUpdate = true;
	}
}

defaultproperties
{
	bNetNotify=true
	bStatic=false
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=0.5
	bAlwaysRelevant=true
	bSkipActorReplication=true
}