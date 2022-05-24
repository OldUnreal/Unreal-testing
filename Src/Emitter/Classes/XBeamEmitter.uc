// Beam particle emitter
Class XBeamEmitter extends XEmitter
	Native
	Abstract;

var(EmBeam) enum EBeamTargetType
{
	BEAM_Velocity, // Use particle velocity as target offset
	BEAM_BeamActor, // Use Beam Target Actor + Offset as target
	BEAM_Offset, // Use offset as target
	BEAM_OffsetAsAbsolute // Use offset in world location as target
} BeamTargetType;

struct export FBeamTargetPoint
{
	var() Actor TargetActor;
	var() vector Offset;
};

var(EmBeam) array<FBeamTargetPoint> BeamTarget; // List of beam targets (will be chosen in random)
var(EmBeam) array<ScaleRangeType> NoiseTimeScale; // Noise time scaling
var(EmBeam) float NoiseSwapTime; // While 'bDynamicNoise' and 'bDoBeamNoise', how often will the beams swap noise pose (in seconds)
var(EmBeam) byte Segments; // Number of segments on the Beam model
var(EmBeam) float TextureUV[4]; // UV mapping of the texture
var(EmBeam) RangeVector NoiseRange; // While 'bDoBeamNoise', noise range between the segments
var(EmBeam) float TurnRate; // While 'bDirectional' how fast will the beam turn towards its target
var(EmBeam) array<float> BeamPointScaling; // Beam scaling list (starting from start point)
var(EmBeam) Texture StartTexture,EndTexture; // Final and First segment texture (optional)

// Internal data
var pointer<class UBeamMesh*> RenderDataModel;

// Bitmask
var(EmBeam) bool bDynamicNoise; // With BeamNoise, dymaically swap between positions at NoiseSwapTime interval.
var(EmBeam) bool bDoBeamNoise; // Beam should make noise with NoiseRange scale.
var(EmBeam) bool bEndPointFixed; // The endpoint should always be locked on to exact position.

simulated function OnMirrorMode()
{
	local int i;
	
	Super.OnMirrorMode();
	for( i=0; i<BeamTarget.Size(); ++i )
		BeamTarget[i].Offset.Y *= -1;
}

defaultproperties
{
	TurnRate=1
	bDirectional=True
	bUnlit=True
	TextureUV(0)=1
	TextureUV(1)=1
	NoiseSwapTime=1
}
