//=============================================================================
// RocketCan.
//=============================================================================
class RocketCan extends Ammo;

#exec OBJ LOAD FILE=Detail.utx

#exec TEXTURE IMPORT NAME=JRocketCan1HD FILE=Models\RocketCn.pcx GROUP="HD" DETAIL=Metal
#exec TEXTURE IMPORT NAME=JRocketCan1 FILE=Models\RocketCn_old.pcx GROUP="Skins" DETAIL=Metal HD=JRocketCan1HD

#exec AUDIO IMPORT FILE="Sounds\Pickups\AMMOPUP1.wav" NAME="AmmoSnd" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Rocketammo.bmp Name=I_HD_Rocketammo Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_RocketAmmo FILE=Textures\Hud\i_rcan.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Rocketammo

#exec MESH IMPORT MESH=RocketCanMesh ANIVFILE=Models\pshell_a.3d DATAFILE=Models\pshell_d.3d LODSTYLE=8 LODFRAME=7 MLOD=1
#exec MESH LODPARAMS MESH=RocketCanMesh STRENGTH=0.3 MINVERTS=27 MORPH=0.3 ZDISP=800.0
#exec MESH ORIGIN MESH=RocketCanMesh X=0 Y=0 Z=-15 YAW=0
#exec MESH SEQUENCE MESH=RocketCanMesh SEQ=All    STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=RocketCanMesh SEQ=Open   STARTFRAME=0  NUMFRAMES=10
#exec MESHMAP SCALE MESHMAP=RocketCanMesh X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=RocketCanMesh NUM=1 TEXTURE=JRocketCan1 TLOD=10

var bool bOpened;

auto state Pickup
{
	function Touch( Actor Other )
	{
		local Vector Dist2D;

		if ( bOpened )
		{
			Super.Touch(Other);
			return;
		}
		if ( (Pawn(Other) == None) || !Pawn(Other).bIsPlayer )
			return;
		Dist2D = Other.Location - Location;
		Dist2D.Z = 0;
		if ( VSize(Dist2D) <= 48.0 )
			Super.Touch(Other);
		else
		{
			SetCollisionSize(Default.CollisionRadius, CollisionHeight);
			SetLocation(Location); //to force untouch
			bOpened = true;
			PlayAnim('Open', 0.1);
		}
	}

	function Landed(vector HitNormal)
	{
		Super.Landed(HitNormal);
		if ( !bOpened )
		{
			bCollideWorld = false;
			SetCollisionSize(172,CollisionHeight);
			SetTimer(0, false);
			RemoteRole = ROLE_DumbProxy;
		}
	}
}

defaultproperties
{
	AmmoAmount=12
	MaxAmmo=48
	UsedInWeaponSlot(5)=1
	PickupMessage="You picked up 12 Eightballs"
	PickupViewMesh=LodMesh'UnrealShare.RocketCanMesh'
	MaxDesireability=0.300000
	PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
	Icon=Texture'UnrealShare.Icons.I_RocketAmmo'
	Physics=PHYS_Falling
	Mesh=LodMesh'UnrealShare.RocketCanMesh'
	CollisionRadius=27.000000
	CollisionHeight=12.000000
	bCollideActors=True
}
