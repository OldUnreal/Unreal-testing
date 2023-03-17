//=============================================================================
// UPakRocket.uc
// $Author: Deb $
// $Date: 4/23/99 12:14p $
// $Revision: 1 $
//=============================================================================
class UPakRocket expands Projectile;

#exec MESH IMPORT MESH=rocketL ANIVFILE=MODELS\ROCKETLAUNCHER\rocketL_a.3d DATAFILE=MODELS\ROCKETLAUNCHER\rocketL_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=rocketL X=20 Y=0 Z=-2

#exec MESH SEQUENCE MESH=rocketL SEQ=All   STARTFRAME=0 NUMFRAMES=5
#exec MESH SEQUENCE MESH=rocketL SEQ=PopUp STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=rocketL SEQ=Wings STARTFRAME=1 NUMFRAMES=1
#exec MESH SEQUENCE MESH=rocketL SEQ=Fly   STARTFRAME=2 NUMFRAMES=3

#exec TEXTURE IMPORT NAME=JrocketL1 FILE=MODELS\ROCKETLAUNCHER\rocketL1.PCX GROUP=Skins FLAGS=2 // rocket01

#exec MESHMAP NEW   MESHMAP=rocketL MESH=rocketL
#exec MESHMAP SCALE MESHMAP=rocketL X=0.375 Y=0.375 Z=0.75

#exec MESHMAP SETTEXTURE MESHMAP=rocketL NUM=1 TEXTURE=JrocketL1

#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketLoop2.WAV" NAME="RocketLoop2" GROUP="RocketLauncher"
#exec AUDIO IMPORT FILE="Sounds\RocketLauncher\RocketLoop1.WAV" NAME="RocketLoop1" GROUP="RocketLauncher"

var vector OldVel;
var float SpeedModifier;
var float MagnitudeVel,Count,SmokeRate;
var vector InitialDir;
var bool bSmoking,bRing,bHitWater,bWaterStart, bBubbling;
var int NumExtraRockets;
var int Sequence;
var float NextSmoke;

replication
{
	reliable if ( Role == ROLE_Authority )
		Sequence, SpeedModifier, OldVel, bSmoking, bBubbling;
}

function PostBeginPlay()
{
	if( Level.Game.bDeathMatch )
		Damage -= 35;
	Super.PostBeginPlay();
}

simulated function Tick(float DeltaTime)
{
	local SpriteSmokePuff b;
	local Bubbletrail bb;
	local float TempVelocity;

	TempVelocity = VSize( Velocity );

	if( TempVelocity > 1200 && bSmoking && AnimSequence!='Fly' )
		LoopAnim( 'Fly' );
	Velocity *= 1.5;
	if( NextSmoke>Level.TimeSeconds )
		Return;
	NextSmoke = Level.TimeSeconds+0.025;
	if ( bSmoking )
	{
		b = Spawn( class'RisingSpriteSmokePuff',,, Location );
		b.RemoteRole = ROLE_None;
		b.LifeSpan = 1.5 + Rand( 8.5 );
		b.DrawScale += 0.75 + FRand();
	}
	else if( bBubbling )
	{
		if( AnimSequence!='Wings' )
			LoopAnim( 'Wings' );
		RotationRate.Roll = 90000;
		bb = Spawn( class'BubbleTrail', Instigator,,Location );
		bb.RemoteRole = ROLE_None;
		bb.ScaleGlow = 0.5;
	}
}

// ================================================================================================
// Flying State
// ================================================================================================

