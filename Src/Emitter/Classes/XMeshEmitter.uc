// Mesh particle emitter
Class XMeshEmitter extends XEmitter
	Native
	Abstract;

enum EEmPartRotType
{
	MEP_DesiredRot,
	MEP_FacingCamera,
	MEP_YawingToCamera
};
struct export AnimationType
{
	var() name AnimSeq;
	var() float Frame,Rate;
	var() bool bAnimLoop;
};

var(EmMesh) Mesh ParticleMesh;
var(EmMesh) ByteRange ParticleFatness;
var(EmRotation) RangeVector RotationsPerSec;
var(EmRotation) RangeVector InitialRot;
var(EmRotation) EEmPartRotType ParticleRotation;
var(EmAnim) name ParticleAnim;
var(EmAnim) float PartAnimRate;
var(EmAnim) float PartAnimFrameStart;
var(EmAnim) Actor AnimateByActor;
var(EmAnim) array<AnimationType> RandAnims; // If at least one random frame is set, disregard the other anim props.

// Bitmask
var(EmMesh) bool bRenderParticles,bParticlesRandFrame,bMeshEnviromentMapping;
var(EmRotation) bool bRelativeToMoveDir;
var(EmAnim) bool bPartAnimLoop,bAnimateParticles;
var(EmPhysX) bool bUsePhysXRotation; // Use particle PhysX rotation rather then particle rotation.

defaultproperties
{
	ParticleMesh=Mesh'WoodenBoxM'
	bPartAnimLoop=True
	bRotationRequest=True
	ParticleFatness=(Min=128,Max=128)
	bNeedsTexture=false
}
