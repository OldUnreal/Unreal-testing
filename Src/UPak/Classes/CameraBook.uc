//=============================================================================
// CameraBook.
//=============================================================================
class CameraBook expands Book;

var rotator StartRot;
var int Counter;

function PostBeginPlay()
{
	Disable( 'Tick' );
	RemoveSecondActors();
	StartRot = Rotation;
	RotationRate.Yaw = 3700;
	SetTimer( 1.5, false );
}

function Timer()
{
	Enable( 'Tick' );
}
	
function Tick( float DeltaTime )
{
	if( Rotation == StartRot && Counter == 1 )
	{
		RemoveFirstActors();
		InsertSecondActors();
	}
	else Counter++;
}

function RemoveFirstActors()
{
	local Actor A;
	
	foreach allactors( class'Actor', A  )
	{
		if( A.Tag == '1' && ( A.IsA( 'Actor' ) || A.IsA( 'Pawn' ) ) )
			A.bHidden = true;
	}
}

function InsertSecondActors()
{
	local Actor A;
	
	foreach allactors( class'Actor', A )
	{
		if( A.Tag == '2' && ( A.IsA( 'Decoration' ) || A.IsA( 'Pawn' )  ))
			A.bHidden = false;
	}
}


function RemoveSecondActors()
{
	local Actor A;
	
	foreach allactors( class'Actor', A  )
	{
		if( A.Tag == '2' && ( A.IsA( 'Actor' ) || A.IsA( 'Pawn' ) ) )
			A.bHidden = true;
	}
}


function InsertFirstActors()
{
	local Actor A;
	
	foreach allactors( class'Actor', A )
	{
		if( A.Tag == '1' && ( A.IsA( 'Decoration' ) || A.IsA( 'Pawn' )  ))
			A.bHidden = false;
	}
}

defaultproperties
{
     Rotation=(Yaw=144)
}
