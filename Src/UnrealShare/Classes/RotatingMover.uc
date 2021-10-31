//=============================================================================
// RotatingMover.
//=============================================================================
class RotatingMover extends Mover
	NoUserCreate; // Marco: This mover doesn't even work online.

var() rotator RotateRate;

function BeginPlay()
{
	Disable( 'Tick' );
}

function Tick( float DeltaTime )
{
	SetRotation( Rotation + (RotateRate*DeltaTime) );
}

function Trigger( Actor other, Pawn EventInstigator )
{
	Enable('Tick');
}

function UnTrigger( Actor other, Pawn EventInstigator )
{
	Disable('Tick');
}

defaultproperties
{
}
