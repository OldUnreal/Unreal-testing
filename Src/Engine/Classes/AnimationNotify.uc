//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Coder: Raven
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Creation date: 19-08-2009, 14:23
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Last revision: 21-11-2011 18:25
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Extended version of previous animation 
// notify code. You can call AnimUpdate to 
// update it from UScript, or NativeAnimUpdate
// from C++ code.
// This time, you can have one class per mesh
// or animation. 
class AnimationNotify extends Object
	native;

struct export sAnimNotify
{
	var() name AnimName; // Animation name
	var() name FunctionName; // Callback function name on owner actor
	var() int KeyFrame; // Key frame (0 = start)
	var() eAnimNotifyEval NotifyEval; // When call notify
	var() bool bCallOncePerLoop; // Call event once per animation loop
	var bool bAlreadyCalled;
};
var() array<sAnimNotify> AnimationNotify;

/** Owner */
var const Actor Owner;

var name OldAnimation; // Previous initialized animation sequence.
var int NumAnimFrames; // Current animation sequence anim frames (0 = anim not found).

/** initalized */
var bool bInitialized, bErrorOccured;

// [227k] LIPSync audio data.
var transient const float VoiceVolume, LIPSyncTime, LIPSyncRate; // VoiceVolume is current talking volume for the current LIPSync track.
var transient const Sound LIPSyncSound;

/**
 * Called on notify
 *
 * @param	delta time
 * @param	notify index of the array
 */
event Notify(float DeltaTime, int Num);

// Animation Notify was initialized.
event OnInit();

// [227k] Start a LIPSynch audio track.
// Use Sound 'None' to stop it.
native final function StartLIPSyncTrack( Sound Sound, optional float Pitch );

// [227k] Notify event when this actor is about to play a sound effect with SLOT_Talk (called on client, only when played within hearing distance).
// Useful for starting a LIPSync track at the same time.
event OnPlayVoiceSound( Sound Sound, float Volume, float Pitch );

defaultproperties
{
}