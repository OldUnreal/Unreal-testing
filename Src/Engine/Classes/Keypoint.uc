//=============================================================================
// Keypoint, the base class of invisible actors which mark things.
//=============================================================================
class Keypoint extends Actor
		abstract
			native;

// Sprite.
#exec Texture Import File=Textures\KeyPoint.pcx Name=S_Keypoint Mips=Off Flags=2

defaultproperties
{
	bStatic=True
	bHidden=True
	SoundVolume=0
	CollisionRadius=+00010.000000
	CollisionHeight=+00010.000000
	Texture=S_Keypoint
	CollisionFlag=COLLISIONFLAG_Keypoints
}
