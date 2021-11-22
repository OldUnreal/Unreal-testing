//=============================================================================
// OBSOLETE!
//=============================================================================
class ActorAttachActorRI extends RenderIterator;

var transient const enum EAttachingGoalType
{
	EATGT_AttachToOwner,
	EATGT_AttachToInstigator,
	EATGT_AttachToMisc
} AttachingGoalActor;
var transient const Actor MiscAttachActor;
var transient const vector RelativeLocation;
var transient const rotator RelativeRotation,BaseRotation;
var transient const bool bAttachLocation,bAttachRotation;
var transient const bool bInvisibleWhenNotUpdating;
var transient const bool bStasisMode;
var transient const bool bConstantUpdates;
var transient const bool bDrawMe;
var transient const float LastUpdateTime;
var transient const vector ActorOldPos;
var transient const rotator ActorOldRot;

defaultproperties
{
}