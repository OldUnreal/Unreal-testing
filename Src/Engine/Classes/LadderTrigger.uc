//=============================================================================
// LadderTrigger
// Used to specify climbable point or volume.
//=============================================================================
class LadderTrigger extends Volume;

#exec Texture Import File=Textures\ladder.pcx Name=S_LadderTrigger Mips=Off Flags=2

var() Sound ClimbingNoise;
var() float MaxGrabVelocity;	// Maximum fall velocity to be able to grab this ladder.
var() float MaxOffAngle;		// If bMustFaceForward, how much angle difference is tolerated (0-180).
var() float ClimbSpeed;			// AirSpeed multiplier to climbing speed.
var() float SideStepSpeedMod;	// Speed modifier ontop of ClimbSpeed while sidestepping.
var() bool bUnarmedClimbing;	// Don't allow hold weapon while climbing this ladder.
var() bool bMustFaceForward;	// Player must face at ladder direction while climbing it (must also have bDirectional true for this).
var() bool bAllowSideStep;		// Allow player to strafe on ladder (should have bDirectional true)
var transient bool bWasUntouch;

var vector ClimbAxis,SideAxis;
var int MaxOffAngleRadii,MaxOffAngleRadiiHi;

simulated function PostBeginPlay()
{
	local vector X,Z;

	if( bMustFaceForward && bDirectional )
	{
		MaxOffAngleRadii = MaxOffAngle*{65536.f / 360.f};
		MaxOffAngleRadiiHi = 65536-MaxOffAngleRadii;
	}
	if( bDirectional )
		GetAxes(Rotation,X,SideAxis,ClimbAxis);
	else if( bAllowSideStep )
		GetAxes(Rotation,X,SideAxis,Z);
}

simulated function Touch( Actor Other )
{
	if( Other.bIsPawn )
	{
		bWasUntouch = false;
		SetPendingTouch(Other); // Using PostTouch to allow for entry/exit climb velocity change.
	}
}
simulated function UnTouch( Actor Other )
{
	if( Other.bIsPawn )
	{
		bWasUntouch = true;
		SetPendingTouch(Other);
	}
}
simulated function PostTouch( Actor Other )
{
	if( Other.bIsPawn )
	{
		if( bWasUntouch )
			Pawn(Other).EndClimbing(Self);
		else Pawn(Other).StartClimbing(Self);
	}
}

event EdBrushDeployed()
{
	bDirectional = false;
}

defaultproperties
{
	bDirectional=true
	RemoteRole=ROLE_None
	MaxGrabVelocity=300
	bUnarmedClimbing=true
	bBlockZeroExtentTraces=false
	bMustFaceForward=true
	
	DrawType=DT_Sprite
	BrushColor=(R=171,G=254,B=250)
	Texture=Texture'S_LadderTrigger'
	ClimbAxis=(Z=1)
	MaxOffAngle=45
	ClimbSpeed=0.4
	SideStepSpeedMod=0.65
	
	CollisionRadius=40
	CollisionHeight=40
	CollisionFlag=COLLISIONFLAG_Triggers
}