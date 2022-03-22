//=============================================================================
// InventorySpot.
//=============================================================================
class InventorySpot extends NavigationPoint
	nousercreate
	native;

cpptext
{
	AInventorySpot() {}
	UBOOL IsValidOnImport() { return FALSE; }
	UBOOL IsInventorySpot() const {	return TRUE; }
	class AInventory* GetMarkedItem() const { return markedItem; }
}

var Inventory markedItem;

// Kill off any unused inventoryspots.
function NotifyPathDefine( bool bPreNotify )
{
	if( bPreNotify && (markedItem==None || markedItem.bDeleteMe) )
		Destroy();
}

defaultproperties
{
	CollisionRadius=+00020.000000
	CollisionHeight=+00040.000000
	bCollideWhenPlacing=False
	bHiddenEd=true
	bEndPointOnly=true
	bNoStrafeTo=true
}
