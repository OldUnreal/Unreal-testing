// Advanced sprite emitter
Class XSpriteEmitter extends XEmitter
Native
Abstract;

var const Mesh SheetModel;

enum ESprPartRotType
{
	SPR_DesiredRot,
	SPR_RelFacingVelocity,
	SPR_AbsFacingVelocity,
	SPR_RelFacingNormal,
	SPR_AbsFacingNormal
};

var(EmRotation) RangeVector RotationsPerSec;
var(EmRotation) RangeVector InitialRot;
var(EmRotation) vector RotNormal;
var(EmRotation) ESprPartRotType ParticleRotation;
var(EmRotation) float RotateByVelocityScale;

defaultproperties
{
	SheetModel=Mesh'EmitSheetM'
	RotNormal=(Z=1)
	bRotationRequest=True
}
