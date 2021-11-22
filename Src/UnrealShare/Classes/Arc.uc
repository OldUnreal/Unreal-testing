//=============================================================================
// Arc.
//=============================================================================
class Arc extends Projectile;

var() texture SpriteAnim[8];

#exec TEXTURE IMPORT NAME=Arc1 FILE=Models\proa1.pcx GROUP=Effects Flags=2
#exec TEXTURE IMPORT NAME=Arc2 FILE=Models\proa2.pcx GROUP=Effects Flags=2
#exec TEXTURE IMPORT NAME=Arc3 FILE=Models\proa3.pcx GROUP=Effects Flags=2
#exec TEXTURE IMPORT NAME=Arc4 FILE=Models\proa4.pcx GROUP=Effects Flags=2
#exec TEXTURE IMPORT NAME=Arc5 FILE=Models\proa5.pcx GROUP=Effects Flags=2
#exec TEXTURE IMPORT NAME=Arc6 FILE=Models\proa6.pcx GROUP=Effects Flags=2
#exec TEXTURE IMPORT NAME=Arc7 FILE=Models\proa7.pcx GROUP=Effects Flags=2
#exec TEXTURE IMPORT NAME=Arc8 FILE=Models\proa8.pcx GROUP=Effects Flags=2

#exec MESH IMPORT MESH=ArcM ANIVFILE=Models\cros_s_a.3d DATAFILE=Models\cros_s_d.3d X=0 Y=0 Z=0  ZEROTEX=1 MLOD=1
// 24 Vertices, 8 Triangles
#exec MESH LODPARAMS MESH=ArcM STRENGTH=1.0 MINVERTS=12 MORPH=0.0 ZDISP=1200.0
#exec MESH ORIGIN MESH=ArcM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=ArcM SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=ArcM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=ArcM X=0.1 Y=0.1 Z=0.2
#exec MESHMAP SETTEXTURE MESHMAP=ArcM NUM=0 TEXTURE=Arc1 TLOD=10

var int i;
var vector X,Y,Z;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	i=0;
	if ( Instigator==None )
		Velocity = Vector(Rotation) * speed;
	else Velocity = VSize(Instigator.Velocity)*vector(Instigator.ViewRotation) + Vector(Rotation) * speed;
}
simulated function Tick(float DeltaTime)
{
	if ( Level.NetMode != NM_DedicatedServer )
		Skin = SpriteAnim[i];
	i++;
	if (i==8) i=0;
}
simulated function HitWall( vector HitNormal, actor Wall )
{
	Destroy();
}

defaultproperties
{
	SpriteAnim(0)=Texture'Arc1'
	SpriteAnim(1)=Texture'Arc2'
	SpriteAnim(2)=Texture'Arc3'
	SpriteAnim(3)=Texture'Arc4'
	SpriteAnim(4)=Texture'Arc5'
	SpriteAnim(5)=Texture'Arc6'
	SpriteAnim(6)=Texture'Arc7'
	SpriteAnim(7)=Texture'Arc8'
	Skin=Texture'Arc1'
	Mesh=LodMesh'ArcM'
}
