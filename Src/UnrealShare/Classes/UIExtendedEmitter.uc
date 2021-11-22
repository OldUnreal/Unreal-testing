// since implementations rest of the states requires replication,
// i've decided to implement it in subclass. That way anyone, who
// wish to use only Emitter without turning it on/off, etc. will
// use version without replication.
class UIExtendedEmitter extends UIParticleEmitter;

var() bool bIsOn;                     // replaces bOn from ParticleEmitter in new states
var() float TriggerBlastDelay;        // time between blasts (how often Emitter in TriggerBlast state can be triggered)

replication
{
	reliable if (Role == ROLE_Authority)
		bIsOn, SetOn;
}
//=============================================================================
// Set's bOn on or off. cleintside function
//=============================================================================
function SetOn(bool btun)
{
	/*if(Level.NetMode != NM_DedicatedServer)*/
	bIsOn=btun;
}
//=============================================================================
// Toggle when triggered.
//=============================================================================
simulated state() TriggerToggle
{
	simulated function BeginState()
	{
		Disable('Tick');
	}
	/*simulated */function Trigger( actor Other, pawn EventInstigator )
	{
		if (bIsOn)
		{
			SetOn(false);
		}
		else
		{
			SetOn(true);
		}
	}
Begin:
//nothing here :)
AfterBegin:
	if (!bIsOn) GoTo('NearEnd');
	InStateStuff();
NearEnd:
	sleep(trIntervall);
	GoTo('AfterBegin');
}
//=============================================================================
// tunrs off when triggered.
//=============================================================================
simulated state() TriggerTurnsOff
{
	simulated function BeginState()
	{
		SetOn(true);
	}
	/*simulated */function Trigger( actor Other, pawn EventInstigator )
	{
		SetOn(false);
		if (!bNoDelete) GoToState('BeforeDie'); //Destroy();
		else GoToState('NoParticles');
	}
Begin:
//nothing here :)
AfterBegin:
	if (!bIsOn) GoTo('NearEnd');
	InStateStuff();
NearEnd:
	sleep(trIntervall);
	GoTo('AfterBegin');
}
//=============================================================================
// turns on when triggered.
//=============================================================================
simulated state() TriggerTurnsOn
{
	simulated function BeginState()
	{
		SetOn(false);
	}
	/*simulated */function Trigger( actor Other, pawn EventInstigator )
	{
		SetOn(true);
	}
Begin:
//nothing here :)
AfterBegin:
	if (!bIsOn) GoTo('NearEnd');
	InStateStuff();
NearEnd:
	sleep(trIntervall);
	GoTo('AfterBegin');
}
//=============================================================================
// Start when triggered, Stop when get untriggered.
//=============================================================================
simulated state() TriggerControl
{
	simulated function BeginState()
	{
		SetOn(false);
	}
	/*simulated */function Trigger( actor Other, pawn EventInstigator )
	{
		SetOn(true);
	}
	/*simulated */function UnTrigger( actor Other, pawn EventInstigator )
	{
		SetOn(false);
	}
Begin:
//nothing here :)
AfterBegin:
	if (!bIsOn) GoTo('NearEnd');
	InStateStuff();
NearEnd:
	sleep(trIntervall);
	GoTo('AfterBegin');
}
//=============================================================================
// Blast triggered.
//=============================================================================
simulated state() TriggeredBlast
{
	simulated function BeginState()
	{
		SetOn(false);
	}

	/*simulated */function Trigger( actor Other, pawn EventInstigator )
	{
		SetOn(true);
		Disable('Trigger');
	}
Begin:
//nothing here :)
AfterBegin:
	if (!bIsOn) GoTo('NearEnd');
	InStateStuff();
	SetOn(false);
	Sleep(TriggerBlastDelay);
	Enable('Trigger');
NearEnd:
	sleep(0.1);
	GoTo('AfterBegin');
}

simulated state Startup
{
Begin:
//     if(Level.NetMode != NM_DedicatedServer)
//     {
	if (InitialState != '') GoToState(InitialState);
	else GotoState('NormalParticle');
//     }
}

defaultproperties
{
	TriggerBlastDelay=0.5
}
