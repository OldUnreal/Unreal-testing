//=============================================================================
// PX_VehicleHover: Hover craft vehicle behaviour.
//=============================================================================
Class PX_VehicleHover extends PX_VehicleBase
	native;

var(Vehicle) array<vector> ThrusterOffsets;
var(Vehicle) float HoverSoftness;
var(Vehicle) float HoverCheckDist;

var(Vehicle) float MaxThrustForce;
var(Vehicle) float LongDamping;

var(Vehicle) float MaxStrafeForce;
var(Vehicle) float LatDamping;

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

// User input (range -1 to 1):
var float CurrentThrust;
var float CurrentStrafe;
var vector CurrentDirection; // Should be vector(ViewRotation)

cpptext
{
	UPX_VehicleHover() {}
	void DrawPreview(FSceneNode* Frame);
	void InitPhysics(PX_SceneBase* Scene);
}

defaultproperties
{
	bStayUpright=true
	CurrentDirection=(X=1)
	InertiaTensor=(X=3,Y=3,Z=1)
	
	HoverSoftness=0.75
	HoverCheckDist=60
	MaxThrustForce=900
	LongDamping=0.9
	MaxStrafeForce=700
	LatDamping=0.25
	TurnTorqueFactor=1000
	TurnTorqueMax=250
	TurnDamping=40
	MaxYawRate=2
	PitchTorqueFactor=200
	PitchTorqueMax=9
	PitchDamping=20
	RollTorqueTurnFactor=450
	RollTorqueStrafeFactor=50
	RollTorqueMax=12.5
	RollDamping=30
}