//by Punish3r
class UIpWaterRing extends UIEffectJunk;

#exec MESH IMPORT MESH=UIpWaterRing ANIVFILE=Models\TCOpWaterRing_a.3d DATAFILE=Models\TCOpWaterRing_d.3d X=0 Y=0 Z=0 MLOD=0
#exec MESH ORIGIN MESH=UIpWaterRing X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=UIpWaterRing SEQ=All STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=UIpWaterRing SEQ=Still STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=UIpWaterRingSkin FILE=Models\TCOpWaterRingSkin.pcx GROUP=Skins FLAG=3
#exec MESHMAP NEW MESHMAP=UIpWaterRing MESH=UIpWaterRing
#exec MESHMAP SCALE MESHMAP=UIpWaterRing X=0.25000 Y=0.25000 Z=0.50000
#exec MESHMAP SETTEXTURE MESHMAP=UIpWaterRing NUM=0 TEXTURE=UIpWaterRingSkin TLOD=10

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=Mesh'UIpWaterRing'
	CollisionRadius=128.00000
	CollisionHeight=0.00000
	MultiSkins(0)=Texture'UIpWaterRingSkin'
}