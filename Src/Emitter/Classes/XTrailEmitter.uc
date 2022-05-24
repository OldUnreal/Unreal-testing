// A trail emitter which leaves a trail behind as it moves.
Class XTrailEmitter extends XEmitter
	Abstract
	Native;

var(EmTrail) enum ETrailType
{
	TRAIL_Sheet, // Single sheet trailer
	TRAIL_DoubleSheet // Cross shaped trailer
} TrailType;
var(EmTrail) float TrailTreshold,MaxTrailLength,TextureUV[4];
var(EmTrail) vector SheetUpdir; // If non-zero, a custom up axis to use.
var(EmTrail) bool bSmoothEntryPoint; // Made trail start and end always start with 0 opacity.
var(EmTrail) bool bDynamicParticleCount; // Trail segments are split by TrailTreshold value instead of time/max particles.
var(EmTrail) bool bTexContinous; // Trail texture is continuent.
var(EmTrail) bool bSheetRelativeToRotation; // With SheetUpDir non-zero, it should be relative to particle rotation.
var(EmTrail) bool bFadeByOwnerParticle; // This trail should fade out along with owner particle.

defaultproperties
{
	TrailType=TRAIL_DoubleSheet
	TrailTreshold=5
	MaxTrailLength=40
	bSmoothEntryPoint=true
	bDynamicParticleCount=true
	bFadeByOwnerParticle=true
	TextureUV(0)=1
	TextureUV(1)=1
}