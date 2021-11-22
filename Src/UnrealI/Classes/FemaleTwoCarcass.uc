//=============================================================================
// FemaleTwoCarcass.
// DO NOT USE THESE AS DECORATIONS
//=============================================================================
class FemaleTwoCarcass extends Female2Body;

function ForceMeshToExist()
{
	//never called
	Spawn(class 'FemaleTwo');
}

defaultproperties
{
	Mesh=Mesh'UnrealI.Female2'
	AnimSequence=Dead1
	Physics=PHYS_Falling
	bBlockActors=true
	bBlockPlayers=true
}