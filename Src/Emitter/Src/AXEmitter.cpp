// ===========================================================================
// Particle emitter code written by .:..:
// ===========================================================================

#include "EmitterPrivate.h"

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) EMITTER_API FName EMITTER_##name=FName(TEXT(#name),FNAME_Intrinsic);
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION (cls, idx, name)
#include "EmitterClasses.h"
#undef DECLARE_NAME
#undef NAMES_ONLY

IMPLEMENT_PACKAGE(Emitter)

IMPLEMENT_CLASS(ADistantLightActor);
IMPLEMENT_CLASS(UActorFaceCameraRI);

/*
ParticleEmitter base class functions ===================================================
*/

void AXParticleEmitter::execSetParticlesProps (FFrame& Stack, RESULT_DECL)
{
	guard (AXParticleEmitter::execSetParticlesProps);
	P_GET_FLOAT_OPTX(Speed,1.f)
	P_GET_FLOAT_OPTX(Scale,1.f)
	P_FINISH;

	if (PartPtr)
		PartPtr->ScaleParticles(Speed, Scale);
	unguardexec;
}
void AXParticleEmitter::execAllParticles (FFrame& Stack, RESULT_DECL)
{
	guard (AXParticleEmitter::execAllParticles);
	P_GET_ACTOR_REF(ResActor)
	P_FINISH;

	StartIterator;
	for (AActor* A = GetRenderList(nullptr); A; A = A->Target)
	{
		*ResActor = A;
		LoopIterator(return);
	}
	EndIterator;

	unguardexec;
}

void AXParticleEmitter::PostEditChange()
{
	AActor::PostEditChange();
	if( GIsEditor )
		ResetEmitter();
}

void AXParticleEmitter::ResetVars()
{
	guard(AXParticleEmitter::ResetVars);
	bHasInitialized = 0;
	ActiveCount = 0;
	unguard;
}

void AXParticleEmitter::PostNetReceive()
{
	Super::PostNetReceive();
	if( bNotifyNetReceive )
		eventPostNetNotify();
}

UBOOL AXParticleEmitter::Tick( FLOAT DeltaTime, enum ELevelTick TickType )
{
	guardSlow(AXParticleEmitter::Tick);
	if (!Super::Tick(DeltaTime, TickType))
		return FALSE;
	if (bDestruction && !GIsEditor && !bDeleteMe && !bNoDelete && ((EmitterLifeSpan -= DeltaTime) <= 0.f || !HasAliveParticles()))
	{
		eventExpired();
		XLevel->DestroyActor(this);
	}
	return TRUE;
	unguardSlow;
}
void AXParticleEmitter::PostScriptDestroyed()
{
	guardSlow(AXParticleEmitter::PostScriptDestroyed);
	if (PartPtr && !GIsEditor)
	{
		AEmitterGarbageCollector::MarkGCParticles(XLevel, PartPtr);
		PartPtr = NULL;
	}
	if (!GIsEditor) // Skip if in editor so it doesn't crash if you undo emitter deletion.
		DestroyCombiners();
	Super::PostScriptDestroyed();
	unguardSlow;
}

void AXParticleEmitter::Serialize(FArchive& Ar)
{
	guardSlow(AXParticleEmitter::Serialize);
	if (Ar.IsSaving() && bIsInternalEmitter)
	{
		// Skip saving some variables that aren't needed.
		Location = FVector(0, 0, 0);
		Rotation = FRotator(0, 0, 0);
		Level = NULL;
		XLevel = NULL;
		HitActor = NULL;
		Super::Serialize(Ar);
		if (ParentEmitter)
		{
			Level = ParentEmitter->Level;
			XLevel = ParentEmitter->XLevel;
			HitActor = ParentEmitter;
		}
	}
	else
	{
		Super::Serialize(Ar);

		if (!Ar.IsLoading() && !Ar.IsSaving() && PartPtr)
			PartPtr->Serialize(Ar);
	}
	unguardSlow;
}

UBOOL AXParticleEmitter::ShouldExportProperty(UProperty* Property) const
{
	guardSlow(AXParticleEmitter::ShouldExportProperty);
	if (bIsInternalEmitter && Property->GetOuter() == AActor::StaticClass())
	{
		const TCHAR* Type = Property->GetName();
		if (!appStricmp(Type, TEXT("Location"))
			|| !appStricmp(Type, TEXT("HitActor"))
			|| !appStricmp(Type, TEXT("bDeleteMe"))
			|| !appStricmp(Type, TEXT("Rotation")))
		{
			return FALSE;
		}
	}
	return Super::ShouldExportProperty(Property);
	unguardSlow;
}

FParticlesDataBase* AXParticleEmitter::GetParticleInterface()
{
	guardSlow(AXParticleEmitter::GetParticleInterface);
	return PartPtr;
	unguardSlow;
}

