//=============================================================================
// Woodruff.
//=============================================================================
class WoodruffSchool extends Woodruff;

defaultproperties
{
	HealingAmount=20
	PickupMessage="You got a bundle Master of the woods +"
	PickupViewMesh=Mesh'WoodruffSchool'
	Mesh=Mesh'Waldmeister'
	CollisionRadius=16
	CollisionHeight=7.5
	AnimSequence="Idle1"
	RespawnTime=10
	DrawScale=0.1
	PickupViewScale=0.1
	PrePivot=(Z=-3.5)
}
