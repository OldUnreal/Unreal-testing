//=============================================================================
// ForceField.
//=============================================================================
class ForceField extends Pickup;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\FFIELDA3.wav" NAME="FieldSnd" GROUP="Pickups"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\FFIELDh2.wav" NAME="fFieldh2" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_ForceField.bmp Name=I_HD_ForceField Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_ForceField FILE=Textures\Hud\i_force.pcx GROUP="Icons" MIPS=OFF HD=I_HD_ForceField

#exec MESH IMPORT MESH=ForceFieldPick ANIVFILE=Models\force2_a.3d DATAFILE=Models\force2_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ForceFieldPick X=0 Y=0 Z=0 YAW=64
#exec MESH LODPARAMS MESH=ForceFieldPick STRENGTH=0.3
#exec MESH SEQUENCE MESH=ForceFieldPick SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=aforce1 FILE=Models\force2.pcx GROUP="Skins"
#exec OBJ LOAD FILE=..\UnrealShare\Textures\fireeffect27.utx  PACKAGE=UNREALI.Effect27
#exec MESHMAP SCALE MESHMAP=ForceFieldPick X=0.07 Y=0.07 Z=0.14
#exec MESHMAP SETTEXTURE MESHMAP=ForceFieldPick NUM=1 TEXTURE=aforce1
#exec MESHMAP SETTEXTURE MESHMAP=ForceFieldPick NUM=0 TEXTURE=UnrealI.Effect27.FireEffect27

var vector X,Y,Z;
var ForceFieldProj r;
var() localized String M_NoRoom;

state Activated
{
	function BeginState()
	{
		bStasis = false;
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		r = Spawn(class'ForceFieldProj', Owner, '', Pawn(Owner).Location + 90.0 * X - 0 * Y - 0 * Z );
		if (r == None)
		{
			Owner.PlaySound(DeActivateSound);
			Pawn(Owner).ClientMessage(M_NoRoom);
			GoToState('DeActivated');
		}
		else
		{
			r.Charge = Charge;
			Owner.PlaySound(ActivateSound);
			Pawn(Owner).DeleteInventory(Self);
		}
	}
}

state DeActivated
{
Begin:
}

defaultproperties
{
	M_NoRoom="No room to activate force field."
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up the Force Field"
	RespawnTime=20.000000
	PickupViewMesh=Mesh'UnrealI.ForceFieldPick'
	Charge=130
	PickupSound=Sound'UnrealI.Pickups.GenPickSnd'
	ActivateSound=Sound'UnrealI.Pickups.FieldSnd'
	DeActivateSound=Sound'UnrealI.Pickups.fFieldh2'
	Icon=Texture'UnrealI.Icons.I_ForceField'
	RemoteRole=ROLE_DumbProxy
	Mesh=Mesh'UnrealI.ForceFieldPick'
	AmbientGlow=78
	bMeshCurvy=False
	CollisionRadius=8.000000
	CollisionHeight=22.000000
}
