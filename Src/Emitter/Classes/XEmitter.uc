// Normal particle emitter
Class XEmitter extends XParticleEmitter
	Native
	Abstract;

enum ESpawnPosType
{
	SP_Box,
	SP_Sphere,
	SP_Cylinder,
	SP_BoxSphere,
	SP_BoxCylinder
};
struct export SpeedRangeType
{
	var() float VelocityScale,Time;
};
struct export Speed3DType
{
	var() vector VelocityScale; // Velocity/DrawScale of the particles.
	var() float Time; // Time range of particle lifespan 0-1.
};
struct export RevolveScaleType
{
	var() vector RevolutionScale;
	var() float Time;
};
struct export ScaleRangeType
{
	var() float DrawScaling,Time;
};
struct export ColorScaleRangeType
{
	var() float Time;
	var() vector ColorScaling;
};
enum EEmitterTriggerType
{
	ETR_ToggleDisabled,
	ETR_ResetEmitter,
	ETR_SpawnParticles
};
enum EEmitterPartCol
{
	ECT_HitNothing,
	ECT_HitWalls,
	ECT_HitActors,
	ECT_HitProjTargets
};
enum ESpriteAnimType
{
	SAN_None, // No animationing, just use current frame
	SAN_PlayOnce, // Play once through animation on it's lifetime
	SAN_PlayOnceInverted, // Play once but inverted the animation.
	SAN_LoopAnim // Constantly loop the animation over and over like any sprite
};

// Natively updated variables, do not touch.
var transient float NextParticleTime,SpawnInterval,ResetTimer;
var transient Coords CacheRot;
var transient vector OldSpawnPosition;
var transient BoundingBox RendBoundingBox;

var transient array<XEmitter> TSpawnC,TLifeTimeC,TDestructC,TWallHitC; // For in game runtime to use.

// Obsolete (but remains for backwards compatibility):
var array<XEmitter> SpawnCombiners,LifeTimeCombiners,DestructCombiners,WallHitCombiners; // For editor to save list and implement in map.
var array< class<XEmitter> > ParticleSpawnCClass; // Class definition for mod authors (for ready-to-use FX)
var array< class<XEmitter> > ParticleKillCClass; // Class definition for mod authors (for ready-to-use FX)
var array< class<XEmitter> > ParticleWallHitCClass; // Class definition for mod authors (for ready-to-use FX)
var array< class<XEmitter> > ParticleLifeTimeCClass; // Class definition for mod authors (for ready-to-use FX)
var(EmCombiner) name ParticleSpawnTag; // A second emitter to emit particle over spawn location of a new particle.
var(EmCombiner) name ParticleKillTag; // A second emitter to emit particle over kill location of a particle.
var(EmCombiner) name ParticleWallHitTag; // A second emitter to emit particle over wallhit location of a particle.
var(EmCombiner) name ParticleLifeTimeTag; // Emit this particle every X amount of seconds of this particles lifetime.