void AXParticleEmitter::SpawnChildPart(const FVector& Pos, TArray<AXEmitter*>& PartIdx)
{
	guardSlow(AXParticleEmitter::SpawnChildPart);
	AXEmitter** F = &PartIdx(0);
	for (INT i = (PartIdx.Num() - 1); i >= 0; --i)
		if (F[i])
			F[i]->RemoteSpawnParticle(Pos);
	unguardSlow;
}

void AXParticleEmitter::KillEmitter()
{
	guardSlow(AXParticleEmitter::KillEmitter);
	if (bDeleteMe || bStatic || bNoDelete)
		return;
	if (GIsEditor || !HasAliveParticles())
		XLevel->DestroyActor(this);
	else
	{
		EmitterLifeSpan = GetMaxLifeTime(); // To ensure emitter is destroyed even if bHidden.
		bDestruction = TRUE;
		for (AXParticleEmitter* P = CombinerList; P; P = P->CombinerList)
			P->bDestruction = TRUE;
	}
	unguardSlow;
}

FLOAT AXParticleEmitter::GetMaxLifeTime() const
{
	guardSlow(AXParticleEmitter::GetMaxLifeTime);
	return 0.1f;
	unguardSlow;
}

void AXParticleEmitter::ScriptDestroyed()
{
	guard(AXParticleEmitter::ScriptDestroyed);
	if (PartPtr)
	{
		AEmitterGarbageCollector::MarkGCParticles(XLevel, PartPtr);
		PartPtr = NULL;
	}
	Super::ScriptDestroyed();
	unguard;
}
void AXParticleEmitter::Destroy()
{
	guard(AXParticleEmitter::Destroy);
	if (PartPtr)
	{
		delete PartPtr; // Most likely called during gc...
		PartPtr = NULL;
	}
	Super::Destroy();
	unguard;
}

void AXParticleEmitter::DestroyCombiners()
{
	guard(AXParticleEmitter::DestroyCombiners);
	if (TransientEmitters)
	{
		AXParticleEmitter* NP;
		for (AXParticleEmitter* P = TransientEmitters; P; P = NP)
		{
			NP = P->TransientEmitters;
			P->TransientEmitters = NULL;
			P->DestroyCombiners();
			P->ConditionalDestroy();
			delete P;
		}
		TransientEmitters = NULL;
	}
	CombinerList = NULL;
	unguardobj;
}

void AXParticleEmitter::InitializeEmitter(AXParticleEmitter* Parent)
{
	guardSlow(AXParticleEmitter::InitializeEmitter);
	bHasInitialized = TRUE;
	ParentEmitter = Parent;
	if (Parent != this)
	{
		Location = Parent->Location;
		Rotation = Parent->Rotation;
		Level = Parent->Level;
		XLevel = Parent->XLevel;
		Region = Parent->Region;
		HitActor = Parent;
	}
	unguardSlow;
}

void AXParticleEmitter::RespawnEmitter()
{
	guardSlow(AXParticleEmitter::RespawnEmitter);
	if (PartPtr)
		PartPtr->HideAllParts();
	if (ParentEmitter == this)
	{
		for (AXParticleEmitter* P = CombinerList; P; P = P->CombinerList)
			P->RespawnEmitter();
	}
	unguardSlow;
}

void AXParticleEmitter::RelinkChildEmitters()
{
	guardSlow(AXParticleEmitter::RelinkChildEmitters);
	if (ParentEmitter == this)
	{
		CombinerList = NULL;
		for (AXParticleEmitter* P = TransientEmitters; P; P = P->TransientEmitters)
		{
			P->CombinerList = CombinerList;
			CombinerList = P;
		}
	}
	unguardSlow;
}

void FParticleSndType::PlaySoundEffect(const FVector& Location, ULevel* Level) const
{
	guardSlow(FParticleSndType::PlaySoundEffect);
	if (!SndCount || !Level->Engine->Audio || !ALevelInfo::LocalPlayer || !ALevelInfo::LocalPlayer->Actor)
		return;
	BYTE i = GetRandomVal(SndCount);
	if (Sounds[i])
	{
		FLOAT RADI = SndRadius.GetValue();
		if ((ALevelInfo::LocalPlayer->Actor->CalcCameraLocation - Location).SizeSquared() < Square(RADI * 0.95f))
			Level->Engine->Audio->PlaySound(NULL, SLOT_None, Sounds[i], Location, SndVolume.GetValue(), RADI, SndPitch.GetValue());
	}
	unguardSlow;
}
void FParticleSndType::InitSoundList()
{
	guardSlow(FParticleSndType::InitSoundList);
	SndCount = 0;
	for (BYTE i = 0; i < 8; i++)
	{
		if (!Sounds[i])
			return;
		SndCount = (i + 1);
	}
	unguardSlow;
}
