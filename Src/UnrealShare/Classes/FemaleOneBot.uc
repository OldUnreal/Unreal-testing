//=============================================================================
// FemaleOneBot.
//=============================================================================
class FemaleOneBot extends FemaleBot;

function ForceMeshToExist()
{
	Spawn(class'FemaleOne');
}

defaultproperties
{
	Mesh=Female1
	Skin=Texture'UnrealShare.Gina'
	CarcassType=FemaleOneCarcass
}
