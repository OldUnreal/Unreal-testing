//=============================================================================
// Fragment1.
//=============================================================================
class Fragment1 extends Fragment;

#exec MESH IMPORT MESH=vfrag1 ANIVFILE=Models\frag1_a.3d DATAFILE=Models\frag1_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vfrag1 X=0 Y=0 Z=0 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=vfrag1 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=vfrag1 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vfrag1 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=vfrag1 NUM=0 TEXTURE=Jvase1

#exec MESH IMPORT MESH=vfrag2 ANIVFILE=Models\frag2_a.3d DATAFILE=Models\frag2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vfrag2 X=0 Y=0 Z=0 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=vfrag2 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=vfrag2 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vfrag2 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=vfrag2 NUM=0 TEXTURE=Jvase1

#exec MESH IMPORT MESH=vfrag3 ANIVFILE=Models\frag3_a.3d DATAFILE=Models\frag3_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vfrag3 X=0 Y=0 Z=0 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=vfrag3 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=vfrag3 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vfrag3 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=vfrag3 NUM=0 TEXTURE=Jvase1

#exec MESH IMPORT MESH=vfrag4 ANIVFILE=Models\frag4_a.3d DATAFILE=Models\frag4_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vfrag4 X=0 Y=0 Z=0 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=vfrag4 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=vfrag4 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vfrag4 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=vfrag4 NUM=0 TEXTURE=Jvase1

#exec MESH IMPORT MESH=vfrag5 ANIVFILE=Models\frag5_a.3d DATAFILE=Models\frag5_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vfrag5 X=0 Y=0 Z=0 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=vfrag5 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=vfrag5 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vfrag5 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=vfrag5 NUM=0 TEXTURE=Jvase1

#exec MESH IMPORT MESH=vfrag6 ANIVFILE=Models\frag6_a.3d DATAFILE=Models\frag6_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vfrag6 X=0 Y=0 Z=0 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=vfrag6 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=vfrag6 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vfrag6 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=vfrag6 NUM=0 TEXTURE=Jvase1

#exec MESH IMPORT MESH=vfrag7 ANIVFILE=Models\frag7_a.3d DATAFILE=Models\frag7_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=vfrag7 X=0 Y=0 Z=0 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=vfrag7 SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=vfrag7 SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=vfrag7 X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=vfrag7 NUM=0 TEXTURE=Jvase1

#exec AUDIO IMPORT FILE="Sounds\General\Tink1.wav" NAME="GlassTink1" GROUP="General"
#exec AUDIO IMPORT FILE="Sounds\General\Tink2.wav" NAME="GlassTink2" GROUP="General"


simulated function CalcVelocity(vector Momentum, float ExplosionSize)
{
	ExplosionSize = VSize(Momentum);
	Velocity = VRand()*(ExplosionSize+FRand()*100.0+100.0);
	Velocity.z += ExplosionSize/2;
}

defaultproperties
{
	Fragments(0)=UnrealShare.vfrag1
	Fragments(1)=UnrealShare.vfrag2
	Fragments(2)=UnrealShare.vfrag3
	Fragments(3)=UnrealShare.vfrag4
	Fragments(4)=UnrealShare.vfrag5
	Fragments(5)=UnrealShare.vfrag6
	Fragments(6)=UnrealShare.vfrag7
	numFragmentTypes=7
	ImpactSound=UnrealShare.GlassTink1
	MiscSound=UnrealShare.GlassTink2
	Mesh=UnrealShare.vfrag1
	LifeSpan=+00009.000000
}
