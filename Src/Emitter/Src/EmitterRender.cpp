
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(UEmitterRendering);
IMPLEMENT_CLASS(UScriptPostRenderRI);
IMPLEMENT_CLASS(AEmitterGarbageCollector);

// Garbage collection
UBOOL AEmitterGarbageCollector::Tick( FLOAT DeltaTime, enum ELevelTick TickType )
{
	if (GarbagePtr && Level->TimeSeconds > CleanUpTime)
		CleanUpGarbage();
	return 1;
}
void AEmitterGarbageCollector::Destroy()
{
	CleanUpGarbage();
	Super::Destroy();
}

void AEmitterGarbageCollector::CleanUpGarbage()
{
	guard(AEmitterGarbageCollector::CleanUpGarbage);
	if (GarbagePtr)
	{
		for (INT i = (GarbagePtr->Num() - 1); i >= 0; --i)
			delete (*GarbagePtr)(i);
		delete GarbagePtr;
		GarbagePtr = NULL;
	}
	unguard;
}

void AEmitterGarbageCollector::AddGarbage( ParticlesDataList* Ptr )
{
	guard(AEmitterGarbageCollector::AddGarbage);
	CleanUpTime = Level->TimeSeconds+1.f;
	if (!GarbagePtr)
		GarbagePtr = new TArray<ParticlesDataList*>;
	GarbagePtr->AddItem(Ptr);
	unguard;
}

FCoords UEmitterRendering::CamPos;

UEmitterRendering::UEmitterRendering()
	: PartPtr(new ParticlesDataList)
{
	guard(UEmitterRendering::UEmitterRendering);
	AXParticleEmitter* A = CastChecked<AXParticleEmitter>(GetOuter());
	A->InitView();
	unguard;
}

void UEmitterRendering::SpawnDelayedPart(const FVector& Pos)
{
	if (PartPtr)
	{
		PartPtr->DelaySpawn.AddItem(Pos);
		PartPtr->bHadDelaySpawn = 1;
	}
}

inline AActor* UEmitterRendering::GetActorsInner(UBOOL bDrawSelf)
{
	guardSlow(UEmitterRendering::GetActorsInner);
	// Local variables.
	AXParticleEmitter* A = (AXParticleEmitter*)GetOuter();

	// Draw self.
	AActor* P, * Result = NULL;
	int i;
	int l = PartPtr->Len();

	if (bDrawSelf)
	{
		Result = (AActor*)GetOuter();
		Result->Target = NULL;
	}
	for (i = 0; i < l; i++)
	{
		P = PartPtr->GetA(i);
		if (!P->bHidden && ((P->DrawType == DT_Mesh && P->Skin && P->Mesh) || P->Texture))
		{
			P->Target = Result;
			Result = P;
		}
	}

	// Draw combiners.
	if (A->bHasSpecialParts)
	{
		l = A->PartCombiners.Num();
		AXEmitter** PA = &A->PartCombiners(0);
		for (i = 0; i < l; i++)
			if (PA[i] && !PA[i]->bHurtEntry)
			{
				PA[i]->bHurtEntry = TRUE; // Using Actor.bHurtEntry to detect infinite loops within emitters.
				P = ((UEmitterRendering*)PA[i]->RenderInterface)->GetActorsInner();
				PA[i]->bHurtEntry = FALSE;
				if (P)
				{
					P->Target = Result;
					Result = P;
				}
			}
	}
	return Result;
	unguardSlow;
}

