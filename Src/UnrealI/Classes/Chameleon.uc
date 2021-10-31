class Chameleon extends FlockPawn;

#exec MESH IMPORT MESH=ChameleonM ANIVFILE="Models\chamel_a.3d" DATAFILE="Models\chamel_d.3d"
#exec MESH LODPARAMS MESH=ChameleonM STRENGTH=0.1
#exec MESH ORIGIN MESH=ChameleonM X=20 Y=-230 Z=40 YAW=64 PITCH=0 ROLL=-64

#exec MESH SEQUENCE MESH=ChameleonM SEQ=All        STARTFRAME=0  NUMFRAMES=173 RATE=30
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Crawl      STARTFRAME=0  NUMFRAMES=20 RATE=30
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Dead1      STARTFRAME=20 NUMFRAMES=41 RATE=30
#exec MESH SEQUENCE MESH=ChameleonM SEQ=TakeHit    STARTFRAME=20 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Glide      STARTFRAME=61 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Hide       STARTFRAME=62 NUMFRAMES=30 RATE=30
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Wait       STARTFRAME=92 NUMFRAMES=30 RATE=30
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Land       STARTFRAME=122 NUMFRAMES=1
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Run        STARTFRAME=123 NUMFRAMES=20 RATE=30
#exec MESH SEQUENCE MESH=ChameleonM SEQ=Walk       STARTFRAME=143 NUMFRAMES=30 RATE=30

#exec MESHMAP SCALE MESHMAP=ChameleonM X=0.032 Y=0.032 Z=0.064
#exec TEXTURE IMPORT NAME=Cham2 FILE=Models\CameLion2.PCX GROUP="Skins" Masked=1
#exec MESHMAP SETTEXTURE MESHMAP=ChameleonM NUM=1 TEXTURE=Cham2

var NavigationPoint retreatDest;

simulated function BeginPlay()
{
	if ( Class'GameInfo'.Default.bCastShadow && Level.NetMode!=NM_DedicatedServer && Shadow==None )
	{
		if( Class'GameInfo'.Default.bCastProjectorShadows )
			Shadow = Spawn(Class'PawnShadowX',Self);
		else Shadow = Spawn(Class'PawnShadow',Self);
	}
	Super.BeginPlay();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local rotator newRotation;

	if (damageType == 'corroded')
		return;
	SetPhysics(PHYS_Falling);
	newRotation = Rotation;
	newRotation.Roll = 0;
	setRotation(newRotation);
	MoveTimer = -1.0;
	Super.TakeDamage(Damage,instigatedBy,hitLocation,momentum,damageType);
}

function BaseChange()
{
}

function PreSetMovement()
{
	bCanWalk = true;
	bCanSwim = true;
	bCanFly = false;
	MinHitWall = -0.75;
}

function PlayDying(name DamageType, vector HitLoc)
{
	PlayAnim('Dead1');
}
function damageAttitudeTo(pawn Other)
{
	SeePlayer(Other);
}

function Killed(pawn Killer, pawn Other, name damageType)
{
	if ( Enemy==Other )
		Enemy = None;
}

auto state waiting
{
	function SeePlayer(actor Seen)
	{
		if ( Pawn(Seen).Health<=0 || Seen.Class==Class )
			return;
		Enemy = Pawn(Seen);
		GotoState('Active');
	}

	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		LoopAnim('Wait');
		SetPhysics(PHYS_Spider);
	}

Begin:
	LoopAnim('Hide');
	if (Physics != PHYS_Spider)
		SetPhysics(PHYS_Falling);
}

