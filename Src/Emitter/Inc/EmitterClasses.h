﻿/*===========================================================================
    C++ class definitions exported from UnrealScript.
    This is automatically generated by the tools.
    DO NOT modify this manually! Edit the corresponding .uc files instead!
===========================================================================*/
#if ((_MSC_VER) || (HAVE_PRAGMA_PACK))
#pragma pack (push,OBJECT_ALIGNMENT)
#endif

#ifndef EMITTER_API
#define EMITTER_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern EMITTER_API FName EMITTER_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(PostNetNotify)
AUTOGENERATE_NAME(NotifyNewParticle)
AUTOGENERATE_NAME(GetParticleProps)
AUTOGENERATE_NAME(ParticleWallHit)
AUTOGENERATE_NAME(ParticleZoneHit)
AUTOGENERATE_NAME(ModifyCameraLoc)

#ifndef NAMES_ONLY

enum EHitEventType
{
	HIT_DoNothing,
	HIT_Destroy,
	HIT_StopMovement,
	HIT_Bounce,
	HIT_Script,
	HIT_MAX,
};
enum EWeatherAreaType
{
	EWA_Box,
	EWA_Zone,
	EWA_Brush,
	EWA_MAX,
};
enum EFallingType
{
	EWF_Rain,
	EWF_Snow,
	EWF_Dust,
	EWF_Neighter,
	EWF_MAX,
};
enum ESpawnPosType
{
	SP_Box,
	SP_Sphere,
	SP_Cylinder,
	SP_BoxSphere,
	SP_BoxCylinder,
	SP_MAX,
};
enum EEmitterTriggerType
{
	ETR_ToggleDisabled,
	ETR_ResetEmitter,
	ETR_SpawnParticles,
	ETR_MAX,
};
enum EEmitterPartCol
{
	ECT_HitNothing,
	ECT_HitWalls,
	ECT_HitActors,
	ECT_HitProjTargets,
	ECT_MAX,
};
enum ESpriteAnimType
{
	SAN_None,
	SAN_PlayOnce,
	SAN_PlayOnceInverted,
	SAN_LoopAnim,
	SAN_MAX,
};
enum ETrailType
{
	TRAIL_Sheet,
	TRAIL_DoubleSheet,
	TRAIL_MAX,
};
enum ESprPartRotType
{
	SPR_DesiredRot,
	SPR_RelFacingVelocity,
	SPR_AbsFacingVelocity,
	SPR_RelFacingNormal,
	SPR_AbsFacingNormal,
	SPR_MAX,
};
enum EEmPartRotType
{
	MEP_DesiredRot,
	MEP_FacingCamera,
	MEP_YawingToCamera,
	MEP_MAX,
};
enum EBeamTargetType
{
	BEAM_Velocity,
	BEAM_BeamActor,
	BEAM_Offset,
	BEAM_OffsetAsAbsolute,
	BEAM_MAX,
};

struct FIntRange
{
	INT Min GCC_PACK(INT_ALIGNMENT);
	INT Max;

	inline INT GetValue() const
	{
		return (Min==Max ? Min : Min+(appRand() % (Max-Min)));
	}
};
struct FByteRange
{
	BYTE Min GCC_PACK(INT_ALIGNMENT);
	BYTE Max;

	inline BYTE GetValue() const
	{
		return (Min==Max ? Min : Min+(appRand() % (Max-Min)));
	}
};
struct FFloatRange
{
	FLOAT Min GCC_PACK(INT_ALIGNMENT);
	FLOAT Max;

	inline FLOAT GetValue() const
	{
		return (Min==Max ? Min : Min+(Max-Min)*appFrand());
	}
};
struct FRangeVector
{
	FFloatRange X GCC_PACK(INT_ALIGNMENT);
	FFloatRange Y;
	FFloatRange Z;

	inline FVector GetValue() const
	{
		return FVector(X.GetValue(), Y.GetValue(), Z.GetValue());
	}
};
struct FParticleSndType
{
	class USound* Sounds[8] GCC_PACK(INT_ALIGNMENT);
	FFloatRange SndPitch;
	FFloatRange SndRadius;
	FFloatRange SndVolume;
	BYTE SndCount;

