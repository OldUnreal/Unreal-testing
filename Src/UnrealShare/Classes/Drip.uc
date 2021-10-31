//=============================================================================
// Drip.
//=============================================================================
class Drip extends DripGenerator;

#exec AUDIO IMPORT FILE="Sounds\General\Drip.wav" NAME="Drip1" GROUP="General"

var() sound DripSound;

auto state FallingState
{

	function Landed( vector HitNormal )
	{
		HitWall(HitNormal, None);
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		PlaySound(DripSound);
		Destroy();
	}

	singular function touch(actor Other)
	{
		PlaySound(DripSound);
		Destroy();
	}

Begin:
	PlayAnim('Dripping',0.3);
}

defaultproperties
{
	DripSound=UnrealShare.Drip1
	DripPause=+00000.000000
	DripVariance=+00000.000000
	DripTexture=None
	bHidden=False
	Skin=UnrealShare.JMisc1
	bMeshCurvy=False
	CollisionRadius=+00000.000000
	CollisionHeight=+00000.000000
	bCollideWorld=True
	Physics=PHYS_Falling
	LifeSpan=+00005.000000
}
