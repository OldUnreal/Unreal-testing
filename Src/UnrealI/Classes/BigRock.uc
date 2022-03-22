//=============================================================================
// BigRock.
//=============================================================================
class BigRock extends Projectile;

#exec MESH IMPORT MESH=TBoulder ANIVFILE=..\UnrealShare\Models\rock_a.3d DATAFILE=..\UnrealShare\Models\rock_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=TBoulder X=0 Y=0 Z=0 YAW=64

#exec MESH SEQUENCE MESH=TBoulder SEQ=All  STARTFRAME=0  NUMFRAMES=4
#exec MESH SEQUENCE MESH=TBoulder SEQ=Pos1  STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=TBoulder SEQ=Pos2  STARTFRAME=1   NUMFRAMES=1
#exec MESH SEQUENCE MESH=TBoulder SEQ=Pos3  STARTFRAME=2   NUMFRAMES=1
#exec MESH SEQUENCE MESH=TBoulder SEQ=Pos4  STARTFRAME=3   NUMFRAMES=1

#exec TEXTURE IMPORT NAME=JBoulder1 FILE=..\UnrealShare\Models\rock.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=TBoulder X=0.01 Y=0.01 Z=0.02
#exec MESHMAP SETTEXTURE MESHMAP=TBoulder NUM=1 TEXTURE=JBoulder1

#exec AUDIO IMPORT FILE="Sounds\Titan\Rockhit1.wav" NAME="Rockhit" GROUP="Titan"

var transient float SpawnTime,NoiseTime;
var nowarn transient const Actor Shadow; // Obsolete!

simulated function BeginPlay()
{
}
simulated function Destroyed()
{
}

function PostBeginPlay()
{
	local float decision;

	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * (0.8 + (0.3 * FRand())) * speed;
	DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;
	DesiredRotation.Roll = Rotation.Roll + Rand(2000) - 1000;
	DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
	decision = FRand();
	if (decision<0.25)
		PlayAnim('Pos2', 1.0, 0.0);
	else if (decision<0.5)
		PlayAnim('Pos3', 1.0, 0.0);
	else if (decision <0.75)
		PlayAnim('Pos4', 1.0, 0.0);
	if (FRand() < 0.5)
		RotationRate.Pitch = Rand(180000);
	if ( (RotationRate.Pitch == 0) || (FRand() < 0.8) )
		RotationRate.Roll = Max(0, 50000 + Rand(200000) - RotationRate.Pitch);
	SpawnTime = Level.TimeSeconds+0.1;
}

function TakeDamage( int NDamage, Pawn instigatedBy,
					 Vector hitlocation, Vector momentum, name damageType)
{

	// If a rock is shot, it will fragment into a number of smaller
	// pieces.  The player can fragment a giant boulder which would
	// otherwise crush him/her, and escape with minor or no wounds
	// when a multitude of smaller rocks hit.

	//log ("Rock gets hit by something...");
	Velocity += Momentum/FMax(DrawScale * 10,0.025f);
	if (Physics == PHYS_None )
	{
		SetPhysics(PHYS_Falling);
		Velocity.Z += 0.4 * VSize(momentum);
	}
	SpawnChunks(4);
}

function SpawnChunks(int num)
{
	local int    NumChunks,i;
	local BigRock   TempRock;
	local float scale;

	if ( DrawScale < 1 + FRand() || (SpawnTime>Level.TimeSeconds) )
		return;

	NumChunks = 1+Rand(num);
	scale = sqrt(0.52/NumChunks);
	if ( scale * DrawScale < 1 )
	{
		NumChunks *= scale * DrawScale;
		scale = 1/FMax(DrawScale,0.025f);
	}
	speed = VSize(Velocity);
	for (i=0; i<NumChunks; i++)
	{
		TempRock = Spawn(class'BigRock');
		if (TempRock != None )
			TempRock.InitFrag(self, scale);
	}
	InitFrag(self, 0.5);
}

