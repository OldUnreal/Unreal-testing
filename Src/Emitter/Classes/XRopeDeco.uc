// Rope decoration with Physics.
Class XRopeDeco extends Decoration
	native;

struct export RopePiece
{
	var vector Pos,Velocity;
	var rotator Dir;
};

var(Wind) bool bRopeWind; // Rope should blow with wind effect.
var(Wind) float WindStrength;
var(Wind) float WindOscalliationRate,WindAmptitude;
var(Wind) float WindRandDir; // Dot product of angle random wind offset from direction.
var(Wind) vector WindDirection; // Direction of the wind.

var() Actor RopeStartActor; // Start-point actor (optional).
var() Actor RopeEndActor; // End-point actor (optional).
var() vector RopeEndOffset; // Relative offset from either EndPointActor or if none specified, relative offset from rope itself.
var() array<Actor> MidPointActors; // Actors that should make up mid-points to this rope if you don't want it to start at a straight line.
var() byte NumSegments; // Number of segments this rope should split up into.
var() float RopeThickness; // How many UU wide should this rope be?
var() float TexVertScaling; // Vertical texture V-map scaling along the rope.
var() bool bHasLooseStart; // Start point is not tied to anything.
var() bool bHasLooseEnd; // End is not tied up to anything.
var() editinline PXJ_BaseJoint RopeJointStart,RopeJointEnd; // Constraint that should tie rope to end/start anchors.
var() class<Effects> BreakEffect; // Effect to spawn when rope breaks.
var() Sound BreakSound; // Effect to play when rope has been broken.
var() float RopeLoseness; // How much should rope hang downwards (or negative for upwards).
var float RopeLength;
var repnotify byte RopeBrokenIndex;

var transient const uint LastUpdateFrame; // Most recent frame number this was updated.

var array<vector> MidPoints; // Serialized mid-points for when saving/loading game (if empty, use locations of MidPointActors array).
var transient const array<vector> RenderPoints; // Edge points while rendering (array size is always NumSegments+1).
var noedsave const array<RopePiece> PiecePoints; // Rope pieces for when saving or restoring rope physics.

var pointer<class URopeMesh*> RopeMeshPtr;

native final function ResetRope(); // Reset rope to new MidPoints array.
native final function bool BreakRope( byte Offset ); // Break rope at a point.

// Instantly set a new start/end location, Offset is relative if NewStart/NewEnd is specified, otherwise its absolute.
native final function SetStartLocation( vector Offset, optional Actor NewStart );
native final function SetEndLocation( bool bLooseEnd, optional vector Offset, optional Actor NewEnd );

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		RopeBrokenIndex;
}

simulated function PostBeginPlay()
{
	WindDirection = Normal(WindDirection);
	Role = ROLE_Authority; // Always remain client authority.
}

// Called by BreakRope function.
simulated event OnRopeBreak( byte Offset )
{
	local Actor e;
	
	if( BreakEffect && Level.NetMode!=NM_DedicatedServer && (Level.NetMode!=NM_Client || Level.TimeSeconds>1.f) )
	{
		PlaySound(BreakSound);
		e = Spawn(BreakEffect,,,RenderPoints[Offset],rotator(RenderPoints[Offset]-RenderPoints[Offset-1]));
		if( e )
			e.RemoteRole = ROLE_None;
	}
	if( Level.NetMode!=NM_Client )
	{
		RopeBrokenIndex = Offset;
		RemoteRole = ROLE_SimulatedProxy;
		bAlwaysRelevant = true;
		bForceNetUpdate = true;
	}
}

function ShadowModeChange();
function BaseChange();
function Bump( actor Other );
function GrabbedBy( Pawn Other );

function EdNoteAddedActor( vector HitLocation, vector HitNormal );

function Trigger( Actor Other, Pawn EventInstigator )
{
	BreakRope(NumSegments/2);
}

simulated event OnRepNotify( name Property )
{
	if( Property=='RopeBrokenIndex' )
	{
		if( RopeBrokenIndex==255 )
			ResetRope();
		else BreakRope(RopeBrokenIndex);
	}
}

function Reset()
{
	ResetRope();
}

defaultproperties
{
	BEGIN OBJECT CLASS=PX_RigidBodyData NAME=RopePhysics
		MaxAngularVelocity=4
		MaxLinearVelocity=1200
		bCheckWallPenetration=false
		bClientSimulate=True
	END OBJECT
	PhysicsData=RopePhysics
	
	BEGIN OBJECT CLASS=PXJ_SocketJoint NAME=RopeConstraint
		MovementLimit=(X=75,Y=75)
	END OBJECT
	RopeJointStart=RopeConstraint
	
	BEGIN OBJECT CLASS=PXJ_SocketJoint NAME=RopeConstraintB
		MovementLimit=(X=75,Y=75)
	END OBJECT
	RopeJointEnd=RopeConstraintB
	
	RopeEndOffset=(X=128)
	bHasLooseEnd=true
	NumSegments=12
	RopeThickness=2
	Physics=PHYS_RigidBody
	TexVertScaling=3
	RopeLoseness=0.1
	
	WindRandDir=0.1
	WindDirection=(X=1,Y=1)
	WindStrength=6
	WindOscalliationRate=1.5
	
	bNoDynamicShadowCast=true
	
	RemoteRole=ROLE_None
	bNoDelete=true
	bBlockActors=false
	bBlockPlayers=false
	bStatic=false
	Texture=Texture'DefaultTexture'
	DrawType=DT_Mesh
	Mass=10
	RopeBrokenIndex=255
	NetUpdateFrequency=1
}