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
var byte RepIndex,ClientIndex;

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
		Array_Size(Sequence.SequenceItems,2);
		Sequence.SequenceItems[1].DisplayTime = 1.f;
		Sequence.SequenceItems[1].FadeOutTime = 0.f;
		Sequence.SequenceItems[1].Material = Materials[0].Material;
		Sequence.SequenceItems[0].Material = Materials[0].Material;
	}
}
simulated function PostNetReceive()
{
	if( ClientIndex!=RepIndex )
	{
		ClientIndex = RepIndex;
		FadeToMaterial(RepIndex);
	}
}
simulated final function FadeToMaterial( byte Num )
{
	RepIndex = Num;

	if( Level.NetMode!=NM_DedicatedServer )
	{
		Sequence.Paused = false;
		Sequence.CurrentTime = 0.f;
		Sequence.SequenceItems[0].Material = Sequence.SequenceItems[1].Material;
		Sequence.SequenceItems[0].DisplayTime = 0.f;
		Sequence.SequenceItems[0].FadeOutTime = Materials[RepIndex].FadeInTime;
		Sequence.SequenceItems[1].Material = Materials[RepIndex].Material;
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	if( (RepIndex+1)>=Array_Size(Materials) )
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
	bNetNotify=true
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	NetUpdateFrequency=10
	bSkipActorReplication=true
	bCollideActors=false
} 