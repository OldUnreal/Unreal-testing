//=============================================================================
// PeaceBarrel.
//=============================================================================
Class PeaceBarrel extends Projectile;

#exec MESH IMPORT MESH=peace ANIVFILE=Models\peace_a.3D DATAFILE=Models\peace_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=peace X=0 Y=0 Z=0 YAW=-64 ROLL=0 PITCH=0
#exec MESH SEQUENCE MESH=peace SEQ=All       STARTFRAME=0   NUMFRAMES=33
#exec MESH SEQUENCE MESH=peace SEQ=UnFold    STARTFRAME=0   NUMFRAMES=29
#exec MESH SEQUENCE MESH=peace SEQ=Launch1   STARTFRAME=29  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peace SEQ=Launch2   STARTFRAME=30  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peace SEQ=Launch3   STARTFRAME=31  NUMFRAMES=1
#exec MESH SEQUENCE MESH=peace SEQ=Launch4   STARTFRAME=32  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jpeace1 FILE=Models\peaceg.PCX
#exec MESHMAP SCALE MESHMAP=peace  X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=peace NUM=0 TEXTURE=Jpeace1
#exec MESHMAP SETTEXTURE MESHMAP=peace NUM=1 TEXTURE=Jpeace1

var float CountDown;
var rotator Rot;
var byte RocketNumber;
var bool bFireType;

auto state Flying
{
	singular function Touch (Actor Other)
	{
		if( Other!=Instigator )
			HitWall(Normal(Other.Location - Location), Other);
	}
	function Landed( vector HitNormal )
	{	
		HitWall( HitNormal, None );	
	}
	function HitWall( vector HitNormal, actor Wall )
	{
		if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), '');
		SetPhysics(PHYS_Falling);
		MakeNoise(0.6);
		Velocity = 0.8*MirrorVectorByNormal(Velocity,HitNormal); // Reflect off Wall w/damping
		if( Wall!=None && Wall.Physics!=PHYS_None )
			Velocity+=Wall.Velocity;
		SetRotation(rotator(Velocity));
		if( VSize(Velocity)<40 )
			GoToState('AtRest');
		else PlaySound(ImpactSound);
	}

	function BeginState()
	{
		local Vector X,Y,Z;
	
		GetAxes(Instigator.ViewRotation,X,Y,Z);	
		Velocity = (X dot Instigator.Velocity) * X +    // Impart ONLY forward
			Vector(Rotation) * 100.0; 			// Velocity 
		Velocity.Z += 250;
		bBounce = True;
		PlaySound(SpawnSound);
	}
}

///////////////////////////////////////////////////////////
state AtRest
{
Ignores HitWall,Touch;

Begin:
	SetPhysics(PHYS_None);
	Rot = Rotation;
	Rot.Roll = Rand(200)-100;
	Rot.Pitch = Rand(200)-100;
	SetRotation(Rot);
	Sleep(CountDown+0.1);
	GoToState('UnFolding');
}

state Unfolding
{
Ignores HitWall,Touch;

Begin:
	if (!bFireType)
	{
		Explosion();
		Stop;
	}
	PlayAnim('UnFold',0.3,0.05);
	FinishAnim();
	Sleep(0.3);
	GoToState('Launching');
}

///////////////////////////////////////////////////////////
state Launching
{
Ignores HitWall,Touch;

	function Timer()
	{
		local Vector X,Y,Z;

		GetAxes(Rotation,X,Y,Z);
		switch( RocketNumber )
		{
		case 0:
			Spawn(class'PeaceRocket',, '',Location - 15 * X -  0 * Y - Z * 10, Rot);		
			Rot.Yaw -= 16384;	
			PlayAnim('Launch1',1.0, 0);
			PlaySound(Sound'Ignite');
			break;
		case 1:
			Spawn(class'PeaceRocket',, '', Location +  0 * X + 15 * Y - Z * 10, Rot);	
			Rot.Yaw -= 32768;	
			PlayAnim('Launch2',1.0, 0);
			PlaySound(Sound'Ignite');
			break;
		case 2:
			Spawn(class'PeaceRocket',, '', Location + 0 * X - 15 * Y - Z * 10, Rot);	
			Rot.Yaw += 16384;	
			PlayAnim('Launch3',1.0, 0);
			PlaySound(Sound'Ignite');
			break;
		case 3:
			Spawn(class'PeaceRocket',, '',Location +  15 * X - 0 * Y - Z * 10, Rot);	
			PlayAnim('Launch4',1.0, 0);
			PlaySound(Sound'Ignite');
			break;
		case 5:
			HurtRadius(Damage/4, 100.0, 'exploded', MomentumTransfer, Location);
			Spawn(class'BallExplosion');
			LifeSpan = 0.2;
		}	
		RocketNumber++;
	}
	function BeginState()
	{
		Rot.Pitch += 6000;
		Rot.Yaw += 32768;
		SetTimer(0.6,True);
	}
}

///////////////////////////////////////////////////////////
function Explosion()
{
	HurtRadius(Damage, 200.0, 'exploded', MomentumTransfer, Location);
	Spawn(class'BallExplosion');
	LifeSpan = 0.2;
}

simulated function Destroyed()
{
	if( Level.NetMode!=NM_DedicatedServer && EffectIsRelevant(Location) )
		Spawn(ExplosionDecal,,,,rotator(vect(0,0,1)));
}

defaultproperties
{
	bNetTemporary=false
	Mesh=Mesh'peace'
	CollisionHeight=22
	CollisionRadius=10
	Physics=PHYS_Falling
	Damage=500
	MomentumTransfer=50000
	MyDamageType="exploded"
	LifeSpan=0
	ImpactSound=Sound'GrenadeFloor'
	ExplosionDecal=class'Unrealshare.BallBlastMark'
	bNetInterpolatePos=true
}