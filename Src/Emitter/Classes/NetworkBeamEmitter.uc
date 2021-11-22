// Normal particle emitter with network replication for triggering.
Class NetworkBeamEmitter extends XBeamEmitter;

var byte RepCounter,ClientRepCounter;

replication
{
	reliable if ( Role==ROLE_Authority )
		RepCounter;
}

function PreBeginPlay()
{
	RepCounter = 0;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	bNetNotify = true;
}

simulated event PostNetReceive()
{
	if (ClientRepCounter != RepCounter)
	{
		if (RepCounter == 0)
			Reset();
		else if (TriggerAction != ETR_ToggleDisabled || ((RepCounter - ClientRepCounter) & 1) != 0)
			EmTrigger();
		ClientRepCounter = RepCounter;
	}
}

simulated function Reset()
{
	RepCounter = 0;
	bDisabled = BACKUP_Disabled;
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	if ( Level.NetMode!=NM_DedicatedServer )
		EmTrigger();
	if ( ++RepCounter==255 )
		RepCounter = 1;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bCarriedItem=True
	Texture=Texture'S_EmitterNet'
	bNoDelete=True
	RepCounter=255
}
