//=============================================================================
// PX_VehicleWheeled: Wheeled vehicle behaviour.
//=============================================================================
Class PX_VehicleWheeled extends PX_VehicleBase
	native;

struct export VehicleWheel
{
	var() name BoneName;
	var() vector Offset;
	var transient const vector HitLocation,HitNormal; // World contact location.
	var transient const vector LocalOffset; // Actual offset with bone offset added to it.
	
	var() bool bPowered; // Powered wheel.
	var() bool bSteering; // Steering wheel.
	var() bool bReverseSteering; // Steering is in reverse.
	var() bool bBreaks; // Handbreaks wheel.
	var transient const bool bContact; // Currently in contact with world.
};
var(Vehicle) const array<VehicleWheel> Wheels;
var(Vehicle) const float WheelRadius; // Wheels are a sphere, the radius of the sphere.
var(Vehicle) const float WheelRestitution; // Bouncyness of wheels (in range of 0-1).
var(Vehicle) const float WheelFriction; // Current friction of wheels.

// Movement controls.
var float	SteeringValue, // Current steering (0-360 degrees), only effected by bPowered+bSteering wheels.
			Acceleration, // Current acceleration (forward or steering direction from powered wheels).
			DeaccelRate, // Break speed (-EngineSpeed at forward direction), only works on bBreaks wheels.
			SlipCorrection, // Slip linear movement correction (Y axis dampening).
			AngularCorrection; // Slip angular movement correction (yaw axis dampening).
var vector	Torque; // Torque along roll/pitch/yaw axis.

var const float AngularSpeed; // Current angular speed along yaw axis.

var const enum EBreakMode
{
	BREAKS_All, // All wheels are stopped.
	BREAKS_Handbreak, // Only bBreaks wheels are stopped.
	BREAKS_None, // None of the wheels are stopped.
} BreakMode;

cpptext
{
	UPX_VehicleWheeled() {}
	void DrawPreview(FSceneNode* Frame);
	void InitPhysics(PX_SceneBase* Scene);
	virtual void InitInnerPx(PX_SceneBase* Scene, PX_PhysicsObject* P);
	void SetBreakMode(BYTE Mode);
}

native final function SetBreakMode( EBreakMode Mode ); // Change break mode.
native final function SetWheelFriction( float NewFriction ); // Change friction of wheels.

defaultproperties
{
	WheelRadius=10
	WheelRestitution=0.85
	SlipCorrection=1
	AngularCorrection=1
	WheelFriction=0.45
	BreakMode=BREAKS_All
}