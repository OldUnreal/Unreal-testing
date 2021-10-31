//=============================================================================
// Electricity.
//=============================================================================
class Electricity extends Effects
	transient;

#exec MESH IMPORT MESH=Electr ANIVFILE=Models\Electr_a.3d DATAFILE=Models\Electr_d.3d X=0 Y=0 Z=0 LODNOTEX MLOD=1
// 44 Vertices, 30 Triangles
#exec MESH LODPARAMS MESH=Electr STRENGTH=1.0 MINVERTS=21 MORPH=0.3 ZDISP=1200.0

#exec MESH ORIGIN MESH=Electr X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=Electr SEQ=All        STARTFRAME=0   NUMFRAMES=11
#exec MESH SEQUENCE MESH=Electr SEQ=ElectBurst STARTFRAME=0   NUMFRAMES=11
#exec OBJ LOAD FILE=Textures\fireeffect7.utx PACKAGE=UnrealShare.Effect7
#exec MESHMAP SCALE MESHMAP=Electr X=0.1 Y=0.1 Z=0.2 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=Electr NUM=1 TEXTURE=UnrealShare.Effect7.MyTex16 TLOD=10

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'ElectBurst', 0.6 );
		PlaySound (EffectSound1);
	}
}

simulated function AnimEnd()
{
	Destroy ();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=2.000000
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealShare.Electr'
	bUnlit=True
}
