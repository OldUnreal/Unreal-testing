//=============================================================================
// CARTracer.
//=============================================================================
class CARTracer expands Projectile;

#exec MESH IMPORT MESH=TR050 ANIVFILE=MODELS\TRACER\TR050_a.3d DATAFILE=MODELS\TRACER\TR050_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TR050 X=-239 Y=0 Z=0
#exec MESH SEQUENCE MESH=TR050 SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TR050 SEQ=TR050 STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JTR0501 FILE=MODELS\TRACER\Tracer2.PCX GROUP=Skins FLAGS=2

#exec MESHMAP NEW   MESHMAP=TR050 MESH=TR050
#exec MESHMAP SCALE MESHMAP=TR050 X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=TR050 NUM=0 TEXTURE=JTR0501

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
