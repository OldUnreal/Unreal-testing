//=============================================================================
// DuskFallsGame.
//
// no default weapon
//=============================================================================

class DuskFallsGame expands UPakSinglePlayer;

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local PlayerPawn NewPlayer;
	NewPlayer = Super.Login( Portal, Options, Error, SpawnClass );
	if ( NewPlayer != None && NewPlayer.Health == NewPlayer.Default.Health && !bIsSavedGame )
	{
		NewPlayer.PlayerRestartState = 'PlayerWaking';
		NewPlayer.ViewRotation.Pitch = 16384;
		NewPlayer.Health = 100;
	}
	return NewPlayer;
}

function bool RestartPlayer( pawn aPlayer )
{
	local bool result;

	result = Super.RestartPlayer(aPlayer);
	if ( result )
	{
		aPlayer.Health = 100;
		aPlayer.ViewRotation.Pitch = 16384;
	}
	return result;
}

/*
function int ReduceDamage( int Damage, name DamageType, pawn injured, pawn instigatedBy )
{
	// no friendly fire always in coop
	if ( (instigatedBy != None) 
		&& instigatedBy.bIsPlayer && injured.bIsPlayer && (instigatedBy != injured) )
		return 0;

	return Super.ReduceDamage( Damage, DamageType, injured, instigatedBy );
}
*/

function AddDefaultInventory( pawn aPlayer )
{
	local Weapon aWeapon;
	local Pickup aPickup;

	log( Self $ " AddDefaultInventory( " $ aPlayer $ ")" );
	Super.AddDefaultInventory( aPlayer );
	if( !aPlayer.IsA( 'Spectator' ) )
	{
		if( aPlayer.FindInventoryType( class'DispersionPistol' ) == None )
		{
			aWeapon = Spawn( class'DispersionPistol',,, Location );
			if( aWeapon != None )
			{
				//aWeapon.BecomeItem();
				//aWeapon.Instigator = aPlayer;
				//aPlayer.AddInventory( aWeapon );
				//aWeapon.BringUp();
				aWeapon.bHeldItem = true;
				aWeapon.GiveTo( aPlayer );
				aWeapon.GiveAmmo( aPlayer );
				aWeapon.SetSwitchPriority( aPlayer );
				aWeapon.WeaponSet( aPlayer );
			}
		}
		if( aPlayer.FindInventoryType( class'Translator' ) == None )
		{
			aPickup = Spawn( class'Translator',,, Location );
			if( aPickup != None )
			{
				aPickup.bHeldItem = true;
				aPickup.GiveTo( aPlayer );
				//aPickup.Activate();
				aPlayer.SelectedItem = aPickup;
				aPickup.PickupFunction( aPlayer );
			}
		}
		if( aPlayer.FindInventoryType( class'UPakScubaGear' ) == None )
		{
			aPickup = Spawn( class'UPakScubaGear',,, Location );
			if( aPickup != None )
			{
				aPickup.bHeldItem = true;
				aPickup.GiveTo( aPlayer );
				aPlayer.SelectedItem = aPickup;
				aPickup.PickupFunction( aPlayer );
			}
		}
	}
}

/*
function bool PickupQuery( Pawn Other, Inventory item )
{
	if( item.IsA('DispersionPistol') )
		DefaultWeapon = class'DispersionPistol';
	return Super.PickupQuery( Other, item );
}
*/

defaultproperties
{
     DefaultWeapon=None
}
