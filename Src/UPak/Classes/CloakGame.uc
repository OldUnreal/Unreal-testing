//=============================================================================
// CloakGame.
//=============================================================================
class CloakGame expands UPakGame;

var Pawn CloakedPawn;
var() int SuicidePenalty;

function AddDefaultInventory( pawn PlayerPawn )
{
	local Weapon newWeapon;
	local Cloak CloakItem;
	
	PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ * PlayerJumpZScaling();
	 
	if( PlayerPawn.IsA('Spectator') )
		return;

	// Spawn default weapon.
	if( DefaultWeapon==None || PlayerPawn.FindInventoryType(DefaultWeapon)!=None )
		return;

	newWeapon = Spawn(BaseMutator.MutatedDefaultWeapon());
	if( newWeapon != None )
	{
		newWeapon.Instigator = PlayerPawn;
		newWeapon.BecomeItem();
		PlayerPawn.AddInventory(newWeapon);
		newWeapon.BringUp();
		newWeapon.GiveAmmo(PlayerPawn);
		newWeapon.SetSwitchPriority(PlayerPawn);
		newWeapon.WeaponSet(PlayerPawn);
	}

	if( PlayerPawn == CloakedPawn )
	{
		CloakItem = spawn( class'Cloak', PlayerPawn,, Location, Rotation );
		CloakItem.bHeldItem = true;
		CloakItem.GiveTo( PlayerPawn );
		//aPickup.Activate();
		PlayerPawn.SelectedItem = CloakItem;
		CloakItem.PickupFunction( PlayerPawn );
		CloakItem.Activate();
	}	
}

function Killed(pawn killer, pawn Other, name damageType)
{
	Other.AmbientGlow = 0;
	Other.LightType = LT_None;
	Other.DamageScaling = 1.0;
	Other.bUnLit = false;

	if( ( CloakedPawn == Other ) || ( CloakedPawn == None ) )
	{
		if( (killer == None) || (killer == Other) || (killer.Health <= 0) )
		{
			if( ( killer == CloakedPawn ) && ( CloakedPawn == Other ) )
				CloakedPawn.PlayerReplicationInfo.Score -= SuicidePenalty;
			CloakedPawn = None;
		} 
		else if( killer != CloakedPawn )
		{
			DestroyCloaks();
			CloakNewPawn( killer );
		}	
	}
	Super.Killed( killer, Other, damageType );
}

function DestroyCloaks()
{
	local Cloak C;
	
	foreach allactors( class'Cloak', C )
	{
		C.GotoState( 'Deactivated' );
		C.Charge = 0;
	}
}

function CloakNewPawn( pawn newCloakedPawn )
{
	CloakedPawn = newCloakedPawn;
	AdjustHUDS();
}

function AdjustHUDS()
{
	local PlayerPawn P;
	
	foreach allactors( class'PlayerPawn', P )
	{
		CloakMatchHUD( P.MyHUD ).Target = CloakedPawn;
	}
}

defaultproperties
{
}
