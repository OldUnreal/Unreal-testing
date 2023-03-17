// Network triggered material sequence.
// Written by Marco
Class MaterialTrigger extends Triggers;

struct MaterialSequenceItem
{
	var() Texture Material;
	var() float FadeInTime;
};

var() bool bLoopSequence;
var() MaterialSequence Sequence;
var() array<MaterialSequenceItem> Materials;
var repnotify byte RepIndex;

replication
{
	reliable if ( Role==ROLE_Authority )
		RepIndex;
}

simulated function PostBeginPlay()
{
	if( Level.NetMode!=NM_DedicatedServer )
	{
		Sequence.Paused = true;
		Sequence.Loop = false;
		Sequence.CurrentTime = 0.f;
		Sequence.SequenceItems.SetSize(2);
		Sequence.SequenceItems[1].DisplayTime = 1.f;
		Sequence.SequenceItems[1].FadeOutTime = 0.f;
		Sequence.SequenceItems[1].Material = Materials[0].Material;
		Sequence.SequenceItems[0].Material = Materials[0].Material;
	}
}
simulated function OnRepNotify( name Property )
{
	if( Property=='RepIndex' )
		FadeToMaterial(RepIndex);
}
simulated final function FadeToMaterial( byte Num )
{
	if( Level.NetMode!=NM_Client )
	{
		RepIndex = Num;
		bForceNetUpdate = true;
	}
	if( Level.NetMode!=NM_DedicatedServer )
	{
		Sequence.Paused = false;
		Sequence.CurrentTime = 0.f;
		Sequence.SequenceItems[0].Material = Sequence.SequenceItems[1].Material;
		Sequence.SequenceItems[0].DisplayTime = 0.f;
		Sequence.SequenceItems[0].FadeOutTime = Materials[Num].FadeInTime;
		Sequence.SequenceItems[1].Material = Materials[Num].Material;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	if( (RepIndex+1)>=Materials.Size() )
	{
		if( !bLoopSequence )
			Disable('Trigger');
		else FadeToMaterial(0);
	}
	else FadeToMaterial(RepIndex+1);
}
function Reset()
{
	FadeToMaterial(0);
	Enable('Trigger');
}

defaultproperties
{
	bStatic=true
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	NetUpdateFrequency=1
	bSkipActorReplication=true
	bOnlyDirtyReplication=true
	bCollideActors=false
} 