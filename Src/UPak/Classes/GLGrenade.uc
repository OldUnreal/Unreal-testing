//=============================================================================
// GLGrenade.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class GLGrenade expands Projectile;

#exec MESH IMPORT MESH=grenade ANIVFILE=MODELS\GLAUNCHER\grenade_a.3d DATAFILE=MODELS\GLAUNCHER\grenade_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=grenade X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=grenade SEQ=All     STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=grenade SEQ=GRENADE STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jgrenade1 FILE=MODELS\GLAUNCHER\grenpln.pcx GROUP=Grenade FLAGS=2 // Material #1

#exec MESHMAP NEW   MESHMAP=grenade MESH=grenade
#exec MESHMAP SCALE MESHMAP=grenade X=0.1 Y=0.1 Z=0.2

var bool bCanHitOwner, bHitWater;
var float Count, SmokeRate;
var ScriptedPawn WarnTarget;	// warn this pawn away
var int NumExtraGrenades;
var bool bSmoking, bBubbling, bVelDecreaser, bAvoiderSet;
var float TrailModifier;
var LocationAvoider AvoidThisSpot;

simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	Super.PostBeginPlay();

	if (Instigator!=None)
		{
			GetAxes(Instigator.ViewRotation,X,Y,Z);
			Velocity = X * ( Instigator.Velocity Dot X ) * 0.4 + Vector( Rotation ) * Speed + FRand() * 100 * Vector( Rotation );
		}
	else
		Velocity = Vector( Rotation ) * Speed + FRand() * 100 * Vector( Rotation );

	Velocity.Z += 210;
	SetTimer( 3.0, false );                 
	RandRot.Pitch = FRand() * 1400 - 700;
	RandRot.Roll = 0.8 * 1400 - 700;
	MaxSpeed = 1500;
	Velocity = Velocity >> RandRot;
	RotationRate.Pitch = ( 100000 * FRand() );
	RotationRate.Roll = 90000 * 2 * 0.5 - 10000;
	bCanHitOwner = False;
	TrailModifier = 0.7;

	if (((Instigator!=None)&&(Instigator.HeadRegion.Zone.bWaterZone))||(Region.Zone.bWaterZone))
	{
		bHitWater = True;
		bBubbling = True;
		bVelDecreaser = True;
		Velocity = 0.8 * Velocity;
		if( Velocity.Z > 100 )
		Velocity.Z *= 0.5;
		SetPhysics( PHYS_Projectile );
		RotationRate.Pitch = 0;
		Spawn( class'BubbleBurst',,,, Instigator.Rotation );			
	}
	else bSmoking = True;
}

simulated function BeginPlay()
{
	if( Level.bHighDetailMode )
		SmokeRate = 0.03;
	else SmokeRate = 0.15;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	local waterring r;
	
	if( !NewZone.bWaterZone || bHitWater )
	{
		if( bBubbling )
		{
			SetPhysics( PHYS_Falling );
			bBubbling = False;
			Velocity *= 1.5;
			r = Spawn( class'WaterRing',,,,rot( 16384, 0, 0 ));
			r.DrawScale = 0.15;
			r.RemoteRole = ROLE_None;
		}
		return;
	}
	bSmoking = False;
	bHitWater = True;
	bBubbling = True;
	bVelDecreaser = True;
	RotationRate.Pitch = 0;
	RotationRate.Roll = 90000 * 2 * 0.5 - 10000;
	Velocity=0.8*Velocity;
}

simulated function Timer()
{
	Explosion( Location+Vect( 0, 0, 1 ) * 16 );
}