AActor* UEmitterRendering::GetActors()
{
	guard(UEmitterRendering::GetActors);
	STAT(++GStatEmitter.UpdEmitters.Calls);
	STAT(FStatTimerScope Scope(GStatEmitter.UpdEmitTime));
	AXParticleEmitter* A = (AXParticleEmitter*)GetOuter();

	// Local variables.
	if (!A || A->bKillNextTick || !A->ShouldUpdateEmitter(this))
	{
		LastUpdateTime = GFrameNumber;
		return NULL;
	}
	if (A->bNotOnPortals && Frame->Recursion)
		return NULL;

	if (!A->bHasInitialized)
	{
		A->bHasInitialized = 1;
		A->InitializeEmitter(this, A);
		LastUpdateTime = GFrameNumber;
	}

	if ((LastUpdateTime != GFrameNumber) &&
		(GIsEditor
			? (Frame->Viewport && Frame->Viewport->IsRealtime())
			: (!A->Level->Pauser.Len() && (A->bAlwaysTick || !A->Level->bPlayersOnly))
			))
	{
		LastUpdateTime = GFrameNumber;
		CamPos.Origin = Frame->Coords.Origin;
		CamPos.XAxis = Frame->Coords.ZAxis;
		CamPos.YAxis = Frame->Coords.XAxis;
		CamPos.ZAxis = -Frame->Coords.YAxis;
		const FLOAT DeltaTime = A->Level->LastDeltaTime;
		A->UpdateEmitter(DeltaTime, this);
	}

	if (!A->ShouldRenderEmitter(this))
		return NULL;

	AActor* Result = GetActorsInner(!(Observer->ShowFlags & SHOW_InGameMode));
	STAT(unclockTimer(GStatEmitter.UpdEmitTime.Time));
	return Result;
	unguard;
}

void UEmitterRendering::ChangeParticleCount( int NewNum )
{
	guard(UEmitterRendering::ChangeParticleCount);
	if( !PartPtr || !NewNum )
		return;
	if( NewNum==PartPtr->Len() )
		return;

	AActor* OwnerA = (AActor*)GetOuter();
	AActor* HitA=(OwnerA->HitActor ? OwnerA->HitActor : OwnerA);
	PartPtr->SetLen(NewNum);
	AActor* A;
	UTexture* T = AActor::StaticClass()->GetDefaultActor()->Texture;
	for( INT i=0; i<NewNum; i++ )
	{
		A = PartPtr->GetA(i);
		// Initilize the particles to have good default values.
		A->DrawScale3D = OwnerA->DrawScale3D;
		A->Owner = OwnerA;
		A->bHidden = 1;
		A->LifeSpan = 1.f;
		A->HitActor = HitA;
		A->SetClass(AEmitterRC::StaticClass());
		A->XLevel = HitA->XLevel;
		A->Region.iLeaf = INDEX_NONE;
		A->AnimSequence = NAME_None;
		A->LODBias = 1.f;
		A->Texture = T;
		A->Skin = T;
		A->Region = OwnerA->Region;
		A->NetTag = i;
		for( INT j=0; j<8; j++ )
			A->MultiSkins[j] = OwnerA->MultiSkins[j];
	}
	unguard;
}
bool UEmitterRendering::HasAliveParticles()
{
	guard(UEmitterRendering::HasAliveParticles);
	if( !PartPtr )
		return 0;
	if( PartPtr->DelaySpawn.Num() )
		return 1;
	int l = PartPtr->Len();
	int i;
	for( i=0; i<l; i++ )
		if( !PartPtr->GetA(i)->bHidden )
			return 1;
	AXParticleEmitter* PActor = (AXParticleEmitter*)GetOuter();
	if( PActor->bHasSpecialParts )
	{
		l = PActor->PartCombiners.Num();
		for( i=0; i<l; i++ )
			if( PActor->PartCombiners(i) && PActor->PartCombiners(i)->bHasInitialized
			 && Cast<UEmitterRendering>(PActor->PartCombiners(i)->RenderInterface)
			 && ((UEmitterRendering*)PActor->PartCombiners(i)->RenderInterface)->HasAliveParticles() )
				return 1;
	}
	return 0;
	unguard;
}
void UEmitterRendering::HideAllParticles()
{
	guardSlow(UEmitterRendering::HideAllParticles);
	if( PartPtr )
		PartPtr->HideAllParts();
	unguardSlow;
}
void UEmitterRendering::Destroy()
{
	guard(UEmitterRendering::Destroy);
	Super::Destroy();
	if( PartPtr )
	{
		delete PartPtr;
		PartPtr = NULL;
	}
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
