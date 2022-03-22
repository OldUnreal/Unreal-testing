// Normal mesh particle emitter with network replication for triggering.
Class NetworkMeshEmitter extends XMeshEmitter;

var transient repnotify byte RepCounter;
var transient byte ClientRepCounter;

replication
{
	reliable if ( Role==ROLE_Authority )
		RepCounter;
}

function PreBeginPlay(); // preserved for binary compatibility with old derived classes
function PostNetBeginPlay();
function PostNetReceive();

simulated function OnRepNotify( name Property )
{
	if( Property=='RepCounter' )
	{
		if( bNetBeginPlay )
		{
			if( TriggerAction==ETR_ToggleDisabled && (RepCounter & 1) )
				EmTrigger();
		}
		else if (RepCounter == 0)
			Reset();
		else if (TriggerAction != ETR_ToggleDisabled || ((RepCounter - ClientRepCounter) & 1) )
			EmTrigger();
		ClientRepCounter = RepCounter;
	}
}

simulated function Reset()
{
	RepCounter = 0;
	bDisabled = BACKUP_Disabled;
	bForceNetUpdate = true;
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	if ( Level.NetMode!=NM_DedicatedServer )
		EmTrigger();
	if ( ++RepCounter==255 )
		RepCounter = 1;
	bForceNetUpdate = true;
}

defaultproperties
{
	Texture=Texture'S_EmitterNet'
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bSkipActorReplication=True
	bNoDelete=True
	NetUpdateFrequency=1
	bOnlyDirtyReplication=true
}
