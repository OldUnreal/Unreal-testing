// Rope decoration with Physics.
Class XRopeDeco extends Decoration
	native;

var() Actor RopeStartActor; // Start-point actor (optional).
var() Actor RopeEndActor; // End-point actor (optional).
var() vector RopeEndOffset; // Relative offset from either EndPointActor or if none specified, relative offset from rope itself.
var() array<Actor> MidPointActors; // Actors that should make up mid-points to this rope if you don't want it to start at a straight line.
var() byte NumSegments; // Number of segments this rope should split up into.
var() float RopeThickness; // How many UU wide should this rope be?
var() float TexVertScaling; // Vertical texture V-map scaling along the rope.
var() bool bHasLooseStart; // Start point is not tied to anything.
var() bool bHasLooseEnd; // End is not tied up to anything.
var() editinline PXJ_BaseJoint RopeJoint; // Constraint that should tie rope together.
var class<Effects> BreakEffect; // Effect to spawn when rope breaks. (TODO)
var name BreakEvent; // Event to fire when rope broke. (TODO)
var float RopeLength;

var transient const byte RopeBreakIndex; // During PhysicsJointBreak assign location of that joint here.

var transient const uint LastUpdateFrame; // Most recent frame number this was updated.

var array<vector> MidPoints; // Serialized mid-points for when saving/loading game (if empty, use locations of MidPointActors array).
var transient const array<vector> RenderPoints; // Edge points while rendering (array size is always NumSegments+1).

var pointer<class URopeMesh*> RopeMeshPtr;

native final function ResetRope(); // Reset rope to new MidPoints array.

// Instantly set a new start/end location, Offset is relative if NewStart/NewEnd is specified, otherwise its absolute.
native final function SetStartLocation( vector Offset, optional Actor NewStart );
native final function SetEndLocation( bool bLooseEnd, optional vector Offset, optional Actor NewEnd );

// TODO: Implement this.
function PhysicsJointBreak( PXJ_BaseJoint Joint )
{
	if( BreakEffect )
		Spawn(BreakEffect,,,RenderPoints[RopeBreakIndex]);
	TriggerEvent(BreakEvent);
}

function ShadowModeChange();
function BaseChange();
function Bump( actor Other );
function GrabbedBy( Pawn Other );

function EdNoteAddedActor( vector HitLocation, vector HitNormal );

defaultproperties
{
	BEGIN OBJECT CLASS=PX_RigidBodyData NAME=RopePhysics
		MaxAngularVelocity=2
		MaxLinearVelocity=600
		bCheckWallPenetration=true
	END OBJECT
	PhysicsData=RopePhysics
	
	BEGIN OBJECT CLASS=PXJ_SocketJoint NAME=RopeConstraint
		//bLimitMovement=true
		MovementLimit=(X=75,Y=75)
	END OBJECT
	RopeJoint=RopeConstraint
	
	RopeEndOffset=(X=128)
	bHasLooseEnd=true
	NumSegments=12
	RopeThickness=2
	//Physics=PHYS_RigidBody
	Physics=PHYS_None
	TexVertScaling=3
	
	bNoDynamicShadowCast=true
	
	RemoteRole=ROLE_None
	bNoDelete=true
	bBlockActors=false
	bBlockPlayers=false
	bStatic=false
	Texture=Texture'DefaultTexture'
	DrawType=DT_Mesh
	Mass=1000
}