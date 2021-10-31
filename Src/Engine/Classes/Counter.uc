//=============================================================================
// Counter: waits until it has been triggered 'NumToCount' times, and then
// it sends Trigger/UnTrigger events to actors whose names match 'EventName'.
//=============================================================================
class Counter extends Triggers;

#exec Texture Import File=Textures\Counter.pcx Name=S_Counter Mips=Off Flags=2

//-----------------------------------------------------------------------------
// Counter variables.

var() byte       NumToCount;                // Number to count down from.
var() bool       bShowMessage;              // Display count message?
var() localized  string CountMessage;       // Human readable count message.
var() localized  string CompleteMessage;    // Completion message.
var   byte       OriginalNum;               // Number to count at startup time.

var() name TriggerLevelID; // 227j: Sub-Level name to send this trigger event to.

//-----------------------------------------------------------------------------
// Counter functions.

//
// Init for play.
//
function BeginPlay()
{
	OriginalNum = NumToCount;
}

//
// Reset the counter.
//
function Reset()
{
	NumToCount = OriginalNum;
}

//
// Counter was triggered.
//
function Trigger( actor Other, pawn EventInstigator )
{
	local string Num;

	if ( NumToCount > 0 )
	{
		if ( --NumToCount == 0 )
		{
			// Trigger all matching actors.
			if ( bShowMessage && Len(CompleteMessage)>0 && EventInstigator!=None )
				EventInstigator.ClientMessage( CompleteMessage );
			TriggerEvent(Event,Other,EventInstigator,TriggerLevelID);
		}
		else if ( bShowMessage && CountMessage != "" && EventInstigator!=None && EventInstigator.bIsPlayerPawn )
		{
			// Still counting down.
			switch ( NumToCount )
			{
			case 1:
				Num="one";
				break;
			case 2:
				Num="two";
				break;
			case 3:
				Num="three";
				break;
			case 4:
				Num="four";
				break;
			case 5:
				Num="five";
				break;
			case 6:
				Num="six";
				break;
			default:
				Num=string(NumToCount);
				break;
			}
			EventInstigator.ClientMessage( ReplaceStr(CountMessage,"%i",Num) );
		}
	}
}

// Return my trigger actor
function Actor GetTriggerActor()
{
	local Actor A;

	if ( Tag=='' )
		return Self;
	ForEach AllActors(Class'Actor',A,,Tag)
	if ( A!=Self )
		return A.GetTriggerActor();
	return Self;
}

defaultproperties
{
	NumToCount=2
	bShowMessage=False
	CountMessage="Only %i more to go..."
	CompleteMessage="Completed!"
	Texture=S_Counter
}