var(EmGeneral) const int MaxParticles; // Maximum particles of this emitter.
var(EmGeneral) float ParticlesPerSec; // Number of particles that should spawn per second (0 = LifeSpan/MaxParticles).
var(EmGeneral) float LODFactor; // Increased time delay on particle emitting while on low detail level.
var(EmGeneral) FloatRange LifetimeRange; // Particle lifespan.
var(EmGeneral) FloatRange AutoResetTime; // With bAutoReset, reset time.
var(EmGeneral) FloatRange StartupDelay; // Delay in seconds before Emitter activates (can be used for triggered emitters to delay an effect).
var(EmGeneral) Actor FinishedSpawningTrigger; // Single actor to be triggered when all particles are spawned out.
var(EmRevolution) RangeVector RevolutionOffset; // Particle revolution offset, added to this emitters location.
var(EmRevolution) RangeVector RevolutionsPerSec; // Number of revolutions per second.
var(EmRevolution) array<RevolveScaleType> RevolutionTimeScale; // Revolution time scale.
var(EmRevolution) vector RevolutionOffsetUnAxis; // Revolution offset (per axis) should move this fast with the particle velocity.
var(EmVisuals) array<Texture> ParticleTextures; // Random particle textures (or animation).
var(EmVisuals) ERenderStyle ParticleStyle; // Style of the particles.
var(EmFade) ERenderStyle FadeStyle; // While particle is fading use this style (STY_None = ParticleStyle).
var(EmCombiner) export editinline array<XEmitter> SpawnCombiner; // A second emitter to emit particle over spawn location of a new particle.
var(EmCombiner) export editinline array<XEmitter> KillCombiner; // A second emitter to emit particle over kill location of a particle.
var(EmCombiner) export editinline array<XEmitter> WallHitCombiner; // A second emitter to emit particle over wallhit location of a particle.
var(EmCombiner) export editinline array<XEmitter> LifeTimeCombiner; // Emit this particle every X amount of seconds of this particles lifetime.
var(EmCombiner) export editinline array<XEmitter> IdleCombiner; // An emitter that is simply idle and doesn't interact with other emitters (useful for multi-emitter effect on trigger).
var(EmCombiner) IntRange CombinedParticleCount; // When this Emitter actor is a combiner, spawn this amount of particles.
var(EmCombiner) FloatRange ParticleLifeTimeSDelay; // Spawn delay for lifetime combiner.
var(EmCombiner) export editinline XTrailEmitter ParticleTrail; // Trail that should appear for each particle.
var(EmFade) float FadeInTime,FadeOutTime; // Scaling from 0 to 1 (in lifetime scale). For SpriteEmitters set bUnlit false to use alphablend fading.
var(EmFade) float FadeInMaxAmount; // Max scaleglow when on full fade in.
var(EmVisuals) FloatRange StartingScale; // Initial scaling of the particles.
var(EmVisuals) RangeVector Scale3DRange; // Initial 3D scaling of the particles.
var(EmVisuals) array<ScaleRangeType> TimeScale; // Time scaled particle scale.
var(EmVisuals) array<Speed3DType> TimeDrawScale3D; // Time scaled particles 3D scale.
var(EmVisuals) ESpriteAnimType SpriteAnimationType;
var(EmVisuals) float PartSpriteForwardZ; // With sprite particles, how much forward should their Z offset be.
var(EmVisibility) BoundingBox VisibilityBox;
var(EmVisibility) float CullDistance; // Only render when camera is closer than this range.
var(EmVisibility) float CullDistanceFadeDist; // Fade out distance scaling (scaled by CullDistance), where particles should start fading out.
var(EmPosition) RangeVector BoxLocation;
var(EmPosition) FloatRange SphereCylinderRange;
var(EmPosition) ESpawnPosType SpawnPosType;
var(EmPosition) vector SpawnOffsetMultiplier;
var(EmMeshPos) Actor UseActorCoords; // Use actor mesh vertexes as random spawn positions.
var(EmMeshPos) BoundingBox VertexLimitBBox; // Only spawn in vertexes within this bounding box
var(EmMeshPos) int SingleIVert; // Only spawn in this vertex index.
var(EmTrigger) EEmitterTriggerType TriggerAction;
var(EmTrigger) IntRange SpawnParts;
var(EmSpeed) array<SpeedRangeType> SpeedScale; // Set speedtime to something else then 0 to make it used (and always start from lowest time and go higher).
var(EmSpeed) RangeVector ParticleAcceleration;
var(EmSpeed) RangeVector BoxVelocity;
var(EmSpeed) FloatRange SphereCylVelocity;
var(EmSpeed) ESpawnPosType SpawnVelType;
var(EmSpeed) vector VelocityLossRate;
var(EmSpeed) array<Speed3DType> SpeedTimeScale3D;
var(EmCollision) EEmitterPartCol ParticleCollision;
var(EmCollision) EHitEventType WallImpactAction,WaterImpactAction;
var(EmCollision) vector ParticleExtent,ParticleBounchyness;
var(EmCollision) float HittingActorKickVelScale; // Allow hitting actor to kick the particles.
var(EmCollision) float MinBounceVelocity; // At least have this high speed after bounce in order to continue.
var(EmSound) ParticleSndType ImpactSound,SpawnSound,DestroySound;
var(EmSound) float MinImpactVelForSnd; // Minimum impact velocity for impact sound.
var array<XParticleForces> ForcesList; // This is the actual list, filled in by editor from native codes.
var(EmForces) name ForcesTags[4]; // List of particle force actors in level, 'ForcesListCount' defines the count of valid ones in this list.

var(EmVisuals) RangeVector ParticleColor; // Particle spawn color
var(EmVisuals) array<ColorScaleRangeType> ParticleColorScale; // Particle lifespan color scale
var(EmCorona) RangeVector CoronaColor;
var(EmCorona) texture CoronaTexture;
var(EmCorona) float CoronaFadeTimeScale,CoronaMaxScale,CoronaScaling,MaxCoronaDistance;
var(EmCorona) vector CoronaOffset;

