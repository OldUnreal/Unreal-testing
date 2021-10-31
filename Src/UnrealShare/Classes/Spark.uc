//=============================================================================
// spark.
//=============================================================================
class Spark extends Effects
	transient;

#exec TEXTURE IMPORT NAME=Sparky FILE=Models\Decals\spark.pcx GROUP=Effects


function PostBeginPlay()
{
	Velocity = (Vector(Rotation) + VRand()) * 200 * FRand();
}

auto state Explode
{
	simulated function ZoneChange( ZoneInfo NewZone )
	{
		if ( NewZone.bWaterZone )
			Destroy();
	}

	simulated function Landed( vector HitNormal )
	{
		Destroy();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Destroy();
	}
}

defaultproperties
{
	Physics=PHYS_Falling
	RemoteRole=ROLE_None
	LifeSpan=1.000000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'Unrealshare.Effects.Sparky'
	DrawScale=0.100000
	bUnlit=True
	bMeshCurvy=False
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	bCollideWorld=True
	bBounce=True
	NetPriority=2.000000
}
