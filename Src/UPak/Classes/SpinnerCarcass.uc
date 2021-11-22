//=============================================================================
// SpinnerCarcass.
//=============================================================================
class SpinnerCarcass expands CreatureCarcass;

function ForceMeshToExist()
{
	//never called
	Spawn( class 'Spinner' );
}

function InitFor( actor Other )
{
	Super.InitFor( Other );
	if( AnimSequence == 'Death5' )
		bodyparts[7]=None;
}

defaultproperties
{
     bodyparts(0)=LodMesh'UPak.SpinnerBody'
     bodyparts(1)=LodMesh'UPak.SpinnerTail'
     bodyparts(2)=LodMesh'UPak.SpinnerLeg1'
     bodyparts(3)=LodMesh'UPak.SpinnerLeg2'
     bodyparts(4)=LodMesh'UPak.SpinnerLeg3'
     bodyparts(5)=LodMesh'UPak.SpinnerLeg4'
     bodyparts(6)=LodMesh'UPak.SpinnerClaw'
     bodyparts(7)=LodMesh'UPak.SpinnerHead'
     ZOffset(1)=0.750000
     ZOffset(2)=0.250000
     ZOffset(3)=0.250000
     ZOffset(4)=0.250000
     ZOffset(5)=0.250000
     ZOffset(7)=0.500000
     bGreenBlood=True
     AnimSequence=Death
     Mesh=LodMesh'UPak.Spinner'
     CollisionRadius=32.000000
     CollisionHeight=22.000000
     Mass=100.000000
     Buoyancy=100.000000
}
