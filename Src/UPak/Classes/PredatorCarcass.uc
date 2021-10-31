//=============================================================================
// PredatorCarcass.
//=============================================================================
class PredatorCarcass expands CreatureCarcass;

function ForceMeshToExist()
{
	//never called
	Spawn( class 'Predator' );
}
function InitFor( actor Other )
{
	Super.InitFor( Other );
	if( AnimSequence == 'Death5' )
		bodyparts[6]=None;
}

defaultproperties
{
     bodyparts(0)=LodMesh'UPak.PredatorBody'
     bodyparts(1)=LodMesh'UPak.PredatorTail'
     bodyparts(2)=LodMesh'UPak.PredatorLeftLeg'
     bodyparts(3)=LodMesh'UPak.PredatorRightLeg'
     bodyparts(4)=LodMesh'UPak.PredatorFoot'
     bodyparts(5)=LodMesh'UnrealShare.CowBody1'
     bodyparts(6)=LodMesh'UPak.PredatorHead'
     ZOffset(1)=0.500000
     ZOffset(2)=0.250000
     ZOffset(3)=0.250000
     ZOffset(5)=0.500000
     ZOffset(6)=0.500000
     AnimSequence=Death
     Mesh=LodMesh'UPak.Predator'
     CollisionRadius=16.000000
     CollisionHeight=20.000000
     Mass=50.000000
     Buoyancy=50.000000
}
