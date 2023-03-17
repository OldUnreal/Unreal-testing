//=============================================================================
// PX_VehicleBase: Vehicle behaviour physics.
//=============================================================================
Class PX_VehicleBase extends PX_RigidBodyData
	native
	abstract;

var const float EngineSpeed; // Current speed of the engine.
var const bool bDriving; // Currently controls are enabled.

cpptext
{
	UPX_VehicleBase() {}
	virtual void SetDriveMode(UBOOL bDrive);
}

native final function SetDriving( bool bDrive ); // Set to driving mode (apply controls).

defaultproperties
{
	AngularDamping=0.1
	LinearDamping=0.1
}