state active
{
	function AnimEnd()
	{
		if (Floor.Z >= 0.7)
			loopAnim('Run', -2.0/GroundSpeed,, 0.4);
		else
			loopAnim('Crawl', -2.0/GroundSpeed,, 0.4);
	}
	function Killed(pawn Killer, pawn Other, name damageType)
	{
		if ( Enemy==Other )
		{
			Enemy = None;
			GoToState(,'Hide');
		}
	}

	function Falling()
	{
		local rotator newRot;
		LoopAnim('Glide',0.5,0.1);
		newRot = Rotation;
		newRot.Pitch = 0;
		newRot.Roll = 0;
		Velocity = 1.5 * GroundSpeed * Normal(Destination - Location);
		Velocity.Z = JumpZ;
		SetRotation(newRot);
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		Disable('HitWall');
		if ( (Physics == PHYS_Falling) && (HitNormal.Z >= 0) )
			SetPhysics(PHYS_Spider);
		movetimer = -1.0;
	}

	function Landed(vector HitNormal)
	{
		if ( !FootRegion.Zone.bWaterZone )
			PlaySound(Land);
		SetRotation(Rot(0,0,0));
		TweenAnim('Land',0.1);
		SetPhysics(PHYS_Spider);
		movetimer = -1.0;
	}

	function bool TryPick(vector DestDir)
	{
		local actor HitActor;
		local vector HitNormal, HitLocation;

		if (Floor != vect(0,0,0))
			Destination = Location + (200 + 300 * FRand()) * Normal( DestDir - Floor * (DestDir Dot Floor)) + FRand() * vect(0,0,100);
		else
			Destination = Location + (200 + 300 * FRand()) * DestDir;

		HitActor = Trace(HitLocation, HitNormal, Destination, Location, false);
		if ( VSize(HitLocation - Location) < 80 )
		{
			if ( HitNormal.Z < 0 )
				return false;
			Destination = Location + Normal(DestDir + (HitNormal Cross vect(0,0,1))) * (200 + 300 * FRand());
			HitActor = Trace(HitLocation, HitNormal, Destination, Location, false);
			if ( VSize(HitLocation - Location) > 80 )
				return true;
			Destination = Location + Normal(DestDir - (HitNormal Cross vect(0,0,1))) * (200 + 300 * FRand());
			HitActor = Trace(HitLocation, HitNormal, Destination, Location, false);
			if ( VSize(HitLocation - Location) < 80 )
				return false;
		}

		return true;
	}

	function PickDestination()
	{
		local float enemydist;
		local bool EnemyFOV, bSeeEnemy;
		local vector enemyViewDir, hideDir;

		if ( Enemy==None || Enemy.Health<=0 || Enemy.bDeleteMe )
		{
			Enemy = None;
			GoToState(,'Hide');
		}
		enemydist = VSize(Location - Enemy.Location);
		enemyViewDir = Vector(Enemy.ViewRotation);
		bSeeEnemy = LineOfSightTo(Enemy);
		EnemyFOV = ( ((Location - Enemy.Location) Dot enemyViewDir) > 0.7 * enemydist );

		if ( enemydist > 600 )
		{
			if ( bSeeEnemy && EnemyFOV && (Location.Z > Enemy.Location.Z) )
				GotoState('Active', 'Hide');
			else
			{
				Destination = 0.5 * (Location + Enemy.Location);
				Destination.Z = FMax(Location.Z, Enemy.Location.Z);
			}
			return;
		}
		if ( (enemydist > 180) && bSeeEnemy && !EnemyFOV )
			GotoState('Active', 'Hide');

		// try to get out of FOV, more than away
		hideDir = Normal( 2 * (Location - Enemy.Location)/enemydist - enemyViewDir);
		if ( TryPick(hideDir) )
			return;

		// try to get away
		if ( TryPick((Location - Enemy.Location)/enemydist) )
			return;

		// move toward pathnode
		if ( (RetreatDest == None) || ActorReachable(RetreatDest) )
			RetreatDest = FindRandomDest();

		if ( RetreatDest != None )
		{
			if ( ActorReachable(RetreatDest) )
			{
				Destination = RetreatDest.Location;
				return;
			}
			else
			{
				MoveTarget = FindPathToward(RetreatDest);
				if ( MoveTarget != None )
				{
					Destination = MoveTarget.Location;
					return;
				}
			}
		}

		// try other FOV dir.
		if ( TryPick(-1 * hideDir) )
			return;
		GotoState(, 'Hide');
	}

	function SeePlayer(Actor Seen)
	{
		local float enemydist;

		if ( Pawn(Seen).Health<=0 || Seen.Class==Class )
			return;
		Enemy = Pawn(Seen);
		enemydist = VSize(Enemy.Location - Location);
		if ( (enemydist < 500) && ((Location - Enemy.Location) Dot Vector(Enemy.ViewRotation) > enemyDist * 0.707) )
		{
			GotoState(,'Begin');
			Disable('SeePlayer');
			Enable('EnemyNotVisible');
		}
	}

	function EnemyNotVisible()
	{
		GoToState(,'hide');
	}

begin:
	if ( Physics==PHYS_Falling )
		WaitForLanding();
	if ( Physics!=PHYS_Spider )
		SetPhysics(PHYS_Spider);
	if (Floor.Z >= 0.7)
		TweenAnim('Run', 0.2);
	else
		TweenAnim('Crawl', 0.2);
wander:
	PickDestination();
	Enable('HitWall');
	MoveTo(Destination);
	Goto('Wander');

hide:
	Disable('EnemyNotVisible');
	Enemy = None;
	LoopAnim('Hide', 0.3, 0.2);
	Acceleration = vect(0,0,0);
	Enable('SeePlayer');
}

singular function SpawnGibbedCarcass()
{
	local carcass carc;

	carc = Spawn(Class'PupaeCarcass');
	if ( carc != None )
	{
		carc.Initfor(self);
		carc.ChunkUp(-1 * Health);
	}
}
singular function Carcass SpawnCarcass()
{
	local carcass carc;

	carc = Spawn(Class'PupaeCarcass');
	if ( carc != None )
		carc.Initfor(self);

	return carc;
}

defaultproperties
{
	GroundSpeed=440
	AccelRate=1000
	JumpZ=360
	DrawType=DT_Mesh
	Mesh=ChameleonM
	CollisionRadius=12
	CollisionHeight=12
	Physics=PHYS_Falling
	PeripheralVision=-1
	Mass=50
}