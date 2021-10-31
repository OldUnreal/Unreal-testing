//===========================================================================
// base class for all beam emitter scripts
//===========================================================================
class UIBeam extends UIFX abstract;

enum EMeshOrientation
{
	OR_XAxis,
	OR_YAxis,
	OR_ZAxis
};

simulated function vector RandLoc(vector EffectArea)
{
	local vector NewLoc;

	NewLoc.Z=Location.Z + (1-FRand()*2) * EffectArea.Z;
	NewLoc.X=Location.X + (1-FRand()*2) * EffectArea.X;
	NewLoc.Y=Location.Y + (1-FRand()*2) * EffectArea.Y;

	return NewLoc;
}
