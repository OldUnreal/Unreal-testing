//=============================================================================
// Suits.
//=============================================================================
class Suits extends Pickup;

#exec OBJ LOAD FILE=Detail.utx

#exec Texture Import File=Textures\HD_Icons\I_HD_Suit.bmp Name=I_HD_Suit Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Suit FILE=Textures\HUD\i_Suit.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Suit

#exec MESH IMPORT MESH=Suit ANIVFILE=Models\bsuit_a.3d DATAFILE=Models\bsuit_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1
#exec MESH LODPARAMS MESH=Suit STRENGTH=0.5 MINVERTS=60 MORPH=0.1 ZDISP=1200.0
#exec MESH ORIGIN MESH=Suit X=0 Y=100 Z=40 YAW=64 ROLL=64
#exec MESH SEQUENCE MESH=Suit SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Asuit1 FILE=Models\bsuit.pcx GROUP="Skins" DETAIL=Metal
#exec MESHMAP SCALE MESHMAP=Suit X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=Suit NUM=1 TEXTURE=Asuit1 TLOD=10

function BeginPlay()
{
	if( Class==Class'Suits' )
		Error("Can't use Class"@string(Class)@"in level.");
	else Super.BeginPlay();
}

function PickupFunction(Pawn Other)
{
	local Suits S;
	
	foreach Other.AllInventory(class'Suits',S)
	{
		if( S.Class!=Class )
			S.Destroy();
	}
}

defaultproperties
{
	bDisplayableInv=True
	RespawnTime=30.000000
	PickupViewMesh=LodMesh'UnrealShare.Suit'
	ProtectionType1=ProtectNone
	ProtectionType2=ProtectNone
	MaxDesireability=1.700000
	Icon=Texture'UnrealShare.Icons.I_Suit'
	RemoteRole=ROLE_DumbProxy
	DrawType=DT_Mesh
	AmbientGlow=64
	Mesh=LodMesh'UnrealShare.Suit'
	CollisionRadius=26.000000
	CollisionHeight=39.000000
}
