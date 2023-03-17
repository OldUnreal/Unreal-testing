
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(UEmitterRendering);
IMPLEMENT_CLASS(AEmitterGarbageCollector);

// Garbage collection
void AEmitterGarbageCollector::MarkGCParticles(ULevel* Map, FParticlesDataBase* Ptr)
{
	guard(AEmitterGarbageCollector::MarkGCParticles);
	if (GIsCollectingGarbage || GIsEditor)
		delete Ptr;
	else
	{
		if (Map->ParentLevel)
			Map = Map->ParentLevel;
		AEmitterGarbageCollector* GA = NULL;
		for (TActorIterator<AEmitterGarbageCollector> It(Map); It; ++It)
		{
			GA = *It;
			break;
		}
		if (!GA)
		{
			GA = reinterpret_cast<AEmitterGarbageCollector*>(Map->SpawnActor(AEmitterGarbageCollector::StaticClass()));
			if (GA)
				GA->bNoDelete = TRUE;
		}
		if (GA)
			GA->AddGarbage(Ptr);
		else delete Ptr;
	}
	unguard;
}

UBOOL AEmitterGarbageCollector::Tick( FLOAT DeltaTime, enum ELevelTick TickType )
{
	if (GarbagePtr && --CleanUpTime<=0)
	{
		for (INT i = (GarbagePtr->Num() - 1); i >= 0; --i)
			delete (*GarbagePtr)(i);
		delete GarbagePtr;
		GarbagePtr = NULL;
	}
	return 1;
}
void AEmitterGarbageCollector::Destroy()
{
	guard(AEmitterGarbageCollector::Destroy);
	if (GarbagePtr)
	{
		for (INT i = (GarbagePtr->Num() - 1); i >= 0; --i)
			delete (*GarbagePtr)(i);
		delete GarbagePtr;
		GarbagePtr = NULL;
	}
	Super::Destroy();
	unguard;
}

void AEmitterGarbageCollector::AddGarbage(FParticlesDataBase* Ptr)
{
	guard(AEmitterGarbageCollector::AddGarbage);
	CleanUpTime = 5;
	if (!GarbagePtr)
		GarbagePtr = new TArray<FParticlesDataBase*>;
	GarbagePtr->AddItem(Ptr);
	unguard;
}

void AEmitterGarbageCollector::Serialize(FArchive& Ar)
{
	guard(AEmitterGarbageCollector::Serialize);
	if (GarbagePtr && Ar.SerializeRefs())
	{
		for (INT i = (GarbagePtr->Num() - 1); i >= 0; --i)
			(*GarbagePtr)(i)->Serialize(Ar);
	}
	Super::Serialize(Ar);
	unguard;
}

FCoords UEmitterRendering::CamPos;

UEmitterRendering::UEmitterRendering()
{
	guard(UEmitterRendering::UEmitterRendering);
	AXParticleEmitter* A = CastChecked<AXParticleEmitter>(GetOuter());
	A->InitView();
	unguard;
}

AActor* UEmitterRendering::GetActors()
{
	guard(UEmitterRendering::GetActors);
	STAT(++GStatEmitter.UpdEmitters.Calls);
	STAT(FStatTimerScope Scope(GStatEmitter.UpdEmitTime));
	AXParticleEmitter* A = reinterpret_cast<AXParticleEmitter*>(GetOuter());

	if (!A->bFilterByVolume) // This is already handeled at earlier call from PrepareVolume
	{
		// Local variables.
		if (!A || !A->ShouldUpdateEmitter(Frame))
		{
			A->LastUpdateTime = GFrameNumber;
			return NULL;
		}
		if (A->bNotOnPortals && Frame->Recursion)
			return NULL;

		if (!A->bHasInitialized)
		{
			A->bHasInitialized = 1;
			A->InitializeEmitter(A);
			A->LastUpdateTime = GFrameNumber;
		}

		if ((A->LastUpdateTime != GFrameNumber) &&
			(GIsEditor
				? (Frame->Viewport && Frame->Viewport->IsRealtime())
				: (!A->Level->Pauser.Len() && (A->bAlwaysTick || !A->Level->bPlayersOnly))
				))
		{
			A->LastUpdateTime = GFrameNumber;
			CamPos.Origin = Frame->Coords.Origin;
			CamPos.XAxis = Frame->Coords.ZAxis;
			CamPos.YAxis = Frame->Coords.XAxis;
			CamPos.ZAxis = -Frame->Coords.YAxis;
			const FLOAT DeltaTime = A->Level->LastDeltaTime;
			A->UpdateEmitter(DeltaTime, this, FALSE);
		}

		if (!A->ShouldRenderEmitter(Frame))
			return NULL;
	}

	AActor* Result = (Observer->ShowFlags & SHOW_InGameMode) ? nullptr : A;
	Result = A->GetRenderList(Result);
	A->Target = NULL; // Make sure owner emitter never references a particle (should always be on the end of list)!
	return Result;
	unguard;
}

