//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_SetPhysics ]
//
// Adjusts the physics of an actor.
//
//=============================================================================

class CS_SetPhysics expands CutSeq;

var() name ActorTag;
var() EPhysics NewPhysics;
var() bool bRestore;       // If true, the second trigger undoes the first

var bool bTriggered;
var EPhysics SavedPhysics;

function PreBeginPlay()
{
    foreach AllActors(class'Actor', Target, ActorTag)
	break;
}

function Trigger(actor Other, Pawn EventInstigator)
{
    CsLog("Triggered.");
    if (bTriggered && bRestore) {
 	Target.SetPhysics(SavedPhysics);
    } else {
	bTriggered = true;
	SavedPhysics = Target.Physics;
	Target.SetPhysics(NewPhysics);
    }
}

defaultproperties
{
     bRestore=True
	Texture=CSACTION
}