	void PlaySoundEffect( const FVector &Location, ULevel* Level ) const;
	void InitSoundList();
};
struct FSpeedRangeType
{
	FLOAT VelocityScale GCC_PACK(INT_ALIGNMENT);
	FLOAT Time;
};
struct FSpeed3DType
{
	FVector VelocityScale GCC_PACK(INT_ALIGNMENT);
	FLOAT Time;
};
struct FRevolveScaleType
{
	FVector RevolutionScale GCC_PACK(INT_ALIGNMENT);
	FLOAT Time;
};
struct FScaleRangeType
{
	FLOAT DrawScaling GCC_PACK(INT_ALIGNMENT);
	FLOAT Time;
};
struct FColorScaleRangeType
{
	FLOAT Time GCC_PACK(INT_ALIGNMENT);
	FVector ColorScaling;
};
struct FTrailOffsetPart
{
	FVector Location GCC_PACK(INT_ALIGNMENT);
	FVector Velocity;
	FVector Color;
	FVector Accel;
	FVector Z;
	FLOAT LifeSpan[3];
	FLOAT Scale;
	FLOAT X;

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
};
struct FAnimationType
{
	FName AnimSeq GCC_PACK(INT_ALIGNMENT);
	FLOAT Frame;
	FLOAT Rate;
	BITFIELD bAnimLoop:1 GCC_PACK(INT_ALIGNMENT);
};
struct FFBeamTargetPoint
{
	class AActor* TargetActor GCC_PACK(INT_ALIGNMENT);
	FVector Offset;
};

class EMITTER_API AXRainRestrictionVolume : public AVolume
{
public:
	TArrayNoInit<class AXWeatherEmitter*> Emitters GCC_PACK(INT_ALIGNMENT);
	FVector BoundsMin;
	FVector BoundsMax;
	FBoundingBox RainBounds;
	BITFIELD bBoundsDirty:1 GCC_PACK(INT_ALIGNMENT);
	DECLARE_CLASS(AXRainRestrictionVolume,AVolume,0,Emitter)
	#include "AXRainRestrictionVolume.h"
};

class EMITTER_API AEmitterGarbageCollector : public AInfo
{
public:
	FLOAT CleanUpTime GCC_PACK(INT_ALIGNMENT);
	TArray<class ParticlesDataList*>* GarbagePtr;
	BITFIELD bCleanUp:1 GCC_PACK(INT_ALIGNMENT);
	DECLARE_CLASS(AEmitterGarbageCollector,AInfo,CLASS_Transient,Emitter)
	#include "AEmitterGarbageCollector.h"
};

class EMITTER_API ADistantLightActor : public ALight
{
public:
	FLOAT NewLightRadius GCC_PACK(INT_ALIGNMENT);
	DECLARE_CLASS(ADistantLightActor,ALight,0,Emitter)
	#include "ADistantLightActor.h"
};

