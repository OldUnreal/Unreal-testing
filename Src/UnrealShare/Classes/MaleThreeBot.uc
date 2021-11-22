//=============================================================================
// MaleThreeBot.
//=============================================================================
class MaleThreeBot extends MaleBot;

#exec AUDIO IMPORT FILE="Sounds\Male\jump11.wav" NAME="MJump3" GROUP="Male"
#exec AUDIO IMPORT FILE="Sounds\Male\land12.wav" NAME="MLand3" GROUP="Male"

function ForceMeshToExist()
{
	Spawn(class'MaleThree');
}


defaultproperties
{
	Mesh=Male3
	Skin=Texture'UnrealShare.Dante'
	JumpSound=MJump3
	LandGrunt=MLand3
	CarcassType=MaleThreeCarcass
}