auto state Flying
{
	simulated function Explode( vector HitLocation, vector HitNormal )
	{
		local UPakBurst UPB;
		local UPakExplosion1 UPE;

		if (Pawn(Owner) != none && RocketLauncher(Pawn(Owner).Weapon) != none && !RocketLauncher(Pawn(Owner).Weapon).bRJDisabled)
			ControlledHurtRadius(Damage, 340.0, 'exploded', MomentumTransfer, HitLocation);
		else
			ControlledHurtRadiusNoRJ(Damage, 340.0, 'exploded', MomentumTransfer, HitLocation);
		if (Level.NetMode != NM_DedicatedServer)
		{
			UPB = Spawn(class'UPakBurst',,, HitLocation + HitNormal * 16);
			if (UPB != none)
				UPB.RemoteRole = ROLE_None;
			UPE = Spawn(class'UPakExplosion1',,, HitLocation + HitNormal * 8 , rotator(HitNormal));
			if (UPE != none)
				UPE.RemoteRole = ROLE_None;
		}
		Destroy();
	}
	simulated function ProcessTouch( Actor Other, Vector HitLocation )
	{
		if ( ( Other != instigator) && ( Rocket( Other ) == none ) )
		{
			if( Pawn( Other ) != none && Pawn( Other ) == Instigator && !RocketLauncher( Pawn( Owner ).Weapon ).bRJDisabled )
				Damage *= 0.25;
			Explode( HitLocation, Normal( HitLocation - Other.Location ) );
		}
	}
	function BeginState()
	{
		SpeedModifier = 1;
		initialDir = vector( Rotation );
		Velocity = speed * initialDir;
		Acceleration = initialDir * 50;
		Sequence = 1;
		PlayAnim( 'Popup', 0.001 );
		RotationRate.Roll = 75000;
		if ( Region.Zone.bWaterZone )
		{
			bHitWater = True;
			bSmoking = False;
			bBubbling = True;
			Velocity = 0.6 * Velocity;
		}
		PlaySound( sound'RocketShot1', SLOT_None );

	}
	simulated function ZoneChange( Zoneinfo NewZone )
	{
		if ( !NewZone.bWaterZone || bHitWater )
		{
			if ( bBubbling )
			{
				bBubbling = False;
				bSmoking = True;
				PlayAnim( 'Wings', 0.15 );
			}
			return;
		}
		bSmoking = False;
		bHitWater = True;
		bBubbling = True;
		RotationRate.Pitch = 0;
		RotationRate.Roll = 90000 * 2 * 0.5 - 10000;
		Velocity = 0.6 * Velocity;
	}
	simulated function AnimEnd()
	{
		if( Sequence == 1 )
		{
			Oldvel = Velocity;
			Velocity *= 0.37;
			PlayAnim( 'Wings', 0.001 );
			RotationRate.Roll = 80000;
		}

		else if( Sequence == 2 )
		{
			if ( Region.Zone.bWaterZone )
			{
				bHitWater = True;
				bSmoking = False;
				bBubbling = True;
				Velocity = 0.6 * Velocity;
			}
			else bSmoking = True;
			AmbientSound = sound'RocketLoop1';
			Velocity = OldVel;
		}

		Sequence++;
	}
}

//
// Hurt actors within the radius.
//
function ControlledHurtRadius( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims != self )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if( Pawn( Victims ) != none && Pawn( Victims ) == Instigator )
			{
				DamageScale *= 0.5;
				Momentum *= 5;
			}
			Victims.TakeDamage(	damageScale * DamageAmount, Instigator,  Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir, ( ( damageScale * 4 )* ( Momentum * 0.75 ) * dir), DamageName	);
		}
	}
	bHurtEntry = false;
}
function ControlledHurtRadiusNoRJ( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		if( Victims != self )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if( Pawn( Victims ) != None && Pawn( Victims ) != Pawn( Owner ) )
			{
				Victims.TakeDamage( damageScale * DamageAmount,	Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir, (damageScale * Momentum * dir), DamageName );
			}
			else
			{
				Victims.TakeDamage( damageScale * DamageAmount, Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius ) * dir, ( damageScale * ( Momentum * 0.01 ) * dir ), DamageName );
			}
		}
	}
	bHurtEntry = false;
}

defaultproperties
{
     speed=850.000000
     MaxSpeed=2500.000000
     Damage=80.000000
     MomentumTransfer=8500
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.000000
     AnimSequence=Armed
     Mesh=LodMesh'UPak.rocketL'
     AmbientGlow=96
     bUnlit=True
     SoundRadius=128
     SoundVolume=255
     CollisionRadius=8.500000
     CollisionHeight=2.000000
     bProjTarget=True
     bBounce=True
     bFixedRotationDir=True
     RotationRate=(Roll=95000)
     ExplosionDecal=class'Unrealshare.RocketBlastMark'
}