simulated function Tick(float DeltaTime)
{
	local SpriteSmokePuff b;
	local BubbleTrail bt;

	if( Level.NetMode!=NM_Client && VSize( Velocity ) == 0 && !bAvoiderSet )
	{
		AvoidThisSpot = Spawn( class'LocationAvoider',,, Location );
		bAvoiderSet = True;
	}

	if( Velocity.Z < -550 )
	{
		// Temporarily disabled Falling Grenade sound; needs a whistling sound
		// AmbientSound = sound'FallingGrenade';
		SoundVolume = 255;
		if ( SoundPitch >= 48 )
			SoundPitch -= 1;
	}
	else
	{
		AmbientSound = none;
		SoundVolume = 0;
	}
		
	Count += DeltaTime;
	if( bSmoking && Level.NetMode!=NM_DedicatedServer && (Count>Frand() * SmokeRate+SmokeRate) ) 
	{
		b = Spawn( class'SpriteSmokePuff' );
		b.RemoteRole = ROLE_None;
		b.DrawScale -= 0.2 + FRand();
		b.ScaleGlow = 0.5;
		if( Level.bDropDetail || (Level.TimeSeconds-LastRenderedTime)>1.f )
			Count = -0.5f;
		else Count = 0;
	}
	else if( bBubbling )
	{
		if( Velocity.Z <= 200 )
			Velocity.Z -= 64.f*DeltaTime;
			
		if( FRand() < 0.25 && FRand() < 0.25 && FRand() < 0.25  && bVelDecreaser ) 
			Velocity *= FMax(1.f-DeltaTime*7.f,0.1f);
			
		if( VSize( Velocity ) <= 45 )
		{
			if( VSize(Velocity) < 10 )
				bBubbling = False;
			else
			{
				SetPhysics( PHYS_Falling );
				bSmoking = False;
				bVelDecreaser = False;
			}
		}

		if( Level.NetMode != NM_DedicatedServer )
		{
			if( VSize( Velocity ) > 300 )
				TrailModifier = 0.95;
			else if( VSize( Velocity ) > 200 )	
				TrailModifier = 0.5;
			else if(VSize(Velocity) > 80)
				TrailModifier = 0.3;
			else TrailModifier = 0.1;

			if( Count>Frand()*SmokeRate+SmokeRate )
			{
				if( FRand() < TrailModifier )
				{
					bt = Spawn( class'BubbleTrail' );
					bt.RemoteRole = ROLE_None;
					bt.ScaleGlow = 0.5;
				}
				if( Level.bDropDetail || (Level.TimeSeconds-LastRenderedTime)>1.f )
					Count = -0.5f;
				else Count = 0;
			}
		}
	}

	if( Level.NetMode!=NM_Client && (Physics==PHYS_None) && (WarnTarget != None) && WarnTarget.bCanDuck
		 && (WarnTarget.Physics == PHYS_Walking) && (WarnTarget.Acceleration != vect(0,0,0)) )
		WarnTarget.Velocity = WarnTarget.Velocity + 2 * DeltaTime * WarnTarget.GroundSpeed * Normal(WarnTarget.Location - Location);
}

simulated function Landed( vector HitNormal )
{
	bSmoking = False;
	HitWall( HitNormal, None );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if( ( Other != Instigator ) || bCanHitOwner )
	{
		Explosion( HitLocation );
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local SmallSpark2 Spark;
	
	bSmoking = False;
	bCanHitOwner = True;

	if( VSize( Velocity ) > 600 )
	{
		Spark = Spawn( class'SmallSpark2',,,,Rotation+RotRand() );
		Spark.RemoteRole = ROLE_None;
	}
	
	Velocity = 0.65 * (( Velocity dot HitNormal ) * HitNormal * ( -2.0 ) + Velocity );  
	RandSpin( 100000 );
	speed = VSize( Velocity );

	if( Level.NetMode != NM_DedicatedServer )
		PlaySound( ImpactSound, SLOT_Misc, FMax( 0.5, speed/800 ) );
	if( Velocity.Z > 400 )
		Velocity.Z = 0.65 * ( 400 + Velocity.Z );	
	else if( speed < 20 ) 
	{
		bBounce = False;
		SetPhysics( PHYS_None );
	}
}
simulated function BlowUp(vector HitLocation)
{
	local vector HitNormal;
	HitNormal = Normal( Location - HitLocation );
	HurtRadiusProj( damage, 200, MyDamageType, MomentumTransfer, HitLocation );
	Spawn( class'UPakBurst',,, HitLocation + HitNormal * 16 );
	Spawn(class'UPakExplosion1',,, HitLocation + HitNormal * 8 , rotator( HitNormal ));
	MakeNoise(1.0);
}

function Explosion(vector HitLocation)
{
	BlowUp(HitLocation);
	PlaySound( SpawnSound );
	Destroy();
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	Explosion( Location );
}
simulated function Destroyed()
{
	if( EffectIsRelevant(Location) )
		spawn(class'Unrealshare.GrenadeBlastMark',,,,rot(16384,0,0));
		
	if( AvoidThisSpot != none )
		AvoidThisSpot.Destroy();
}

defaultproperties
{
     speed=600.000000
     MaxSpeed=1000.000000
     Damage=90.000000
     MomentumTransfer=75000
     ImpactSound=Sound'UPak.GrenadeLauncher.GrenadeHit'
     bNetTemporary=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     AnimSequence=WingIn
     Texture=Texture'UPak.Grenade.Jgrenade1'
     Skin=Texture'UPak.Grenade.Jgrenade1'
     Mesh=LodMesh'UPak.Grenade'
     DrawScale=1.500000
     AmbientGlow=128
     SoundRadius=64
     SoundPitch=128
     CollisionRadius=4.600000
     CollisionHeight=4.750000
     bProjTarget=True
     bBounce=True
     bFixedRotationDir=True
     Mass=25.000000
     DesiredRotation=(Pitch=12000)
     MyDamageType="exploded"
     SmokeRate=0.08
}
