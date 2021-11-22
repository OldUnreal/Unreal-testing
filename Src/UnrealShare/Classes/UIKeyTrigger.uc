//=================================================
// Authorizer: This Trigger can replace
// KeyMover (as base I use KeyMover avidible
// form http://chimeric.beyondunreal.com/tutorials/tut11.html).
//=================================================
// by Raven
// http://turniej.unreal.pl
// http://ued2.prv.pl
// http://skaarj.unreal.pl
// for The Chosen One SP mod
//=================================================
class UIKeyTrigger extends Trigger;

#exec TEXTURE IMPORT NAME=Authorizer FILE="Textures\Icons\auth.bmp" GROUP=Icons LODSET=2

var() class<inventory> KeyClass;
var() bool bDestroyKey;
var() bool bCheckKeyOnceOnly;
var() bool bShowSuccessMessage;
var() bool bShowFailtureMessage;
var() localized String SuccessMessage;
var() localized String FailtureMessage;
var bool bWasOpened;

function Touch( actor Other )
{

	local Inventory key;
	local actor A;

	if (Other.IsA('Pawn') && KeyClass != none && !bWasOpened)

	{
		key = Pawn(Other).FindInventoryType(KeyClass);


		if (key != none && Event != '' && !bCheckKeyOnceOnly)

			foreach AllActors( class 'Actor', A, Event )

			A.Trigger( Other, Other.Instigator );


		if (bDestroyKey)
			if (!bWasOpened) Pawn(Other).DeleteInventory(key);

		if (bCheckKeyOnceOnly)
			bWasOpened=true;

	}
	if (bWasOpened && Event != '')

		foreach AllActors( class 'Actor', A, Event )

		A.Trigger( Other, Other.Instigator );

	if (bShowSuccessMessage && PlayerPawn(Other) != none)

		PlayerPawn(Other).ClientMessage(SuccessMessage);

	if (bShowFailtureMessage && !bWasOpened)

		PlayerPawn(Other).ClientMessage(FailtureMessage);

}

defaultproperties
{
	bShowFailtureMessage=True
	SuccessMessage="Access granded."
	FailtureMessage="You need a key to open this door."
	Texture=Texture'UnrealShare.Icons.Authorizer'
	bCheckKeyOnceOnly=true
}
