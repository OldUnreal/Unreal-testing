//=============================================================================
// PX_VehicleWheeledAuto: Wheeled vehicle behaviour with automatic transmissions/physics.
//=============================================================================
Class PX_VehicleWheeledAuto extends PX_VehicleWheeled
	native;

var(Vehicle) InterpCurve AccelFunc; // Acceleration based on current speed.
var(Vehicle) InterpCurve ReverseFunc; // Reverse speed.
var(Vehicle) InterpCurve WheelSteerFunc; // Steering speed based on current movement speed (output in 0-360 degrees).
var(Vehicle) InterpCurve WheelSlipFunc; // Slipping on turn based on speed.

var(Vehicle) float TipRollingRate; // Roll outwards while turning rate.
var(Vehicle) float TipRollingSpeed; // Speed at which the rolling happens.

var(Vehicle) float ChassisTorqueScale; // Pitch vehicle upwards when accelerating.
var(Vehicle) float ChassisTorqueSpeed; // Lowest speed at which torque stops at.

// User input (-1 -> 1 range)
var float CurrentGas;
var float CurrentSteering;
var bool CurrentHandbrake;

cpptext
{
	UPX_VehicleWheeledAuto() {}
	void InitInnerPx(PX_SceneBase* Scene, PX_PhysicsObject* P);
}

defaultproperties
{
	AccelFunc=(Points=((InVal=0,OutVal=100.0),(InVal=650.0,OutVal=50.0),(InVal=800.0,OutVal=0)))
	ReverseFunc=(Points=((InVal=0,OutVal=100.0),(InVal=300.0,OutVal=50.0),(InVal=500.0,OutVal=0)))
	WheelSteerFunc=(Points=((InVal=0,OutVal=26.0),(InVal=500.0,OutVal=24.0),(InVal=800.0,OutVal=20)))
	WheelSlipFunc=(Points=((InVal=0,OutVal=0.0),(InVal=500.0,OutVal=20.0),(InVal=800.0,OutVal=50)))
	TipRollingRate=120
	TipRollingSpeed=900
	ChassisTorqueScale=75
	ChassisTorqueSpeed=350
}