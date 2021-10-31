//=============================================================================
// GLGrenade.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class GLDetGrenade expands GLGrenade;

#exec TEXTURE IMPORT NAME=Jgrenade2 FILE=MODELS\GLAUNCHER\grensmrt.pcx GROUP=Grenade FLAGS=2 

var nowarn int TimerCounter;
var bool bNoEnemy;
var bool bTrapGrenade;
var GrenadeLauncher GL;

function Explosion(vector HitLocation) {}

simulated function PostBeginPlay()
{
	local vector X,Y,Z;
	local rotator RandRot;

	if( Level.NetMode!=NM_Client )
	{
		if (Instigator!=None){
			GetAxes(Instigator.ViewRotation, X, Y, Z);	
			Velocity = X * ( Instigator.Velocity Dot X )*0.4 + Vector( Rotation ) * Speed + FRand() * 100 * Vector( Rotation );
		}
		else Velocity = Vector( Rotation ) * Speed + FRand() * 100 * Vector( Rotation );
		Velocity.z += 210;
		RandRot.Pitch = FRand() * 1400 - 700;
		RandRot.Roll = 0.8 * 1400 - 700;
		MaxSpeed = 1500;
		Velocity = Velocity >> RandRot;
	}

	RotationRate.Pitch = ( 100000 * FRand() );
	RotationRate.Roll = 90000 * 2 * 0.5 - 10000;
	bCanHitOwner = false;
	TrailModifier = 0.7;

	if (((Instigator!=None)&&(Instigator.HeadRegion.Zone.bWaterZone))||(Region.Zone.bWaterZone))
	{
		bHitWater = true;
		bBubbling = true;
		bVelDecreaser = true;
		Velocity = 0.8 * Velocity;
		if( Velocity.Z > 100 )
			Velocity.Z *= 0.5;
		SetPhysics( PHYS_Projectile );
		RotationRate.Pitch = 0;
		Spawn( class'BubbleBurst', Instigator,,, RotRand() );			
	}
	else bSmoking = true;

	if( Level.NetMode!=NM_Client && Instigator!=None)
	{
		if( Instigator.IsA( 'Bots' ) )
			SetTimer( 1.5, true );
		if( Instigator.IsInState( 'Roaming' ) )
			bNoEnemy = true;
	}
}

simulated function BlowUp(vector HitLocation)
{
	local vector HitNormal;
	
	HitNormal = Normal( Location - HitLocation );
	
	HurtRadius(damage*1.25, 250, 'exploded', MomentumTransfer, HitLocation );
	
	Spawn( class'UPakBurst',,, HitLocation + HitNormal * 16 );
	Spawn(class'UPakExplosion1',,, HitLocation + HitNormal * 8 , rotator( HitNormal ));

	if( AvoidThisSpot != none )
		AvoidThisSpot.Destroy();
	if( GL != none )
	{
		GL.bDetGrenadeActive = false;
		GL.DetGrenade = none;
		TimerCounter = 0;
	}
	Destroy();
}

simulated function Destroyed()
{
	if( GL != none )
	{
		GL.bDetGrenadeActive = false;
		GL.DetGrenade = none;
		TimerCounter = 0;
	}
	if( EffectIsRelevant(Location) )
		spawn(class'Unrealshare.GrenadeBlastMark',,,,rot(16384,0,0));
		
	if( AvoidThisSpot != none )
		AvoidThisSpot.Destroy();
}

// Bot related functions:
// JC: This function was started growing out of hand; needs to be optimized.

simulated function Timer()
{
	local Pawn P;
	local Pawn Victim;
	local Actor HitActor;
	local vector HitLocation, HitNormal;
	
	ForEach RadiusActors( class'Pawn', P, 300 )
	{
		if( P == Instigator )
		{
			Victim = none;
			break;
		}
		else if( P != Instigator )
			Victim = P;
	}
	
	if( Victim != none )
		HitActor = Instigator.Trace( HitLocation, HitNormal, Victim.Location, Instigator.Location, true );
	if( Instigator != none && VSize( Instigator.Location - Location ) > 300 )
	{
		if( ( Victim != none) && HitActor == Victim && Instigator.IsA( 'Bots' ) )
		{
			Instigator.SetRotation( rotator( Location - Instigator.Location ) );
			ResetGrenadeLauncher();
		}
		else if( Instigator.Target != none && VSize( Instigator.Target.Location - Location ) > 500 && !bTrapGrenade )
			ResetGrenadeLauncher();
		else if( Bots( Instigator ).Target != none && bTrapGrenade )
			ResetGrenadeLauncher();
		else if( bTrapGrenade && Region.Zone.bWaterZone )
			ResetGrenadeLauncher();	
		else if( Instigator != none )
		{
			TimerCounter++;
			HitActor = Trace( HitLocation, HitNormal, Instigator.Location, Location, true );
			if(  Instigator != none && ( HitActor != none && HitActor != Instigator ) && TimerCounter > 3 )
			{
				if( VSize( Instigator.Location - GL.DetGrenade.Location ) > 325 )
					ResetGrenadeLauncher();
			}
			else if( TimerCounter >= 6 || Instigator != none && VSize( Instigator.Location - GL.DetGrenade.Location ) > 1500 )
				ResetGrenadeLauncher();
		}
	}
}

//function BaseChange()
//{
//	log(" ******** BASECHANGE CALLED" );
//	log( "Base is: "$Base );
//	log( "Base Texture is: "$Base.Texture );
//	log( "Base SKin is: "$Base.Skin );
//	Texture = ZoneInfo( Base.Texture.EnviromentMap );
//	Skin = Base.Skin;
//}

function ResetGrenadeLauncher()
{
	if( GL != none && GL.DetGrenade != none )
	{
		GL.bDetGrenadeActive = false;
		GL.DetGrenade = none;
		TimerCounter = 0;
		BlowUp( Location );
	}
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if( GL != none )
	{
		GL.bDetGrenadeActive = false;
		GL.DetGrenade = none;
	}
	BlowUp( Location );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if( !Other.bIsPawn )
		HitWall(Normal(Location-Other.Location),Other);
}

defaultproperties
{
     Damage=80.000000
     MomentumTransfer=100000
     LifeSpan=40.000000
     Texture=Texture'UPak.Grenade.Jgrenade2'
     Skin=Texture'UPak.Grenade.Jgrenade2'
     DrawScale=1.750000
     MultiSkins(1)=Texture'UPak.Grenade.Jgrenade2'
     DesiredRotation=(Yaw=2334,Roll=5666)
}
