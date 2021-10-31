//=============================================================================
//  Galium odoratum Seeds.
//=============================================================================
class WoodruffSeeds extends Seeds;

#exec Texture Import File=Textures\HD_Icons\I_HD_WSeed.bmp Name=I_HD_WSeed Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=W_Seed FILE=Textures\Hud\i_wseed.pcx GROUP="Icons" MIPS=OFF HD=I_HD_WSeed
#exec MESH IMPORT MESH=Woodruf_Seed ANIVFILE=Models\Woodruf_Seed_a.3d DATAFILE=Models\Woodruf_Seed_d.3d MLOD=0 LODSTYLE=8
#exec MESH ORIGIN MESH=Woodruf_Seed X=0 Y=0 Z=10

#exec MESH SEQUENCE MESH=Woodruf_Seed SEQ=All STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=Woodruf_Seed MESH=Woodruf_Seed
#exec MESHMAP SCALE MESHMAP=Woodruf_Seed X=0.02 Y=0.02 Z=0.02

#exec TEXTURE IMPORT NAME=JWoodruff_Seed FILE=Models\wseed.pcx GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=Woodruf_Seed NUM=0 TEXTURE=JWoodruff_Seed

state Shrinking
{
	function Timer()
	{
		Spawn(class'WoodRuff',,,Location+Vect(0,0,8),Rotator(Vect(0,1,0)));
		Destroy();
	}
	function Tick(Float DeltaTime)
	{
		ShrinkTime += DeltaTime;
		DrawScale = 1.0 - fMin(ShrinkTime,0.95);
	}
Begin:
	ShrinkTime = 0;
	SetTimer(0.5,False);
}

defaultproperties
{
	bCanHaveMultipleCopies=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You got the Woodruff seeds"
	RespawnTime=30.000000
	PickupViewMesh=Mesh'UnrealI.Woodruf_Seed'
	PickupSound=Sound'UnrealI.Pickups.GenPickSnd'
	Icon=Texture'W_Seed'
	Mesh=Mesh'UnrealI.Woodruf_Seed'
	bMeshCurvy=False
	CollisionRadius=12.000000
	CollisionHeight=4.000000
	DrawScale=1
	PickupViewScale=1
	bCollideWorld=True
	bProjTarget=True
}
