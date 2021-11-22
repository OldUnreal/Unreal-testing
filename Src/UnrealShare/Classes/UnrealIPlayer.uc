//=============================================================================
// UnrealIPlayer.
//=============================================================================
class UnrealIPlayer extends PlayerPawn
	config(user)
	abstract;

#exec AUDIO IMPORT FILE="Sounds\Generic\land1.wav" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\lsplash.wav" NAME="LSplash" GROUP="Generic"
#exec AUDIO IMPORT FILE="Sounds\Generic\Say3A.wav" NAME="Beep" GROUP="Generic"

var(Sounds) sound 	drown;
var(Sounds) sound	breathagain;
var(Sounds) sound	Footstep1;
var(Sounds) sound	Footstep2;
var(Sounds) sound	Footstep3;
var(Sounds) sound	HitSound3;
var(Sounds) sound	HitSound4;
var(Sounds) sound	Die2;
var(Sounds) sound	Die3;
var(Sounds) sound	Die4;
var(Sounds) sound	GaspSound;
var(Sounds) sound	UWHit1;
var(Sounds) sound	UWHit2;
var(Sounds) sound	LandGrunt;

var nowarn class<VoicePack> VoiceType;

var transient byte WetSteps;

replication
{
	// Functions server can call.
	unreliable if ( Role==ROLE_Authority )
		ClientPlayTakeHit;
}

simulated function BeginPlay()
{
	// Dummy stub, for compatibility (moved shadow code to Pawn).
	Super.BeginPlay();
}

event Possess()
{
	/*local UnrealMeshMenu M; <- Fix for anti-cheat problems

	if ( Level.Netmode == NM_Client )
	{
		M = spawn(class'UnrealMeshMenu');
		M.LoadAllMeshes();
		M.Destroy();
	}*/
	Super.Possess();
}

simulated function PlayBeepSound()
{
	if ( ViewTarget!=None )
		ViewTarget.PlaySound(sound'Beep',SLOT_Interface, 2.0);
	else PlaySound(sound'Beep',SLOT_Interface, 2.0);
}

exec event ShowUpgradeMenu()
{
	bSpecialMenu = true;
	SpecialMenu = class'UpgradeMenu';
	ShowMenu();
}

exec function ShowLoadMenu()
{
	Super.ShowLoadMenu();
}

exec function Summon( string ClassName )
{
	Super.Summon(ClassName);
}

