//=============================================================================
// EFXTriggerGravZone - Generic.
//
// Set the DesireGrav in the Editor. Normal zone value is -950 as default.
//=============================================================================
class EFXTriggerGravZone extends EFXZoneInfo;

var() float DesireGrav;

// ----------------------------------------------------------------------------
// Trigger()
// ----------------------------------------------------------------------------

function Trigger( actor Other, pawn EventInstigator )
{
//	Log(" ZoneTrigger " $ZoneGravity.Z);
	if (ZoneGravity.Z == -950)
		ZoneGravity.Z = DesireGrav;
	else 
		ZoneGravity.Z = -950;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

defaultproperties
{
	DesireGrav=100.000000
}