UBOOL UEmitterRendering::PrepareVolume(FSceneNode* Camera)
{
	guard(UEmitterRendering::PrepareVolume);
	STAT(FStatTimerScope Scope(GStatEmitter.UpdEmitTime));
	AXParticleEmitter* A = reinterpret_cast<AXParticleEmitter*>(GetOuter());
	Frame = Camera;
	Observer = Camera->Viewport->Actor;

	// Local variables.
	if (!A || !A->ShouldUpdateEmitter(Camera))
	{
		A->LastUpdateTime = GFrameNumber;
		return FALSE;
	}
	if (A->bNotOnPortals && Camera->Recursion)
		return FALSE;

	if (!A->bHasInitialized)
	{
		A->bHasInitialized = 1;
		A->InitializeEmitter(A);
		A->LastUpdateTime = GFrameNumber;
	}

	if ((A->LastUpdateTime != GFrameNumber) &&
		(GIsEditor
			? (Camera->Viewport && Camera->Viewport->IsRealtime())
			: (!A->Level->Pauser.Len() && (A->bAlwaysTick || !A->Level->bPlayersOnly))
			))
	{
		A->LastUpdateTime = GFrameNumber;
		CamPos.Origin = Camera->Coords.Origin;
		CamPos.XAxis = Camera->Coords.ZAxis;
		CamPos.YAxis = Camera->Coords.XAxis;
		CamPos.ZAxis = -Camera->Coords.YAxis;
		const FLOAT DeltaTime = A->Level->LastDeltaTime;
		A->UpdateEmitter(DeltaTime, this, FALSE);
	}

	if (!A->ShouldRenderEmitter(Camera))
		return FALSE;
	return TRUE;
	unguard;
}

// Actor script post render iterator --------------------------------------------

AActor* UActorFaceCameraRI::GetActors()
{
	guard(UActorFaceCameraRI::GetActors);
	AActor* A = (AActor*)GetOuter();
	if (Frame && Frame->Viewport && (GIsEditor || (A->Level->TimeSeconds - A->XLevel->Model->Zones[A->Region.ZoneNumber].LastRenderTime) < 1.f))
	{
		FRotator R;
		if (bFaceCameraRotation)
		{
			FCoords CR = FCoords(FVector(0, 0, 0), -Frame->Coords.ZAxis, -Frame->Coords.XAxis, -Frame->Coords.YAxis);
			R = CR.OrthoRotation();
		}
		else
		{
			FVector COF = (Frame->Coords.Origin - A->Location);
			R = COF.Rotation();
		}
		if (!bFaceYaw)
			R.Yaw = A->Rotation.Yaw;
		if (!bFacePitch)
			R.Pitch = A->Rotation.Pitch;
		if (!bFaceRoll)
			R.Roll = A->Rotation.Roll;
		R += RotationModifier;
		if (bUSEventCheck && GIsScriptable && Frame->Viewport->Canvas)
			eventModifyCameraLoc(Frame->Viewport->Canvas, R);
		if (A->Rotation != R)
		{
			A->Rotation = R;
			if (A->MeshInstance)
				A->MeshInstance->bCoordsDirty = 1;
		}
	}
	A->Target = NULL;
	return A;
	unguard;
}
