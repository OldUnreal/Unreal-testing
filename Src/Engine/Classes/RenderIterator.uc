//=============================================================================
// RenderIterator.
//
// Created by Mark Poesch
//=============================================================================
class RenderIterator expands Object
	native
	transient;

cpptext
{
	// Constructor
	URenderIterator();

	// URenderIterator interface
	// Handeled in render code like:
	/*
		for( Actor A = GetActors(Viewport); A!=None; A=A.Target )
			DrawActor(A);
	*/
	AActor* OnGetActors(FSceneNode* Camera);
	virtual AActor* GetActors();
}

var int MaxItems, Index; // Obsolete.
var pointer<class APlayerPawn*>	Observer;
var pointer<struct FSceneNode*>	Frame;
var transient private bool bHurtEntry; // Keep GetActors from being reentered.

// Call native code for obtaining actors.
native(921) final function Actor GetNativeActors( Canvas Canvas );

// Default behaviour unless overridden by native codes.
event Actor GetActors( Canvas Canvas )
{
	local Actor Result;
	
	Result = Actor(Outer);
	Result.Target = None;
	return Result;
}

defaultproperties
{
}