class EMITTER_API AXParticleEmitter : public AActor
{
public:
	INT ActiveCount GCC_PACK(INT_ALIGNMENT);
	TArrayNoInit<class AXEmitter*> PartCombiners;
	BITFIELD bHasInitialized:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bKillNextTick:1;
	BITFIELD bHasSpecialParts:1;
	BITFIELD bWasPostDestroyed:1;
	BITFIELD bHasInitView:1;
	BITFIELD bUSNotifyParticles:1;
	BITFIELD bNotifyNetReceive:1;
	BITFIELD bUSModifyParticles:1;
	BITFIELD bNotOnPortals:1;
	DECLARE_FUNCTION(execAllParticles);
	DECLARE_FUNCTION(execSetParticlesProps);
	void eventParticleZoneHit(class AActor* Particle, class AZoneInfo* OtherZone)
	{
		struct { class AActor* Particle; class AZoneInfo* OtherZone; } Parms = { Particle, OtherZone };
		ProcessEvent(FindFunctionChecked(EMITTER_ParticleZoneHit),&Parms);
	}
	void eventParticleWallHit(class AActor* Particle, FVector HitNormal, FVector& HitLocation)
	{
		#if _USE_REF_PARMS
		struct { class AActor* Particle; FVector HitNormal; FVector* HitLocation; } Parms = { Particle, HitNormal, &HitLocation };
		#else
		struct { class AActor* Particle; FVector HitNormal; FVector HitLocation; } Parms = { Particle, HitNormal, HitLocation };
		#endif
		ProcessEvent(FindFunctionChecked(EMITTER_ParticleWallHit),&Parms);
		#if !_USE_REF_PARMS
		HitLocation=Parms.HitLocation;
		#endif
	}
	void eventGetParticleProps(class AActor* Particle, FVector& Pos, FVector& Vel, FRotator& Ro)
	{
		#if _USE_REF_PARMS
		struct { class AActor* Particle; FVector* Pos; FVector* Vel; FRotator* Ro; } Parms = { Particle, &Pos, &Vel, &Ro };
		#else
		struct { class AActor* Particle; FVector Pos; FVector Vel; FRotator Ro; } Parms = { Particle, Pos, Vel, Ro };
		#endif
		ProcessEvent(FindFunctionChecked(EMITTER_GetParticleProps),&Parms);
		#if !_USE_REF_PARMS
		Pos=Parms.Pos;
		Vel=Parms.Vel;
		Ro=Parms.Ro;
		#endif
	}
	void eventNotifyNewParticle(class AActor* Other)
	{
		ProcessEvent(FindFunctionChecked(EMITTER_NotifyNewParticle),&Other);
	}
	void eventPostNetNotify()
	{
		ProcessEvent(FindFunctionChecked(EMITTER_PostNetNotify),NULL);
	}
	DECLARE_CLASS(AXParticleEmitter,AActor,CLASS_Abstract,Emitter)
	#include "AXParticleEmitter.h"
};

class EMITTER_API AXWeatherEmitter : public AXParticleEmitter
{
public:
	INT ParticleCount GCC_PACK(INT_ALIGNMENT);
	FLOAT NextParticleTime;
	FLOAT SpawnInterval;
	FLOAT WallHitMinZ;
	class UMesh* SheetModel;
	class AVolume* RainVolume;
	FName WallHitEmitter;
	FName RainVolumeTag;
	FName WaterHitEmitter;
	TArrayNoInit<class AXRainRestrictionVolume*> NoRainBounds;
	TArrayNoInit<class AXEmitter*> WallHitEmitters;
	TArrayNoInit<class AXEmitter*> WaterHitEmitters;
	TArrayNoInit<class UTexture*> PartTextures;
	FVector LastCamPosition;
	FVector VecArea[2];
	FCoords CachedCoords;
	FCoords TransfrmCoords;
	FRangeVector Position;
	FRangeVector AppearArea;
	FRangeVector ParticlesColor;
	FFloatRange Lifetime;
	FFloatRange speed;
	FFloatRange Size;
	FFloatRange FadeOutDistance;
	FRainAreaTree* RainTree;
	BYTE WallHitEvent;
	BYTE WaterHitEvent;
	BYTE AppearAreaType;
	BYTE WeatherType;
	BYTE PartStyle;
	BITFIELD bUseAreaSpawns:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bParticleColorEnabled:1;
	BITFIELD bIsEnabled:1;
	BITFIELD bBoundsDirty:1;
	DECLARE_FUNCTION(execSetRainVolume);
	DECLARE_FUNCTION(execRemoveNoRainBounds);
	DECLARE_FUNCTION(execAddNoRainBounds);
	DECLARE_CLASS(AXWeatherEmitter,AXParticleEmitter,CLASS_Abstract,Emitter)
	#include "AXWeatherEmitter.h"
};

