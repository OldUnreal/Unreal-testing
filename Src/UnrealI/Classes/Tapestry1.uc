//=============================================================================
// Tapestry1.
//=============================================================================
class Tapestry1 extends Decoration;

#exec TEXTURE IMPORT NAME=JTap1HD FILE=Models\Tap1.pcx GROUP="HD" FLAGS=2 DETAIL=wood2
#exec TEXTURE IMPORT NAME=JTap1 FILE=Models\Tap1_old.pcx GROUP=Skins FLAGS=2 HD=JTap1HD

#exec MESH IMPORT MESH=Tap ANIVFILE=Models\Tap_a.3d DATAFILE=Models\Tap_d.3d X=0 Y=0 Z=0 LODSTYLE=2 MLOD=1

// 37 Vertices, 48 Triangles
#exec MESH LODPARAMS MESH=Tap STRENGTH=0.5 MINVERTS=3 MORPH=0.1 ZDISP=800.0

#exec MESH ORIGIN MESH=Tap X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=Tap SEQ=All    STARTFRAME=0   NUMFRAMES=15
#exec MESH SEQUENCE MESH=Tap SEQ=Waver  STARTFRAME=0   NUMFRAMES=15

#exec MESHMAP SCALE MESHMAP=Tap X=0.15 Y=0.15 Z=0.3

#exec MESHMAP SETTEXTURE MESHMAP=Tap NUM=1 TEXTURE=JTap1 TLOD=10


Auto State Animate
{
Begin:
	LoopAnim('Waver',0.2);
}

defaultproperties
{
	bStatic=False
	Physics=PHYS_Walking
	DrawType=DT_Mesh
	Mesh=LodMesh'UnrealI.Tap'
}
