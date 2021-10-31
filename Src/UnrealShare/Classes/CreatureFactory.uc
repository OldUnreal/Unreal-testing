//=============================================================================
// CreatureFactory.
//=============================================================================
class CreatureFactory extends ThingFactory;

var() name Orders;      // creatures from this factory will have these orders
var() name OrderTag;
var pawn	enemy;
var() name AlarmTag;	// alarmtag given to creatures from this factory
var() int  AddedCoopCapacity; // Extra creatures for coop mode

function PreBeginPlay()
{
	if ( Level.Game.bNoMonsters )
		Destroy();
	else
		Super.PreBeginPlay();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Level.NetMode!=NM_StandAlone )
		capacity += AddedCoopCapacity;
	backup_capacity = capacity;
}

Auto State Waiting
{
	function Touch(Actor Other)
	{
		local pawn otherpawn;

		otherpawn = Pawn(Other);
		if ( (otherpawn != None) && (!bOnlyPlayerTouched || otherpawn.bIsPlayer) )
		{
			enemy = otherpawn;
			Trigger(other, otherPawn);
		}
	}
}

defaultproperties
{
	Orders=Attacking
	capacity=1
	bCovert=True
}
