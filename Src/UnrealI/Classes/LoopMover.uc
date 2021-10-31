//=============================================================================
// LoopMover.
// When the last keyframe position is reached, this mover
// interpolates to the first keyframe (directly, not through
// the intermediate frames), and repeats the movement forever.
//=============================================================================
class LoopMover extends Mover;

var int NextKeyNum;

function BeginPlay()
{
	KeyNum = 0;
	Super.BeginPlay();
}


function DoOpen()
{
	// Move to the next keyframe.
	//
	bOpening = true;
	bDelaying = false;
	InterpolateTo( NextKeyNum, MoveTime );
	PlaySound( OpeningSound );
	AmbientSound = MoveAmbientSound;
}

state() LoopMove
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		SavedTrigger = Other;
		Instigator = EventInstigator;
		if ( SavedTrigger!=None )
			SavedTrigger.BeginEvent();
		GotoState( 'LoopMove', 'Open' );
	}

	function UnTrigger( actor Other, pawn EventInstigator )
	{
		Enable( 'Trigger' );
		SavedTrigger = Other;
		Instigator = EventInstigator;
		GotoState( 'LoopMove', 'InactiveState' );
	}

	function InterpolateEnd(actor Other)
	{
	}

	function BeginState()
	{
		bOpening = false;
	}

Open:
	Disable ('Trigger');
	NextKeyNum = KeyNum + 1;
	if ( NextKeyNum >= NumKeys ) NextKeyNum = 0;
	DoOpen();
	FinishInterpolation();
	FinishedOpening();

	// Loop forever
	GotoState( 'LoopMove', 'Open' );
InactiveState:
	FinishInterpolation();
	FinishedOpening();
	Stop;
}

defaultproperties
{
}
