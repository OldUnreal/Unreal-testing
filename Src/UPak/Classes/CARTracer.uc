//=============================================================================
// CARTracer.
//=============================================================================
class CARTracer expands Projectile;

simulated function PostBeginPlay()
{
	local rotator R;

	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * speed;
	if( Level.NetMode!=NM_DedicatedServer )
	{
		R.Pitch = Rotation.Pitch;
		R.Yaw = Rotation.Yaw;
		R.Roll = Rand(65536);
		SetRotation(R);
	}
}

defaultproperties
{
     speed=10000.000000
     MaxSpeed=10000.000000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=3.000000
     Style=STY_Translucent
     Skin=Texture'UPak.Skins.JTR0501'
     Mesh=LodMesh'UPak.TR025'
     DrawScale=2.000000
     ScaleGlow=10.000000
     Fatness=90
     bUnlit=True
}