// Bitmask
var(EmRevolution) bool bRevolutionEnabled,bEffectsVelocity;
var(EmGeneral) bool bDisabled,bRespawnParticles,bAutoDestroy,bAutoReset,bSpawnInitParticles,bDisableRender;
var(EmVisuals) bool bUseRandomTex; // If enabled, it will use random texture, otherwise animate (starting from tex[0]->tex[X])
var(EmVisibility) bool bBoxVisibility,bAutoVisibilityBox; // Should render only when player sees the box bounds.
var(EmVisibility) bool bDistanceCulling;
var(EmVisibility) bool bStasisEmitter; // Only render when emitter zone has been recently rendered.
var(EmVisibility) bool bNoUpdateOnInvis; // Stop updating emitter particles when not rendered.
var(EmPosition) bool bRelativeToRotation;
var(EmPosition) bool bUseRelativeLocation; // Location/Rotation/Velocity should be relative to emitter actor?
var(EmPosition) bool bGradualSpawnCoords; // As Emitter actor moves, spawn them smoothly between the old and new location.
var(EmMeshPos) bool bUseMeshAnim; // Slower: use mesh animated frame rather than static frame.
var(EmSpeed) bool bVelRelativeToRotation,bCylRangeBasedOnPos,bAccelRelativeToRot;
var(EmCorona) bool bCheckLineOfSight,bActorsBlockSight;
var(EmCorona) bool bParticleCoronaEnabled;
var(EmCorona) bool bCOffsetRelativeToRot; // Corona offset should be relative to particle rotation?

// PhysX
var(EmPhysX) bool bEnablePhysX; /* Enable PhysX for particles.
ParticleAcceleration works as gravity value.
Set PhysicsData PX_RigidBodyData for this actor for parameters.
Do Note that Particle Forces do not work together with this other then kill force.*/

var transient bool bHasLossVel,bAllParticlesSpawned;
var transient private bool bInitCombiners;
var const bool bRotationRequest,bNeedsTexture;
var bool BACKUP_Disabled;

native(1766) final function SpawnParticles( int Count );
native(1767) final function SetMaxParticles( int MaxParts );
native(1768) final function Kill(); // Stop spawning particles and auto-destroy when all particles are gone.
native(1769) final function EmTrigger(); // Trigger this emitter.

simulated function PostBeginPlay()
{
	BACKUP_Disabled = bDisabled;
}
simulated function Trigger( Actor Other, Pawn EventInstigator )
{
	EmTrigger();
}
simulated function Reset()
{
	bDisabled = BACKUP_Disabled;
}

simulated final function SwapFloatMirror( out float A, out float B )
{
	local float T;
	
	T = A;
	A = -B;
	B = -T;
}

simulated function OnMirrorMode()
{
	SwapFloatMirror(BoxVelocity.Y.Min, BoxVelocity.Y.Max);
	SwapFloatMirror(ParticleAcceleration.Y.Min, ParticleAcceleration.Y.Max);
	SwapFloatMirror(BoxLocation.Y.Min, BoxLocation.Y.Max);
}

defaultproperties
{
	bRespawnParticles=True
	MaxParticles=50
	ParticleTextures(0)=Texture'S_Pawn'
	ParticleStyle=STY_Translucent
	FadeOutTime=1
	StartingScale=(Min=1,Max=1)
	FadeInMaxAmount=1
	bSpawnInitParticles=True
	LifetimeRange=(Min=4,Max=4)
	ParticleBounchyness=(X=1,Y=1,Z=1)
	bStasisEmitter=True
	ImpactSound=(SndPitch=(Min=1,Max=1),SndRadius=(Min=500,Max=500),SndVolume=(Min=1,Max=1))
	SpawnSound=(SndPitch=(Min=1,Max=1),SndRadius=(Min=500,Max=500),SndVolume=(Min=1,Max=1))
	DestroySound=(SndPitch=(Min=1,Max=1),SndRadius=(Min=500,Max=500),SndVolume=(Min=1,Max=1))
	SpawnOffsetMultiplier=(X=1,Y=1,Z=1)
	bEffectsVelocity=True
	SingleIVert=-1
	VisibilityBox=(Min=(X=-128,Y=-128,Z=-128),Max=(X=128,Y=128,Z=128))
	CullDistance=2000
	CombinedParticleCount=(Min=1,Max=1)
	ParticleLifeTimeSDelay=(Min=0.2,Max=0.5)
	bNoDelete=False
	bNoUpdateOnInvis=True
	CoronaColor=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
	Scale3DRange=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
	bCheckLineOfSight=true
	CoronaFadeTimeScale=2
	CoronaMaxScale=2
	CoronaScaling=1
	MaxCoronaDistance=2000
	WallImpactAction=HIT_Bounce
	LODFactor=1.85
	bUseMeshAnim=true
	CullDistanceFadeDist=1
	ParticleColor=(X=(Min=1,Max=1),Y=(Min=1,Max=1),Z=(Min=1,Max=1))
	bNeedsTexture=true
}