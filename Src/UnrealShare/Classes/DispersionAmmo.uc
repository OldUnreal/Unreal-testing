//=============================================================================
// DispersionAmmo.
//=============================================================================
class DispersionAmmo extends Projectile;

#exec MESH IMPORT MESH=plasmaM ANIVFILE=Models\cros_t_a.3d DATAFILE=Models\cros_t_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=plasmaM X=0 Y=-500 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=plasmaM SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=plasmaM SEQ=Still  STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=plasmaM X=0.09 Y=0.15 Z=0.08
#exec  OBJ LOAD FILE=Textures\fireeffect1.utx PACKAGE=UnrealShare.Effect1
#exec MESHMAP SETTEXTURE MESHMAP=plasmaM NUM=0 TEXTURE=UnrealShare.Effect1.FireEffect1u
#exec MESHMAP SETTEXTURE MESHMAP=plasmaM NUM=1 TEXTURE=UnrealShare.Effect1.FireEffect1t

#exec AUDIO IMPORT FILE="Sounds\Dispersion\DFly1.wav" NAME="DispFly" GROUP="Dispersion"
#exec AUDIO IMPORT FILE="Sounds\Dispersion\dpexplo4.wav" NAME="DispEX1" GROUP="General"

#exec OBJ LOAD FILE=Textures\DispExpl.utx PACKAGE=UnrealShare.DispExpl
#exec TEXTURE IMPORT NAME=BluePal FILE=Textures\expal2a.pcx GROUP=Effects

#exec TEXTURE IMPORT NAME=ExplosionPal FILE=Textures\exppal.pcx GROUP=Effects
#exec OBJ LOAD FILE=Textures\MainE.utx PACKAGE=UnrealShare.MainEffect

var bool bExploded,bAltFire, bExplosionEffect;
var() float SparkScale;
var() class<SmallSpark> ParticleType;
var() float SparkModifier;
var() texture ExpType;
var() texture ExpSkin;
var() Sound EffectSound1;
var() texture SpriteAnim[20];
var() int NumFrames;
var() float Pause;
var int i;
var Float AnimTime;

simulated function Tick(float DeltaTime)
{
	if ( Physics != PHYS_None )
		LifeSpan = 0.7; // keep resetting it - can't make it longer since animspriteeffect base of this
}

simulated function PostBeginPlay()
{
	//log("Spawn "$self$" with role "$Role$" and netmode "$Level.netmode);
	Super.PostBeginPlay();
	Velocity = Speed * vector(Rotation);
}

function InitSplash(float DamageScale)
{
	Damage *= DamageScale;
	MomentumTransfer *= DamageScale;
	SparkScale = FClamp(DamageScale*3.0 - 1.2,0.5,4.0);
	DrawScale = fMin(DamageScale,2.0);
}

simulated function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation,
							   Vector momentum, name damageType)
{
	bExploded = True;
}

function BlowUp(vector HitLocation)
{
	if ( bAltFire )
		HurtRadiusProj(Damage,150.0, 'exploded', MomentumTransfer, HitLocation );
	PlaySound (EffectSound1,,7.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( !bExplosionEffect )
	{
		BlowUp(HitLocation);
		bExplosionEffect = true;
		if (Level.bHighDetailMode)
			DrawScale = Min(Damage/12.0 + 0.8,2.5);
		else
			DrawScale = Min(Damage/20.0 + 0.8,1.5);
		LightRadius = 6;
		SetCollision(false,false,false);
		if( !EffectIsRelevant(Location,true) )
			LifeSpan = 0.1;
		else LifeSpan = 0.7;
		Texture = ExpType;
		LightType = LT_TexturePaletteOnce;
		Skin = ExpSkin;
		DrawType = DT_SpriteAnimOnce;
		Style = STY_Translucent;
		SetPhysics(PHYS_None);
		Disable('Tick');
	}
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	If (Other!=Instigator  && DispersionAmmo(Other)==None)
	{
		bExploded = ( Other.IsA('Pawn') && !Level.bHighDetailMode );
		if ( Role == ROLE_Authority )
			Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), 'exploded');
		Explode(HitLocation, vect(0,0,1));
	}
}

defaultproperties
{
	ExplosionDecal=class'Unrealshare.BoltscorchB'
	SpriteAnim(0)=Texture'UnrealShare.Maineffect.e1_a00'
	SpriteAnim(1)=Texture'UnrealShare.Maineffect.e2_a00'
	SpriteAnim(2)=Texture'UnrealShare.Maineffect.e3_a00'
	SpriteAnim(3)=Texture'UnrealShare.Maineffect.e4_a00'
	SpriteAnim(4)=Texture'UnrealShare.Maineffect.e5_a00'
	Pause=+0.05
	NumFrames=8
	EffectSound1=Sound'UnrealShare.General.DispEX1'
	ExpSkin=Texture'UnrealShare.Effects.BluePal'
	ExpType=Texture'UnrealShare.DispExpl.dseb_A00'
	SparkScale=1.000000
	ParticleType=Class'UnrealShare.Spark3'
	SparkModifier=1.000000
	speed=1300.000000
	Damage=15.000000
	MomentumTransfer=6000
	ExploWallOut=10.000000
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.700000
	Style=STY_Translucent
	Texture=FireTexture'UnrealShare.Effect1.FireEffect1u'
	Mesh=Mesh'UnrealShare.plasmaM'
	DrawScale=0.800000
	AmbientGlow=187
	bUnlit=True
	SoundRadius=10
	SoundVolume=218
	AmbientSound=Sound'UnrealShare.Dispersion.DispFly'
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=170
	LightSaturation=69
	LightRadius=5
	bFixedRotationDir=True
	MyDamageType="Exploded"
}
