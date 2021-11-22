//=============================================================================
// GrenadeLauncher.uc
// $Revision: 1 $
//=============================================================================
class GrenadeLauncher expands Weapon;

#exec AUDIO IMPORT FILE="Sounds\grenadelauncher\Bounce1.WAV" NAME="Bounce1" GROUP="GrenadeLauncher"
#exec AUDIO IMPORT FILE="Sounds\grenadelauncher\GrenadeHit.WAV" NAME="GrenadeHit" GROUP="GrenadeLauncher"

#exec AUDIO IMPORT FILE="Sounds\GrenadeLauncher\GrenadeSelect1.WAV" NAME="GrenadeSelect1" GROUP="GrenadeLauncher"
#exec AUDIO IMPORT FILE="Sounds\GrenadeLauncher\GrenadeLoad3.WAV" NAME="GrenadeLoad3" GROUP="GrenadeLauncher"
#exec AUDIO IMPORT FILE="Sounds\GrenadeLauncher\GrenadeShot2.WAV" NAME="GrenadeShot2" GROUP="GrenadeLauncher"
#exec AUDIO IMPORT FILE="Sounds\GrenadeLauncher\GrenadeSet3.WAV" NAME="GrenadeSet3" GROUP="GrenadeLauncher"


var GLDetGrenade DetGrenade;
var PathNode TrapLocation;
var PathNodeIterator pni;

var bool bAltFireOff;
var bool bDetGrenadeActive;
var bool bNoAnimate;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	ProjectileSpeed = class'GLGrenade'.Default.speed;
	AltProjectileSpeed = class'GLDetGrenade'.Default.speed;
}
function float RateSelf( out int bUseAltMode )
{
	bUseAltMode = 0.9;
	return AIRating;
}
function Fire( float Value )
{
	bPointing = True;
	CheckVisibility();
	if( AmmoType.UseAmmo( 1 ) )
		GoToState( 'NormalFire' );
}
function AltFire( float Value )
{
	if( !bDetGrenadeActive && bAltFireOff )
	{
		bPointing=True;
		CheckVisibility();
		if( AmmoType.UseAmmo( 1 ) )
			GoToState( 'AltFiring' );
	}
	else if( DetGrenade != None && !Owner.IsA( 'Bots' ) )
	{
		DetGrenade.BlowUp( DetGrenade.Location + Vect( 0, 0, 1 ) * 16 );
		DetGrenade = None;
		bDetGrenadeActive = False;
		Finish();
	}
}

// ================================================================================================
// AltFiring State
// ================================================================================================

state AltFiring
{
Ignores Fire,AltFire;

	function BeginState()
	{
		local vector FireLocation, StartLoc, X, Y, Z;
		local CampingInfoTimer CIT;
						
		if( bDetGrenadeActive && Owner.IsA( 'Bots' ) )
			GotoState( 'Idle' );
		GetAxes( Pawn( Owner ).ViewRotation, X , Y, Z );
		StartLoc = Owner.Location + CalcDrawOffset(); 
		if( TrapLocation != None )
		{
			if( !Bots( Owner ).bWantsToCamp )
			{
				Owner.SetRotation( rotator( TrapLocation.Location - Owner.Location ) );
				Pawn( Owner ).ViewRotation.Pitch -= 15000;
				DetGrenade = Spawn( class'GLDetGrenade',,'', Pawn( Owner ).Location, Pawn( Owner ).ViewRotation );
				DetGrenade.bTrapGrenade = True;
				CIT = Spawn( class'CampingInfoTimer',,, Location, Rotation );
				CIT.Camper = Bots( Owner );
				CIT.GL = GrenadeLauncher( Bots( Owner ).Weapon );
				CIT.GotoState( 'CampingTracking' );
			}
		}
		else
		{
			FireLocation = StartLoc + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z; 
			Firelocation = StartLoc - 10.78*Z + X * (10 + 8 * FRand());
	
			AdjustedAim = Pawn( Owner ).AdjustToss( AltProjectileSpeed, FireLocation, AimError, True, bAltWarnTarget );	
			if( PlayerPawn( Owner ) != None )
				AdjustedAim = Pawn( Owner ).ViewRotation;

			DetGrenade = Spawn( class 'GLDetGrenade',, '', FireLocation, AdjustedAim );
			DetGrenade.GL = Self;
			PlayAnim( 'Fire', 0.6, 0.05 );
	
			if( !Pawn( Owner ).HeadRegion.Zone.bWaterZone )
				spawn( class'GLFirePuff',, '', FireLocation + vect( 0, 0, 15 ), AdjustedAim );
		}
		Owner.PlaySound( AltFireSound, SLOT_None, 3.0 * Pawn( Owner ).SoundDampening );	
		TrapLocation = None;
		if( PlayerPawn(Owner) != None )
			PlayerPawn( Owner ).ShakeView( ShakeTime, ShakeMag * 5, ShakeVert * 5 ); 
		bDetGrenadeActive = True;
		Pawn( Owner ).bAltFire = 0;
		Disable( 'Tick' );
		SetTimer( 0.5, false );
	}

	function Timer()
	{
		enable( 'Tick' );
	}
	
	function Tick( float DeltaTime )
	{
		if( Pawn( Owner ).bAltFire != 0 && bDetGrenadeActive && IsAnimating() )
		{
			DetGrenade.BlowUp( DetGrenade.Location + Vect( 0, 0, 1 ) * 16 );
			DetGrenade = None;
			bDetGrenadeActive = False;
			bNoAnimate = true;
			Disable( 'Tick' );
		}
	}
							
Begin:
	if( !bNoAnimate && !bAltFireOff )
	{
		bAltFireOff = true;	
		Owner.MakeNoise(Pawn(Owner).SoundDampening );
		if( PlayerPawn(Owner) != None )
			PlayerPawn( Owner ).ShakeView( ShakeTime, ShakeMag * 5, ShakeVert * 5 ); 
		FinishAnim();
		PlaySound( sound'GrenadeLoad3', SLOT_None, 3.0 * Pawn( Owner ).SoundDampening );	

		PlayAnim( 'Reload', 1.85, 0.05 );
		FinishAnim();
		bNoAnimate = false;
	}
	FinishAnim();
	Sleep( 0.2 );
	Finish();
}