class EMITTER_API AXEmitter : public AXParticleEmitter
{
public:
	INT MaxParticles GCC_PACK(INT_ALIGNMENT);
	INT SingleIVert;
	FLOAT NextParticleTime;
	FLOAT SpawnInterval;
	FLOAT ResetTimer;
	FLOAT ParticlesPerSec;
	FLOAT LODFactor;
	FLOAT FadeInTime;
	FLOAT FadeOutTime;
	FLOAT FadeInMaxAmount;
	FLOAT PartSpriteForwardZ;
	FLOAT CullDistance;
	FLOAT CullDistanceFadeDist;
	FLOAT HittingActorKickVelScale;
	FLOAT MinBounceVelocity;
	FLOAT MinImpactVelForSnd;
	FLOAT CoronaFadeTimeScale;
	FLOAT CoronaMaxScale;
	FLOAT CoronaScaling;
	FLOAT MaxCoronaDistance;
	class AActor* FinishedSpawningTrigger;
	class AActor* UseActorCoords;
	class UTexture* CoronaTexture;
	FName ParticleSpawnTag;
	FName ParticleKillTag;
	FName ParticleWallHitTag;
	FName ParticleLifeTimeTag;
	FName ForcesTags[4];
	TArrayNoInit<class AXEmitter*> SpawnCombiners;
	TArrayNoInit<class AXEmitter*> LifeTimeCombiners;
	TArrayNoInit<class AXEmitter*> DestructCombiners;
	TArrayNoInit<class AXEmitter*> WallHitCombiners;
	TArrayNoInit<class AXEmitter*> TSpawnC;
	TArrayNoInit<class AXEmitter*> TLifeTimeC;
	TArrayNoInit<class AXEmitter*> TDestructC;
	TArrayNoInit<class AXEmitter*> TWallHitC;
	TArrayNoInit<FRevolveScaleType> RevolutionTimeScale;
	TArrayNoInit<class UTexture*> ParticleTextures;
	TArrayNoInit<class UClass*> ParticleSpawnCClass;
	TArrayNoInit<class UClass*> ParticleKillCClass;
	TArrayNoInit<class UClass*> ParticleWallHitCClass;
	TArrayNoInit<class UClass*> ParticleLifeTimeCClass;
	TArrayNoInit<FScaleRangeType> TimeScale;
	TArrayNoInit<FSpeed3DType> TimeDrawScale3D;
	TArrayNoInit<FSpeedRangeType> SpeedScale;
	TArrayNoInit<FSpeed3DType> SpeedTimeScale3D;
	TArrayNoInit<class AXParticleForces*> ForcesList;
	TArrayNoInit<FColorScaleRangeType> ParticleColorScale;
	FCoords CacheRot;
	FVector OldSpawnPosition;
	FBoundingBox RendBoundingBox;
	FFloatRange LifetimeRange;
	FFloatRange AutoResetTime;
	FRangeVector RevolutionOffset;
	FRangeVector RevolutionsPerSec;
	FVector RevolutionOffsetUnAxis;
	FIntRange CombinedParticleCount;
	FFloatRange ParticleLifeTimeSDelay;
	FFloatRange StartingScale;
	FRangeVector Scale3DRange;
	FBoundingBox VisibilityBox;
	FRangeVector BoxLocation;
	FFloatRange SphereCylinderRange;
	FVector SpawnOffsetMultiplier;
	FBoundingBox VertexLimitBBox;
	FIntRange SpawnParts;
	FRangeVector ParticleAcceleration;
	FRangeVector BoxVelocity;
	FFloatRange SphereCylVelocity;
	FVector VelocityLossRate;
	FVector ParticleExtent;
	FVector ParticleBounchyness;
	FParticleSndType ImpactSound;
	FParticleSndType SpawnSound;
	FParticleSndType DestroySound;
	FRangeVector ParticleColor;
	FRangeVector CoronaColor;
	FVector CoronaOffset;
	BYTE ParticleStyle;
	BYTE FadeStyle;
	BYTE SpriteAnimationType;
	BYTE SpawnPosType;
	BYTE TriggerAction;
	BYTE SpawnVelType;
	BYTE ParticleCollision;
	BYTE WallImpactAction;
	BYTE WaterImpactAction;
	BITFIELD bRevolutionEnabled:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bEffectsVelocity:1;
	BITFIELD bDisabled:1;
	BITFIELD bRespawnParticles:1;
	BITFIELD bAutoDestroy:1;
	BITFIELD bAutoReset:1;
	BITFIELD bSpawnInitParticles:1;
	BITFIELD bDisableRender:1;
	BITFIELD bUseRandomTex:1;
	BITFIELD bBoxVisibility:1;
	BITFIELD bAutoVisibilityBox:1;
	BITFIELD bDistanceCulling:1;
	BITFIELD bStasisEmitter:1;
	BITFIELD bNoUpdateOnInvis:1;
	BITFIELD bRelativeToRotation:1;
	BITFIELD bUseRelativeLocation:1;
	BITFIELD bGradualSpawnCoords:1;
	BITFIELD bUseMeshAnim:1;
	BITFIELD bVelRelativeToRotation:1;
	BITFIELD bCylRangeBasedOnPos:1;
	BITFIELD bAccelRelativeToRot:1;
	BITFIELD bCheckLineOfSight:1;
	BITFIELD bActorsBlockSight:1;
	BITFIELD bParticleCoronaEnabled:1;
	BITFIELD bCOffsetRelativeToRot:1;
	BITFIELD bEnablePhysX:1;
	BITFIELD bHasLossVel:1;
	BITFIELD bHasAliveParticles:1;
	BITFIELD bDestruction:1;
	BITFIELD bRotationRequest:1;
	BITFIELD bNeedsTexture:1;
	BITFIELD BACKUP_Disabled:1;
	DECLARE_FUNCTION(execEmTrigger);
	DECLARE_FUNCTION(execKill);
	DECLARE_FUNCTION(execSetMaxParticles);
	DECLARE_FUNCTION(execSpawnParticles);
	DECLARE_CLASS(AXEmitter,AXParticleEmitter,CLASS_Abstract,Emitter)
	#include "AXEmitter.h"
};

