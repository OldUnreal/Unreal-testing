//=============================================================================
// ThingFactory.
//=============================================================================
class ThingFactory extends Keypoint;

var() class<actor> prototype; 	// the template class
var() int maxitems;	// max number of items from this factory at any time
var	  int	numitems;	// current number of items from this factory
var int numspots;		// number of spawnspots
var() int capacity;		// max number of items ever buildable (-1 = no limit)
var() float interval;	// average time interval between spawnings
var() name	itemtag;	// tag given to items produced at this factory
var() bool	bFalling;	// non-pawn items spawned should be set to falling
var() name  FinishedEvent; // 227: Called once all items has been spawned and destroyed.

var() enum EDistribution
{
	DIST_Constant,
	DIST_Uniform,
	DIST_Gaussian
}
timeDistribution;

var() bool bOnlyPlayerTouched; //only player can trigger it
var() bool bCovert;		//only do hidden spawns
var() bool bStoppable;	//stops producing when untouched
var Spawnpoint spawnspot[16]; //possible start locations

var int backup_capacity;

function PostBeginPlay()
{
	local Spawnpoint newspot;

	Super.PostBeginPlay();
	backup_capacity = capacity;
	numspots = 0;
	numitems = 0;
	foreach AllActors( class 'Spawnpoint', newspot, tag )
	{
		if (numspots < 16)
		{
			spawnspot[numspots] = newspot;
			newspot.factory = self;
			numspots += 1;
		}
	}
	if (itemtag == '')
		itemtag = 'MadeInUSA';
}


function StartBuilding()
{
}

Auto State Waiting
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		TriggerEvent(Event,Self,EventInstigator);
		GotoState('Spawning');
	}

	function Touch(Actor Other)
	{
		local pawn otherpawn;

		otherpawn = Pawn(Other);
		if ( (otherpawn != None) && (!bOnlyPlayerTouched || otherpawn.bIsPlayer) )
			Trigger(other, otherPawn);
	}
}

State Spawning
{
	function UnTouch(Actor Other)
	{
		local int i;
		if (bStoppable)
		{
			//check if some other pawn still touching
			for (i=0; i<4; i++)
				if ( (pawn(Touching[i]) != None) && (!bOnlyPlayerTouched || pawn(Touching[i]).bIsPlayer) )
					return;
			GotoState('Waiting');
		}
	}

	function Trigger(actor Other, pawn EventInstigator)
	{
		//only if Other is from this factory
		if ( Other.class != prototype )
			return;

		numitems--;
		if (numitems < maxitems)
			StartBuilding();
	}

	function bool trySpawn(int start, int end)
	{
		local int i;
		local bool done;

		done = false;
		i = start;
		while (i < end)
		{
			if (spawnspot[i].Create())
			{
				done = true;
				i = end;
				capacity--;
				numitems++;
				if (capacity == 0)
					GotoState('Finished');
			}
			i++;
		}

		return done;
	}

	function Timer()
	{
		local int start;

		if (numitems < maxitems)
		{
			//pick a spawn point
			start = Rand(numspots);
			if ( !trySpawn(start, numspots) )
				trySpawn(0, start);
		}

		if (numitems < maxitems)
			StartBuilding();
	}

	Function StartBuilding()
	{
		local float nextTime;
		if (timeDistribution == DIST_Constant)
			nextTime = interval;
		else if (timeDistribution == DIST_Uniform)
			nextTime = 2 * FRand() * interval;
		else //timeDistribution is gaussian
			nextTime = 0.5 * (FRand() + FRand() + FRand() + FRand()) * interval;

		if (interval > 0 && nextTime == 0)
			nextTime = 0.01;

		if (capacity > 0)
			SetTimer(nextTime, false);
	}

	function BeginState()
	{
		if ( !bStoppable )
			Disable('UnTouch');
	}
	function Reset()
	{
		Global.Reset();
		SetTimer(0,false);
		GoToState('Auto');
	}

Begin:
	Timer();
}

state Finished
{
	function Reset()
	{
		Global.Reset();
		GoToState('Auto');
	}
	function Trigger(actor Other, pawn EventInstigator)
	{
		if( Other.class==prototype && --numitems==0 )
			TriggerEvent(FinishedEvent,Self,EventInstigator);
	}
}

function Reset()
{
	capacity = backup_capacity;
	numitems = 0;
}

defaultproperties
{
	maxitems=1
	capacity=1000000
	interval=+00001.000000
	bFalling=true
	bStatic=False
	bCollideActors=True
}