// ================================================================================================
// NormalFire State
// ================================================================================================

state NormalFire
{
Ignores Fire,AltFire;

	function BeginState()
	{
		local vector FireLocation, StartLoc, X, Y, Z;
		local GLGrenade g;
	
		GetAxes( Pawn( Owner ).ViewRotation, X, Y, Z );
		StartLoc = Owner.Location + CalcDrawOffset(); 
		Firelocation = StartLoc - 10.78 * Z + X * ( 10 + 8 * FRand() );
		AdjustedAim = Pawn( Owner ).AdjustToss( AltProjectileSpeed, FireLocation, AimError, True, bAltWarnTarget );	

		if( PlayerPawn( Owner ) != None )
			AdjustedAim = Pawn( Owner ).ViewRotation;

		g = Spawn( class 'GLGrenade',, '', FireLocation, AdjustedAim );
		StartLoc = Owner.Location + CalcDrawOffset();
		FireLocation = StartLoc - 10.78 * Z + ( X * 1.5 ) * ( 10 + 8 * FRand() );
		if( !Pawn( Owner ).HeadRegion.Zone.bWaterZone )
			spawn( class'GLFirePuff',, '', FireLocation+ vect( 0, 0, 15 ), AdjustedAim );
		Owner.PlaySound( AltFireSound, SLOT_None, 3.0 * Pawn( Owner ).SoundDampening );	

		if( PlayerPawn( Owner ) != None )
			PlayerPawn( Owner ).ShakeView( ShakeTime, ShakeMag * 5, ShakeVert * 5 );
	}
Begin:
	PlayAnim( 'Fire', 0.6, 0.05);	
	Owner.MakeNoise( Pawn(Owner).SoundDampening );

	if( PlayerPawn( Owner ) != None )
		PlayerPawn( Owner ).Shakeview( ShakeTime, ShakeMag * 5, ShakeVert * 5 );
	FinishAnim();
	PlaySound( sound'GrenadeLoad3', SLOT_None, 3.0 * Pawn( Owner ).SoundDampening );	

	PlayAnim( 'Reload', 1.85, 0.05 );
	FinishAnim();
	Sleep( 0.2 );
	Finish();
	GotoState( 'Idle' );
}




// ================================================================================================
// Idle State
// ================================================================================================

