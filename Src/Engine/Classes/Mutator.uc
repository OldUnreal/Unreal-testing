//=============================================================================
// Mutator.
// called by the IsRelevant() function of DeathMatchPlus
// by adding new mutators, you can change actors in the level without requiring
// a new game class.  Multiple mutators can be linked together.
//=============================================================================
class Mutator expands Info
	NoUserCreate;

var Mutator NextMutator;
var class<Weapon> DefaultWeapon;

event PreBeginPlay()
{
	// Don't call Actor PreBeginPlay()
}

// return what should replace the default weapon
// mutators further down the list override earlier mutators
function Class<Weapon> MutatedDefaultWeapon()
{
	local Class<Weapon> W;

	if ( NextMutator != None )
	{
		W = NextMutator.MutatedDefaultWeapon();
		if ( W == Level.Game.DefaultWeapon )
			W = MyDefaultWeapon();
	}
	else
		W = MyDefaultWeapon();
	return W;
}

function Class<Weapon> MyDefaultWeapon()
{
	if ( DefaultWeapon != None )
		return DefaultWeapon;
	else
		return Level.Game.DefaultWeapon;
}

function AddMutator(Mutator M)
{
	if ( NextMutator == None )
		NextMutator = M;
	else
		NextMutator.AddMutator(M);
}

/* ReplaceWith()
Call this function to replace an actor Other with an actor of aClass.
*/
function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
	{
		A = Other.Spawn(aClass,,Other.Tag,,,None);
		if ( A != None )
		{
			if ( Other.IsA('Inventory') && Inventory(Other).myMarker != None )
			{
				Inventory(Other).MyMarker.markedItem = Inventory(A);
				if ( Inventory(A) != None )
					Inventory(A).myMarker = Inventory(Other).myMarker;
				Inventory(Other).myMarker = None;
			}
			A.event = Other.event;
			A.tag = Other.tag;
			return true;
		}
	}
	return false;
}

function bool IsRelevant(Actor Other, out byte bSuperRelevant)
{
	local bool bResult;

	bResult = CheckReplacement(Other, bSuperRelevant);

	if ( bResult && (NextMutator != None) )
		bResult = NextMutator.IsRelevant(Other, bSuperRelevant);

	return bResult;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	return true;
}

// Allow mutator to optionally save/load travel info (must have bTravel=true).
function PreServerTravel()
{
	Level.Game.SaveTravelInventory(Self,string(Class.Name));
}
function PostServerTravel()
{
	if( Level.Game.LoadTravelInventory(Self,string(Class.Name)) )
		Level.Game.DeleteTravelInventory(string(Class.Name),false);
}
