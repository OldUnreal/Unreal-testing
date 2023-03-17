//=============================================================================
// ShieldBelt.
//=============================================================================
class ShieldBelt extends Pickup;

#exec AUDIO IMPORT FILE="Sounds\Pickups\SBELTA1.wav"  NAME="BeltSnd"       GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\pSBELTA2.wav"  NAME="PSbelta2"       GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\SBELThe2.wav"  NAME="Sbelthe2"       GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_ShieldBelt.bmp Name=I_HD_ShieldBelt Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_ShieldBelt FILE=Textures\Hud\i_belt.pcx GROUP="Icons" MIPS=OFF HD=I_HD_ShieldBelt
#exec TEXTURE IMPORT NAME=GoldSkin FILE=Models\gold.pcx GROUP="None"
#exec TEXTURE IMPORT NAME=RedSkin FILE=Models\ChromR.pcx GROUP=Skins FLAGS=2 // skin
#exec TEXTURE IMPORT NAME=BlueSkin FILE=Models\ChromB.pcx GROUP=Skins FLAGS=2 // skin

#exec TEXTURE IMPORT NAME=Abelt1HD FILE=Models\belt.pcx GROUP="HD"
#exec TEXTURE IMPORT NAME=Abelt1 FILE=Models\belt_old.pcx GROUP="Skins" HD=Abelt1HD

#exec MESH IMPORT MESH=ShieldBeltMesh ANIVFILE=Models\belt_a.3d DATAFILE=Models\belt_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=ShieldBeltMesh X=0 Y=120 Z=110 YAW=64
#exec MESH LODPARAMS MESH=ShieldBeltMesh STRENGTH=0.3
#exec MESH SEQUENCE MESH=ShieldBeltMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=ShieldBeltMesh X=0.025 Y=0.025 Z=0.05
#exec MESHMAP SETTEXTURE MESHMAP=ShieldBeltMesh NUM=1 TEXTURE=Abelt1

#exec OBJ LOAD FILE=..\Textures\Belt_fx.utx PACKAGE=Unrealshare.Belt_fx

var ShieldBeltEffect MyEffect;
var() firetexture TeamFireTextures[4];
var() texture TeamTextures[4];
var int TeamNum;

function ArmorImpactEffect(vector HitLocation)
{
	if (PlayerPawn(Owner))
		PlayerPawn(Owner).ClientFlash(-0.05,vect(400,400,400));

	if (Pawn(Owner))
		Owner.PlaySound(DeActivateSound, SLOT_None, 2.7 * Pawn(Owner).SoundDampening);

	if ( MyEffect )
	{
		//MyEffect.Texture = MyEffect.LowDetailTexture;
		MyEffect.ScaleGlow = 4.0;
		MyEffect.Fatness = 255;
		SetTimer(0.8, false);
	}
} 

function Timer()
{
	if( MyEffect )
	{
		MyEffect.Fatness = MyEffect.Default.Fatness;
		SetEffectTexture();
	}
}

function Destroyed()
{
	if ( Owner )
		Owner.SetDefaultDisplayProperties();
	if ( MyEffect )
		MyEffect.Destroy();
	Super.Destroyed();
}

function PickupFunction(Pawn Other)
{
	MyEffect = Spawn(class'ShieldBeltEffect', Owner,,Owner.Location, Owner.Rotation);
	MyEffect.Mesh = Owner.Mesh;
	MyEffect.DrawScale = Owner.Drawscale;

	if( Level.Game.bTeamGame )
		TeamNum = Min(Other.GetTeamNum(), 3);
	else TeamNum = 3;

	SetEffectTexture();
}

function SetEffectTexture()
{
	if ( TeamNum != 3 )
		MyEffect.ScaleGlow = 0.5;
	else
		MyEffect.ScaleGlow = 1.0;
	MyEffect.Texture = TeamFireTextures[TeamNum];
	MyEffect.LowDetailTexture = TeamTextures[TeamNum];
}

// 227j: Support dropped shieldbelt inventory.
function DropFrom(vector StartLocation)
{
	local Pawn PawnOwner;
	
	PawnOwner = Pawn(Owner);
	Super.DropFrom(StartLocation);
	if( !Owner && PawnOwner )
	{
		if ( PawnOwner )
			PawnOwner.SetDefaultDisplayProperties();
		if( MyEffect )
			MyEffect.Destroy();
	}
}

// 227j: Support switching sub-levels.
function OnSubLevelChange( LevelInfo PrevLevel )
{
	Super.OnSubLevelChange(PrevLevel);
	if( MyEffect )
		MyEffect.SendToLevel(Level, Location);
}

defaultproperties
{
	TeamFireTextures(0)=Unrealshare.Belt_fx.Redshield
	TeamFireTextures(1)=Unrealshare.Belt_fx.Blueshield
	TeamFireTextures(2)=Unrealshare.Belt_fx.Greenshield
	TeamFireTextures(3)=Unrealshare.Belt_fx.N_shield
	TeamTextures(0)=Unrealshare.Belt_fx.NewRed
	TeamTextures(1)=Unrealshare.Belt_fx.NewBlue
	TeamTextures(2)=Unrealshare.Belt_fx.NewGreen
	TeamTextures(3)=Unrealshare.Belt_fx.NewGold
	bOwnerNoSee=True
	bDisplayableInv=True
	PickupMessage="You got the Shield Belt."
	RespawnTime=60.000000
	PickupViewMesh=Mesh'UnrealShare.ShieldBeltMesh'
	ProtectionType1=ProtectNone
	ProtectionType2=ProtectNone
	Charge=100
	ArmorAbsorption=100
	bIsAnArmor=True
	AbsorptionPriority=10
	PickupSound=Sound'UnrealShare.Pickups.BeltSnd'
	DeActivateSound=Sound'UnrealShare.Pickups.Sbelthe2'
	Icon=Texture'UnrealShare.Icons.I_ShieldBelt'
	RemoteRole=ROLE_DumbProxy
	Mesh=Mesh'UnrealShare.ShieldBeltMesh'
	bMeshCurvy=False
	CollisionRadius=20.000000
	CollisionHeight=5.000000
	MaxDesireability=2.0000
}
