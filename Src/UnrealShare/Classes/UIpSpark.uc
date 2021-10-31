//by Punish3r
class UIpSpark extends UIEffectJunk;

#exec MESH IMPORT MESH=UIpSpark ANIVFILE=Models\TCOpSpark_a.3d DATAFILE=Models\TCOpSpark_d.3d X=0 Y=0 Z=0 MLOD=0
#exec MESH ORIGIN MESH=UIpSpark X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=UIpSpark SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=UIpSpark SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=UIpSparkSkin FILE=Models\TCOpSparkSkin.pcx GROUP=Skins FLAG=3
#exec MESHMAP NEW MESHMAP=UIpSpark MESH=UIpSpark
#exec MESHMAP SCALE MESHMAP=UIpSpark X=0.12500 Y=0.12500 Z=0.25000
#exec MESHMAP SETTEXTURE MESHMAP=UIpSpark NUM=0 TEXTURE=UIpSparkSkin TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=Mesh'UnrealShare.UIpSpark'
	CollisionRadius=64.00000
	CollisionHeight=32.00000
	MultiSkins(0)=Texture'UnrealShare.UIpSparkSkin'
}

