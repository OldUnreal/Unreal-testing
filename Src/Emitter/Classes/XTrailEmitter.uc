// A trail emitter which leaves a trail behind as it moves.
Class XTrailEmitter extends XEmitter
	Abstract
	Native;

var const transient XTrailParticle ParticleData;
var(EmTrail) enum ETrailType
{
	TRAIL_Sheet, // Single sheet trailer
	TRAIL_DoubleSheet // Cross shaped trailer
} TrailType;
var(EmTrail) float TrailTreshold,MaxTrailLength,TextureUV[4];
var(EmTrail) vector SheetUpdir;

struct export TrailOffsetPart
{
	var vector Location,Velocity,Color,Accel,Z;
	var float LifeSpan[3],Scale,X;
	
	cpptext
	{
		inline FLOAT GetLifeSpanScale()
		{
			return (LifeSpan[0]/LifeSpan[1]);
		}
		inline FLOAT GetLifeSpanScaleNeq()
		{
			return 1.f - (LifeSpan[0]/LifeSpan[1]);
		}
		inline FLOAT GetEndTimeSpan()
		{
			return (LifeSpan[2]==0 ? 1.f : LifeSpan[0]/LifeSpan[2]);
		}
		inline FLOAT GetEndTimeSpanReverse()
		{
			return (LifeSpan[2]==0 ? 0.f : (1.f-LifeSpan[0]/LifeSpan[2]));
		}
	}
};
var transient array<TrailOffsetPart> Trail;
var transient vector OldTrailSpot;
var transient float TexOffset;

var(EmTrail) bool bSmoothEntryPoint,bDynamicParticleCount,bTexContinous;
var transient bool bSettingTrail;

defaultproperties
{
	TrailType=TRAIL_DoubleSheet
	RenderIteratorClass=Class'TrailEmitterRender'
	TrailTreshold=5
	MaxTrailLength=40
	bSmoothEntryPoint=true
	bDynamicParticleCount=true
	TextureUV(0)=1
	TextureUV(1)=1
}