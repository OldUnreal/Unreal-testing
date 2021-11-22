//=============================================================================
// Volume: a bounding volume
// touch() and untouch() notifications to the volume as actors enter or leave it
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Volume extends Brush
	native
	NoUserCreate;

cpptext
{
	void PostEditMove();
	void TransformPermanently( BYTE KeepRotation );
	UBOOL Encompasses( const FVector& Position );
	bool ShouldTrace( DWORD TraceFlags, AActor* SourceActor );
}

native final function bool Encompasses(vector V); // returns true if position is within volume

// Must use external timer because volumes are (usually) static.
function StartTimer( float TimeSeconds, optional bool bLoop )
{
	local VolumeTimer T;
	
	T = Spawn(class'VolumeTimer',Self);
	T.SetTimer(TimeSeconds,bLoop);
}
function TimerPop( VolumeTimer T );

defaultproperties
{
	bCollideActors=True
	bSkipActorReplication=true
	RemoteRole=ROLE_None
	BrushColor=(R=248,G=248,B=248)
	bSpecialBrushActor=true
	bHidden=true
}