function InitFrag(BigRock myParent, float scale)
{
	// Pick a random size for the chunks
	RotationRate = RotRand();
	scale *= (0.5 + FRand());
	DrawScale = scale * myParent.DrawScale;
	if ( DrawScale <= 2 )
		SetCollisionSize(0,0);
	else
		SetCollisionSize(CollisionRadius * DrawScale/Default.DrawScale, CollisionHeight * DrawScale/Default.DrawScale);

	Velocity = Normal(VRand() + myParent.Velocity/FMax(myParent.speed,0.1f))
			   * (myParent.speed * (0.4 + 0.3 * (FRand() + FRand())));
}

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local int hitdamage;

		if ( Other == instigator )
			return;
		if( NoiseTime<Level.TimeSeconds )
		{
			PlaySound(ImpactSound, SLOT_Interact, DrawScale/10);
			NoiseTime = Level.TimeSeconds+0.1f;
		}

		if ( !Other.IsA('BigRock') && !Other.IsA('Titan') )
		{
			Hitdamage = Damage * 0.00002 * (DrawScale**3) * speed;
			if ( (HitDamage > 6) && (speed > 150) )
				Other.TakeDamage(hitdamage, instigator,HitLocation,
								 (35000.0 * Normal(Velocity)), 'crushed' );
		}
	}

	simulated function Landed(vector HitNormal)
	{
		HitWall(HitNormal, None);
	}

	function MakeSound()
	{
		local float soundRad;

		if( NoiseTime<Level.TimeSeconds )
		{
			if ( Drawscale > 2.0 )
				soundRad = 500 * DrawScale;
			else
				soundRad = 100;
			PlaySound(ImpactSound, SLOT_Misc, DrawScale/8,,soundRad);
			NoiseTime = Level.TimeSeconds+0.1f;
		}
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local vector RealHitNormal;
		local float old;

		if ( (Role == ROLE_Authority) && (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');
		speed = VSize(velocity);
		MakeSound();
		if ( Level.NetMode != NM_DedicatedServer && DrawScale>3 && speed>250 )
		{
			old=class'BigWallCrack'.default.drawscale;
			class'BigWallCrack'.default.drawscale=(self.drawscale*0.1);
			Spawn(class'BigWallCrack',,,Location, rotator(HitNormal));
			class'BigWallCrack'.default.drawscale=old;
		}
		if ( (HitNormal.Z > 0.8) && (speed < 60 - DrawScale) )
		{
			SetPhysics(PHYS_None);
			GotoState('Sitting');
		}
		else
		{
			SetPhysics(PHYS_Falling);
			RealHitNormal = HitNormal;
			if ( FRand() < 0.5 )
				RotationRate.Pitch = Max(RotationRate.Pitch, 100000);
			else
				RotationRate.Roll = Max(RotationRate.Roll, 100000);
			HitNormal = Normal(HitNormal + 0.5 * VRand());
			if ( (RealHitNormal Dot HitNormal) < 0 )
				HitNormal.Z *= -0.7;
			Velocity = 0.7 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
			DesiredRotation = rotator(HitNormal);
			if ( (speed > 150) && (FRand() * 30 < DrawScale) )
				SpawnChunks(4);
		}
	}

Begin:
	Sleep(5.0);
	SetPhysics(PHYS_Falling);
}

State Sitting
{
Begin:
	SetPhysics(PHYS_None);
	Sleep(DrawScale * 0.5);
	Destroy();
}

defaultproperties
{
	speed=+00900.000000
	MaxSpeed=+01000.000000
	Damage=+00040.000000
	ImpactSound=Rockhit
	Physics=PHYS_Falling
	CollisionRadius=+00030.000000
	CollisionHeight=+00030.000000
	bBounce=True
	bFixedRotationDir=true
	LifeSpan=+00020.000000
	RemoteRole=ROLE_SimulatedProxy
	AnimSequence=Pos1
	NetPriority=+00006.000000
	Mesh=TBoulder
	DrawScale=+00007.500000
	bMeshCurvy=False
	bNetTemporary=false
	bNoDynamicShadowCast=false
	
	// Marco: Disabled this here because bigrock chunks are so plentiful and a bandwidth hog already...
	bNetInitialVelocity=false
	bNetInitExactLocation=false
}