//================================================================
// class: UIParticleSystem
// file: UIParticleSystem.uc
// author: Raven
// www: http://turniej.unreal.pl/rp
// description:
// base class for particle system.
// store structure definitions in case someone will need'em
// in subclasses other then 'ParticleEmitter'
//================================================================
class UIParticleSystem extends UIFX abstract;
#exec TEXTURE IMPORT NAME=ParticleEmitter FILE="Textures\Icons\Emitter.pcx" GROUP=Icons LODSET=2
#exec TEXTURE IMPORT NAME=ParticleForce FILE="Textures\Icons\Force.pcx" GROUP=Icons LODSET=2
#exec TEXTURE IMPORT NAME=ParticlePath FILE="Textures\Icons\Path.pcx" GROUP=Icons LODSET=2 FLAGS=2
#exec TEXTURE IMPORT NAME=ParticleCombiner FILE="Textures\Icons\Combiner.pcx" GROUP=Icons LODSET=2
//================================================================
// ENUMS
//================================================================
enum EAccelType
{
	ACC_Addictive,                                                     // acceleration will be added to velocity.
	ACC_Multiply                                                       // velocity will be multiplied by acceleration.
};
enum ESizeType
{
	ST_Normal,                                                         // particle will not change size
	ST_Grow,                                                           // particle will grow (ParticleGrowth)
	ST_Shrink,                                                         // particle will shrink (ParticleShrink)
	ST_Cycle                                                           // particle will cyclically shrinks and grow
};
enum ESizing
{
	SIZING_Infinity,                                                   // particle will grow/shrink till lifespan ends
	SIZING_UserDecided                                                 // particle will grow/shrink till DrawScale reach specifeid size
};
enum ETAnim
{
	AN_PlayOnce,                                                       // should animation be played only once
	AN_Loop                                                            // or should it be looped
};
enum EFType
{
	FACE_None,                                                         // rotation is not changed
	FACE_Velocity,                                                     // mesh always faces velocity
	FACE_Actor                                                         // mesh always faces chosen actor
};
enum EDest
{
	DEST_None,                                                         // no destination :)
	DEST_Once,                                                         // will pick target's destination only once
	DEST_Seek                                                          // will constantly try to found a way to destination actor
};
enum EDestActor
{
	DA_Chosen,                                                         // destination actor is used as a target
	DA_Self                                                            // emitter is particle destination
};
enum ESType
{
	ST_Normal,                                                        // no special calculations
	ST_Box,                                                           // particles are spawned inside a box
	ST_Sphere,                                                        // particles are spawned inside a sphere
	ST_Cylindrical                                                    // particles will be spawned inside of a cylinder
};
enum ESpawnStyle
{
	SS_BindToParticle,
	SS_StayStill
};
//================================================================
// AdditionalSpawn Effect
//================================================================
struct SSpawnEffect
{
	var() bool bUseSpawnEffect;
	var() class<Actor> SpawnedEffect;
	var() ESpawnStyle SpawnStyle;
};
//================================================================
// GLOBAL STRUCTURE
//================================================================
struct SGlobal                                                        // global can be force tu used instead of variables in MAIN
{
	var() float ParticleLifeTime;                                      // lifespan (in seconds)
	var() float ParticleLifeTimeVariance;                              // lifespan variance (in seconds)
	var() bool bDefineSpeedAsVector;                                   // defines speed as a vector
	var() vector BaseSpeed;                                            // base particle speed (if bDefineSpeedAsVector is true)
	var() float SpeedVariance;                                         // speed variance
	var() float ParticleSpeed;                                         // speed when particle system is rotated as generator
	var() float SprayFactor;                                           // spray
	var() float SprayFactorVariance;                                   // spray vairance
};
//================================================================
// TEMPLATE STRUCTURES
//================================================================
struct SMain
{
	var() bool bForceGlobalSettings;                                   // if true global settings will be used
	var() rotator ParticleRotation;                                    // custom particle rotation (useful when we have mesh instead of sprite)
	var() bool bUseParticleRotation;                                   // should we use custom particle rotation
	var() float ParticleLifeTime;                                      // lifespan (in seconds)
	var() float ParticleLifeTimeVariance;                              // lifespan variance (in seconds)
	var() float ParticleSlowingDownFactor;                             // particle slow down factor (can not be 0 (!!) 1.0 - no slow down, higher then 1.0 - faster, lower then 1.0 - lower)
	var() bool bMoveSmooth;                                            // particle will move smooth
	var() bool bDefineSpeedAsVector;                                   // defines speed as a vector
	var() vector BaseSpeed;                                            // base particle speed (if bDefineSpeedAsVector is true)
	var() float SpeedVariance;                                         // speed variance
	var() float ParticleSpeed;                                         // speed when particle system is rotated as generator
	var() float SprayFactor;                                           // spray
	var() float SprayFactorVariance;                                   // spray vairance
};
struct SAnimation
{
	var() texture AnimTextures[60];                                    // animation textures
	var() int NumOfTextures;                                           // number of textures
	var() bool DefineAnimationStorage;                                 // should animated textures be taken from 'AnimationStorage' class (for coders)
	var() class<UIParticleAnimationStorage> ParticleAnimationStorage;  // stores animations (for coders)
};
struct SAdvanced
{
	var() bool bUseParticleClass;                                      // can we use custom class
	var() class<UIBasicParticle> ParticleClass;                        // custom class
};
struct SSize
{
	var() float ParticleDrawScale;                                     // particle size
	var() float ParticleDrawScaleVariance;                             // particle size variance
	var() float ParticleGrowth;                                        // particle grow rate
	var() ESizeType SizeType;                                          // size type
	var() float ParticleShrink;                                        // particle shring rate
	var() float MinSize;                                               // the smallest of particle (only if SizeType is ST_Cycle or Sizing is SIZING_UserDecided)
	var() float MaxSize;                                               // the biggest size of particle (only if SizeType is ST_Cycle or Sizing is SIZING_UserDecided)
	var() ESizing Sizing;                                              // describes end size of particle (not used if SizeType is ST_Cycle)
//   var() bool bCycleSize;                                           // will cyclically makes particle grow and shrink
};
struct SDisplay
{
	var() ERenderStyle ParticleStyle;                                  // particle render style
	var() bool bUnlitParticle;                                         // is particle unlit
	var() bool bParticleCastShadow;                                    // particle cast shadow
	var() bool bParticleMeshEnviroMap;                                 // only when particle is a mesh
	var() bool bUseMesh;                                               // particle will use mesh instead of sprite
	var() mesh PraticleMesh;                                           // mesh (if use_mesh is true)
	var() bool bUseRandomTexture;                                      // uses random texture from anim_textures
	var() texture ParticleTexture;                                     // particle texture (if doesn't use particle animation
	var() bool bUseSpriteAnimation;                                    // particle will use sprite animation
};
struct SDecal
{
	var() texture ParticleDecalTexture;                                // texture used for decal
	var() bool ParticleSpawnDecal;                                     // particle will spawn decal (true) when they hit wall
	var() class<decal> ParticleDecal;                                  // decal class
	var() float ParticleDecalSize;                                     // decal size
	var() bool bLimitDecals;                                           // if true, decals will be limited
};
struct SSound
{
	var() sound BornSound;                                             // when particle starts it's life
	var() sound FlyingSound;                                           // particle flying sound
	var() sound DyingSound;                                            // particle dying sound
	var() sound LandingSound;                                          // particle landing sound
	var() sound HittingSound;                                          // when particle hit's wall
	var() sound TouchingSound;                                         // when particle hits an actor
	var() ESoundSlot ParticleSoundSlot;                                // sound slot
	var() float ParticleSoundVolume;                                   // sound volume
	var() bool ParticleSoundbNoOverride;                               // sound no override
	var() float ParticleSoundRadius;                                   // sound radius
	var() float ParticleSoundPitch;                                    // sound pitch
};
struct SLight
{
	var() bool CastLight;                                              // particle will cast light!!
};
struct SLightColor
{
	var() byte ParticleLightBrightness;                                // light brightness
	var() byte ParticleLightHue;                                       // light hue
	var() byte ParticleLightSaturation;                                // light satruation
};
struct SLighting
{
	var() ELightType  ParticleLightType;                               // light type (can lag :))
	var() ELightEffect ParticleLightEffect;                            // light effect (can lag :))
	var() byte ParticleLightRadius;                                    // light radius
	var() byte ParticleLightPeriod;                                    // light period
	var() byte ParticleLightPhase;                                     // light phase
	var() byte ParticleLightCone;                                      // light cone
	var() byte ParticleVolumeBrightness;                               // volume brightness
	var() byte ParticleVolumeRadius;                                   // volume radius
	var() byte ParticleVolumeFog;                                      // volume fog
};
struct SFading
{
	var() bool CanFadeOut;                                             // can fade out
	var() bool CanFadeIn;                                              // can fade in
	var() float InitailScaleGlow;                                      // initial glow
	var() float FadeOutTime;	               	                      // fade out time
	var() float FadeOutScaleFactor;                                    // feade out scale factor
	var() float FadeInTime;	                            	      // fade in time
	var() float FadeInScaleFactor;                                     // feade scale factor
};
struct SDamage
{
	var() bool ParticleGivesDamage;                                    // particle will give damage when touchening actor
	var() name ParticleDamageType;                                     // damage type
	var() int ParticleDamage;                                          // damage
	var() bool PlayerTakeDamage;                                       // player pawn can be damaged
	var() bool ScriptedPawnTakeDamage;                                 // scripted pawns can be damaged
	var() bool FlockPawnTakeDamage;                                    // flock pawns can be damaged
	var() bool OtherActorTakeDamage;                                   // all other actors such as eg. wooden boxes can be damaged
	var() int MomentumTransfer;                                        // momentum transfer
};
struct SPPhysics
{
	var() EPhysics ParticlePhysics;                                    // custom physic
	var() bool bCanAccelerate;                                         // particle can accelerate
	var() vector AccelerateFactor;                                     // accelerate factor
	var() vector TerminalVelocity;                                     // max accelerate
	var() EAccelType AccelerationType;                                 // acceleration type
};
struct SCollision
{                                                                     // acceleration type
	var() bool ParticlesUseCollision;                                   // particle shoud collide with world and actors?
	var() float ParticleCollisonRadius;                                 // collision radius
	var() float ParticleCollisonHeight;                                 // collision height
	var() bool CollideWithActors;                                       // will collide with actors if true
	var() bool BlockPlayers;                                            // will block players if true
	var() bool BlockActors;                                             // will block actors if true
	var() bool ParticleCollideWorld;                                    // will Collide world
	var() bool DestroyWhenTouch;                                        // will destroy particle when touching an actor
	var() bool DestroyWhenColideWorld;                                  // will destroy particle when touching world geometry (eg walls)
	var() bool DestroyWhenLand;                                         // will destroy particle when land
	var() bool DestroyWhenTouchWater;                                   // will destroy particle when touches water
	var() bool StopWhenTouchWall;                                       // will stop when touches world geometry
	var() bool StopWhenTouchPawn;                                       // will stop when touches pawn
	var() bool StickToWall;                                             // will stick to wall
	var() bool StickToPawn;                                             // will stick to pawn
	var() bool bSpawnLandEffect;                                        // spawn effect when landed
	var() class<actor> LandEffect;                                      // land effect
	var() bool bOverrideWaterEntrySound;                                // override default water entry sound (if particles_use_collision is false)
	var() sound WaterEntrySound;                                        // water entry sound
	var() bool bOverrideWaterEntryEffect;                               // override default water entry actor (if particles_use_collision is false)
	var() class<actor> WaterEntryActor;                                 // water entry actor
	var() bool bSpawnEffectOnDestroy;                                   // spawn effect when destroy
	var() class<actor> DestroyEffect;                                   // destroy effect
};
struct SBounce
{
	var() bool CanBounce;                                               // can we use bounce
	var() float BounceRatio;                                            // bounce ratio
	var() float BounceModifier;                                         // bounce height (when landed)
	var() bool EndlessBounce;                                           // will bounce till it die if true
	var() int BounceNum;                                                // if EndlessBounce is false this is number of bounces
};
struct SBuoyance
{
	var() bool CanBuoyance;                                             // can buoyance in water
	var() bool SplashWhenHitWater;                                      // splash when hit water
	var() bool SoundWhenHitWater;                                       // plays sound when hit water
	var() float ParticleBuoyancy;                                       // particle buoyancy
	var() float ParticleMass;                                           // particle mass
};
struct SVelocity
{
	var() bool bUseInvertVelocity;                                      // should velocity be inversed
	var() bool bLoop;                                                   //
	var() bool InvertX;                                                 // X-Axis velocity vill be inversed
	var() bool InvertY;                                                 // Y-Axis velocity vill be inversed
	var() bool InvertZ;                                                 // Z-Axis velocity vill be inversed
	var() float InvertDelay;                                            // inverse delay
};
struct SSpawnPlace
{
	var() vector OwnEffectArea;                                         // each template can override effect area
	var() bool bUseOwnEffectArea;                                       // overrided effect area
};
struct SDest
{
	var() actor Destination;                                            // particle destination
	var() EDest DestinationType;                                        // type of destination
	var() EDestActor DestinationActor;                                  // destination actor type
	var() bool bForceFollow;                                            // will ignore anything just to reach destination
};
struct SMesh
{
	var() bool bAnimatedMesh;                                           // if mesh have to be animated
	var() name AnimationName;                                           // name of animation which should be played
	var() float AnimationRate;                                          // animation rate
	var() float TweenRate;                                              // tween rate
	var() ETAnim AnimationType;                                         // animation type
	var() EFType FaceObject;                                            // object particle should face
	var() actor LookTarget;                                             // Used if DynamicRotation == FACE_Actor
	var() rotator MeshRotationRate;                                     // rotation rate (only if DynamicRotation == FACE_None)
};
struct SRot
{
	var() bool bRandomizeRotation;                                      // uses random spawn rotation
	var() bool bRandPitch;                                              // random pitch
	var() bool bRandYaw;                                                // random yaw
	var() bool bRandRoll;                                               // randomed roll
	var() rotator MinRotation;                                          // min rotation
	var() rotator MaxRotation;                                          // max rotation
	var() bool bForceRndRot;                                            // forces RotRand() function
	var() bool bAlignRotator;                                           // aligns current spawn rotator to emitters rotation
};
struct SAdvSpwn
{
	var() ESType SpawnType;                                          // Spawn type
	var() vector BoxMinArea;                                         // box min values
	var() vector BoxMaxArea;                                         // box max values
	var() float SphereRadius;                                        // sphere radius
	var() vector SpawnOffset;                                        // spawn offset
	var() bool bSpawnOnSurface;                                      // Should particles be spawn ONLY on spawn area surface
	var() float CylinderHeight;                                      // Cylinder height
	var() float CylinderRadius;                                      // Cylinder radius
	var() bool bAlignSpawnSurface;                                   // Should spawn area be rotated according to emitter rotation
	var() rotator AlignModifier;                                     // Modifies rotation afer it's aligned
};
struct SMisc
{
	var() float ParticlesBounce_Min;
	var() float ParticlesBounce_Max;
	var() bool ParticlesFixedTrailer;
	var() bool ParticlesUseJerkyness;
	var() float ParticlesJerkyness;
	var() bool bUseDistanceCulling;
	var() float PartVisibilityHeight;
	var() float PartVisibilityRadius;
};


//================================================================
// BASIC FUNCTIONS
//================================================================
simulated function int RandFloat(float max)
{
	local int num;
	local float delta;
	num = max;
	delta= max - num;

	if (rand(100)<delta*100) num++;
	return num;
}
simulated function int Jiiter(float max)
{
	return rand(2*max)-max;
}
simulated function vector RotateVector(rotator VRotation, vector VOffset)
{
	local vector X,Y,Z;
	GetAxes(VRotation,X,Y,Z);
	return VOffset.X * X + VOffset.Y * Y + VOffset.Z * Z;
}