//=============================================================================
// WoodFragments.
//=============================================================================
class WoodFragments extends Fragment
	DependsOn(WoodenBox); // <= Import JWoodenBox1 texture first.

#exec MESH IMPORT MESH=wfrag1 ANIVFILE=Models\wfrag1_a.3d DATAFILE=ModelsFX\wfrag1_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag1 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag1 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag1 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag2 ANIVFILE=Models\wfrag2_a.3d DATAFILE=ModelsFX\wfrag2_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag2 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag2 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag2 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag2 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag3 ANIVFILE=Models\wfrag3_a.3d DATAFILE=ModelsFX\wfrag3_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag3 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag3 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag3 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag3 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag3 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag4 ANIVFILE=Models\wfrag4_a.3d DATAFILE=ModelsFX\wfrag4_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag4 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag4 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag4 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag4 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag4 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag5 ANIVFILE=Models\wfrag5_a.3d DATAFILE=ModelsFX\wfrag5_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag5 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag5 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag5 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag5 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag5 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag6 ANIVFILE=Models\wfrag6_a.3d DATAFILE=ModelsFX\wfrag6_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag6 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag6 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag6 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag6 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag6 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag7 ANIVFILE=Models\wfrag7_a.3d DATAFILE=ModelsFX\wfrag7_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag7 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag7 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag7 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag7 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag7 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag8 ANIVFILE=Models\wfrag8_a.3d DATAFILE=ModelsFX\wfrag8_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag8 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag8 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag8 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag8 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag8 NUM=0 TEXTURE=JWoodenBox1

#exec MESH IMPORT MESH=wfrag9 ANIVFILE=Models\wfrag9_a.3d DATAFILE=ModelsFX\wfrag9_d.3d X=0 Y=0 Z=0 FLAT=1
#exec MESH ORIGIN MESH=wfrag9 X=0 Y=0 Z=0 YAW=64 ROLL=0
#exec MESH SEQUENCE MESH=wfrag9 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=wfrag9 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=wfrag9 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=wfrag9 NUM=0 TEXTURE=JWoodenBox1

#exec AUDIO IMPORT FILE="Sounds\General\WoodHit1.wav" NAME="WoodHit1" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\WoodHit2.wav" NAME="WoodHit2" GROUP="General"

simulated function CalcVelocity(vector Momentum, float ExplosionSize)
{
	Super.CalcVelocity(Momentum, ExplosionSize);
	Velocity.z += ExplosionSize/2;
}

defaultproperties
{
	Fragments(0)=UnrealShare.wfrag1
	Fragments(1)=UnrealShare.wfrag2
	Fragments(2)=UnrealShare.wfrag3
	Fragments(3)=UnrealShare.wfrag4
	Fragments(4)=UnrealShare.wfrag5
	Fragments(5)=UnrealShare.wfrag6
	Fragments(6)=UnrealShare.wfrag7
	Fragments(7)=UnrealShare.wfrag8
	Fragments(8)=UnrealShare.wfrag9
	numFragmentTypes=9
	ImpactSound=UnrealShare.WoodHit1
	MiscSound=UnrealShare.WoodHit2
	Mesh=UnrealShare.wfrag2
	CollisionRadius=+00012.000000
	CollisionHeight=+00002.000000
	Mass=+00005.000000
	Buoyancy=+00006.000000
}
