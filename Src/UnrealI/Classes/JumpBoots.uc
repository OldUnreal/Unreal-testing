//=============================================================================
// JumpBoots
//=============================================================================
class JumpBoots extends Pickup;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\BOOTSA1.wav" NAME="BootSnd" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\BOOTJMP.wav" NAME="BootJmp" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_JumpBoots.bmp Name=I_HD_JumpBoots Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Boots FILE=Textures\Hud\i_Boots.pcx GROUP="Icons" MIPS=OFF HD=I_HD_JumpBoots

#exec TEXTURE IMPORT NAME=Jlboot1HD FILE=Models\boot.pcx GROUP="HD"
#exec TEXTURE IMPORT NAME=Jlboot1 FILE=Models\boot_old.pcx GROUP=Skins HD=Jlboot1HD

#exec MESH IMPORT MESH=lboot ANIVFILE=Models\boot_a.3d DATAFILE=Models\boot_d.3d X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=lboot STRENGTH=0.3

#exec MESH ORIGIN MESH=lboot X=-70 Y=150 Z=-50 YAW=64
#exec MESH SEQUENCE MESH=lboot SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=lboot SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=lboot X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=lboot NUM=1 TEXTURE=Jlboot1 TLOD=5

var int TimeCharge;

function PickupFunction(Pawn Other)
{
	TimeCharge = 0;
	SetTimer(1.0, True);
}

function OwnerJumped()
{
	TimeCharge=0;
	if ( Charge <= 0 )
	{
		if ( Owner!=None && bActive )
			Owner.PlaySound(DeActivateSound);
		UsedUp();
		Return;
	}
	else
		Owner.PlaySound(sound'BootJmp');
	Charge -= 1;
}

function Timer()
{
	if ( Charge <= 0 ) // Draining out.
	{
		if ( Owner.Physics!=PHYS_Falling || !bActive )
			OwnerJumped();
		Return;
	}
	if ( !Pawn(Owner).bAutoActivate )
	{
		TimeCharge++;
		if (TimeCharge>20) OwnerJumped();
	}
}

state Activated
{
	function endstate()
	{
		if ( Owner!=None )
		{
			Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * Level.Game.PlayerJumpZScaling();
			Pawn(Owner).bCountJumps = False;
		}
		bActive = false;
	}
Begin:
	Pawn(Owner).bCountJumps = True;
	Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * 3;
	Owner.PlaySound(ActivateSound);
	While( True ) // Fix multiplie jumpboots issues.
	{
		Sleep(1);
		if ( !Pawn(Owner).bCountJumps )
		{
			Pawn(Owner).bCountJumps = True;
			Pawn(Owner).JumpZ = Pawn(Owner).Default.JumpZ * 3;
		}
		else if ( Pawn(Owner).JumpZ!=(Pawn(Owner).Default.JumpZ*3) )
			Activate(); // Deactivate if we aren't the active boots.
	}
}

state DeActivated
{
Begin:
}

defaultproperties
{
	ExpireMessage="The Jump Boots have drained"
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up the jump boots"
	RespawnTime=30.000000
	PickupViewMesh=LodMesh'UnrealI.lboot'
	Charge=3
	MaxDesireability=0.500000
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ActivateSound=Sound'UnrealI.Pickups.BootSnd'
	Icon=Texture'UnrealI.Icons.I_Boots'
	RemoteRole=ROLE_DumbProxy
	Mesh=LodMesh'UnrealI.lboot'
	AmbientGlow=64
	CollisionRadius=22.000000
	CollisionHeight=7.000000
}
