//=============================================================================
// Invisibility.
//=============================================================================
class Invisibility expands PickUp;

#exec Texture Import File=Textures\HD_Icons\I_HD_Invisibility.bmp Name=I_HD_Invisibility Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Invisibility FILE=Textures\Hud\i_Invis.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Invisibility

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Pickups\Scloak1.wav" NAME="Invisible" GROUP="Pickups"

#exec MESH IMPORT MESH=InvisibilityMesh ANIVFILE=Models\Invis_a.3d DATAFILE=ModelsFX\Invis_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=InvisibilityMesh X=0 Y=0 Z=-15
#exec MESH LODPARAMS MESH=InvisibilityMesh STRENGTH=0.3
#exec MESH SEQUENCE MESH=InvisibilityMesh SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=InvisibilityMesh SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JInvisibility1 FILE=Models\Invis.pcx GROUP=Skins
#exec OBJ LOAD FILE=..\UnrealShare\Textures\fireeffect26.utx  PACKAGE=UNREALI.Effect26
#exec MESHMAP SCALE MESHMAP=InvisibilityMesh X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=InvisibilityMesh NUM=1 TEXTURE=JInvisibility1
#exec MESHMAP SETTEXTURE MESHMAP=InvisibilityMesh NUM=0 TEXTURE=UnrealI.Effect26.FireEffect26

var byte TempVis;

function Invisibility (bool Vis)
{
	if (Pawn(Owner)==None) Return;

	if ( Vis )
	{
		Owner.PlaySound(ActivateSound,,4.0);
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ClientAdjustGlow(-0.15, vect(156.25,156.25,351.625));
		Pawn(Owner).Visibility = 10;
		Owner.bHidden=True;
	}
	else
	{
		Owner.PlaySound(DeActivateSound);
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).ClientAdjustGlow(0.15, vect(-156.25,-156.25,-351.625));
		Pawn(Owner).Visibility = Pawn(Owner).Default.Visibility;
		if ( Pawn(Owner).health > 0 )
			Owner.bHidden=False;
	}
}

state Activated
{
	function endstate()
	{
		Invisibility(False);
		bActive = false;
	}

	function Timer()
	{
		Charge -= 1;
		Owner.bHidden=True;
		Pawn(Owner).Visibility = 10;
		if (Charge<-0)
			UsedUp();
	}

	function BeginState()
	{
		bActive = true;
		Invisibility(True);
		SetTimer(0.5,True);
	}
}

state DeActivated
{
Begin:
}

defaultproperties
{
	ExpireMessage="Invisibility has worn off."
	bAutoActivate=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You have Invisibility"
	RespawnTime=100.000000
	PickupViewMesh=Mesh'UnrealI.InvisibilityMesh'
	Charge=100
	MaxDesireability=1.200000
	PickupSound=Sound'UnrealI.Pickups.GenPickSnd'
	ActivateSound=Sound'UnrealI.Pickups.Invisible'
	Icon=Texture'UnrealI.Icons.I_Invisibility'
	RemoteRole=ROLE_DumbProxy
	Mesh=Mesh'UnrealI.InvisibilityMesh'
	AmbientGlow=96
	bMeshCurvy=False
	CollisionRadius=15.000000
	CollisionHeight=17.000000
}
