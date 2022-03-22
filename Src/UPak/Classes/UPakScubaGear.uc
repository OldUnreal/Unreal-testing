//=============================================================================
// UPakScubaGear.
//=============================================================================
class UPakScubaGear expands Pickup;

var vector X,Y,Z;
var Actor EffectsActor;
var bool bWarningSignaled, bUseRechargedMessage;
var localized string RechargedMessage;
var localized string LowOxygenMessage;

function inventory PrioritizeArmor( int Damage, name DamageType, vector HitLocation )
{
	if( DamageType == 'Breathe' ) 
	{
		if ( Pawn( Owner )!= None && IsInState( 'Activated' )
			&& !Pawn( Owner ).FootRegion.Zone.bPainZone ) Pawn( Owner ).PainTime = 12;
		GotoState( 'Deactivated' );
	}
	else if( DamageType == 'Drowned' && Damage == 0 ) 
	{
		GoToState( 'Activated' );
	}
	if( DamageType == 'Drowned' )
	{
		NextArmor = None;
		Return Self;
	}
	return Super.PrioritizeArmor( Damage, DamageType, HitLocation );
}

function Activate()
{
	if (Charge > 0 && Pawn(Owner).HeadRegion.Zone.bWaterZone && !Pawn(Owner).FootRegion.Zone.bPainZone)
		Super.Activate();
	else if (!IsInState('Activated'))
		bActive = false; // travel value should be reset if activation is not done
}

function UsedUp()
{
	local Pawn OwnerPawn;

	OwnerPawn = Pawn(Owner);
	if (Charge <= 0 && OwnerPawn != none && 0 < OwnerPawn.PainTime && OwnerPawn.PainTime < 15 &&
		!OwnerPawn.FootRegion.Zone.bPainZone && OwnerPawn.HeadRegion.Zone.bWaterZone)
	{
		OwnerPawn.PainTime = 15;
	}
	GotoState( 'DeActivated' );
}

function bool UseSpecialEffectsActor()
{
	return Class == class'UPakScubaGear';
}

function EnableInventoryEffects()
{
	local Triggers SoundActor;

	if (!UseSpecialEffectsActor())
		EffectsActor = Owner;
	else if (EffectsActor == none || EffectsActor.bDeleteMe)
	{
		// trying to find a sound source of other scuba gear
		foreach Owner.ChildActors(class'Triggers', SoundActor)
			if (SoundActor.Tag == 'SCUBAGear_EffectsActor') // name of the tag intentionally matches the one for UnrealShare.SCUBAGear
			{
				EffectsActor = SoundActor; // EffectsActor is shared between different scuba gears
				SetScubaAmbientSound();
				return;
			}

		EffectsActor = Spawn(class'Triggers', Owner, 'SCUBAGear_EffectsActor', Owner.Location);
		if (EffectsActor != none)
		{
			EffectsActor.SetCollision(false);
			EffectsActor.SetPhysics(PHYS_Trailer);
			EffectsActor.RemoteRole = ROLE_SimulatedProxy;
			EffectsActor.SoundRadius = Owner.default.SoundRadius;
			EffectsActor.SoundVolume = Owner.default.SoundVolume;
		}
		else
			EffectsActor = Owner;
	}

	SetScubaAmbientSound();
}

function SetScubaAmbientSound()
{
	if (EffectsActor == none || Pawn(Owner) == none)
		return;
	if (EffectsActor != Owner && (Owner.AmbientSound == ActivateSound || Owner.AmbientSound == RespawnSound))
		EffectsActor.AmbientSound = none;
	else if (Pawn(Owner).HeadRegion.Zone.bWaterZone)
		EffectsActor.AmbientSound = ActivateSound;
	else
		EffectsActor.AmbientSound = RespawnSound;
}

function DisableInventoryEffects()
{
	if (Owner != none && (!UseSpecialEffectsActor() || EffectsActor == Owner))
		Owner.AmbientSound = none;
	if (EffectsActor != none && EffectsActor != Owner)
		EffectsActor.Destroy();
	EffectsActor = none;
}

state Sleeping
{
	ignores Touch;

Begin:
	Sleep(ReSpawnTime);
	if (RespawnSound != sound'UnrealShare.Pickups.Scubal2')
		PlaySound(RespawnSound);
	Sleep(Level.Game.PlaySpawnEffect(self));
	GoToState('Pickup');
}

