// ===========================================================================
// Particle emitter code written by .:..:
// ===========================================================================

#include "EmitterPrivate.h"

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern EMITTER_API FName EMITTER_##name=FName(TEXT(#name),FNAME_Intrinsic);
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION (cls, idx, name)
#include "EmitterClasses.h"
#undef DECLARE_NAME
#undef NAMES_ONLY

IMPLEMENT_PACKAGE(Emitter)

IMPLEMENT_CLASS(ADistantLightActor);
IMPLEMENT_CLASS(UActorFaceCameraRI);

inline bool CheckHitRootSelected( AActor* A )
{
	while( A )
	{
		if( A->bSelected )
			return true;
		A = A->HitActor;
	}
	return false;
}

/*
ParticleEmitter base class functions ===================================================
*/

void AXParticleEmitter::execSetParticlesProps (FFrame& Stack, RESULT_DECL)
{
	guard (AXParticleEmitter::execSetParticlesProps);
	P_GET_FLOAT_OPTX(Speed,1.f)
	P_GET_FLOAT_OPTX(Scale,1.f)
	P_FINISH;
	UEmitterRendering* Render = (UEmitterRendering*)RenderInterface;
	if( !Render )
		return;
	int l=Render->PartPtr->Len();
	for( int i=0; i<l; i++ )
	{
		AActor* A=Render->PartPtr->GetA(i);
		if( A->bHidden )
			continue;
		A->Velocity*=Speed;
		A->Acceleration*=Speed;
		A->DrawScale*=Scale;
		Render->PartPtr->Get(i).Scale*=Scale;
	}
	unguardexec;
}
void AXParticleEmitter::execAllParticles (FFrame& Stack, RESULT_DECL)
{
	guard (AXParticleEmitter::execAllParticles);
	P_GET_ACTOR_REF(ResActor)
	P_FINISH;

	UEmitterRendering* Render = (UEmitterRendering*)RenderInterface;

	StartIterator;

	if( Render && Render->PartPtr )
	{
		// Loop for UScript
		int l=Render->PartPtr->Len();
		AActor* A;
		for( int i=0; i<l; i++ )
		{
			A = Render->PartPtr->GetA(i);
			if( A->bHidden )
				continue;
			*ResActor = A;
			LoopIterator(return);
		}
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

void AXParticleEmitter::ResetEmitter()
{
	guard(AXParticleEmitter::ResetEmitter);
	ActiveCount = 0;
	unguard;
}

void AXParticleEmitter::ResetVars()
{
	guard(AXParticleEmitter::ResetVars);
	bHasInitialized = 0;
	bKillNextTick = 0;
	bHasSpecialParts = 0;
	bWasPostDestroyed = 0;
	ActiveCount = 0;
	PartCombiners.Empty();
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
	if (bKillNextTick && (bHasSpecialParts || !GIsEditor) && !bNoDelete)
	{
		UBOOL bReady = TRUE;
		if( bHasSpecialParts )
		{
			for( INT i=0; i<PartCombiners.Num(); i++ )
				if( PartCombiners(i) && PartCombiners(i)->bHasInitialized
				 && PartCombiners(i)->RenderInterface
				 && ((UEmitterRendering*) PartCombiners(i)->RenderInterface)->HasAliveParticles() )
				{
					PartCombiners(i)->bDestruction = 1;
					bReady = FALSE;
				}
		}
		if (bReady)
		{
			XLevel->DestroyActor(this);
			return 1;
		}
	}
	return Super::Tick(DeltaTime,TickType);
}
void AXParticleEmitter::PostScriptDestroyed()
{
	UEmitterRendering* UR = Cast<UEmitterRendering>(RenderInterface);
	if (UR && UR->PartPtr && !GIsEditor)
	{
		TTransArray<AActor*>& Actors(XLevel->Actors);
		AEmitterGarbageCollector* GA = NULL;
		for (INT i = 0; i < Actors.Num(); i++)
		{
			GA = Cast<AEmitterGarbageCollector>(Actors(i));
			if (GA)
				break;
		}
		if (!GA)
			GA = (AEmitterGarbageCollector*)XLevel->SpawnActor(AEmitterGarbageCollector::StaticClass());
		if (GA)
			GA->AddGarbage(UR->PartPtr);
		UR->PartPtr = NULL;
	}

	for (INT i = 0; i < PartCombiners.Num(); i++)
		if (PartCombiners(i))
		{
			PartCombiners(i)->bWasPostDestroyed = 1;
			PartCombiners(i)->PostScriptDestroyed();
			delete PartCombiners(i);
		}
	PartCombiners.Empty();
	Super::PostScriptDestroyed();
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