state Idle
{
	function BeginState()
	{
		bAltFireOff = false;
		if( Owner.IsA( 'Bots' ) )
			SetTimer( 3.5, True );
		if( DetGrenade == none && bDetGrenadeActive )
			bDetGrenadeActive = false;		
	}
	function Timer()
	{
		local PathNode PN;
		
		if( Instigator.IsInState( 'Roaming' ) || Instigator.Target == None || Instigator.Enemy == None || Instigator.IsInState( 'Retreating' ) )
		{
			ForEach RadiusActors( class'PathNode', PN, 450 )
				TrapLocation = PN;
				
			if( TrapLocation != None && !bDetGrenadeActive )
			{
				if( FRand() < 0.1 && FRand() < 0.2 && FRand() < 0.2 )
					AltFire( 0.0 );
				else TrapLocation = None;
			}
		}
		else TrapLocation = None;
	}
			
	function AltFire( float Value )
	{
		if( !bDetGrenadeActive )
		{
			bPointing=True;
			CheckVisibility();
			if( AmmoType.UseAmmo( 1 ) )
			{
				GoToState( 'AltFiring' );
				bNoAnimate = false;
			}
		}
		else if( DetGrenade != None && !Owner.IsA( 'Bots' ) )
		{
            	Owner.PlaySound( sound'GrenadeSet3' );
			DetGrenade.BlowUp( DetGrenade.Location + Vect( 0, 0, 1 ) * 16 );
			bDetGrenadeActive = False;
			DetGrenade = None;
			bDetGrenadeActive = False;
			bNoAnimate = true;
		}
	}
	
Begin:
	if( Pawn( Owner ).bAltFire != 0 )
		AltFire( 0.0 );

	bPointing = False;
	if( AmmoType.AmmoAmount <= 0 ) 
		Pawn( Owner ).SwitchToBestWeapon();  

	if( VSize( Pawn( Owner ).Velocity ) > 20 )
		PlayAnim( 'Sway', 0.05 );
	else PlayAnim( 'Still' );
}



// Finish a firing sequence
function Finish()
{
	if( bChangeWeapon )
	{
		GotoState( 'DownWeapon' );
		return;
	}
	if( PlayerPawn(Owner) == None )
	{
		//bFireMem = false;
		//bAltFireMem = false;
		if( AmmoType.AmmoAmount<=0 )
		{
			Pawn(Owner).StopFiring();
			Pawn(Owner).SwitchToBestWeapon();
			if( bChangeWeapon )
			{
				GotoState( 'DownWeapon' );
			}
		}
		else if( ( Pawn( Owner ).bFire != 0) && FRand() < RefireRate && !bDetGrenadeActive )
			Fire( 0 );
		else if( ( Pawn( Owner ).bAltFire != 0 && FRand() < AltRefireRate ) )
			AltFire( 0 );		 
		else 
		{
			Pawn( Owner ).StopFiring();
			GotoState( 'Idle' );
		}
		return;
	}
	if( ( AmmoType.AmmoAmount<=0 ) || ( Pawn(Owner).Weapon != self ) )
		GotoState( 'Idle' );
	else 
	{
		Pawn( Owner ).StopFiring();
		GotoState( 'Idle' );
	}
}

defaultproperties
{
     AmmoName=Class'UPak.GLAmmo'
     PickupAmmoCount=25
     bWarnTarget=True
     bAltWarnTarget=True
     bSplashDamage=True
     ProjectileClass=Class'UPak.GLGrenade'
     AltProjectileClass=Class'UPak.GLDetGrenade'
     shakemag=350.000000
     shaketime=0.200000
     shakevert=7.500000
     AIRating=0.700000
     RefireRate=0.200000
     AltRefireRate=0.200000
     FireSound=Sound'UPak.GrenadeLauncher.GrenadeShot2'
     AltFireSound=Sound'UPak.GrenadeLauncher.GrenadeShot2'
     SelectSound=Sound'UPak.GrenadeLauncher.GrenadeSelect1'
     AutoSwitchPriority=5
     InventoryGroup=4
     PickupMessage="You got the GrenadeLauncher."
     ItemName="GrenadeLauncher"
     PlayerViewOffset=(X=3.500000,Y=-1.800000,Z=-2.000000)
     PlayerViewMesh=LodMesh'UPak.GL1st'
     BobDamping=0.985000
     PickupViewMesh=LodMesh'UPak.GLpickup'
     ThirdPersonMesh=LodMesh'UPak.GL3rd'
     PickupSound=Sound'UnrealShare.Pickups.WeaponPickup'
     Mesh=LodMesh'UPak.GLpickup'
     AmbientGlow=15
     bNoSmooth=False
     CollisionRadius=21.000000
     CollisionHeight=16.000000
}
