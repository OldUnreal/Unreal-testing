//=============================================================================
// ShotShellCase.
//=============================================================================
class ShotShellCase extends ShellCase;

#exec MESH IMPORT MESH=shotshellused ANIVFILE=Models\shotshellused_a.3d DATAFILE=Models\shotshellused_d.3d LODSTYLE=1 MLOD=1
// 122 Vertices, 120 Triangles
#exec MESH LODPARAMS MESH=shotshellused STRENGTH=0.3 MINVERTS=42 MORPH=0.6 ZDISP=500.0

#exec MESH ORIGIN MESH=shotshellused X=0 Y=0 Z=0 YAW=0 ROLL=64
#exec MESH SEQUENCE MESH=shotshellused SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW MESHMAP=shotshellused MESH=shotshellused
#exec MESHMAP SCALE MESHMAP=shotshellused X=0.03 Y=0.03 Z=0.05
#exec MESHMAP SETTEXTURE MESHMAP=shotshellused NUM=0 TEXTURE=Jshells1 TLOD=10

var nowarn bool bHasBounced;

simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector RealHitNormal;

	if ( bHasBounced && ((FRand() < 0.85) || (Velocity.Z > -50)) )
		bBounce = false;
	if ( !Region.Zone.bWaterZone )
		PlaySound(sound 'shell2',SLOT_Misc,0.4,False,300.0,0.6+FRand()/20.0);
	RealHitNormal = HitNormal;
	HitNormal = Normal(HitNormal + 0.4 * VRand());
	if ( (HitNormal Dot RealHitNormal) < 0 )
		HitNormal *= -0.5;
	Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	RandSpin(100000);
	bHasBounced = True;
}

simulated function Landed( vector HitNormal )
{
	local rotator RandRot;

	if ( !Region.Zone.bWaterZone )
		PlaySound(sound 'shell2',SLOT_Misc,0.5,False,300.0,0.5+FRand()/20.0);
	SetPhysics(PHYS_None);
	RandRot = Rotation;
	RandRot.Pitch = 0;
	RandRot.Roll = 0;
	SetRotation(RandRot);
}

defaultproperties
{
	MaxSpeed=1000.000000
	bNetOptional=True
	bReplicateInstigator=False
	Physics=PHYS_Falling
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=4.000000
	Mesh=LodMesh'shotshellused'
	bUnlit=True
	bNoSmooth=True
	bCollideActors=False
	LightType=LT_Steady
	LightEffect=LE_None
	LightBrightness=0
	LightHue=0
	LightSaturation=0
	LightRadius=0
	bBounce=True
	bFixedRotationDir=True
	NetPriority=2.000000
	CollisionHeight=4.0
	CollisionRadius=8.0
	bMeshCurvy=True
}