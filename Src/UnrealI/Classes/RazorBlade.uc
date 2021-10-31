//=============================================================================
// RazorBlade.
//=============================================================================
class RazorBlade extends Projectile;

#exec MESH IMPORT MESH=razorb ANIVFILE=Models\razorb_a.3d DATAFILE=Models\razorb_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=razorb X=0 Y=0 Z=0 YAW=-64
#exec MESH SEQUENCE MESH=razorb SEQ=All    STARTFRAME=0   NUMFRAMES=15
#exec MESH SEQUENCE MESH=razorb SEQ=Spin  STARTFRAME=0   NUMFRAMES=15
#exec TEXTURE IMPORT NAME=Jrazor1 FILE=Models\razor.pcx
#exec OBJ LOAD FILE=..\UnrealShare\Textures\FireEffect54.utx PACKAGE=UnrealI.Effect54
#exec MESHMAP SCALE MESHMAP=razorb X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=razorb NUM=1 TEXTURE=Jrazor1
#exec MESHMAP SETTEXTURE MESHMAP=razorb NUM=0 TEXTURE=UnrealI.Effect54.FireEffect54

#exec AUDIO IMPORT FILE="Sounds\Razor\fly15.wav" NAME="RazorHum" GROUP="RazorJack"
#exec AUDIO IMPORT FILE="Sounds\Razor\bladehit.wav" NAME="BladeHit" GROUP="RazorJack"
#exec AUDIO IMPORT FILE="Sounds\Razor\bladethunk.wav" NAME="BladeThunk" GROUP="RazorJack"
#exec AUDIO IMPORT FILE="Sounds\Razor\start9b.wav" NAME="StartBlade" GROUP="RazorJack"

var int NumWallHits;
var bool bCanHitInstigator, bHitWater;

/////////////////////////////////////////////////////
auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( bCanHitInstigator || (Other != Instigator) )
		{
			if ( Instigator != NONE && Other.Role==ROLE_Authority  )
			{
				if ( Other.bIsPawn && (instigator.IsA('PlayerPawn') || (instigator.skill > 1)) && Pawn(Other).IsHeadShot(HitLocation,Normal(Velocity)) )
					Other.TakeDamage(3.5 * damage, instigator,HitLocation,(MomentumTransfer * Normal(Velocity)), 'decapitated' );
				else
					Other.TakeDamage(damage, instigator,HitLocation,(MomentumTransfer * Normal(Velocity)), 'shredded' );
			}
			if ( Other.bIsPawn )
				PlaySound(MiscSound, SLOT_Misc, 2.0);
			else
				PlaySound(ImpactSound, SLOT_Misc, 2.0);
			Destroy();
		}
	}

	simulated function ZoneChange( Zoneinfo NewZone )
	{
		local Splash w;

		if (!NewZone.bWaterZone || bHitWater) Return;

		bHitWater = True;
		w = Spawn(class'Splash',,,,rotang(90,0,0));
		w.DrawScale = 0.5;
		w.RemoteRole = ROLE_None;
		Velocity=0.6*Velocity;
	}

	simulated function SetRoll(vector NewVelocity)
	{
		local rotator newRot;

		newRot = rotator(NewVelocity);
		SetRotation(newRot);
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		local Texture T;

		bCanHitInstigator = true;
		PlaySound(ImpactSound, SLOT_Misc, 2.0);
		if ( Level.NetMode != NM_DedicatedServer )
			Spawn(class'WallCrack',,,Location, rotator(HitNormal));
		if( AnimSequence!='Spin' )
			LoopAnim('Spin',1.0);
		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
		{
			if ( Role == ROLE_Authority )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');
			Destroy();
			return;
		}
		NumWallHits++;
		SetTimer(0, False);
		MakeNoise(0.3);
		if ( NumWallHits > 5 )
			Destroy();
		T = GetHitTexture();
		if( T==None || (T.SurfaceType!=EST_Wood && T.SurfaceType!=EST_Plant && T.SurfaceType!=EST_Flesh && T.SurfaceType!=EST_Snow && T.SurfaceType!=EST_Dirt) )
			Velocity = MirrorVectorByNormal(Velocity,HitNormal);
		else if( T.SurfaceType==EST_Snow || Level.NetMode==NM_DedicatedServer ) // Instant destruct on impact with snow.
			Destroy();
		else // Hit something soft, stop movement.
		{
			AnimRate = 0.f;
			RemoteRole = ROLE_None;
			SetPhysics(PHYS_None);
			SetCollision(false);
			LightType = LT_None;
			AmbientSound = None;
			MultiSkins[0] = Texture'ExplosionPal3'; // Hide trail.
			SetBase(Wall);
			LifeSpan = 3.f;
		}
		SetRoll(Velocity);
	}
	function SetUp()
	{
		local vector X;
		X = vector(Rotation);
		Velocity = Speed * X;     // Impart ONLY forward vel
		if (Instigator != None && Instigator.HeadRegion.Zone != None && Instigator.HeadRegion.Zone.bWaterZone)
			bHitWater = True;
		PlaySound(SpawnSound, SLOT_None,4.2);
	}

	simulated function BeginState()
	{
		SetTimer(0.2, false);
		SetUp();

		if ( Level.NetMode != NM_DedicatedServer )
		{
			LoopAnim('Spin',1.0);
			if ( Level.NetMode == NM_Standalone )
				SoundPitch = 200 + 50 * FRand();
		}
	}
	simulated function Timer()
	{
		bCanHitInstigator = true;
	}
}

defaultproperties
{
	speed=1300.000000
	MaxSpeed=1200.000000
	Damage=30.000000
	MomentumTransfer=15000
	SpawnSound=Sound'UnrealI.Razorjack.StartBlade'
	ImpactSound=Sound'UnrealI.Razorjack.BladeHit'
	MiscSound=Sound'UnrealI.Razorjack.BladeThunk'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=6.000000
	AnimSequence=spin
	Mesh=Mesh'UnrealI.razorb'
	AmbientGlow=167
	bUnlit=True
	bMeshCurvy=False
	SoundRadius=12
	SoundVolume=128
	SoundPitch=200
	AmbientSound=Sound'UnrealI.Razorjack.RazorHum'
	bBounce=True
	NetPriority=6.000000
	MyDamageType="Shredded"
}
