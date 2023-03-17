//=============================================================================
// PhysicsProp - A physics prop with player interactions possibility.
//=============================================================================
Class PhysicsProp extends Decoration
	abstract;

var() bool bCanCarryProp; // Prop is carryable (ignores mass).
var() bool bTranslucentCarry; // Prop should turn translucent while carried.
var() int Health; // 0 = invincible.
var() float DamageImpactForce; // How hard should momentum from damage transfer to this prop.
var() float MinCrushVelocity; // Minimum velocity of this object before it should deal damage.
var() float PushingForce; // How strong normal actors can push this object.
var() float CrushDamageScaling; // Damage scale when prop is hitting an actor.
var() float ImpactDamageVel; // Minimum velocity before this object takes physics impact damage.
var() Sound CrushedPawnSound; // Sound FX when hitting a Pawn actor.
var() sound ImpactSound; // Physics impact sound.

var const PXJ_ShadowParm GrabConstraint;
var PXJ_ShadowParm ActiveConstraint;
var ERenderStyle BackupStyle;
var Pawn CurrentCarrier;

const MIN_DOWN_ANGLE = 8192;

function Destroyed()
{
	if( CurrentCarrier && CurrentCarrier.CarriedDecoration==Self )
		CurrentCarrier.DropDecoration();
	ActiveConstraint = None; // Important! Don't keep this ref or gc could crash.
	Super.Destroyed();
}

event bool EncroachingOn( actor Other )
{
	return RanInto(Other);
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
			if ( Other.bIsPawn && CrushedPawnSound!=None )
				PlaySound(CrushedPawnSound,,TransientSoundVolume*1.25);
			Other.TakeDamage(int(Speed * 0.075 * CrushDamageScaling), Instigator, Other.Location, Momentum, 'Crushed');
			TakeDamage(int(Speed * 0.025 * CrushDamageScaling), Instigator, Other.Location, vect(0,0,0), 'Crushed');
		}
		
		if( PhysicsData!=None )
			PhysicsData.Impulse((-Velocity+OldVelo)*PushingForce, Other.Location);
	}
	return false;
}

function Bump( actor Other )
{
	local float M,S,OtherVel;

	if ( bPushable && Other.bIsPawn && (Other.Mass > 40) && PhysicsData )
	{
		M = GetBaseMomentumModifier();
		S = Normal(Other.Velocity) Dot Velocity;
		OtherVel = FMax(VSize(Other.Velocity), Pawn(Other).GroundSpeed*0.5f);
		if( S<OtherVel )
			PhysicsData.Impulse( (Other.Velocity-Velocity)*(0.25f*PushingForce*M) + Normal(Location-Other.Location)*(FMin(Other.Mass / Mass,1.f)*(OtherVel-S)*PushingForce*M), Other.Location);
		if( PushSound )
		{
			AmbientSound=PushSound;
			SoundRadius=32;
			SoundVolume=128;
			SoundPitch=64;
		}
		SetTimer(0.3,False);
		Instigator = Pawn(Other);
	}
}
singular function ZoneChange( ZoneInfo NewZone )
{
	local float splashsize;
	local actor splash;

	if ( NewZone.bWaterZone )
	{
		if ( !Region.Zone.bWaterZone && (Velocity.Z < -200) )
		{
			// Else play a splash.
			splashSize = FClamp(0.0001 * Mass * (250 - 0.5 * FMax(-600,Velocity.Z)), 1.0, 3.0 );
			if ( NewZone.EntrySound != None )
				PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
			if ( NewZone.EntryActor != None )
			{
				splash = Spawn(NewZone.EntryActor);
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
		}
		bSplash = true;
	}
	else if ( Region.Zone.bWaterZone && (Buoyancy > Mass) )
	{
		bBobbing = true;
		if ( Buoyancy > 1.1 * Mass )
			Buoyancy = 0.95 * Buoyancy; // waterlog
		else if ( Buoyancy > 1.03 * Mass )
			Buoyancy = 0.99 * Buoyancy;
	}
	if ( NewZone.bPainZone && (NewZone.DamagePerSec > 0) )
		TakeDamage(100, None, location, vect(0,0,0), NewZone.DamageType);
}

function Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	SetPhysics(PHYS_RigidBody);
}

final function float GetBaseMomentumModifier()
{
	return (1.f / FMax(GetStandingWeight() / Mass,1.f));
}

