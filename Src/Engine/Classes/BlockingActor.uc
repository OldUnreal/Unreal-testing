// BlockingActor
// Can be used to block specific actors only.
// Obsolete! Use Blocking Volume instead!
Class BlockingActor extends Actor
	Native;

var() bool bBlockSubClasses;
var() array< class<Actor> > BlockingClasses, // Block these actors (+ subclasses if bBlockSubClasses) with the exception of IgnoreSubClasses.
					IgnoreSubClasses;

var() array< class<Actor> > ScriptBlocking; // Call slow UScript event to check whatever to block or not if actor is based on any of these.

simulated event bool ShouldBlock( Actor Other ) // Called if actor is based under any of 'ScriptBlocking'
{
	return true; // Return true to block.
}

defaultproperties
{
	bStatic=true
	CollisionHeight=32
	CollisionRadius=32

	bBlockActors=true
	bBlockPlayers=true
	bCollideActors=true
	bWorldGeometry=true

	bBlockSubClasses=true
}
