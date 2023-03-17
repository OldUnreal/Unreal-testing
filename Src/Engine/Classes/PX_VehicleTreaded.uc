//=============================================================================
// PX_VehicleTreaded: Tread craft vehicle (tanks).
//=============================================================================
Class PX_VehicleTreaded extends PX_VehicleBase
	native;

var(Vehicle) array<vector> TreadOffsets;
var(Vehicle) float TreadRadius; // Treads are spheres, the radius of the sphere.
var(Vehicle) float TreadRestitution;

var(Vehicle) float ThrustSpeed; // Amount of trust to apply when accelerating.
var(Vehicle) float MaxThrust; // Maximum forward/backward movement speed.
var(Vehicle) float SteerTorque; // Amount of turning trust when turning.
var(Vehicle) float MaxSteerTorque; // Maximum turning speed.
var(Vehicle) float ForwardDampFactor; // Forward movement damping rate.
var(Vehicle) float TurnDampFactor; // Forward movement speed damping while turning.
var(Vehicle) float LateralDampFactor; // Sideways velocity damping rate.
var(Vehicle) float SteerDampFactor; // Steering rotation damping.
var(Vehicle) float PitchTorqueFactor; // How much torque to apply when accelerating (make vehicle flip upwards on accel like a m-bike)
var(Vehicle) float PitchDampFactor; // Pitch damping rate.
var(Vehicle) float BankTorqueFactor; // Rolling speed when turning (like a m-bike).
var(Vehicle) float BankDampFactor; // Roll damping speed.
var(Vehicle) float ParkFriction; // Friction while !bDriving

// User input (range -1 to 1):
var float CurrentThrust;
var float CurrentTurn;

cpptext
{
	UPX_VehicleTreaded() {}
	void DrawPreview(FSceneNode* Frame);
	void InitPhysics(PX_SceneBase* Scene);
}

defaultproperties
{
	bStayUpright=true
	StayUprightRollResistAngle=0.5
	StayUprightPitchResistAngle=0.5
	
	TreadRadius=10
	TreadRestitution=0.25
	ThrustSpeed=1000
	MaxThrust=600
	SteerTorque=6
	MaxSteerTorque=4
	ForwardDampFactor=0.25
	TurnDampFactor=0.25
	LateralDampFactor=5
	SteerDampFactor=2
	PitchTorqueFactor=0
	PitchDampFactor=0.25
	BankTorqueFactor=0
	BankDampFactor=0.75
	ParkFriction=0.25
}