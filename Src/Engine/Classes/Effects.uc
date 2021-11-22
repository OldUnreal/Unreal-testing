//=============================================================================
// Effects, the base class of all gratuitous special effects.
//=============================================================================
class Effects extends Actor
	NoUserCreate;

var() sound 	EffectSound1;
var() sound 	EffectSound2;
var() bool bOnlyTriggerable;

defaultproperties
{
	DrawType=DT_None
	Physics=PHYS_None
	bNetTemporary=true
	bGameRelevant=true
	CollisionRadius=+0.00000
	CollisionHeight=+0.00000
	CollisionFlag=COLLISIONFLAG_Effects
}
