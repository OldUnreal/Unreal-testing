//=============================================================================
// MaleTwoBot.
//=============================================================================
class MaleTwoBot extends MaleBot;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Male\jump10.wav" NAME="MJump2" GROUP="Male"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Male\land10.wav" NAME="MLand2" GROUP="Male"

function ForceMeshToExist()
{
	Spawn(class'MaleTwo');
}


defaultproperties
{
	Skin=Texture'UnrealI.Ash'
	Mesh=Male2
	JumpSound=MJump2
	LandGrunt=MLand2
	CarcassType=MaleTwoCarcass
}
