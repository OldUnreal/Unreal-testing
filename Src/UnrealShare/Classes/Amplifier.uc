//=============================================================================
// Amplifier.
//=============================================================================
class Amplifier extends Pickup;

#exec AUDIO IMPORT FILE="Sounds\Pickups\HEALTH1.wav" NAME="HEALTH1" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\ampl1.wav" NAME="AmpAct" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Amp.bmp Name=I_HD_Amp Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Amp FILE=Textures\Hud\i_amp.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Amp

#exec MESH IMPORT MESH=AmplifierM ANIVFILE=Models\amp_a.3d DATAFILE=Models\amp_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1
// 124 Vertices, 244 Triangles
#exec MESH LODPARAMS MESH=AmplifierM STRENGTH=0.3 MINVERTS=21 MORPH=0.3 ZDISP=1200.0
#exec MESH ORIGIN MESH=AmplifierM X=0 Y=0 Z=50 YAW=0
#exec MESH SEQUENCE MESH=AmplifierM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JAmplifier1 FILE=Models\Amp.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=AmplifierM X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=AmplifierM NUM=1 TEXTURE=JAmplifier1 TLOD=10

var() float AmpMultiplier;
var() sound AmpSound;
var Actor EffectsActor;

event TravelPreAccept()
{
	local DispersionPistol D;
	local ASMD A;

	Super.TravelPreAccept();
	foreach Pawn(Owner).AllInventory(class'DispersionPistol',D)
		D.Amp = self;
	foreach Pawn(Owner).AllInventory(class'ASMD',A)
		A.Amp = self;
}
event TravelPostAccept()
{
	local DispersionPistol D;
	local ASMD A;
	
	Super.TravelPostAccept();
	foreach Pawn(Owner).AllInventory(class'DispersionPistol',D)
		D.Amp = self;
	foreach Pawn(Owner).AllInventory(class'ASMD',A)
		A.Amp = self;
}

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	local DispersionPistol D;
	local ASMD A;

	Copy = Super.SpawnCopy(Other);
	foreach Other.AllInventory(class'DispersionPistol',D)
		D.Amp = Amplifier(Copy);
	foreach Other.AllInventory(class'ASMD',A)
		A.Amp = Amplifier(Copy);
	return Copy;
}

function float UseCharge(float Amount)
{
	Return 1.0;
}

function UsedUp()
{
	local DispersionPistol D;
	local ASMD A;

	foreach Pawn(Owner).AllInventory(class'DispersionPistol',D)
		if( D.Amp==Self )
			D.Amp = None;
	foreach Pawn(Owner).AllInventory(class'ASMD',A)
		if( A.Amp==Self )
			A.Amp = None;

	Super.UsedUp();
}

function bool UseSpecialEffectsActor()
{
	return Class == class'Amplifier';
}

function EnableInventoryEffects()
{
	if( !Owner )
		return;

	if (!UseSpecialEffectsActor())
		EffectsActor = Owner;
	else if (!EffectsActor || EffectsActor.bDeleteMe)
	{
		EffectsActor = Spawn(class'Triggers', Owner, 'Amplifier_EffectsActor', Owner.Location);
		if (EffectsActor)
		{
			EffectsActor.SetCollision(false);
			EffectsActor.SetPhysics(PHYS_Trailer);
			EffectsActor.bHidden = false;
			EffectsActor.DrawType = DT_None;
			EffectsActor.RemoteRole = ROLE_SimulatedProxy;
			EffectsActor.SoundRadius = Owner.default.SoundRadius;
			EffectsActor.SoundVolume = Owner.default.SoundVolume;
		}
		else
			EffectsActor = Owner;
	}

	if( !Owner )
		return;
	Owner.PlaySound(ActivateSound);
	EffectsActor.AmbientSound = AmpSound;
	if (PlayerPawn(Owner))
		PlayerPawn(Owner).ClientAdjustGlow(-0.1, vect(100, 20, 0));
	EffectsActor.LightType = LT_Steady;
	EffectsActor.LightRadius = 6;
	EffectsActor.LightEffect = LE_NonIncidence;
	EffectsActor.LightSaturation = 40;
	EffectsActor.LightHue = 225;
	EffectsActor.LightBrightness = 255;
	EffectsActor.AmbientGlow = 255;
}

function DisableInventoryEffects()
{
	if (Owner != none)
	{
		if (PlayerPawn(Owner) != none)
			PlayerPawn(Owner).ClientAdjustGlow(0.1, vect(-100, -20, 0));
		if (!UseSpecialEffectsActor() || EffectsActor == Owner)
		{
			Owner.AmbientSound = none;
			Owner.LightType = LT_None;
			Owner.AmbientGlow = 0;
		}
	}
	if (EffectsActor && EffectsActor != Owner)
		EffectsActor.Destroy();
	EffectsActor = none;
}

state Activated
{
	function BeginState()
	{
		local DispersionPistol D;
		local ASMD A;

		foreach Pawn(Owner).AllInventory(class'DispersionPistol',D)
			D.Amp = self;
		foreach Pawn(Owner).AllInventory(class'ASMD',A)
			A.Amp = self;
		bActive = true;
	}

	function float UseCharge(float Amount)
	{
		local float TempCharge;
		if (AmpMultiplier<1.0) AmpMultiplier=1.0;

		if (Charge < Amount)
		{
			TempCharge = Charge;
			Charge=0;
			Return (AmpMultiplier-1.0)*TempCharge/Amount+1.0;
		}
		Charge = Charge - Amount;
		return AmpMultiplier;
	}


	function Timer()
	{
		Charge -= 2;
		if (Charge<=0)
		{
			UsedUp();
		}
	}

	function EndState()
	{
		DisableInventoryEffects();
		bActive = false;
	}
Begin:
	SetTimer(1.0,True);
	EnableInventoryEffects();
}

state DeActivated
{
Begin:
}

// 227j: Support switching sub-levels.
function OnSubLevelChange( LevelInfo PrevLevel )
{
	Super.OnSubLevelChange(PrevLevel);
	if (EffectsActor && EffectsActor != Owner)
		EffectsActor.SendToLevel(Level, Location);
}

defaultproperties
{
	AmpMultiplier=4.000000
	AmpSound=Sound'AmpAct'
	bCanActivate=True
	ExpireMessage="Amplifier is out of power."
	bAutoActivate=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You got the Energy Amplifier"
	RespawnTime=90.000000
	PickupViewMesh=LodMesh'AmplifierM'
	Charge=1000
	MaxDesireability=1.200000
	PickupSound=Sound'GenPickSnd'
	ActivateSound=Sound'HEALTH1'
	Icon=Texture'I_Amp'
	Mesh=LodMesh'AmplifierM'
	CollisionRadius=20.000000
	CollisionHeight=13.500000
}