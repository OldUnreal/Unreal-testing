//=============================================================================
// SavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class SavedMove extends Info
	transient;

// also stores info in Acceleration attribute
var SavedMove NextMove;		// Next move in linked list.
var float TimeStamp;		// Time of this move.
var float Delta;			// Distance moved.
var EDodgeDir DodgeMove;	// Dodge info.
var bool	bRun;
var bool	bDuck;
var bool	bPressedJump;
var bool	bSent;			// Whether sent.

// Extra movement info, valid only if PrePlayerMoveTimeStamp == TimeStamp:
// var EDodgeDir DodgeDir; - defined in Actor
var float DodgeClickTimer;
var rotator PlayerRotation;
var rotator ViewRotation;
var bool bIsCrouching;
var bool bIsReducedCrouch;
var name NewState;
var class<CustomPlayerStateInfo> NewCustomPlayerState;

var float ExtraInfoTimeStamp; // is used for validation of extra movement info

final function Clear()
{
	TimeStamp = 0;
	Delta = 0;
	bSent = false;
	DodgeMove = DODGE_None;
	Acceleration = vect(0,0,0);
	bIsReducedCrouch = false;
	ExtraInfoTimeStamp = 0;
}

defaultproperties
{
	bHidden=True
}
