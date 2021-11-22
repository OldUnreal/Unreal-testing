//=============================================================================
// MarineInterestPoint.
//=============================================================================
class MarineInterestPoint expands PickUp;

function PostBeginPlay()
{
	Texture = none;
	DrawType = DT_None;
}
function PickUpFunction( pawn Other )
{
	Destroy();
}

defaultproperties
{
     PickupMessage=""
     RespawnTime=0.500000
     MaxDesireability=2.000000
     M_Activated=""
     M_Selected=""
     M_Deactivated=""
     DrawType=DT_Sprite
}
