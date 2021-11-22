//=============================================================================
// MaleOneCarcass.
// DO NOT USE THESE AS DECORATIONS
//=============================================================================
class MaleOneCarcass extends MaleBody;

function ForceMeshToExist()
{
	//never called
	Spawn(class 'MaleOne');
}

defaultproperties
{
	Mesh=Mesh'UnrealI.Male1'
	AnimSequence=Dead1
	Physics=PHYS_Falling
	bBlockActors=true
	bBlockPlayers=true
}