simulated function PlayFootStep()
{
	local sound step;
	local float decision;
	local PlayerAffectorInfo Affector;

	if (bDeleteMe)
		return;

	if ( !bIsWalking && (Level.Game != None) && (Level.Game.Difficulty > 1) && ((Weapon == None) || !Weapon.bPointing) )
		MakeNoise(0.05 * Level.Game.Difficulty);
	if ( Level.NetMode==NM_DedicatedServer )
		Return; // We don't perform this on dedicated servers.

	for (Affector = FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
		if (Affector.PlayFootStepSound())
			return;

	if( Level.FootprintManager==None || !Level.FootprintManager.Static.OverrideFootstep(Self,step,WetSteps) )
	{
		decision = FRand();
		if ( decision < 0.34 )
			Step = Footstep1;
		else if (decision < 0.67 )
			Step = Footstep2;
		else
			Step = Footstep3;
	}
	if( step==None )
		return;
	if ( bIsWalking )
		PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else PlaySound(step, SLOT_Interact, 2, false, 800.0, 1.0);
}

function PlayHit(float Damage, vector HitLocation, name damageType, float MomentumZ)
{
	local float rnd;
	local Bubble1 bub;
	local bool bServerGuessWeapon;
	local vector BloodOffset;

	if ( (Damage <= 0) && (ReducedDamageType != 'All') )
		return;

	//DamageClass = class(damageType);
	if ( ReducedDamageType != 'All' ) //spawn some blood
	{
		if (damageType == 'Drowned')
		{
			bub = spawn(class 'Bubble1',,, Location
						+ 0.7 * CollisionRadius * vector(ViewRotation) + 0.3 * EyeHeight * vect(0,0,1));
			if (bub != None)
				bub.DrawScale = FRand()*0.06+0.04;
		}
		else if ( (damageType != 'Burned') && (damageType != 'Corroded')
				  && (damageType != 'Fell') )
		{
			BloodOffset = 0.2 * CollisionRadius * Normal(HitLocation - Location);
			BloodOffset.Z = BloodOffset.Z * 0.5;
			if ( (Level.Game != None) && Level.Game.bVeryLowGore )
				spawn(class 'BloodBurst',self,,hitLocation + BloodOffset, rotator(BloodOffset));
			else
				spawn(class 'BloodSpray',self,,hitLocation + BloodOffset, rotator(BloodOffset));
		}
	}

	rnd = FClamp(Damage, 20, 60);
	if ( damageType == 'Burned' )
		ClientFlash( -0.009375 * rnd, rnd * vect(16.41, 11.719, 4.6875));
	else if ( damageType == 'corroded' )
		ClientFlash( -0.01171875 * rnd, rnd * vect(9.375, 14.0625, 4.6875));
	else if ( damageType == 'Drowned' )
		ClientFlash(-0.390, vect(312.5,468.75,468.75));
	else
		ClientFlash( -0.019 * rnd, rnd * vect(26.5, 4.5, 4.5));

	ShakeView(0.15 + 0.005 * Damage, Damage * 30, 0.3 * Damage);
	PlayTakeHitSound(Damage, damageType, 1);
	bServerGuessWeapon = ( ((Weapon != None) && Weapon.bPointing) || (GetAnimGroup(AnimSequence) == 'Dodge') );
	if (!bIsReducedCrouch)
		ClientPlayTakeHit(0.1, hitLocation, Damage, bServerGuessWeapon );
	if ( !bServerGuessWeapon
			&& ((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer)) )
	{
		Enable('AnimEnd');
		BaseEyeHeight = Default.BaseEyeHeight;
		bAnimTransition = true;
		PlayTakeHit(0.1, hitLocation, Damage);
	}
}

function PlayDeathHit(float Damage, vector HitLocation, name damageType)
{
	local Bubble1 bub;

	if ( Region.Zone.bDestructive && (Region.Zone.ExitActor != None) )
		Spawn(Region.Zone.ExitActor);
	if (HeadRegion.Zone.bWaterZone)
	{
		bub = spawn(class 'Bubble1',,, Location
					+ 0.3 * CollisionRadius * vector(Rotation) + 0.8 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
		bub = spawn(class 'Bubble1',,, Location
					+ 0.2 * CollisionRadius * VRand() + 0.7 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
		bub = spawn(class 'Bubble1',,, Location
					+ 0.3 * CollisionRadius * VRand() + 0.6 * EyeHeight * vect(0,0,1));
		if (bub != None)
			bub.DrawScale = FRand()*0.08+0.03;
	}

	if ( (damageType != 'Drowned') && (damageType != 'Corroded') )
		spawn(class 'BloodSpray',self,'', hitLocation);
}

//-----------------------------------------------------------------------------
// Sound functions

function PlayDyingSound()
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,,,,Frand()*0.2+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,,,,Frand()*0.2+0.9);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)
		PlaySound(Die, SLOT_Talk);
	else if (rnd < 0.5)
		PlaySound(Die2, SLOT_Talk);
	else if (rnd < 0.75)
		PlaySound(Die3, SLOT_Talk);
	else
		PlaySound(Die4, SLOT_Talk);
}

