//=============================================================================
// GasbagBelch.
//=============================================================================
class GasBagBelch extends Projectile;

#exec TEXTURE IMPORT NAME=gbProj0 FILE=Models\gb_a00.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj1 FILE=Models\gb_a01.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj2 FILE=Models\gb_a02.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj3 FILE=Models\gb_a03.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj4 FILE=Models\gb_a04.pcx GROUP=Effects
#exec TEXTURE IMPORT NAME=gbProj5 FILE=Models\gb_a05.pcx GROUP=Effects

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Flak\expl2.wav" NAME="expl2" GROUP="flak"

var() texture SpriteAnim[6];
var int i;


simulated function Timer()
{
	Texture = SpriteAnim[i];
	i++;
	if (i>=6) i=0;
}

function SetUp()
{
	if ( ScriptedPawn(Instigator) != None )
		Speed = ScriptedPawn(Instigator).ProjectileSpeed;
	Velocity = Vector(Rotation) * speed;
	MakeNoise ( 1.0 );
	PlaySound(SpawnSound);
}

simulated function PostBeginPlay()
{
	SetUp();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		Texture = SpriteAnim[0];
		i=1;
		SetTimer(0.15,True);
	}
	Super.PostBeginPlay();
}

auto state Flying
{


	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (Other != instigator)
		{
			if ( Role == ROLE_Authority )
				Other.TakeDamage(Damage, instigator,HitLocation,
				15000.0 * Normal(velocity), 'burned');
			Explode(HitLocation, Vect(0,0,0));
		}
	}

	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local SpriteBallExplosion s;

		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness

		s = Spawn(class'SpriteBallExplosion',,,HitLocation+HitNormal*9);
		s.RemoteRole = ROLE_None;
		Destroy();
	}

Begin:
	Sleep(3);
	Explode(Location, Vect(0,0,0));
}

defaultproperties
{
	ExplosionDecal=Class'UnrealShare.BelchScorch'
	SpriteAnim(0)=Texture'UnrealI.Effects.gbProj0'
	SpriteAnim(1)=Texture'UnrealI.Effects.gbProj1'
	SpriteAnim(2)=Texture'UnrealI.Effects.gbProj2'
	SpriteAnim(3)=Texture'UnrealI.Effects.gbProj3'
	SpriteAnim(4)=Texture'UnrealI.Effects.gbProj4'
	SpriteAnim(5)=Texture'UnrealI.Effects.gbProj5'
	speed=600.000000
	Damage=40.000000
	ImpactSound=Sound'UnrealShare.flak.expl2'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=3.500000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'UnrealI.Effects.gbProj0'
	DrawScale=1.800000
	Fatness=0
	bUnlit=True
	LightType=LT_Steady
	LightEffect=LE_NonIncidence
	LightBrightness=255
	LightHue=5
	LightSaturation=16
	LightRadius=9
}
