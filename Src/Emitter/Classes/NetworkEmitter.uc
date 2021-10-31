// Normal particle emitter with network replication for triggering.
Class NetworkEmitter extends XEmitter;

#EXEC TEXTURE IMPORT FILE="Textures\S_EmitterNet.bmp" NAME="S_EmitterNet" GROUP="Icons" MIPS=off FLAGS=2 TEXFLAGS=0

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

event PostNetBeginPlay() {} // preserved for binary compatibility with old derived classes

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
	RepCounter=255
	bNetNotify=True
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
	bCarriedItem=True
	Texture=Texture'S_EmitterNet'
	bNoDelete=True
}
