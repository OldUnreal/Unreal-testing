//=============================================================================
// ScriptHook: Base class for setting up function hooks. - Written by Marco
//=============================================================================
// All hooks will be unbound EVERY mapchange, even upon Load game, so make
// sure to rebind everything when needed!
// Hooks will be unbound right after NotifyMapChange event, and before InitGame.
//=============================================================================
// NOTE: In order to enable function hooks client-side for servers, you must
// run GameInfo.SetHooksEnabled(true) serverside!
//=============================================================================
Class ScriptHook extends Object
	native
	abstract;

// If return value is a bool, you must use this enum instead!
enum EBoolParm
{
	RETURN_False,
	RETURN_True,
};

var const transient bool bHasHooks; // Set to true if has currently any hooks active.
var private transient array<Function> Hooks;

// Check if currently allowed to execute hooks.
// Only returns false if client side and server hasn't enabled hooks!
static native final function bool HooksEnabled();

// Grab a list of hooks this object is currently using.
// @Func = the hooked function
// @Callback = the callback function.
// @Priority = the hook priority.
native(340) final iterator function UsedHooks( out Function Func, out Function Callback, optional out int Priority );

// Grab all hooks currently active on a single function.
static native(341) final iterator function AllHooks( Function Func, out Function Callback, out ScriptHook S, optional out int Priority );

/* Hook an UnrealScript function call:
@ Func = The function that should be hooked.
@ Callback = The callback function when hooked function is called.
@ Priority = With multiple hooks on same function, sort them by priority.
@ Return value = returns true if it was a success (will only return false if one of the parameters are none).
NOTE:
- Return param should always be a bool (to return true whenever to override the function call).
- First param should always be an Object to give reference to the function caller.
- Second parameter should always be out <return param type of the original function> (if it is a bool, use EBoolParm instead).
Example:
function bool CheckFutureSight(float DeltaTime) -> function bool HookCheckFutureSight(Pawn P, out EBoolParm Result, float DeltaTime)
SetHook(Pawn.CheckFutureSight,HookCheckFutureSight);
OR:
SetHook(class'MyPawn'.Static.FindFunction('CheckFutureSight'),HookCheckFutureSight);
MORE NOTE:
- It will automatically unhook if either source function or ScriptHook object gets garbage collected/destroyed.
- It will not save hooks with saved games (if your single player campaign depends on this, make sure to re-hook on load game).
- All hooks get detached on mapchange (after NotifyLevelChange, before GameInfo.InitGame).
*/
native(342) final function bool SetHook( Function Func, Function Callback, optional int Priority );

// Remove a single hook.
native(343) final function bool RemoveHook( Function Func, Function Callback );

cpptext
{
	UScriptHook(){}
	void Destroy();
	static UBOOL VerifyParameters(UFunction* Func, UFunction* Callback, FOutputDevice& Out );
}
