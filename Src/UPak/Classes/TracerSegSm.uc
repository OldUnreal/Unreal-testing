//=============================================================================
// BalefireSegSm.
//=============================================================================
class TracerSegSm expands TracerSeg;

#exec MESH IMPORT MESH=TR100 ANIVFILE=MODELS\TRACER\TR100_a.3d DATAFILE=MODELS\TRACER\TR100_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TR100 X=-159 Y=0 Z=6

#exec MESH SEQUENCE MESH=TR100 SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=TR100 SEQ=TR100 STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JTR1001 FILE=MODELS\TRACER\Tracer2.PCX GROUP=Skins FLAGS=2 
#exec TEXTURE IMPORT NAME=JTR1002 FILE=MODELS\TRACER\Tracer2.PCX GROUP=Skins FLAGS=2

#exec MESHMAP NEW   MESHMAP=TR100 MESH=TR100
#exec MESHMAP SCALE MESHMAP=TR100 X=0.1 Y=0.1 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=TR100 NUM=0 TEXTURE=JTR1001

defaultproperties
{
     FadeTime=0.100000
     FadeInterval=0.100000
     LifeSpan=0.090000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=None
     Mesh=LodMesh'UPak.TR100'
     DrawScale=2.000000
     Fatness=90
     bUnlit=True
     CollisionRadius=63.849998
     bCollideWorld=False
}
