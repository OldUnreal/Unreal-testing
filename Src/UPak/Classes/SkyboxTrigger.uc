//=============================================================================
// SkyboxTrigger
//=============================================================================
// When touched, the SkyboxTrigger will change the SkyZone in
// the ZoneInfo with the matching Tag.  The SkyZoneInfo is identified by
// matching the trigger's Tag against the SkyZoneInfo's Tag.
class SkyboxTrigger expands Trigger;

var byte SkyLinkUpd;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		SkyLinkUpd;
}

simulated function PostNetReceive()
{
	if( SkyLinkUpd>0 )
	{
		RelinkSkybox();
		SkyLinkUpd = 0;
	}
}

simulated function RelinkSkybox()
{
	local SkyZoneInfo S;
	local ZoneInfo Z;
	local SkyboxTrigger T;

	if( Level.NetMode!=NM_Client )
	{
		if( ++SkyLinkUpd>=250 )
			SkyLinkUpd = 1;
		bForceNetUpdate = true;
		
		// Do not allow new clients mess up which sky to use.
		foreach AllActors(class'SkyboxTrigger',T,,Event)
			if( T!=Self && T.Event==Event )
				T.SkyLinkUpd = 0;
	}
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	// find the skyzone that matches our "Tag"
	foreach AllActors( class'SkyZoneInfo', S, Tag )
	{
		// update all the Zones that match our "Event"
		foreach AllActors( class 'ZoneInfo', Z, Event )
		{
			Z.SkyZone = S;
		}
	}
}

//
// Called when something touches the trigger.
// Complete override of Trigger.uc implementation (copy&paste + modifications)
//
function Touch( actor Other )
{
	if( IsRelevant( Other ) )
	{
		if( ReTriggerDelay > 0 )
		{
			if( Level.TimeSeconds - TriggerTime < ReTriggerDelay )
				return;
			TriggerTime = Level.TimeSeconds;
		}

		// Update SkyZone in all matching actors.
		if( Event != '' )
			RelinkSkybox();

		if( Other.IsA('Pawn') && (Pawn(Other).SpecialGoal == self) )
			Pawn(Other).SpecialGoal = None;
				
		if( Message != "" )
			// Send a string message to the toucher.
			Other.Instigator.ClientMessage( Message );

		if( bTriggerOnceOnly )
			// Ignore future touches.
			SetCollision(False);
		else if( RepeatTriggerTime > 0 )
			SetTimer(RepeatTriggerTime, false);
	}
}

//
// When something untouches the trigger.
// Complete override of Trigger.uc implementation -- do nothing
//
function UnTouch( actor Other );

defaultproperties
{
	bNoDelete=True
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	CollisionRadius=80.000000
	NetUpdateFrequency=1
	bSkipActorReplication=true
	bNetNotify=true
}