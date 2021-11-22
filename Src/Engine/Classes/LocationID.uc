//=============================================================================
// LocationID - marks and names an area in a zone
//=============================================================================
class LocationID extends KeyPoint;

var() localized string LocationName; // Name of this location.
var() float Radius; // Radius of this location.
var LocationID NextLocation;

simulated function PostBeginPlay()
{
	// add self to zone list
	NextLocation = Region.Zone.LocationID;
	Region.Zone.LocationID = Self;
}

defaultproperties
{
}
