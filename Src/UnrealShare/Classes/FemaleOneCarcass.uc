//=============================================================================
// FemaleOneCarcass.
// DO NOT USE THESE AS DECORATIONS
//=============================================================================
class FemaleOneCarcass extends FemaleBody;

function ForceMeshToExist()
{
	//never called
	Spawn(class 'FemaleOne');
}

defaultproperties
{
	Mesh=Mesh'UnrealShare.Female1'
	AnimSequence=Dead1
	Physics=PHYS_Falling
	bBlockActors=true
	bBlockPlayers=true
}