state Activated
{
	function EndState()
	{
		if (Owner != none)
			Owner.PlaySound(DeactivateSound);
		DisableInventoryEffects();
		bActive = false;		
	}

	function Timer()
	{
		local float LocalTime;
		local Bubble1 b;
		local Pawn OwnerPawn;

		OwnerPawn = Pawn(Owner);
		if (OwnerPawn == none)
		{
			UsedUp();
			return;
		}
		Charge -= 1;
		if( Charge<-0 ) 
		{
			OwnerPawn.ClientMessage( ExpireMessage );
			UsedUp();	
		}
		if (UseSpecialEffectsActor() && Charge > 0)
			EnableInventoryEffects();
		LocalTime += 0.1;
		LocalTime = LocalTime - int( LocalTime );
		if (OwnerPawn.HeadRegion.Zone.bWaterZone && !OwnerPawn.FootRegion.Zone.bPainZone) 
		{
			if (0 < OwnerPawn.PainTime && OwnerPawn.PainTime < OwnerPawn.UnderWaterTime)
			{
				OwnerPawn.PainTime = FMin(OwnerPawn.PainTime + 0.1, OwnerPawn.UnderWaterTime);
				if (OwnerPawn.PainTime < 1)
				{
					Charge -= (1 - OwnerPawn.PainTime) * 10;
					OwnerPawn.PainTime = 1;
				}
			}

			if( FRand() < LocalTime )
			{
				GetAxes(OwnerPawn.ViewRotation, X, Y, Z );	
				b = Spawn( class'Bubble1', Owner, '', OwnerPawn.Location
					+ 20.0 * X - ( FRand() * 6 + 5 ) * Y - ( FRand() * 6 + 5 ) * Z );
				if( b != None )
				{
					b.DrawScale = FRand() * 0.1 + 0.05;
				}
			}
			if( FRand() < LocalTime )
			{
				GetAxes(OwnerPawn.ViewRotation, X, Y, Z);	
				b = Spawn( class'Bubble1', Owner, '', OwnerPawn.Location
					+ 20.0 * X + ( FRand() * 6 + 5 ) * Y - ( FRand() * 6 + 5 ) * Z );
				if( b != None )
				{
					b.DrawScale = FRand() * 0.1 + 0.05;
				}
			}
		}
		if( Charge < ( Default.Charge * 0.25 ) && !bWarningSignaled )
		{
			bWarningSignaled = True;
			OwnerPawn.ClientMessage( LowOxygenMessage );
		}
	}
Begin:
	if (Owner == none)
		GotoState('');
	if (Pawn(Owner).HeadRegion.Zone.bWaterZone && !Pawn(Owner).FootRegion.Zone.bPainZone)
	{
		SetTimer(0.1, true);
		EnableInventoryEffects();
	}
}

state DeActivated
{
	function Timer()
	{
		if( Pawn( Owner ) == None )
		{
			UsedUp();
			return;
		}
		if( Charge < Default.Charge && !Pawn( Owner ).HeadRegion.Zone.bWaterZone )
			Charge = Min(Default.Charge, Charge + 5);
		else if( Charge == Default.Charge && bUseRechargedMessage )
		{
			Pawn( Owner ).ClientMessage( RechargedMessage );
			bUseRechargedMessage = false;
			Disable( 'Timer' );
		}
	}

Begin:

	bWarningSignaled = False;
	
	if( Owner == None )
		GotoState( '' );
	if( Charge < Default.Charge )
	{
		SetTimer( 0.05,True );
		if( Charge < Default.Charge - 20 )
			bUseRechargedMessage = true;
	}
}

defaultproperties
{
	RechargedMessage="ScubaGear fully recharged."
	LowOxygenMessage="Oxygen supply critically low"
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up the SCUBA gear"
	ItemName="Marine SCUBAGear"
	RespawnTime=20.000000
	PickupViewMesh=LodMesh'UnrealShare.Scuba'
	Charge=1250
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ActivateSound=Sound'UnrealShare.Pickups.Scubal1'
	DeActivateSound=Sound'UnrealShare.Pickups.Scubada1'
	RespawnSound=Sound'UnrealShare.Pickups.Scubal2'
	Icon=Texture'UnrealShare.Icons.I_Scuba'
	M_Deactivated="deactivated... Recharging."
	Mesh=LodMesh'UnrealShare.Scuba'
	CollisionRadius=18.000000
	CollisionHeight=15.000000
}