class EMITTER_API AXTrailEmitter : public AXEmitter
{
public:
	FLOAT TrailTreshold GCC_PACK(INT_ALIGNMENT);
	FLOAT MaxTrailLength;
	FLOAT TextureUV[4];
	FLOAT TexOffset;
	class AXTrailParticle* ParticleData;
	TArrayNoInit<FTrailOffsetPart> trail;
	FVector SheetUpdir;
	FVector OldTrailSpot;
	BYTE TrailType;
	BITFIELD bSmoothEntryPoint:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bDynamicParticleCount:1;
	BITFIELD bTexContinous:1;
	BITFIELD bSettingTrail:1;
	DECLARE_CLASS(AXTrailEmitter,AXEmitter,CLASS_Abstract,Emitter)
	#include "AXTrailEmitter.h"
};

class EMITTER_API AXSpriteEmitter : public AXEmitter
{
public:
	FLOAT RotateByVelocityScale GCC_PACK(INT_ALIGNMENT);
	class UMesh* SheetModel;
	FRangeVector RotationsPerSec;
	FRangeVector InitialRot;
	FVector RotNormal;
	BYTE ParticleRotation;
	DECLARE_CLASS(AXSpriteEmitter,AXEmitter,CLASS_Abstract,Emitter)
	#include "AXSpriteEmitter.h"
};

class EMITTER_API AXMeshEmitter : public AXEmitter
{
public:
	FLOAT PartAnimRate GCC_PACK(INT_ALIGNMENT);
	FLOAT PartAnimFrameStart;
	class UMesh* ParticleMesh;
	class AActor* AnimateByActor;
	FName ParticleAnim;
	TArrayNoInit<FAnimationType> RandAnims;
	FByteRange ParticleFatness;
	FRangeVector RotationsPerSec;
	FRangeVector InitialRot;
	BYTE ParticleRotation;
	BITFIELD bRenderParticles:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bParticlesRandFrame:1;
	BITFIELD bMeshEnviromentMapping:1;
	BITFIELD bRelativeToMoveDir:1;
	BITFIELD bPartAnimLoop:1;
	BITFIELD bAnimateParticles:1;
	BITFIELD bUsePhysXRotation:1;
	DECLARE_CLASS(AXMeshEmitter,AXEmitter,CLASS_Abstract,Emitter)
	#include "AXMeshEmitter.h"
};

class EMITTER_API AXBeamEmitter : public AXEmitter
{
public:
	FLOAT NoiseSwapTime GCC_PACK(INT_ALIGNMENT);
	FLOAT TextureUV[4];
	FLOAT TurnRate;
	class UTexture* StartTexture;
	class UTexture* EndTexture;
	class UMesh* RenderDataModel;
	TArrayNoInit<FFBeamTargetPoint> BeamTarget;
	TArrayNoInit<FScaleRangeType> NoiseTimeScale;
	TArrayNoInit<FLOAT> BeamPointScaling;
	TArrayNoInit<FLOAT> SegmentScales;
	FRangeVector NoiseRange;
	BYTE BeamTargetType;
	BYTE Segments;
	BITFIELD bDynamicNoise:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bDoBeamNoise:1;
	DECLARE_CLASS(AXBeamEmitter,AXEmitter,CLASS_Abstract,Emitter)
	#include "AXBeamEmitter.h"
};

