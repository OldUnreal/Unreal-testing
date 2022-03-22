Class PlayerInteraction extends Object
	DependsOn(PlayerPawn)
	abstract
	native;

var PlayerInteraction NextInteraction;
var PlayerPawn PlayerOwner;

var() const byte Priority; // Interaction with highest priority goes to first, also first one to receive callbacks.

var() bool bPlayerTick,bPreRender,bPostRender,bRenderOverlays,bPlayerCalcView,bKeyEvent,bPrePhysicsStep,bPostPhysicsStep; // Request specified callback.

// PlayerPawn hooks, will be called before any of the PlayerPawn functions.
// Return true in any of these functions to override the PlayerPawn behaviour.
// Note this object will receive ObjectDeleted event notification when PlayerPawn was destroyed (disconnected from server).

// [Server+Client] Called when it has been initialized.
function Initialized();

// [Client] PlayerPawn.PlayerInput + PlayerPawn.PlayerTick
event bool PlayerTick( float DeltaTime );

// [Client] PlayerPawn.PreRender
event bool PreRender( Canvas Canvas );

// [Client] PlayerPawn.PostRender
event bool PostRender( Canvas Canvas );

// [Client] PlayerPawn.RenderOverlays
event bool RenderOverlays( Canvas Canvas );

// [Server+Client] PlayerPawn.PlayerCalcView
event bool PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation );

// [Client] Console.KeyType (shares bKeyEvent check)
event bool KeyType( int Key );

// [Client] Console.KeyEvent
event bool KeyEvent( Actor.EInputKey Key, Actor.EInputAction Action, float Delta );

// [Server+Client] Called before PlayerPawn.ProcessPhysics (returning true overrides engine physics behaviour)
event bool PrePhysicsStep( float DeltaTime );

// [Server+Client] Called after PlayerPawn.ProcessPhysics
event PostPhysicsStep( float DeltaTime );

// [Server+Client] Called to notify about upcoming level change.
event NotifyLevelChange();
