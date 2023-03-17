//=============================================================================
// ArbitItem - Arbitrary Item spawner
// (c) }TCP{Wolf aka Mia_The_Chaotic 2005
// TODO:
//     - AdjustedSpawnTime: done 18.09.2005
//     - Capacity: done 18.09.2005
//     - Random: done 18.09.2005
//     - Have items fall to GROUND (Krull) since some items look stupid when
//       spawned one after another (Belt floats in air, armor on ground)
//       done 18.08.2007
//     - Tag: hmm... tag is set on spawn, what about event?
//     - 04.010.2007 - build 3 - findReplacedItem was buggy
//           THANKS KRULL would probably not have found that without you lol
//=============================================================================

class ArbitItem expands Pickup; //Actor;
// subclassing pickup for "MyMarker" (Bot support)
//var InventorySpot MyMarker;

// Debug
var() bool bDebug;	// logs some extra stuff if true

// CFG
var() config class<Inventory> SpawnItem[10]; // what to spawn
var() config byte SpawnItemFallsToGround[10];	// if true(1), spawned item will fall to ground instead of float in the air
var() config float AdjustedSpawnTime;        // how much faster/slower to spawn stuff
var int numItems;                            // number of actors in spawnlist (dynamically filled)
var int nextItem;                            // next Actor in list to spawn
var() config int Capacity_max;               // if greater than 0, there is a capacity limit
var int Capacity;                            // current capacity remaining
var bool bCapacity;                          // capacity feature on off
var() config bool bRandomize;                // if true, next item will always be picked randomely

// Runtime reference
var Inventory currentItem;	// reference to currently spawned item

// other runtime variables
var float SleepTime;	// time in seconds until the next item is spawned


event PostBeginPlay()
{
// make invis if not debugging
	if (!bDebug)
	{
		DrawType=DT_None;
		//default.DrawType=DT_None;
	}

	Super(Actor).PostbeginPlay(); // don't execute Pickup.PostBeginPlay();
//Super.PostBeginPlay();

// check capacity feature
	if (Capacity_max > 0)
	{
		bCapacity = true;
		Capacity = Capacity_max;
	}
}


event destroyed()
{
	if (bDebug) LOG(self$" DESTROYED!!!!");
	if (currentItem != None) currentItem.destroy();
	if (MyMarker != None) MyMarker.markedItem = None;
}



/*
  STARTING STATE - FIRST WE HAVE TO SEE IF ITEMS WE ARE
  SPAWNING ARE REPLACED.
  THUS, WE HAVE TO ADJUST THE SPAWNLIST...
*/
auto state CheckReplacement
{
	function BeginState()
	{
		local int i;
		local Inventory what;

		// destroy any other actors inside a 2-mark radius (safeguard)
		foreach RadiusActors(Class'Inventory',what,2,,true)
		{
			if (what != self)
			{
				if (bDebug) log("safeguard destroys "$what,'ARBITITEM');
				what.destroy();
			}
		}

		// looks like 224 has a problem with default properties... this is for debugging
		// commented out in release
		// DEBUG BEGIN
		/*SpawnItem[0]=class'UnrealI.ASMD';
		SpawnItem[1]=class'UnrealShare.Armor';
		SpawnItem[2]=class'UnrealShare.SuperHealth';*/
		// DEBUG END

		for (i=0; i<ArrayCount(SpawnItem); i++)
		{
			if (bDebug) log("CheckReplacement state - check item = "$i$" - "$SpawnItem[i],'ARBITITEM');
			if (SpawnItem[i]!=None)
				numItems = i+1;
		}
		nextItem = 0;

		if (bDebug) log("CheckReplacement state - numItems = "$numItems,'ARBITITEM');
		if (bDebug) logSpawnList();
		if (numItems <= 0)
		{
			log(self$" without any Items to spawn - self-terminating!",'ARBITITEM');
			destroy();
			return;
		}

		// check if stuff gets replaced
		if (bDebug) log("Starting replacement check on items...",'ARBITITEM');
		for (i=0; i< numItems; i++)
		{
			// spawn item
			currentItem = spawn(SpawnItem[i], Owner, Tag, Location, Rotation);
			//if (currentItem != None) Level.Game.IsRelevant(currentItem);
			if (bDebug) log("CURRENT ITEM ===== "$i@CurrentItem,'ARBITITEM');
			if ((currentItem == None) || (currentItem.bDeleteMe))
			{
				// item was replaced
				currentItem = findReplacedItem();
				if (currentItem == none) // item was either destroyed or replaced by a non-Item
					removeItem(i);
				else // enter the class of the new item in the original's place
					SpawnItem[i] = currentItem.class;
			}
			if (currentItem != None) currentItem.destroy();
		}
		if (bDebug) log("Completed replacement check on items...",'ARBITITEM');

		// check again if all items were replaced...
		if (numItems <= 0)
		{
			log(self$" had all its Items replaced and is now without any Items to spawn - self-terminating!");
			destroy();
			return;
		}
		if (bDebug) log(self$" has "$numItems$" after replacement check...",'ARBITITEM');
		if (bDebug) logSpawnList();
		nextItem = 0;


		if (currentItem != None) currentItem.destroy();
		if (bDebug) log("GOTOSTATE Pickup!",'ARBITITEM');
		gotoState('Pickup');
	}

	/*
		function EndState()
		{
			log("Endstate CHECK");
		}
	*/
} // end state checkreplacement



