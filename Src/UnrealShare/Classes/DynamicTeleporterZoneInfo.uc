//=============================================================================
// DynamicTeleporterZoneInfo.
// This fucking thing is broken!!!!!!!!!!!!!1111111111111111111
//=============================================================================
class DynamicTeleporterZoneInfo expands DynamicZoneInfo;

var() name TeleporterTag;
var Teleporter myTeleporter;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( TeleporterTag != '' )
		ForEach AllActors(class'Teleporter', myTeleporter, TeleporterTag)
		break;
}

event ActorEntered( actor Other )
{
	if ( myTeleporter != None )
		myTeleporter.Touch(Other);
}

defaultproperties
{
}
