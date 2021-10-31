//=============================================================================
// PhysicsAnimation: A class to give physics based animation to pawns.
//=============================================================================
Class PhysicsAnimation extends Object
	native;

cpptext
{
	UPhysicsAnimation() {}
	void Init( class APawn* Pawn );
	void TickAnimations( FLOAT DeltaSeconds );
private:
	BYTE GetMovementDir() const;
}

var() enum EMovementDirCount
{
	MDIR_1Way, // N
	MDIR_2Way, // N/S
	MDIR_4Way, // N/S/E/W
	MDIR_8Way, // N/S/E/W/NE/SE/NW/NE
} MovementDirCount; // The number of movement direction animations this mesh have.
var() bool bCanSwim; // If True, should consider waterzones as swimmable zones.
var() bool bCanWalk; // If true, should play standing/walking animations.
var() bool bCheckWalkSpeed; // If true, look if movement speed is under Pawn.WalkingPct, then use Walk animations.
var() bool bCanCrouch; // If true, should consider crouch animations while standing.
var() bool bCanFly; // If true, should consider flying animations if Physics==PHYS_Flying.
var() bool bCanJump; // If true, should consider falling animations.
var() bool bIgnoreDead; // If true, don't set anim state to Dead if pawn has 0 health.
var() bool bCheckYawStillOnly; // On check for yaw changes while standing still.
var() bool bClientSideAnims; // If true, allow third-person clients do this aswell.
var() bool bServerSideAnims; // If false, don't check for animations serverside.
var() bool bOnlyWhenRendered; // If true, only check if actor is in view (ignored serverside).
var() bool bEnabled; // If this handle is currently enabled.

var() int MaxYawDif; // Maximum yaw difference before triggering OnDoTurn event.
var() float StillSpeedScale; // Speed scale of ground/air/waterspeed when considered not moving.
var() float DodgeMoveSpeed; // In-air speed scale when to consider a dodge move (multiplied by GroundSpeed).

var() name OnAnimationChange; // Function to call on Pawn owner when AnimationNumber was changed.
var() name OnDoTurn; // Function to call on Pawn owner when Pawn is turning.
var() name OnDodgeMove; // Function to call on Pawn owner when Pawn performed a dodge move (by moving faster then GroundSpeed*DodgeMoveSpeed while falling).
var() name CrouchFlagProperty; // Name of a bool that describes if this Pawn is crouching.

enum EMoveDir
{
	MOVE_Still,
	MOVE_North,
	MOVE_South,
	MOVE_West,
	MOVE_East,
	MOVE_NorthWest,
	MOVE_SouthWest,
	MOVE_NorthEast,
	MOVE_SouthEast,
};
enum EMoveAnim
{
	MOVEANIM_Walk,
	MOVEANIM_Run,
	MOVEANIM_Crouch,
	MOVEANIM_Swim,
	MOVEANIM_Jump,
	MOVEANIM_InAir,
	MOVEANIM_Flying,
	MOVEANIM_Dead,
};

var transient int OldYaw;
var transient const Pawn PawnOwner;
var transient const BoolProperty CrouchProperty;

var const EMoveAnim AnimationSeq; // Current animation sequence to play.
var const EMoveDir MovementDir; // Current animation movement direction.
var const EMoveAnim PrevAnimSeq; // Previous animation sequence before current value.
var const EMoveDir PrevMoveDir; // Previous animation movement direction.
var const byte TurnDirection; // When turning, which direction are we turning, 0 = left, 1 = right.
var const EMoveDir DodgeMove; // Dodge move direction, assigned before calling OnDodgeMove.
var const bool bIsDodgeMove;

var bool bShouldInit; // Should call initial OnAnimationChange when first tick passed.

native final function byte GetMoveDir(); // Get move direction in EMoveDir limited by MovementDirCount

simulated final function SetEnabled( bool bEnable )
{
	bEnabled = bEnable;
	if( bEnable )
	{
		if( PawnOwner!=None )
			OldYaw = PawnOwner.Rotation.Yaw;
		bShouldInit = true;
	}
}

defaultproperties
{
	bCanSwim=true
	bCanWalk=true
	bCheckWalkSpeed=true
	bCanCrouch=true
	bCanJump=true
	bCheckYawStillOnly=true
	bServerSideAnims=true
	bEnabled=true
	bShouldInit=true
	MaxYawDif=8000
	StillSpeedScale=0.1
	DodgeMoveSpeed=1.45
}