class EMITTER_API AXTrailParticle : public AActor
{
public:
	DECLARE_CLASS(AXTrailParticle,AActor,CLASS_Transient,Emitter)
	#include "AXTrailParticle.h"
};

class EMITTER_API AXParticleForces : public AActor
{
public:
	FLOAT EffectingRadius GCC_PACK(INT_ALIGNMENT);
	FName OldTagName;
	FBoundingBox EffectingBox;
	FFloatRange EffectPartLifeTime;
	BITFIELD bEnabled:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bUseBoxForcePosition:1;
	DECLARE_CLASS(AXParticleForces,AActor,CLASS_Abstract,Emitter)
	#include "AXParticleForces.h"
};

class EMITTER_API AVelocityForce : public AXParticleForces
{
public:
	FVector VelocityToAdd GCC_PACK(INT_ALIGNMENT);
	BITFIELD bChangeAcceleration:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bInstantChange:1;
	DECLARE_CLASS(AVelocityForce,AXParticleForces,0,Emitter)
	#include "AVelocityForce.h"
};

class EMITTER_API AParticleConcentrateForce : public AXParticleForces
{
public:
	FLOAT DrainSpeed GCC_PACK(INT_ALIGNMENT);
	FLOAT MaxDistance;
	FVector CenterPointOffset;
	BITFIELD bSetsAcceleration:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bActorDistanceSuckIn:1;
	DECLARE_CLASS(AParticleConcentrateForce,AXParticleForces,0,Emitter)
	#include "AParticleConcentrateForce.h"
};

class EMITTER_API AKillParticleForce : public AXParticleForces
{
public:
	FLOAT LifeTimeDrainAmount GCC_PACK(INT_ALIGNMENT);
	DECLARE_CLASS(AKillParticleForce,AXParticleForces,0,Emitter)
	#include "AKillParticleForce.h"
};

class EMITTER_API AEmitterRC : public AActor
{
public:
	DECLARE_CLASS(AEmitterRC,AActor,CLASS_Abstract,Emitter)
	NO_DEFAULT_CONSTRUCTOR(AEmitterRC)
};

class EMITTER_API UTrailEmitterRender : public URenderIterator
{
public:
	class AXTrailEmitter* Owner GCC_PACK(INT_ALIGNMENT);
	class AXTrailParticle* Particle;
	DECLARE_CLASS(UTrailEmitterRender,URenderIterator,CLASS_Transient,Emitter)
	#include "UTrailEmitterRender.h"
};

class EMITTER_API UScriptPostRenderRI : public URenderIterator
{
public:
	class UObject* CallingObject GCC_PACK(INT_ALIGNMENT);
	FName ScriptRenderFunct;
	BITFIELD bOnlyCallWhenVisible:1 GCC_PACK(INT_ALIGNMENT);
	DECLARE_CLASS(UScriptPostRenderRI,URenderIterator,CLASS_Transient,Emitter)
	NO_DEFAULT_CONSTRUCTOR(UScriptPostRenderRI)
};

class EMITTER_API UEmitterRendering : public URenderIterator
{
public:
	UINT LastUpdateTime GCC_PACK(INT_ALIGNMENT);
	class ParticlesDataList* PartPtr;
	DECLARE_CLASS(UEmitterRendering,URenderIterator,CLASS_Transient,Emitter)
	#include "UEmitterRendering.h"
};

class EMITTER_API UActorFaceCameraRI : public URenderIterator
{
public:
	FRotator RotationModifier GCC_PACK(INT_ALIGNMENT);
	BITFIELD bFaceYaw:1 GCC_PACK(INT_ALIGNMENT);
	BITFIELD bFacePitch:1;
	BITFIELD bFaceRoll:1;
	BITFIELD bFaceCameraRotation:1;
	BITFIELD bUSEventCheck:1;
	void eventModifyCameraLoc(class UCanvas* C, FRotator& ActorRot)
	{
		#if _USE_REF_PARMS
		struct { class UCanvas* C; FRotator* ActorRot; } Parms = { C, &ActorRot };
		#else
		struct { class UCanvas* C; FRotator ActorRot; } Parms = { C, ActorRot };
		#endif
		ProcessEvent(FindFunctionChecked(EMITTER_ModifyCameraLoc),&Parms);
		#if !_USE_REF_PARMS
		ActorRot=Parms.ActorRot;
		#endif
	}
	DECLARE_CLASS(UActorFaceCameraRI,URenderIterator,CLASS_Transient,Emitter)
	#include "UActorFaceCameraRI.h"
};

