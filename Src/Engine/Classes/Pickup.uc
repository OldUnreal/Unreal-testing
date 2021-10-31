//=============================================================================
// Pickup items.
//=============================================================================
class Pickup extends Inventory
			abstract;

var inventory Inv;
var travel int NumCopies;
var() bool bCanHaveMultipleCopies;  // if player can possess more than one of this
var() bool bCanActivate;			// Item can be selected and activated
var() localized String ExpireMessage; // Messages shown when pickup charge runs out
var() bool bAutoActivate;			// Should automatically activate when picked up.

replication
{
	// Things the server should send to the client.
	reliable if ( Role==ROLE_Authority && bNetOwner )
		NumCopies;
}

function TravelPostAccept()
{
	Super.TravelPostAccept();
	PickupFunction(Pawn(Owner));
	EstablishInventoryConnection();
}

function EstablishInventoryConnection(); 

//
// Advanced function which lets existing items in a pawn's inventory
// prevent the pawn from picking something up. Return true to abort pickup
// or if item handles the pickup
function bool HandlePickupQuery( inventory Item )
{
	if (item.class == class)
	{
		if (bCanHaveMultipleCopies)
		{   // for items like Artifact
			NumCopies++;
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
			Item.PlaySound(Item.PickupSound,,2.0);
			Item.SetRespawn();
		}
		else if ( bDisplayableInv )
		{
			if ( Charge<Item.Charge )
				Charge= Item.Charge;
			Pawn(Owner).ClientMessage(Item.PickupMessage, 'Pickup');
			Item.PlaySound(Item.PickupSound,,2.0);
			Item.SetReSpawn();
		}
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

function float UseCharge(float Amount);

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;

	Copy = Super.SpawnCopy(Other);
	Copy.Charge = Charge;
	return Copy;
}

auto state Pickup
{
	function Touch( actor Other )
	{
		local Inventory Copy;
		if ( ValidTouch(Other) )
		{
			Pawn(Other).ClientMessage(PickupMessage, 'Pickup');	// add to inventory and run pickupfunction
			PlaySound (PickupSound,,2.0);
			Copy = SpawnCopy(Pawn(Other));
			if (Level.Game.LocalLog != None)
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			if (Level.Game.WorldLog != None)
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			if (bActivatable && Pawn(Other).SelectedItem==None)
				Pawn(Other).SelectedItem=Copy;
			if (bActivatable && bAutoActivate && Pawn(Other).bAutoActivate) Copy.Activate();
			Pickup(Copy).PickupFunction(Pawn(Other));
		}
	}

	function BeginState()
	{
		Super.BeginState();
		NumCopies = 0;
	}
}

function PickupFunction(Pawn Other)
{
}

//
// This is called when a usable inventory item has used up it's charge.
//
function UsedUp()
{
	if ( Pawn(Owner) != None )
	{
		bActivatable = false;
		Pawn(Owner).ClientMessage(ExpireMessage);
	}
	Owner.PlaySound(DeactivateSound);
	Destroy();
}

state Activated
{
	function Activate()
	{
		if ( (Pawn(Owner) != None) && Pawn(Owner).bAutoActivate
		&& bAutoActivate && (Charge>0) )
			return;

		Super.Activate();
	}
}

event float BotDesireability(Pawn Bot)
{
	local Pickup I;

	if ( bCanHaveMultipleCopies )
	{
		I = Pickup(Bot.FindInventoryType(Class));
		if ( I==None )
			Return MaxDesireability;
		else if ( I.NumCopies>3 )
			Return -1;
		Return MaxDesireability/float(Max(1,I.NumCopies));
	}
	Return Super.BotDesireability(Bot);
}

defaultproperties
{
	bRotatingPickup=False
}
