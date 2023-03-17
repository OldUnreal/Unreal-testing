//=============================================================================
// [227k] Physics Mover: A mover that may use PhysX simulation.
//=============================================================================
Class Phys_Mover extends Mover;

var() bool bStartupRigidBody; // Mover should start in rigidbody mode.
var() bool bRigidBodyNoCollision; // Disable collision between this mover and player while its in rigidbody physics.
var() name RigidBodyTag; // Trigger tag that should turn this mover to rigidbody mode.
var() name MoverModeTag; // Trigger tag that should make this mover go back to moving brush mode.
var() byte MoverModeKey; // When triggering to mover mode, move to this keyframe.
var() byte FallbackRigidBodyKey; // If physics engine is disabled, fallback by interpolating the mover to this keyframe instead.
var() int MoverHealth; // Total hitpoints this mover has until it's fully destroyed (0 = indestructable).
var() int RigidBodyHealth; // Hitpoints until mover turns into rigidbody mode (0 = never).
var() name RigidBodyEvent; // Trigger event when mover is 'destroyed' into rigidbody physics.
var() name DestroyedEvent; // Trigger event when mover is fully destroyed.

var() float DamageImpactForce; // How hard should momentum from damage transfer to this prop.
var() float MinCrushVelocity; // Minimum velocity of this object before it should deal damage.
var() float CrushDamageScaling; // Damage scale when prop is hitting an actor.
var() float PushingForce; // How strong normal actors can push this object.
var() Sound CrushedPawnSound; // Sound FX when hitting a Pawn actor.
var() sound ImpactSound; // Physics impact sound.

var int DamageTaken;

var name InitialTag;
var byte InitialKey;
var bool bInitialHidden,bInitialCollision;
var repnotify bool bDestroyed;

replication
{
	// Things the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		bDestroyed;
}

simulated function PreBeginPlay()
{
	InitialTag = Tag;
	bInitialHidden = bHidden;
	bInitialCollision = bCollideActors;
	InitialKey = Clamp( KeyNum, 0, ArrayCount(KeyPos)-1 );
}

function PostBeginPlay()
{
	local mover M;

	//brushes can't be deleted, so if not relevant, make it invisible and non-colliding
	if( Level.Game && !Level.Game.IsRelevant(self) )
	{
		InitialState = 'DisabledState';
		DestroyMover();
		GoToState('DisabledState');
	}
	else
	{
		FindTriggerActor();
		// Initialize all slaves.
		if( !bSlave )
		{
			foreach AllActors( class 'Mover', M, Tag )
			{
				if ( M.bSlave )
				{
					M.GotoState('');
					M.SetBase( Self );
				}
			}
		}
		if( !Leader )
		{
			Leader = self;
			if( ReturnGroup!='' )
			{
				ForEach AllActors( class'Mover', M )
					if ( (M != self) && (M.ReturnGroup == ReturnGroup) )
					{
						M.Leader = self;
						M.Follower = Follower;
						Follower = M;
					}
			}
		}
		if( bStartupRigidBody )
			TurnRigidBody();
		
		if( RigidBodyTag!='' )
			Spawn(class'Phys_MoverTrigger',,RigidBodyTag).Mover = Self;
		if( MoverModeTag!='' )
			Spawn(class'Phys_MoverTrigger',,MoverModeTag).Mover = Self;
	}
}

function OnTrigger( name T )
{
	if( T==RigidBodyTag )
		TurnRigidBody();
}

function Reset()
{
	DamageTaken = 0;
	if( bDestroyed )
		RestoreMover();
	Super.Reset();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	if( MoverHealth && (DamageTaken+Damage)>=MoverHealth && !bDestroyed )
	{
		TriggerEvent(DestroyedEvent,Self,instigatedBy);
		DestroyMover();
		return;
	}
	if( RigidBodyHealth && DamageTaken<RigidBodyHealth && (DamageTaken+Damage)>=RigidBodyHealth )
	{
		TriggerEvent(RigidBodyEvent,Self,instigatedBy);
		TurnRigidBody();
	}
	DamageTaken+=Damage;
}

simulated function ClientSimMove()
{
	if( SimInterpolate!=vect(0,0,0) )
		Super.ClientSimMove();
}

function TurnRigidBody()
{
	if( Level.RigidBodiesEnabled() )
	{
		bOnlyDirtyReplication = false;
		NetUpdateFrequency = 100.f;
		bSimulatedPawnRep = true;
		SimInterpolate = vect(0,0,0);
		bInterpolating = false;
		SetPhysics(PHYS_RigidBody);
	}
	else
	{
		InterpolateTo(FallbackRigidBodyKey, MoveTime);
	}
	AmbientSound = None;
	GoToState('RigidBodyMode');
}

function TurnToMover()
{
	if( bSimulatedPawnRep )
	{
		bOnlyDirtyReplication = true;
		NetUpdateFrequency = Default.NetUpdateFrequency;
		bSimulatedPawnRep = false;
	}
	InterpolateTo(MoverModeKey, MoveTime);
	GoToState(InitialState);
}

simulated function OnRepNotify( name Property )
{
	if( Property=='bDestroyed' )
	{
		if( bDestroyed )
			DestroyMover();
		else RestoreMover();
	}
}