#endif

AUTOGENERATE_FUNCTION(AXWeatherEmitter,-1,execSetRainVolume);
AUTOGENERATE_FUNCTION(AXWeatherEmitter,-1,execRemoveNoRainBounds);
AUTOGENERATE_FUNCTION(AXWeatherEmitter,-1,execAddNoRainBounds);
AUTOGENERATE_FUNCTION(AXParticleEmitter,1771,execAllParticles);
AUTOGENERATE_FUNCTION(AXParticleEmitter,1770,execSetParticlesProps);
AUTOGENERATE_FUNCTION(AXEmitter,1769,execEmTrigger);
AUTOGENERATE_FUNCTION(AXEmitter,1768,execKill);
AUTOGENERATE_FUNCTION(AXEmitter,1767,execSetMaxParticles);
AUTOGENERATE_FUNCTION(AXEmitter,1766,execSpawnParticles);

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif // NAMES_ONLY

#if ((_MSC_VER) || (HAVE_PRAGMA_PACK))
#pragma pack (pop)
#endif

#ifdef VERIFY_CLASS_SIZES
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XRainRestrictionVolume,Emitters)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XRainRestrictionVolume,BoundsMin)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XRainRestrictionVolume,BoundsMax)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XRainRestrictionVolume,RainBounds)
VERIFY_CLASS_SIZE_NODIE(AXRainRestrictionVolume)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,ParticleCount)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,NextParticleTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,SpawnInterval)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WallHitMinZ)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,SheetModel)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,RainVolume)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WallHitEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,RainVolumeTag)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WaterHitEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,NoRainBounds)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WallHitEmitters)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WaterHitEmitters)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,PartTextures)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,LastCamPosition)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,VecArea)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,CachedCoords)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,TransfrmCoords)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,Position)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,AppearArea)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,ParticlesColor)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,Lifetime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,speed)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,Size)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,FadeOutDistance)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,RainTree)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WallHitEvent)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WaterHitEvent)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,AppearAreaType)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,WeatherType)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XWeatherEmitter,PartStyle)
VERIFY_CLASS_SIZE_NODIE(AXWeatherEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XParticleEmitter,ActiveCount)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XParticleEmitter,PartCombiners)
VERIFY_CLASS_SIZE_NODIE(AXParticleEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,TrailEmitterRender,Owner)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,TrailEmitterRender,Particle)
VERIFY_CLASS_SIZE_NODIE(UTrailEmitterRender)
VERIFY_CLASS_SIZE_NODIE(AXTrailParticle)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,TrailTreshold)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,MaxTrailLength)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,TextureUV)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,TexOffset)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,ParticleData)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,trail)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,SheetUpdir)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,OldTrailSpot)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XTrailEmitter,TrailType)
VERIFY_CLASS_SIZE_NODIE(AXTrailEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,MaxParticles)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SingleIVert)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,NextParticleTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpawnInterval)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ResetTimer)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticlesPerSec)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,LODFactor)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,FadeInTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,FadeOutTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,FadeInMaxAmount)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,PartSpriteForwardZ)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CullDistance)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CullDistanceFadeDist)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,HittingActorKickVelScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,MinBounceVelocity)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,MinImpactVelForSnd)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CoronaFadeTimeScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CoronaMaxScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CoronaScaling)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,MaxCoronaDistance)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,FinishedSpawningTrigger)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,UseActorCoords)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CoronaTexture)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleSpawnTag)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleKillTag)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleWallHitTag)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleLifeTimeTag)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ForcesTags)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpawnCombiners)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,LifeTimeCombiners)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,DestructCombiners)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,WallHitCombiners)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,TSpawnC)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,TLifeTimeC)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,TDestructC)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,TWallHitC)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,RevolutionTimeScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleTextures)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleSpawnCClass)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleKillCClass)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleWallHitCClass)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleLifeTimeCClass)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,TimeScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,TimeDrawScale3D)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpeedScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpeedTimeScale3D)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ForcesList)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleColorScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CacheRot)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,OldSpawnPosition)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,RendBoundingBox)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,LifetimeRange)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,AutoResetTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,RevolutionOffset)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,RevolutionsPerSec)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,RevolutionOffsetUnAxis)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CombinedParticleCount)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleLifeTimeSDelay)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,StartingScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,Scale3DRange)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,VisibilityBox)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,BoxLocation)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SphereCylinderRange)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpawnOffsetMultiplier)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,VertexLimitBBox)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpawnParts)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleAcceleration)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,BoxVelocity)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SphereCylVelocity)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,VelocityLossRate)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleExtent)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleBounchyness)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ImpactSound)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpawnSound)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,DestroySound)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleColor)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CoronaColor)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,CoronaOffset)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleStyle)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,FadeStyle)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpriteAnimationType)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpawnPosType)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,TriggerAction)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,SpawnVelType)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,ParticleCollision)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,WallImpactAction)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XEmitter,WaterImpactAction)
VERIFY_CLASS_SIZE_NODIE(AXEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XSpriteEmitter,RotateByVelocityScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XSpriteEmitter,SheetModel)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XSpriteEmitter,RotationsPerSec)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XSpriteEmitter,InitialRot)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XSpriteEmitter,RotNormal)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XSpriteEmitter,ParticleRotation)
VERIFY_CLASS_SIZE_NODIE(AXSpriteEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,PartAnimRate)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,PartAnimFrameStart)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,ParticleMesh)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,AnimateByActor)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,ParticleAnim)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,RandAnims)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,ParticleFatness)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,RotationsPerSec)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,InitialRot)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XMeshEmitter,ParticleRotation)
VERIFY_CLASS_SIZE_NODIE(AXMeshEmitter)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,EmitterGarbageCollector,CleanUpTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,EmitterGarbageCollector,GarbagePtr)
VERIFY_CLASS_SIZE_NODIE(AEmitterGarbageCollector)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,ScriptPostRenderRI,CallingObject)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,ScriptPostRenderRI,ScriptRenderFunct)
VERIFY_CLASS_SIZE_NODIE(UScriptPostRenderRI)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,EmitterRendering,LastUpdateTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,EmitterRendering,PartPtr)
VERIFY_CLASS_SIZE_NODIE(UEmitterRendering)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,VelocityForce,VelocityToAdd)
VERIFY_CLASS_SIZE_NODIE(AVelocityForce)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XParticleForces,EffectingRadius)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XParticleForces,OldTagName)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XParticleForces,EffectingBox)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XParticleForces,EffectPartLifeTime)
VERIFY_CLASS_SIZE_NODIE(AXParticleForces)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,ParticleConcentrateForce,DrainSpeed)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,ParticleConcentrateForce,MaxDistance)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,ParticleConcentrateForce,CenterPointOffset)
VERIFY_CLASS_SIZE_NODIE(AParticleConcentrateForce)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,KillParticleForce,LifeTimeDrainAmount)
VERIFY_CLASS_SIZE_NODIE(AKillParticleForce)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,NoiseSwapTime)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,TextureUV)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,TurnRate)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,StartTexture)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,EndTexture)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,RenderDataModel)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,BeamTarget)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,NoiseTimeScale)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,BeamPointScaling)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,SegmentScales)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,NoiseRange)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,BeamTargetType)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,XBeamEmitter,Segments)
VERIFY_CLASS_SIZE_NODIE(AXBeamEmitter)
VERIFY_CLASS_SIZE_NODIE(AEmitterRC)
VERIFY_CLASS_OFFSET_NODIE_SLOW(U,ActorFaceCameraRI,RotationModifier)
VERIFY_CLASS_SIZE_NODIE(UActorFaceCameraRI)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,DistantLightActor,NewLightRadius)
VERIFY_CLASS_SIZE_NODIE(ADistantLightActor)
#endif // VERIFY_CLASS_SIZES