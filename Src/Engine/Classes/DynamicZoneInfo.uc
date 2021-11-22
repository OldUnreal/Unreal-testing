// DynamicZoneInfo - For making summonable/rising water etc...
// Written by Marco
Class DynamicZoneInfo extends ZoneInfo
	native;

var DynamicZoneInfo NextDynamicZone;

var() enum EDynZoneInfoType
{
	DZONE_Cube, // Use cube shape (using BoxMin and BoxMax)
	DZONE_Sphere, // Sphere shape (using SphereSize)
	DZONE_Cylinder, // Cylinder shape (using SphereSize as width, CylinderSize as height)
	DZONE_Shape, // Use the own collision shape as a volume for the zone (use Mesh or CollisionCylinder or Brush).
} ZoneAreaType;
var() vector BoxMin,BoxMax; // Bounding box of the zone when DZONE_Cube
var() float CylinderSize,SphereSize; // Cylinder/sphere bounds of the zone when DZONE_Sphere or DZONE_Cylinder.
var() ZoneInfo MatchOnlyZone; // Only return this result when that actor is within this zone.
var() bool bUseRelativeToRotation; // Result checks should be done relative to rotation.
var bool bScriptEvent; // Call script event before actually applying this zone.
var transient bool bUpdateTouchers; // Force to update zone touchers next tick (auto-resets to false after its done).
var transient plane BoundingSphere; // Bounding sphere encompassing this volume.

simulated function PostBeginPlay()
{
	if( Role==ROLE_None )
		Role = ROLE_Authority; // Give client authority.
	Super.PostBeginPlay();
}

// Called if bScriptEvent and point test is within this zone bounds.
// Return true to skip this dynamic zone.
simulated event bool FilterZone( vector Position, Actor ZoneActor );

simulated function Destroyed() //backwards compatibility.
{
	Super.Destroyed();
}

event EdBrushDeployed()
{
	ZoneAreaType = DZONE_Shape;
}

defaultproperties
{
	bStatic=False
	bNoDelete=True
	RemoteRole=ROLE_None
	bAlwaysRelevant=False
	BoxMin=(X=-200,Y=-200,Z=-200)
	BoxMax=(X=200,Y=200,Z=200)
	SphereSize=250
	CylinderSize=250
	bNotifyPositionUpdate=true
	bSpecialBrushActor=true
	NetUpdateFrequency=8
	bOnlyDirtyReplication=false
}