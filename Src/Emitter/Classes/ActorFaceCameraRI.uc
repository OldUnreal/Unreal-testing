//=============================================================================
// Actor Face Camera RI - Written by .:..:
//=============================================================================
class ActorFaceCameraRI extends RenderIterator
			native;

var() bool bFaceYaw; // Should face with Yaw at camera.
var() bool bFacePitch; // Should face with Pitch at camera
var() bool bFaceRoll; // Should face with Roll at camera (normally 0)
var() bool bFaceCameraRotation; // Should use camera rotation as base.
var() rotator RotationModifier; // Additional rotation to the current result.
var bool bUSEventCheck;

Event ModifyCameraLoc( Canvas C, out rotator ActorRot );

defaultproperties
{
	bFaceYaw=True
	bFacePitch=True
	bFaceRoll=True
}
