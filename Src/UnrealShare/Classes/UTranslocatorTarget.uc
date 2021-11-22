//=============================================================================
// UTranslocator Target.
//=============================================================================
Class UTranslocatorTarget extends Projectile;

#exec MESH IMPORT MESH=TeleportProj ANIVFILE=Models\telemo_a.3D DATAFILE=Models\telemo_d.3D X=0 Y=0 Z=0 mlod=0
#exec MESH ORIGIN MESH=TeleportProj X=0 Y=0 Z=0 YAW=64 PITCH=0
#exec MESH SEQUENCE MESH=TeleportProj SEQ=All  STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Ahand1 FILE=Models\hand.PCX
#exec MESHMAP SCALE MESHMAP=TeleportProj X=0.03 Y=0.03 Z=0.06
#exec MESHMAP SETTEXTURE MESHMAP=TeleportProj NUM=0 TEXTURE=Ahand1

var UTranslocator MyTranslocator;
var bool bCantPickup;
var vector RepLandedPosition;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		RepLandedPosition;
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( MyTranslocator==None || Other!=MyTranslocator.Owner )
	{
		if( Level.NetMode==NM_Client && Other==Instigator )
			return;
		if ( Level.NetMode!=NM_Client && MyTranslocator!=None && Other.bIsPawn && PlayerPawn(MyTranslocator.Owner)==None
				&& !MyTranslocator.IsTeamMate(Pawn(Other)) )
		{
			MyTranslocator.BotPausingTime = 0;
			MyTranslocator.AltFire(0); // Try to telefrag.
		}
		else HitWall(Normal(Other.Location - Location), Other);
	}
	else if ( !bCantPickup )
	{
		PlaySound(Sound'AmmoSnd');
		Destroy();
	}
}
simulated function Landed( vector HitNormal )
{
	HitWall( HitNormal, None );
}
simulated function HitWall( vector HitNormal, actor Wall )
{
	local rotator R;

	bCantPickup = false;
	SetPhysics(PHYS_Falling);
	MakeNoise(0.6);
	Velocity = 0.8*MirrorVectorByNormal(Velocity,HitNormal); // Reflect off Wall w/damping
	if ( Wall!=None && Wall.Physics!=PHYS_None )
		Velocity+=Wall.Velocity;
	if ( VSize(Velocity)<40 )
	{
		R = Rotation;
		R.Pitch = 0;
		SetRotation(R);
		bFixedRotationDir = false;
		SetPhysics(PHYS_None);
		if ( Level.NetMode!=NM_Client )
			RepLandedPosition = Location;
	}
	else if ( Level.NetMode!=NM_DedicatedServer )
	{
		PlaySound(ImpactSound);
		RandSpin(60000);
	}
}
simulated function PostBeginPlay()
{
	local vector X,Y,Z;

	if ( Level.NetMode!=NM_DedicatedServer )
		RandSpin(100000);
	if ( Level.NetMode==NM_Client || Instigator==None )
		return;
	GetAxes(Instigator.ViewRotation,X,Y,Z);
	Velocity = (X dot Instigator.Velocity) * X +    // Impart ONLY forward
			   Vector(Rotation) * Speed; 			// Velocity
	Velocity.Z += 250;
	RandSpin(100000);
}
function Destroyed()
{
	if ( MyTranslocator!=None )
	{
		MyTranslocator.TargetDestroyed();
		MyTranslocator = None;
	}
}
simulated function PostNetReceive()
{
	local rotator R;

	if ( RepLandedPosition!=vect(0,0,0) )
	{
		SetLocation(RepLandedPosition);
		if ( Physics!=PHYS_None )
		{
			R = Rotation;
			R.Pitch = 0;
			SetRotation(R);
			bFixedRotationDir = false;
			SetPhysics(PHYS_None);
		}
		RepLandedPosition = vect(0,0,0);
	}
}

defaultproperties
{
	bBounce=True
	bNetTemporary=false
	Mesh=Mesh'TeleportProj'
	CollisionHeight=4
	CollisionRadius=4
	Physics=PHYS_Falling
	MyDamageType="gibbed"
	LifeSpan=0
	ImpactSound=Sound'GrenadeFloor'
	bFixedRotationDir=true
	Speed=900
	RemoteRole=ROLE_SimulatedProxy
	bNetNotify=true
	bCantPickup=true
}