// aid function - tries to determine what item the last spawned has
// been replaced with
function Inventory findReplacedItem()
{
	local Inventory what;

	if (bDebug) log("Trying to find replaced item...",'ARBITITEM');

	foreach RadiusActors(Class'Inventory',what,2,,true)
	{
		if( what != self )
			break;
	}
	return what;
}


function removeItem(int which)
{
	local int i;

	if (bDebug) log("Removing item "$which$" ("$SpawnItem[which]$") from list...",'ARBITITEM');
	for (i=which; i<numItems-1; i++)
		SpawnItem[i] = SpawnItem[i+1];

	SpawnItem[--numItems] = None;
}


// simply log entire list
function logSpawnList()
{
	local int i;
	log(self$" has spawnlist:",'ARBITITEM');
	for (i=0; i<arrayCount(SpawnItem); i++)
		log(i$" "$SpawnItem[i],'ARBITITEM');
}



/*
	STATE Item: Spawn item until it has been picked up.
*/
state Pickup
{
	function BeginState()
	{
		if (bDebug) log("BeginState pickup - spawn item "$nextItem$"="$SpawnItem[nextItem],'ARBITITEM');
		// spawn next item
		currentItem = spawn(SpawnItem[nextItem], Owner, Tag, Location, Rotation);
		if (bCapacity) Capacity--;
		if (currentItem == none) log("Spawn failure of "$nextItem$" - "$SpawnItem[nextItem]$"!",'ARBITITEM');
		else
		{
			Level.Game.PlaySpawnEffect(currentItem);
			currentItem.Event = Event; // should we?
			// Physics? implemented for Krull at 18.08.2007
			if (SpawnItemFallsToGround[nextItem]>0)
				currentItem.SetPhysics(Phys_Falling);
		}

		// if it is a weapon, make it so it is always picked up when touched
		if (currentItem.IsA('Weapon'))
			Weapon(currentItem).bWeaponStay = false;
		// use Item's properties to adjust self properly
		SetCollisionSize(currentItem.CollisionRadius, currentItem.CollisionHeight);

		// bot support
		if (MyMarker != None)
		{
			currentItem.MyMarker = MyMarker;
			MyMarker.markedItem = currentItem;
		}

		if (bDebug) log("PICKUP! "$CollisionRadius$" "$CollisionHeight,'ARBITITEM');
		// set 2ndary check...
		SetTimer(getRespawnTime()*0.2, true);
		if (bRandomize)
		{
			nextItem = rand(numItems);
			if (bDebug) log("random -> next="$nextItem,'ARBITITEM');
		}
		else
		{
			nextItem++;
			if (nextItem >= numItems) nextItem = 0;
		}

		Enable('Touch');
		Enable('Timer');
	}


	function EndState()
	{
		disable('Touch'); // no effect?
		disable('Timer');
	}


	// secondary constant check if item was taken
	function Timer()
	{
		if (bDebug) log("timer...",'ARBITITEM');
		if (!currentItem.isInState('Sleeping')) return;
		ItemTaken();
	}


	// triggered when somebody touches (the Item currently spawned)
	event Touch( Actor Other )
	{
		if (bDebug) log(Other$" touched...",'ARBITITEM');
		if (bDebug) log("state of currentItem = "$currentItem.getStateName(),'ARBITITEM');
		if (!Other.IsA('Pawn')) return; // simple check to deter other types of touch
		// would  if (!Other.ValidTouch(currentItem))  work?
		if (!currentItem.isInState('Sleeping')) return; // the item was NOT taken...
		ItemTaken();
	}


	function ItemTaken()
	{
		// item was taken...
		// sleep the amount of time the NEXT item to be spawned takes to spawn
		SleepTime = getRespawnTime();
		if (bDebug) log("Item taken... now going to sleep "$SleepTime,'ARBITITEM');
		currentItem.destroy();
		if (MyMarker != None) MyMarker.markedItem = None;
		if ((bCapacity) && (Capacity <= 0))
		{
			if (bDebug) log(self$" capacity zero... disabling...");
			self.destroy();
			return;
		}
		gotoState('Sleeping');
	}
}



