//=============================================================================
// PX_VehicleChopper: Chopper craft vehicle behaviour.
//=============================================================================
Class PX_VehicleChopper extends PX_VehicleBase
	native;

var(Vehicle) float MaxThrustForce;
var(Vehicle) float LongDamping;

var(Vehicle) float MaxStrafeForce;
var(Vehicle) float LatDamping;

var(Vehicle) float MaxRiseForce;
var(Vehicle) float UpDamping;

var(Vehicle) float TurnTorqueFactor;
var(Vehicle) float TurnTorqueMax;
var(Vehicle) float TurnDamping;
var(Vehicle) float MaxYawRate;

var(Vehicle) float PitchTorqueFactor;
var(Vehicle) float PitchTorqueMax;
var(Vehicle) float PitchDamping;

var(Vehicle) float RollTorqueTurnFactor;
var(Vehicle) float RollTorqueStrafeFactor;
var(Vehicle) float RollTorqueMax;
var(Vehicle) float RollDamping;

var(Vehicle) float MaxRandForce;
var(Vehicle) float RandForceInterval;

var(Vehicle) float StallZ; // Max flight height until starting to descent.

// User input (range -1 to 1):
var float CurrentThrust;
var float CurrentStrafe;
var float CurrentRise;
var vector CurrentDirection; // Should be vector(ViewRotation)

cpptext
{
	UPX_VehicleChopper() {}
	void InitPhysics(PX_SceneBase* Scene);
}

defaultproperties
{
	bStayUpright=true
	CurrentDirection=(X=1)
	InertiaTensor=(X=3,Y=3,Z=1)
	StallZ=65536
	bCustomGravity=true
	
	MaxThrustForce=500.0
	LongDamping=0.05

	MaxStrafeForce=400.0
	LatDamping=0.05

	MaxRiseForce=450.0
	UpDamping=0.05

	TurnTorqueFactor=900.0
	TurnTorqueMax=200.0
	TurnDamping=50.0
	MaxYawRate=1.5

	PitchTorqueFactor=200.0
	PitchTorqueMax=35.0
	PitchDamping=20.0

	RollTorqueTurnFactor=450.0
	RollTorqueStrafeFactor=50.0
	RollTorqueMax=50.0
	RollDamping=30.0

	MaxRandForce=7
	RandForceInterval=0.75
}