function TakeDamage( int Damage, Pawn instigatedBy, vector hitlocation, vector momentum, name damageType)
{
	if( CurrentCarrier && CurrentCarrier.CarriedDecoration==Self )
		CurrentCarrier.DropDecoration();

	Instigator = InstigatedBy;
	if ( Instigator )
		MakeNoise(1.0);
	bBobbing = false;
	
	momentum*=GetBaseMomentumModifier();
	
	if( Health>0 && (Health-=Damage)<=0 )
		Died(momentum, damageType);
	else if( PhysicsData!=None && VSize(Momentum)>10.f )
	{
		if( DamageType=='Exploded' )
			PhysicsData.Impulse(Momentum*DamageImpactForce);
		else PhysicsData.Impulse(Momentum*DamageImpactForce, HitLocation);
	}
}

function PhysicsImpact( float Threshold, vector HitLocation, vector HitNormal, Actor Other )
{
	if ( Threshold>100.f && ImpactSound!=None )
		PlaySound(ImpactSound,,TransientSoundVolume*1.25*FClamp(Threshold/500.f,0.25,1.f));

	Threshold-=ImpactDamageVel;
	if( Threshold>50.f )
	{
		TakeDamage((Threshold*0.25f), Instigator, HitLocation, vect(0,0,0), 'Crushed');
		if( Other!=None && !Other.bStatic )
			Other.TakeDamage((Threshold*0.25f), Instigator, HitLocation, vect(0,0,0), 'Crushed');
	}
}

function Died( vector momentum, name damageType )
{
	TriggerEvent(Event,Self,Instigator);
	Spawn(EffectWhenDestroyed);
	Destroy();
}

final function vector GetCarryOffset( Pawn P )
{
	local rotator R;

	R.Yaw = P.ViewRotation.Yaw;
	R.Pitch = P.ViewRotation.Pitch & 65535;
	if( R.Pitch<32768 )
		R.Pitch = Min(R.Pitch,16384);
	else R.Pitch = Max(R.Pitch,{65536 - MIN_DOWN_ANGLE});
	return vector(R)*(CollisionRadius+P.CollisionRadius+20.f) + P.Location + Construct<Vector>(0.f,0.f,P.EyeHeight);
}

// Carry logic
function GrabbedBy( Pawn Other )
{
	if( Other.CarriedDecoration==Self )
	{
		if( ActiveConstraint && PhysicsData )
			PhysicsData.DeleteJoint(ActiveConstraint);
		ActiveConstraint = None;
		
		if( bTranslucentCarry )
			Style = BackupStyle;
		bBlockActors = Default.bBlockActors;
		bBlockPlayers = Default.bBlockPlayers;
		
		bWasCarried = true;
		Velocity = Other.Velocity + 10 * VRand();
		Instigator = Other;
		Other.CarriedDecoration = None;
		CurrentCarrier = None;
	}
	else if( (Other.Weapon==None || Other.Weapon.Mass<20) && bPushable && bCanCarryProp && StandingCount==0 )
	{
		if( PhysicsData )
		{
			ActiveConstraint = PXJ_ShadowParm(PhysicsData.CreateJoint(class'PXJ_ShadowParm', GrabConstraint));
			IsStillCarrying(Other);
		}
		if( bTranslucentCarry )
		{
			BackupStyle = Style;
			Style = STY_Translucent;
		}
		bBlockActors = false;
		bBlockPlayers = false;
		Other.CarriedDecoration = Self;
		CurrentCarrier = Other;
	}
}

simulated function ClientSyncPosition( PlayerPawn Other, vector MoveDelta );

// Check if prop is still infront of player.
function bool IsStillCarrying( Pawn Other )
{
	local vector V;
	
	V = GetCarryOffset(Other);
	if( ActiveConstraint )
		ActiveConstraint.SetLocation(V + (Other.Velocity*(Level.LastDeltaTime*10.f)), Other.Rotation);
	return VSize(Location-V)<100.f;
}

// Return true to prevent firing weapon.
function bool CarrierFired( Pawn Other, bool bAlt )
{
	Other.DropDecoration();
	Velocity += vector(Other.ViewRotation)*(200.f*FMin(800.f/Mass,2.f));
	return true;
}

defaultproperties
{
	bNetInterpolatePos=true
	bUseMeshCollision=true
	Mass=100
	Buoyancy=20
	Physics=PHYS_RigidBody
	bStatic=False
	bPushable=True
	bCanCarryProp=true
	DrawType=DT_Mesh
	
	ImpactDamageVel=800
	MinCrushVelocity=100
	DamageImpactForce=1
	PushingForce=5
	CrushDamageScaling=1
	
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=True
	bBlockPlayers=True
	bBlockRigidBodyPhys=true
	
	Begin Object Class=PXJ_ShadowParm Name=GrabConstraintTempl
	End Object
	GrabConstraint=GrabConstraintTempl
}