function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.3 )
		return;
	LastPainSound = Level.TimeSeconds;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			PlaySound(drown, SLOT_Pain, 1.5);
		else if ( FRand() < 0.5 )
			PlaySound(UWHit1, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		else
			PlaySound(UWHit2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		return;
	}
	damage *= FRand();

	if (damage < 8)
		PlaySound(HitSound1, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
	else if (damage < 25)
	{
		if (FRand() < 0.5) PlaySound(HitSound2, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
		else PlaySound(HitSound3, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
	}
	else
		PlaySound(HitSound4, SLOT_Pain,2.0,,,Frand()*0.15+0.9);
}

function ClientPlayTakeHit(float tweentime, vector HitLoc, int Damage, bool bServerGuessWeapon)
{
	if ( bServerGuessWeapon && ((GetAnimGroup(AnimSequence) == 'Dodge') || ((Weapon != None) && Weapon.bPointing)) )
		return;
	Enable('AnimEnd');
	bAnimTransition = true;
	BaseEyeHeight = Default.BaseEyeHeight;
	PlayTakeHit(tweentime, HitLoc, Damage);
}

function Gasp()
{
	if ( Role != ROLE_Authority )
		return;
	if ( PainTime < 2 )
		PlaySound(GaspSound, SLOT_Talk, 2.0);
	else
		PlaySound(BreathAgain, SLOT_Talk, 2.0);
}

static function SetMultiSkin( Actor SkinActor, string SkinName, string FaceName, byte TeamNum )
{
	local Texture NewSkin;
	local string MeshName,Chck;
	local string TeamColor[4];
	local int i;

	TeamColor[0]="Red";
	TeamColor[1]="Blue";
	TeamColor[2]="Green";
	TeamColor[3]="Yellow";

	if ( SkinActor.Mesh!=None )
		MeshName = string(SkinActor.Mesh.Name);

	if ( InStr(SkinName, ".") == -1 )
		SkinName = MeshName$"Skins."$SkinName;

	if (TeamNum >=0 && TeamNum <= 3)
		NewSkin = texture(DynamicLoadObject(MeshName$"Skins.T_"$TeamColor[TeamNum], class'Texture',True));
	else if ( Left(SkinName, Len(MeshName)) ~= MeshName )
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture',True));
	else if ( Left(SkinName,8)~="UnrealI." ) // Handle special skins.
	{
		Chck = Caps(Mid(SkinName,8));
		i = InStr(Chck,".");
		if ( i>=0 )
			Chck = Mid(Chck,i+1);
		if ( MeshName~="Female2" )
		{
			if ( Chck!="F2FEMALE2" && Chck!="F2FEMALE4" )
				Return;
		}
		else if ( MeshName~="Male1" )
		{
			if ( Left(Chck,5)!="JMALE" || Right(Chck,2)=="22" ) // Disallow Ivan Male2 skin on Male1 mesh.
				Return;
		}
		else Return;
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture',True));
	}
	else if ( (Left(SkinName,17)~="UnrealShare.JNali" || Left(SkinName,23)~="UnrealShare.Skins.JNali") && Left(MeshName,4)~="Nali" && !(Right(SkinName,5)~="Fruit") ) // Handle more special skins.
		NewSkin = texture(DynamicLoadObject(SkinName, class'Texture',True));

	// Set skin
	if ( NewSkin != None )
		SkinActor.Skin = NewSkin;
}

defaultproperties
{
	bSinglePlayer=True
	WeaponPriority(0)=DispersionPistol
	WeaponPriority(1)=AutoMag
	WeaponPriority(2)=Stinger
	WeaponPriority(3)=ASMD
	WeaponPriority(4)=Eightball
	WeaponPriority(5)=FlakCannon
	WeaponPriority(6)=GESBioRifle
	WeaponPriority(7)=Razorjack
	WeaponPriority(8)=Rifle
	WeaponPriority(9)=Minigun
	Intelligence=BRAINS_HUMAN
	bCanStrafe=True
	MeleeRange=50.00
	GroundSpeed=400.00
	AirSpeed=400.00
	AccelRate=2048.00
	UnderWaterTime=20.00
	Land=Sound'Land1'
	WaterStep=Sound'LSplash'
	AnimSequence=WalkSm
	DrawType=DT_Mesh
	LightBrightness=70
	LightHue=40
	LightSaturation=128
	LightRadius=6
	RotationRate=(Pitch=3072,Yaw=65000,Roll=2048)
	bNoDynamicShadowCast=false
}