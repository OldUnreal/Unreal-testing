//=============================================================================
// ArrowSpawner: An ancient trap that will spawn arrows when triggered.
//=============================================================================
class ArrowSpawner extends Effects;

var() float TriggerDelay, RepeatDelay;
var() int ArrowsToShootAfterDeactivated;
var() int ArrowSpeed;
var int ArrowCount;

function Trigger( actor Other, pawn EventInstigator )
{
	Instigator = EventInstigator;
	GoToState('Active');
}
state Active
{
	function Trigger( actor Other, pawn EventInstigator);

	function UnTrigger( actor Other, pawn EventInstigator )
	{
		ArrowCount = ArrowsToShootAfterDeactivated;
		if (ArrowCount<1) ArrowCount = 1;
	}
	function Timer()
	{
		local Arrow a;

		If (ArrowCount > 0)
		{
			If (ArrowCount==1)
			{
				SetTimer(0.0, False);
				GoToState('');
			}
			a = Spawn(class'Arrow',, '', Location+Vector(Rotation)*20);
			a.Speed = ArrowSpeed;
			ArrowCount--;
		}
		else
		{
			a = Spawn(class'Arrow',,, Location+Vector(Rotation)*20);
			a.Speed = ArrowSpeed;
			SetTimer(RepeatDelay, True);
		}
	}
	function Reset()
	{
		ArrowCount = 0;
		SetTimer(0, false);
		GoToState('');
	}
Begin:
	ArrowCount = 0;
	SetTimer(TriggerDelay, True);
}

defaultproperties
{
	TriggerDelay=+00000.100000
	RepeatDelay=+00000.500000
	bNetTemporary=false
	ArrowsToShootAfterDeactivated=1
	ArrowSpeed=1000
	bHidden=True
	bDirectional=True
	DrawType=DT_Sprite
	CollisionRadius=+00000.000000
	CollisionHeight=+00000.000000
	Physics=PHYS_None
}