simulated function DestroyMover()
{
	if( Level.NetMode!=NM_Client )
	{
		Tag = '';
		bDestroyed = true;
		bForceNetUpdate = true;
		bReplicateSimMove = false;
		GoToState('DestroyedState');
	}
	bInterpolating = false;
	SetPhysics(PHYS_None);
	bHidden = true;
	SetCollision(false);
	AmbientSound = None;
	if( Brush )
		SetLocation(vect(-75536,-75536,-75536));
}
simulated function RestoreMover()
{
	if( Level.NetMode!=NM_Client )
	{
		Tag = InitialTag;
		bDestroyed = false;
		bForceNetUpdate = true;
		bReplicateSimMove = true;
	}
	bHidden = bInitialHidden;
	SetCollision(bInitialCollision);
	SetLocation(BasePos + KeyPos[InitialKey], BaseRot + KeyRot[InitialKey]);
}

state RigidBodyMode
{
Ignores InterpolateEnd,MakeGroupStop,MakeGroupReturn;

	function OnTrigger( name T )
	{
		if( T==MoverModeTag )
			TurnToMover();
	}
	function TakeDamage( int Damage, Pawn instigatedBy, vector hitlocation, vector momentum, name damageType)
	{
		Instigator = InstigatedBy;
		momentum/=Mass;
		if( PhysicsData && VSize(Momentum)>10.f )
		{
			if( DamageType=='Exploded' )
				PhysicsData.Impulse(Momentum*DamageImpactForce);
			else PhysicsData.Impulse(Momentum*DamageImpactForce, HitLocation);
		}
		Global.TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType);
	}
	event bool RanInto( Actor Other )
	{
		local float Speed;
		local vector Momentum, OldVelo;
		
		Speed = VSize(Velocity-Other.Velocity);
		if( Speed>MinCrushVelocity )
		{
			Momentum = Velocity * 0.25 * Other.Mass + Speed * 0.25 * Other.Mass * Normal(Velocity cross vect(0,0,1));
			OldVelo = Other.Velocity;

			if( ((Other.Location-Location) Dot Velocity)>0.f )
			{
				if ( Other.bIsPawn && CrushedPawnSound )
					PlaySound(CrushedPawnSound,,TransientSoundVolume*1.25);
				Other.TakeDamage(int(Speed * 0.075 * CrushDamageScaling), Instigator, Other.Location, Momentum, 'Crushed');
				TakeDamage(int(Speed * 0.025 * CrushDamageScaling), Instigator, Other.Location, vect(0,0,0), 'Crushed');
			}
			
			if( PhysicsData )
				PhysicsData.Impulse((-Velocity+OldVelo)*PushingForce, Other.Location);
		}
		return false;
	}
	function Bump( actor Other )
	{
		local float M,S,OtherVel;

		if( Other.bIsPawn && (Other.Mass > (Mass*0.4)) && PhysicsData )
		{
			M = 1.f / Mass;
			S = Normal(Other.Velocity) Dot Velocity;
			OtherVel = FMax(VSize(Other.Velocity), Pawn(Other).GroundSpeed*0.5f);
			if( S<OtherVel )
				PhysicsData.Impulse( (Other.Velocity-Velocity)*(0.25f*PushingForce*M) + Normal(Location-Other.Location)*(FMin(Other.Mass / Mass,1.f)*(OtherVel-S)*PushingForce*M), Other.Location);
			Instigator = Pawn(Other);
		}
	}
	function bool EncroachingOn( actor Other )
	{
		if ( Other.IsA('Carcass') || Other.IsA('Decoration') )
			Other.TakeDamage(10000, Instigator, Other.Location, Velocity*Mass, 'Crushed');
		else if ( Other.IsA('Fragment') )
			Other.Destroy();
		else if ( Other.IsA('Inventory') )
		{
			if( Other.IsA('Weapon') && (Other.Owner == None) && Inventory(Other).RespawnTime==0.f )
				Other.Destroy();
			else Other.TakeDamage(10000, Instigator, Other.Location, Velocity*Mass, 'Crushed'); // Kill flares.
		}
		else Other.TakeDamage(32, Instigator, Other.Location, Velocity*Mass, 'Crushed'); // Damage the encroached actor.
		return false;
	}
}

state DestroyedState
{
Ignores InterpolateEnd,MakeGroupStop,MakeGroupReturn,TakeDamage,Trigger,OnTrigger;
}

State ResetState
{
Begin:
	Sleep(0.f);
	if( bStartupRigidBody )
		TurnRigidBody();
	if( InitialState!='' )
		GoToState(InitialState);
	else GoToState('Auto');
}

defaultproperties
{
	bUseShortestRotation=true
	bDirectionalPushOff=true
	bIgnoreInventory=true
	bOnlyDirtyReplication=true
	Mass=1000
	bDamageTriggered=true
	
	DamageImpactForce=1
	CrushDamageScaling=1
	MinCrushVelocity=100
	PushingForce=5
	
	Begin Object Class=PX_RigidBodyData Name=MoverRbPhys
		Begin Object Class=PXC_BrushCollision Name=MoverRbCollision
			Friction=0.025
		End Object
		CollisionShape=MoverRbCollision
		bStartSleeping=false
	End Object
	PhysicsData=MoverRbPhys
}