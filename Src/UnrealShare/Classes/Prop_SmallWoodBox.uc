//=============================================================================
// Physics Prop SmallWoodBox
//=============================================================================
class Prop_SmallWoodBox extends Prop_WoodenBox;

defaultproperties
{
	Begin Object Name=BoxRigidBody
		Begin Object Name=BoxShapeBox
			Extent=(X=26.0,Y=26.0,Z=26.0)
		End Object
	End Object
	
	Health=5
	FragChunks=6
	Fragsize=0.6
	DrawScale=0.5
	CollisionRadius=14.5
	CollisionHeight=13
	Mass=20
}