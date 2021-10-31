// Visibility Notify
// Used to make actors relevant through teleporters/security cameras etc...
// Place 2 of these actors on one side and set their Tag to be same.
// Then make sure their collision cylinder covers a good visibility area around.
Class VisibilityNotify extends Info
	Native;

var VisibilityNotify NextNotify;

simulated function PostBeginPlay()
{
	// Add in front of visibility actors list.
	NextNotify = Region.Zone.VisNotify;
	Region.Zone.VisNotify = Self;
}

defaultproperties
{
	Texture=S_Camera
	bStatic=true
}
