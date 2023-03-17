//=============================================================================
// PX_VehiclePlane: Plane craft vehicle behaviour.
//=============================================================================
Class PX_VehiclePlane extends PX_VehicleBase
	native;

// Flying Parameters
var(Vehicle) InterpCurve LiftCoefficientCurve; // Lift potential while flying within specific degrees of movement.
var(Vehicle) InterpCurve DragCoefficientCurve; // Drag with said degrees of movement.
var(Vehicle) float AirFactor; // Technically this should be air density * wingspan area
var(Vehicle) float MaxStrafe; // Strafe speed while on ground.
var(Vehicle) float MaxThrust;
var(Vehicle) float ThrustAcceleration;

// Hover Stuff
var(Vehicle) array<vector> ThrusterOffsets;
var(Vehicle) float HoverSoftness;
var(Vehicle) float HoverCheckDist;

var(Vehicle) float PitchTorque, PitchDamping;
var(Vehicle) float BankTorque, BankDamping;

var(Vehicle) float TakeoffSpeed; // If EngineSpeed gets over this rate, lower gravity and disable Upright mode.

var bool bIsOnGround, bIsFlying;

// User input (range -1 to 1):
var float CurrentThrust;
var float CurrentStrafe;
var vector2d CurrentTurn; // Should be delta view turn yaw/pitch (i.e: CurrentTurn.X = ViewRotation.Yaw-OldRotation.Yaw)

cpptext
{
	UPX_VehiclePlane() {}
	void DrawPreview(FSceneNode* Frame);
	void InitPhysics(PX_SceneBase* Scene);
}

defaultproperties
{
	bStayUpright=true
	InertiaTensor=(X=10,Y=10,Z=2)
	
	LiftCoefficientCurve=(Points=((InVal=-180,OutVal=0.0),(InVal=-10.0,OutVal=0.0),(InVal=0.0,OutVal=0.4),(InVal=6.0,OutVal=0.8),(InVal=10.0,OutVal=1.2),(InVal=12.0,OutVal=1.4),(InVal=20.0,OutVal=0.8),(InVal=60.0,OutVal=0.6),(InVal=90.0,OutVal=0.0),(InVal=180.0,OutVal=0.0)))
	DragCoefficientCurve=(Points=((InVal=-180,OutVal=0.0),(InVal=-90.0,OutVal=1.2),(InVal=-10.0,OutVal=0.1),(InVal=-5.0,OutVal=0.35),(InVal=0.0,OutVal=0.01),(InVal=5.0,OutVal=0.35),(InVal=10.0,OutVal=0.1),(InVal=15.0,OutVal=0.3),(InVal=60.0,OutVal=1.0),(InVal=90.0,OutVal=1.2),(InVal=180.0,OutVal=0.0)))
    AirFactor=0.00025
	MaxThrust=500.0
	TakeoffSpeed=800
	MaxStrafe=250.0
    PitchTorque=900.0
    BankTorque=900.0
	PitchDamping=20
	BankDamping=40
    ThrustAcceleration=250.0
	HoverSoftness=0.75
	HoverCheckDist=40
}