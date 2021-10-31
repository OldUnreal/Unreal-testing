//=============================================================================
// MaleTwoCarcass.
// DO NOT USE THESE AS DECORATIONS
//=============================================================================
class MaleTwoCarcass extends MaleBodyTwo;

function ForceMeshToExist()
{
	//never called
	Spawn(class 'MaleTwo');
}

defaultproperties
{
	Mesh=Mesh'UnrealI.Male2'
	AnimSequence=Dead1
	Physics=PHYS_Falling
	bBlockActors=true
	bBlockPlayers=true
}