/*
 STATE SLEEPING:
 inventory which is lying around in the map awaiting being picked up is in the
 state "sleeping". Thus, I found it fitting the spawner should be in exactly
 that state until the next item is supposed to become available
*/
state Sleeping
{
	function BeginState()
	{
		if (bDebug) log(self$" BeginState SLEEPING",'ARBITITEM');
	}

	function EndState()
	{
		if (bDebug) log(self$" EndState SLEEPING",'ARBITITEM');
	}

Begin:
	Sleep(SleepTime);	// the amount of sleeptime was determined in state Pickup
	gotoState('Pickup');
}



// Bot support
event float BotDesireability( pawn Bot )
{
	local float result;
	if (currentItem == None) result = -1;
	else result = (currentItem.BotDesireability(Bot));
	if (bDebug) log(self$" was desired by "$Bot$" - currentItem="$currentItem$" result="$result,'ARBITITEM');

	return result;
}


// things to disable from normal pickup
event Touch( Actor Other ) {}	// don't do anything outside of state pickup

/*
state Pickup
{
	function BeginState() {gotoState('Pickup');}
	Begin:
	gotoState('Pickup');
}
*/


/*
event Timer() {log("event timer");}
event HitWall( vector HitNormal, actor HitWall ) {log("event hitwall");}
event Falling() {log("event falling");}
event Landed( vector HitNormal ) {log("event landed");}
event ZoneChange( ZoneInfo NewZone ) {log("event zonechange");}
event UnTouch( Actor Other ) {log("event untouch");}
event Bump( Actor Other ) {log("event bump");}
event BaseChange() {log("event basechange");}
event Attach( Actor Other ) {log("event attach");}
event Detach( Actor Other ) {log("event detach");}
event KillCredit( Actor Other ) {log("event killcredit");}
event Actor SpecialHandling(Pawn Other) {log("event specialhandling");}
event bool EncroachingOn( actor Other ) {log("event encroachingon");}
event EncroachedBy( actor Other ) {log("event encroachedby");}
event InterpolateEnd( actor Other ) {log("event interpolateend");}
event EndedRotation() {log("event endedrotation");}
*/


// other functions

// get respawn of next item
function float getRespawnTime()
{
	return SpawnItem[nextItem].default.RespawnTime * AdjustedSpawnTime;
}


//SpawnItemFallsToGround(1)=1

defaultproperties
{
	AdjustedSpawnTime=1
	bRandomize=false
	Capacity_max=0

	SpawnItem(0)=class'ASMD'
	SpawnItem(1)=class'ShieldBelt'
	SpawnItem(2)=class'SuperHealth'

	CollisionRadius=1.000000
	CollisionHeight=1.000000

	bCollideActors=true
	bHiddenEd=false
	bHidden=true
	bDebug=False

	RemoteRole=Role_NONE
	DrawType=DT_Sprite
}
