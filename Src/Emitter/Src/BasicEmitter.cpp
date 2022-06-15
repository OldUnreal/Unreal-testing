
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXParticleEmitter);
IMPLEMENT_CLASS(AXEmitter);
IMPLEMENT_CLASS(AEmitterRC);

void AXEmitter::InitView()
{
	guardSlow(AXEmitter::InitView);
	bFilterByVolume = ((bBoxVisibility || bAutoVisibilityBox) && !GIsEditor && ParticleStyle!=STY_AlphaBlend);
	if( bFilterByVolume && ParticleStyle>=STY_Translucent )
		Style = STY_Translucent;
	unguardSlow;
}
void AXEmitter::execSpawnParticles (FFrame& Stack, RESULT_DECL)
{
	guard (AXEmitter::execSpawnParticles);
	P_GET_INT(Num)
	P_FINISH;
	SpawnMoreParticles(Num);
	unguardexec;
}
void AXEmitter::SpawnMoreParticles( int Count )
{
	if( !RenderInterface )
		return;
	CacheRot = (GMath.UnitCoords * Rotation);
	FVector* TransPose = NULL;
	while( Count>0 )
	{
		SpawnParticle((UEmitterRendering*)RenderInterface,PSF_None,TransPose);
		Count--;
	}
	if( TransPose )
		delete TransPose;
}
void AXEmitter::execSetMaxParticles (FFrame& Stack, RESULT_DECL)
{
	guard (AXEmitter::execSetMaxParticles);
	P_GET_INT(Num)
	P_FINISH;
	ChangeMaxParticles(Num);
	unguardexec;
}
void AXEmitter::ChangeMaxParticles( int Count )
{
	guardSlow(AXEmitter::ChangeMaxParticles);
	if (!GIsClient)
	{
		MaxParticles = Count;
		return;
	}
	GetParticleInterface()->SetLen(Count);
	MaxParticles = Count;
	ActiveCount = Min(ActiveCount, Count);
	if( ParticlesPerSec<=0 )
		SpawnInterval = LifetimeRange.Max/Count;
	unguardSlow;
}
void AXEmitter::execKill (FFrame& Stack, RESULT_DECL)
{
	guard(AXEmitter::execKill);
	P_FINISH;
	KillEmitter();
	unguardexec;
}
void AXEmitter::execEmTrigger (FFrame& Stack, RESULT_DECL)
{
	guard(AXEmitter::execEmTrigger);
	P_FINISH;
	TriggerEmitter();
	unguardexec;
}
void AXEmitter::TriggerEmitter()
{
	guardSlow(AXEmitter::TriggerEmitter);
	switch( TriggerAction )
	{
	case ETR_ToggleDisabled:
		bDisabled = !bDisabled;
		break;
	case ETR_ResetEmitter:
		if( PartPtr )
			PartPtr->HideAllParts();
		ActiveCount = 0;
		bAllParticlesSpawned = FALSE;
		break;
	default:
		SpawnMoreParticles(SpawnParts.GetValue());
		break;
	}
	unguardSlow;
}
FParticlesDataBase* AXEmitter::GetParticleInterface()
{
	guardSlow(AXEmitter::GetParticleInterface);
	if (!PartPtr)
	{
		ParticlesDataList* L = new ParticlesDataList(this);
		L->SetLen(MaxParticles);
		PartPtr = L;
	}
	return PartPtr;
	unguardSlow;
}

void AXEmitter::RenderSelectInfo( FSceneNode* Frame )
{
	Super::RenderSelectInfo(Frame);
	URenderBase* RB = XLevel->Engine->Render;
	if( bBoxVisibility )
		RB->DrawBox(Frame,FPlane(1,1,0.5,1),0,Location+VisibilityBox.Min,Location+VisibilityBox.Max);
	else if( bAutoVisibilityBox )
		RB->DrawBox(Frame,FPlane(1,0.5,1,1),0,RendBoundingBox.Min,RendBoundingBox.Max);
	if( bDistanceCulling )
		RB->DrawCircle(Frame,FPlane(1,0.5,0.5,1),0,Location,CullDistance*0.265,1);
	INT i;
	FPlane Col(1,0.4,1,1);
	for( i=0; i<SpawnCombiners.Num(); i++ )
		if( SpawnCombiners(i) )
			Frame->Viewport->RenDev->Draw3DLine(Frame,Col,0,Location,SpawnCombiners(i)->Location);
	for( i=0; i<LifeTimeCombiners.Num(); i++ )
		if( LifeTimeCombiners(i) )
			Frame->Viewport->RenDev->Draw3DLine(Frame,Col,0,Location,LifeTimeCombiners(i)->Location);
	for( i=0; i<DestructCombiners.Num(); i++ )
		if( DestructCombiners(i) )
			Frame->Viewport->RenDev->Draw3DLine(Frame,Col,0,Location,DestructCombiners(i)->Location);
	for( i=0; i<WallHitCombiners.Num(); i++ )
		if( WallHitCombiners(i) )
			Frame->Viewport->RenDev->Draw3DLine(Frame,Col,0,Location,WallHitCombiners(i)->Location);
	Col = FPlane(0.25,0.25,1,1);
	for( i=0; i<ForcesList.Num(); i++ )
		if( ForcesList(i) )
			Frame->Viewport->RenDev->Draw3DLine(Frame,Col,0,Location,ForcesList(i)->Location);
}

#define HANDLE_COMBINERS(clist) \
	for(i=(clist.Num()-1); i>=0; --i) \
		if (clist(i)) \
			clist(i)->TagPersistentActors();

void AXEmitter::TagPersistentActors()
{
	guard(AXEmitter::TagPersistentActors);
	Super::TagPersistentActors();
	bDeleteMe = FALSE;
	ClearFlags(RF_PendingDelete);

	if (GIsClient)
	{
		if (ParticleTrail)
			ParticleTrail->TagPersistentActors();
		INT i;
		HANDLE_COMBINERS(SpawnCombiner);
		HANDLE_COMBINERS(KillCombiner);
		HANDLE_COMBINERS(WallHitCombiner);
		HANDLE_COMBINERS(LifeTimeCombiner);
	}
	unguardobj;
}
void AXEmitter::PostLoad()
{
	guard(AXEmitter::PostLoad);
	Super::PostLoad();

	if (GIsClient || GIsEditor)
	{
		if (ParticleTrail)
			ParticleTrail->TagPersistentActors();
		INT i;
		HANDLE_COMBINERS(SpawnCombiner);
		HANDLE_COMBINERS(KillCombiner);
		HANDLE_COMBINERS(WallHitCombiner);
		HANDLE_COMBINERS(LifeTimeCombiner);
	}
	unguard;
}
#undef HANDLE_COMBINERS

void AXEmitter::UpdateEmitter(FLOAT DeltaTime, UEmitterRendering* Render, UBOOL bSkipChildren)
{
	guard(AXEmitter::UpdateEmitter);
	if (!PartPtr)
		GetParticleInterface();
	CacheRot = (GMath.UnitCoords * Rotation);
	if (bAllParticlesSpawned && (bAutoReset || GIsEditor))
	{
		if (ResetTimer > 0)
		{
			ResetTimer -= DeltaTime;
			if (ResetTimer <= 0)
			{
				ActiveCount = 0;
				bAllParticlesSpawned = FALSE;
			}
		}
		else if (!HasAliveParticles())
		{
			if (bAutoReset)
				ResetTimer = AutoResetTime.GetValue();
			else ResetTimer = 1.f;
		}
	}
	ParticlesDataList* PH = reinterpret_cast<ParticlesDataList*>(PartPtr);
	if (PH->DelaySpawn.Num())
	{
		guardSlow(SpawnDelayed);
		FVector* TransPose=NULL;
		TArray<FVector>& DS = PH->DelaySpawn;
		INT z;
		for (INT i = 0; i < DS.Num(); i++)
		{
			for (z = CombinedParticleCount.GetValue(); z > 0; z--)
				SpawnParticle(Render, PSF_AbsolutePosition, TransPose, DS(i));
		}
		DS.Empty();
		if( TransPose )
			delete[] TransPose;
		unguardSlow;
	}
	if (!bDisabled && !bDestruction)
	{
		guardSlow(SpawnParticles);
		NextParticleTime-=DeltaTime;
		BYTE LCount=0;
		BYTE PCount=0;
		while( NextParticleTime<=0 && (LCount++)<80 )
		{
			PCount++;
			NextParticleTime+=SpawnInterval;
		}
		if( PCount )
		{
			NextParticleTime = Max(NextParticleTime,0.f);
			// Handle low detail.
			if( !Level->bHighDetailMode || Level->bDropDetail )
				NextParticleTime+=(SpawnInterval*PCount)*(LODFactor-1.f);
			FVector* TransPose=NULL;
			if( bGradualSpawnCoords && OldSpawnPosition!=Location )
			{
				FVector SpawnCoordsOffs(0,0,0);
				if( OldSpawnPosition!=FVector(0,0,0) )
					SpawnCoordsOffs = (OldSpawnPosition-Location)/(PCount+1);
				OldSpawnPosition = Location;
				while( PCount>0 )
				{
					if (!SpawnParticle(Render, PSF_CheckRespawn, TransPose, (SpawnCoordsOffs * PCount)))
						break;
					PCount--;
				}
			}
			else
			{
				while( PCount>0 )
				{
					if (!SpawnParticle(Render, PSF_CheckRespawn, TransPose))
						break;
					PCount--;
				}
			}
			if( TransPose )
				delete[] TransPose;
		}
		unguardSlow;
	}
	if( bAutoVisibilityBox )
	{
		switch( SpawnPosType )
		{
		case SP_Box:
			RendBoundingBox.Min = FVector(BoxLocation.X.Min,BoxLocation.Y.Min,BoxLocation.Z.Min)+Location;
			RendBoundingBox.Max = FVector(BoxLocation.X.Max,BoxLocation.Y.Max,BoxLocation.Z.Max)+Location;
			break;
		default:
			RendBoundingBox.Min = FVector(SphereCylinderRange.Min,SphereCylinderRange.Min,SphereCylinderRange.Min)+Location;
			RendBoundingBox.Max = RendBoundingBox.Min;
			RendBoundingBox+=Location+FVector(SphereCylinderRange.Max,SphereCylinderRange.Max,SphereCylinderRange.Max);
			RendBoundingBox+=Location-FVector(SphereCylinderRange.Max,SphereCylinderRange.Max,SphereCylinderRange.Max);
		}
		RendBoundingBox = RendBoundingBox.ExpandBy(8.f);
	}
	UpdateParticles(DeltaTime, Render);
	if (!bSkipChildren)
		UpdateChildren(DeltaTime, Render);
	unguardobj;
}

#define LOOP_OLD_C_CLASSES(clist, carr) \
	for( i=(clist.Num()-1); i>=0; i-- ) \
		GenerateChildEmitter(clist(i), carr);

#define INCLUDE_EMITTER(citem) \
	citem->CombinerList = Parent->CombinerList; \
	Parent->CombinerList = citem; \
	citem->bIsInternalEmitter = TRUE; \
	citem->InitializeEmitter(Parent)

#define LOOP_NEW_CLASSES(clist, carr) \
	for (i = (clist.Num() - 1); i >= 0; --i) \
	{ \
		X = clist(i); \
		if (X) \
		{ \
			carr.AddItem(X); \
			INCLUDE_EMITTER(X); \
		} \
	}

void AXEmitter::InitializeEmitter(AXParticleEmitter* Parent)
{
	guard(AXEmitter::InitializeEmitter);
	Super::InitializeEmitter(Parent);

	GetParticleInterface();
	if( ParticlesPerSec<=0 )
		SpawnInterval = LifetimeRange.Max/MaxParticles;
	else SpawnInterval = LifetimeRange.Max/ParticlesPerSec;
	NextParticleTime = 0.f;
	if( !bSpawnInitParticles )
		ActiveCount = MaxParticles;
	bHasLossVel = (!VelocityLossRate.IsZero());
	ImpactSound.InitSoundList();
	SpawnSound.InitSoundList();
	DestroySound.InitSoundList();

	INT i;
	if (!bInitCombiners)
	{
		// Add old format emitter class combiners.
		LOOP_OLD_C_CLASSES(ParticleSpawnCClass, TSpawnC);
		LOOP_OLD_C_CLASSES(ParticleKillCClass, TDestructC);
		LOOP_OLD_C_CLASSES(ParticleWallHitCClass, TWallHitC);
		LOOP_OLD_C_CLASSES(ParticleLifeTimeCClass, TLifeTimeC);
		bInitCombiners = TRUE;
	}

	// Link new format emitters.
	AXEmitter* X;
	if (ParticleTrail)
	{
		INCLUDE_EMITTER(ParticleTrail);
	}
	LOOP_NEW_CLASSES(SpawnCombiner, TSpawnC);
	LOOP_NEW_CLASSES(KillCombiner, TDestructC);
	LOOP_NEW_CLASSES(WallHitCombiner, TWallHitC);
	LOOP_NEW_CLASSES(LifeTimeCombiner, TLifeTimeC);
	unguard;
}

#define LOOP_CHILDREN(clist,basetime) \
	for (i = (clist.Num() - 1); i >= 0; --i) \
		if (clist(i) && clist(i)->bIsInternalEmitter) \
			Result = Max(Result, basetime + clist(i)->GetMaxLifeTime());

FLOAT AXEmitter::GetMaxLifeTime() const
{
	guardSlow(AXEmitter::GetMaxLifeTime);
	const FLOAT MaxLife = Max(LifetimeRange.Min, LifetimeRange.Max);
	FLOAT Result = MaxLife;
	INT i;
	LOOP_CHILDREN(TSpawnC, 0.f);
	LOOP_CHILDREN(TLifeTimeC, MaxLife);
	LOOP_CHILDREN(TDestructC, MaxLife);
	LOOP_CHILDREN(TWallHitC, MaxLife);
	if(ParticleTrail)
		Result = Max(Result, MaxLife + ParticleTrail->GetMaxLifeTime());
	return Result;
	unguardSlow;
}

#undef LOOP_OLD_C_CLASSES
#undef INCLUDE_EMITTER
#undef LOOP_NEW_CLASSES

UBOOL AXEmitter::RemoteSpawnParticle(const FVector& Position)
{
	guardSlow(AXEmitter::RemoteSpawnParticle);
	if (!GIsClient || bDisabled)
		return FALSE;
	GetParticleInterface()->AddDelayedSpawn(Position);
	return TRUE;
	unguardSlow;
}

inline UTexture* GetPartTexture(AXEmitter* E)
{
	UTexture* Result = NULL;
	if (E->ParticleTextures.Num())
	{
		if (E->bUseRandomTex)
			Result = E->ParticleTextures(GetRandomVal(E->ParticleTextures.Num()));
		else Result = E->ParticleTextures(0);
	}
	if (GIsEditor && !Result)
		Result = GetDefault<ALevelInfo>()->DefaultTexture;
	return Result;
}

UBOOL AXEmitter::SpawnParticle( UEmitterRendering* Render, BYTE SpawnFlags, FVector*& TransPose, const FVector& SpawnOffs )
{
	guardSlow(AXEmitter::SpawnParticle);
	xParticle* A = NULL;
	UTexture* Tex;
	if( bRespawnParticles || !(SpawnFlags & PSF_CheckRespawn) )
	{
		Tex = GetPartTexture(this);
		if (!Tex && bNeedsTexture)
			return FALSE;
		A = reinterpret_cast<ParticlesDataList*>(PartPtr)->GrabDeadParticle();
		if (!A)
			return FALSE;
	}
	if (!A)
	{
		if (ActiveCount >= MaxParticles)
			return FALSE;
		Tex = GetPartTexture(this);
		if (!Tex && bNeedsTexture)
			return FALSE;

		A = reinterpret_cast<ParticlesDataList*>(PartPtr)->GrabDeadParticle();
		if (!A)
			return FALSE;

		ActiveCount++;
		if (ActiveCount >= MaxParticles)
		{
			bAllParticlesSpawned = TRUE;
			if (bAutoDestroy && !GIsEditor)
				bDestruction = TRUE;
			if (FinishedSpawningTrigger)
				FinishedSpawningTrigger->eventTrigger(this, Instigator);
		}
	}
	const FVector& CurLocation = (SpawnFlags & PSF_AbsolutePosition) ? SpawnOffs : Location;
	FVector DesPos = GetSpawnPosition();
	FVector StartPos;
	FVector CurL;
	if( !UseActorCoords )
		CurL = CurLocation;
	else
	{
		if( UseActorCoords->Brush && UseActorCoords->Brush->Points.Num() ) // Could be a mover.
		{
			if( SingleIVert!=-1 )
			{
				SingleIVert = Min(SingleIVert,UseActorCoords->Brush->Points.Num()-1);
				CurL = UseActorCoords->Brush->Points(SingleIVert);
			}
			else
			{
				INT MaxVal = UseActorCoords->Brush->Points.Num();
				CurL = UseActorCoords->Brush->Points(GetRandomVal(MaxVal));
			}
			CurL = CurL.TransformVectorBy(GMath.UnitCoords * UseActorCoords->Rotation);
		}
		else if( bUseMeshAnim && UseActorCoords->Mesh )
		{
			int c=UseActorCoords->Mesh->FrameVerts;
			if( !TransPose )
			{
				TransPose = new FVector[c];
				UseActorCoords->Mesh->GetFrame(TransPose, sizeof(FVector), GMath.UnitCoords, UseActorCoords);
			}
			INT r=0;
			FVector Ad=UseActorCoords->Location+UseActorCoords->PrePivot;
			if( SingleIVert!=-1 )
			{
				SingleIVert = Min(SingleIVert,c-1);
				r = SingleIVert;
			}
			else if( VertexLimitBBox.Min!=FVector(0,0,0) || VertexLimitBBox.Max!=FVector(0,0,0) )
			{
				FScopedMemMark Mark(GMem);
				FBox BX=FBox(VertexLimitBBox.Min+Ad,VertexLimitBBox.Max+Ad);
				INT* AvP = New<INT>(GMem, c);
				int num=0;
				for( int i=0; i<c; i++ )
				{
					if( BX.Min.X<=TransPose[i].X && BX.Max.X>=TransPose[i].X
						&& BX.Min.Y<=TransPose[i].Y && BX.Max.Y>=TransPose[i].Y
						&& BX.Min.Z<=TransPose[i].Z && BX.Max.Z>=TransPose[i].Z )
						AvP[num++] = i;
				}
				if( !num )
					r = 0;
				else r = AvP[GetRandomVal(num)];
			}
			else r = GetRandomVal(c);
			CurL = TransPose[r]-Ad;
		}
		else if( UseActorCoords->Mesh )
		{
			UseActorCoords->Mesh->Verts.Load();
			int c=UseActorCoords->Mesh->FrameVerts;
			if( c )
			{
				INT r=0;
				FMeshVert* Tr=&UseActorCoords->Mesh->Verts(0);
				if( SingleIVert!=-1 )
				{
					SingleIVert = Min(SingleIVert,c-1);
					r = SingleIVert;
				}
				else if( VertexLimitBBox.Min!=FVector(0,0,0) || VertexLimitBBox.Max!=FVector(0,0,0) )
				{
					FScopedMemMark Mark(GMem);
					FBox BX=FBox(VertexLimitBBox.Min,VertexLimitBBox.Max);
					INT* AvP = New<INT>(GMem, c);
					int num=0;
					FCoords TmCr=(GMath.UnitCoords / UseActorCoords->Mesh->RotOrigin);
					BX.Min/=UseActorCoords->Mesh->Scale;
					BX.Min = BX.Min.TransformVectorBy(TmCr);
					BX.Max/=UseActorCoords->Mesh->Scale;
					BX.Max = BX.Max.TransformVectorBy(TmCr);
					FVector V;
					for( int i=0; i<c; i++ )
					{
						V = FVector(Tr[i].X,Tr[i].Y,Tr[i].Z);
						if( BX.Min.X<=V.X && BX.Max.X>=V.X
						 && BX.Min.Y<=V.Y && BX.Max.Y>=V.Y
						 && BX.Min.Z<=V.Z && BX.Max.Z>=V.Z )
							AvP[num++] = i;
					}
					if( !num )
						r = 0;
					else r = AvP[GetRandomVal(num)];
				}
				else r = GetRandomVal(c);
				FCoords TCH = GMath.UnitCoords * UseActorCoords->Rotation
				 * UseActorCoords->Mesh->RotOrigin * FScale(UseActorCoords->Mesh->Scale
				 * UseActorCoords->DrawScale,0.0,SHEER_None);
				CurL = (FVector(Tr[r].X,Tr[r].Y,Tr[r].Z) - UseActorCoords->Mesh->Origin).TransformPointBy(TCH);
			}
		}
		else CurL = FVector(0,0,0);
		CurL+=((SpawnFlags & PSF_AbsolutePosition) ? SpawnOffs : (UseActorCoords->Location+UseActorCoords->PrePivot));
		if( bUseRelativeLocation )
		{
			DesPos+=CurL.TransformPointBy(CacheRot.Inverse() / CurLocation);
			CurL = CurLocation;
		}
	}
	if( !(SpawnFlags & PSF_AbsolutePosition) )
		DesPos+=SpawnOffs;
	if( !bUseRelativeLocation )
	{
		DesPos+=CurL;
		StartPos = DesPos;
	}
	else
	{
		StartPos = DesPos;
		DesPos = CurL+DesPos.TransformVectorBy(CacheRot);
	}

	A->Style = (FadeStyle!=STY_None && (FadeInTime>0.f || FadeOutTime<=0.f)) ? FadeStyle : ParticleStyle;
	A->DrawType = (SpriteAnimationType == SAN_LoopAnim ? DT_Sprite : DT_SpriteAnimOnce);
	A->bHidden = 0;
	A->LifeSpan = 1.f;
	A->Location = DesPos;
	A->Rotation = Rotation;
	A->bMovable = 1;
	A->Region = Region;
	A->ScaleGlow = (FadeInTime > 0.f) ? 0.f : Clamp(FadeInMaxAmount, 0.f, 2.f);
	A->Texture = Tex;
	if (A->LightDataPtr)
		A->LightDataPtr->UpdateFrame = GFrameNumber - 500; // Force to recompute lighting rather then fade from previous particle.

	A->Pos = StartPos;
	A->DrawScale = StartingScale.GetValue();
	A->DrawScale3D = DrawScale3D * Scale3DRange.GetValue();
	A->StartScale3D = A->DrawScale3D;
	A->Velocity = GetSpawnVelocity(A->Location-CurLocation);
	A->Acceleration = ParticleAcceleration.GetValue();
	if( bAccelRelativeToRot )
		A->Acceleration = A->Acceleration.TransformVectorBy(CacheRot);
	FVector Col = ParticleColor.GetValue();
	A->ActorSColor = Col;
	A->ActorRenderColor = FColor(Col);
	A->ActorGUnlitColor = A->ActorRenderColor;
	A->bUnlit = bUnlit;
	A->bUseLitSprite = bUseLitSprite;

	if( bParticleCoronaEnabled )
	{
		FVector cCol = CoronaColor.GetValue();
		A->CoronaColor = FPlane(cCol.X,cCol.Y,cCol.Z,1.f);
		A->CoronaAlpha = 0.f;
	}
	A->LifeTime = LifetimeRange.GetValue();
	A->LifeStartTime = 1.f / A->LifeTime;
	A->Scale = A->DrawScale;
	if( bRevolutionEnabled )
	{
		A->RevOffs = (DesPos - CurLocation + RevolutionOffset.GetValue());
		A->RevSp = RevolutionsPerSec.GetValue() * 65536.f;
	}
	ModifyParticle(A);
	if (bUSModifyParticles)
		eventGetParticleProps(A, A->Pos, A->Velocity, A->Rotation);
	if (SpawnSound.SndCount)
		SpawnSound.PlaySoundEffect(A->Location, XLevel);
	if( TSpawnC.Num() )
		SpawnChildPart(A->Location,TSpawnC);
	if( TLifeTimeC.Num() )
		A->NextCombinerTime = ParticleLifeTimeSDelay.GetValue();
	if (bEnablePhysX && XLevel->PhysicsScene)
		InitPhysXParticle(A);
	if( bUSNotifyParticles )
		eventNotifyNewParticle(A);

	if (ParticleTrail)
	{
		A->LatentActor = ParticleTrail->GrabTrail(A->Location, A->Rotation);
		if (A->LatentActor)
			A->LatentActor->bAnimByOwner = (ParticleTrail->bFadeByOwnerParticle != 0);
#if 0
		if (A->LatentActor)
		{
			for (xParticle* B = reinterpret_cast<ParticlesDataList*>(PartPtr)->AliveList; B; B = B->NextParticle)
			{
				if (A != B && B->LatentActor == A->LatentActor)
				{
					appErrorf(TEXT("2 particles had same trail! (%i/%i)"), A->NetTag, B->NetTag);
				}
			}
		}
#endif
	}

	if( WaterImpactAction!=HIT_DoNothing )
	{
		XLevel->Model->GetPointRegion(Level, DesPos, A->Region);
		if( A->Region.Zone )
		{
			switch (WaterImpactAction)
			{
			case HIT_Destroy:
				if (A->Region.Zone->bWaterZone)
				{
					A->DestroyParticle();
					if (TDestructC.Num())
						SpawnChildPart(A->Location, TDestructC);
					if (DestroySound.SndCount)
						DestroySound.PlaySoundEffect(A->Location, XLevel);
				}
				break;
			case HIT_StopMovement:
				if (A->Region.Zone->bWaterZone)
					A->bMovable = 0;
				break;
			}
		}
	}

	return 1;
	unguardSlow;
}
void AXEmitter::UpdateParticles(FLOAT Delta, UEmitterRendering* Render)
{
	guardSlow(AXEmitter::UpdateParticles);

	BEGIN_PARTICLE_ITERATOR
		// Particle died
		if( (A->LifeTime-=Delta)<=0 )
		{
			A->DestroyParticle();
			if (DestroySound.SndCount)
				DestroySound.PlaySoundEffect(A->Location, XLevel);
			if( TDestructC.Num() )
				SpawnChildPart(A->Location,TDestructC);
			continue;
		}

		// Update location
		BYTE i=0;
		FLOAT Sc = (1.f - (A->LifeTime * A->LifeStartTime));
		A->OldLocation = A->Location;
		if (A->RbPhysicsData)
		{
			A->RbPhysicsData->Tick(Delta);
			if (bRotationRequest)
				A->Rotation = GetParticleRot(A, Delta, A->Location, Render);
		}
		else
		{
			if (A->bMovable)
			{
				FVector SpeedScale3D(1, 1, 1);
				if (SpeedTimeScale3D.Num())
					SpeedScale3D = GetTimeScaleValue(Sc, &SpeedTimeScale3D(0), SpeedTimeScale3D.Num());
				if (SpeedScale.Num())
					SpeedScale3D *= GetScalerValue(Sc, 1.f, SpeedScale.Num(), &SpeedScale(0).Time, &SpeedScale(0).VelocityScale, sizeof(FSpeedRangeType));
				if (bRevolutionEnabled)
				{
					FVector RevScale3D(1, 1, 1);
					if (RevolutionTimeScale.Num())
						RevScale3D = GetTimeScaleValue(Sc, (FSpeed3DType*)&RevolutionTimeScale(0), RevolutionTimeScale.Num());
					FCoords TC = (GMath.UnitCoords / FRotator(appFloor(A->RevSp.X * Delta * RevScale3D.X), appFloor(A->RevSp.Y * Delta * RevScale3D.Y), appFloor(A->RevSp.Z * Delta * RevScale3D.Z)));
					FVector NewR = A->RevOffs.TransformVectorBy(TC);
					if (bEffectsVelocity)
						A->Velocity = A->Velocity.TransformVectorBy(TC);
					if (NewR != A->RevOffs)
					{
						A->Pos += (NewR - A->RevOffs);
						A->RevOffs = NewR;
					}
				}
				FVector MoveDelta = A->Velocity * Delta * SpeedScale3D;
				if (bRevolutionEnabled)
					A->RevOffs += MoveDelta * RevolutionOffsetUnAxis;
				A->Pos += MoveDelta;
				FVector DesPos;
				if (bUseRelativeLocation)
					DesPos = Location + A->Pos.TransformVectorBy(CacheRot);
				else DesPos = A->Pos;
				if (ParticleCollision && WallImpactAction) /* !=ECT_HitNothing */
				{
					FCheckResult HT;
					DWORD Flgs;
					if (ParticleCollision == ECT_HitWalls)
						Flgs = TRACE_VisBlocking;
					else if (ParticleCollision == ECT_HitActors)
						Flgs = TRACE_AllColliding;
					else Flgs = TRACE_ProjTargets;
					if (!XLevel->SingleLineCheck(HT, this, DesPos, A->Location, Flgs, ParticleExtent))
					{
						if (ImpactSound.SndCount && A->Velocity.SizeSquared() >= Square(MinImpactVelForSnd))
							ImpactSound.PlaySoundEffect(DesPos, XLevel);
						switch (WallImpactAction)
						{
						case HIT_Destroy:
							A->DestroyParticle();
							if (TWallHitC.Num())
								SpawnChildPart(HT.Location, TWallHitC);
							if (TDestructC.Num())
								SpawnChildPart(HT.Location, TDestructC);
							if (DestroySound.SndCount)
								DestroySound.PlaySoundEffect(HT.Location, XLevel);
							break;
						case HIT_StopMovement:
							A->bMovable = 0;
							break;
						case HIT_Bounce:
						{
							if (bUseRelativeLocation)
								HT.Normal = HT.Normal.TransformVectorBy(GMath.UnitCoords / Rotation);
							A->Velocity = A->Velocity.MirrorByVector(HT.Normal) * ParticleBounchyness;
							if (HT.Actor)
								A->Velocity += HT.Actor->Velocity * HittingActorKickVelScale;
							DesPos = HT.Location + HT.Normal;
							if (!bUseRelativeLocation)
								A->Pos = DesPos;
							if (A->Velocity.SizeSquared() < Square(MinBounceVelocity))
								A->bMovable = 0;
						}
						break;
						default:
							if (!bUseRelativeLocation)
								A->Pos = HT.Location;
							eventParticleWallHit(A, HT.Normal, A->Pos);
							if (A->bHidden)
							{
								if (TWallHitC.Num())
									SpawnChildPart(HT.Location, TWallHitC);
								if (TDestructC.Num())
									SpawnChildPart(HT.Location, TDestructC);
								if (DestroySound.SndCount)
									DestroySound.PlaySoundEffect(HT.Location, XLevel);
							}
							break;
						}
						if (A->bHidden)
							continue;
						if (TWallHitC.Num())
							SpawnChildPart(DesPos, TWallHitC);
					}
				}
				A->Location = DesPos;
				if (WaterImpactAction)
				{
					FPointRegion Reg;
					XLevel->Model->GetPointRegion(Level, A->Location, Reg);
					if (Reg.Zone && Reg.Zone != A->Region.Zone)
					{
						switch (WaterImpactAction)
						{
						case HIT_Destroy:
							if (!Reg.Zone->bWaterZone)
								break;
							A->DestroyParticle();
							if (TDestructC.Num())
								SpawnChildPart(A->Location, TDestructC);
							if (DestroySound.SndCount)
								DestroySound.PlaySoundEffect(A->Location, XLevel);
							break;
						case HIT_StopMovement:
							if (Reg.Zone->bWaterZone)
								A->bMovable = 0;
							break;
						case HIT_Bounce:
							if (!Reg.Zone->bWaterZone)
								break;
							A->Pos.Z -= A->Velocity.Z * Delta;
							A->Velocity.Z *= -ParticleBounchyness.Z;
							if (A->Velocity.SizeSquared() < Square(MinBounceVelocity))
								A->bMovable = 0;
							break;
						default:
							eventParticleZoneHit(A, Reg.Zone);
							if (A->bHidden)
							{
								if (TDestructC.Num())
									SpawnChildPart(A->Location, TDestructC);
								if (DestroySound.SndCount)
									DestroySound.PlaySoundEffect(A->Location, XLevel);
							}
							break;
						}
						if (A->bHidden)
							continue;
						A->Region.Zone = Reg.Zone;
					}
				}
			}
			if (bRotationRequest)
				A->Rotation = GetParticleRot(A, Delta, A->Location, Render);

			if (A->bMovable)
			{
				// Add velocity for location
				A->Velocity += A->Acceleration * Delta;

				// Update velocity loss
				if (bHasLossVel)
				{
					A->Velocity.X *= (1.f - Min(VelocityLossRate.X * Delta, 1.f));
					A->Velocity.Y *= (1.f - Min(VelocityLossRate.Y * Delta, 1.f));
					A->Velocity.Z *= (1.f - Min(VelocityLossRate.Z * Delta, 1.f));
				}
			}
		}

		// Update draw scale
		if (TimeScale.Num())
			A->DrawScale = A->Scale * GetScalerValue(Sc, 1.f, TimeScale.Num(), &TimeScale(0).Time, &TimeScale(0).DrawScaling, sizeof(FScaleRangeType));
		if (TimeDrawScale3D.Num())
			A->DrawScale3D = A->StartScale3D * GetTimeScaleValue(Sc, &TimeDrawScale3D(0), TimeDrawScale3D.Num());

		// Update particle color scale
		if(ParticleColorScale.Num())
		{
			FVector GCol = A->ActorSColor * GetScalerValueColor(Sc, &ParticleColorScale(0), ParticleColorScale.Num());
			A->ActorRenderColor = FColor(GCol);
			A->ActorGUnlitColor = A->ActorRenderColor;
		}

		if (SpriteAnimationType == SAN_PlayOnce)
			A->LifeSpan = 1.f - Sc;
		else if (SpriteAnimationType == SAN_PlayOnceInverted)
			A->LifeSpan = Sc;

		// Update texture
		if (!bUseRandomTex && ParticleTextures.Num() > 1)
		{
			if (ParticleTextures.Num())
				A->Texture = ParticleTextures(Min(appFloor(Sc * FLOAT(ParticleTextures.Num())), ParticleTextures.Num() - 1));
			if (!A->Texture)
				A->Texture = Level->DefaultTexture;
		}

		if( A->bMovable && ForcesList.Num() )
		{
			for( i=0; i<ForcesList.Num(); i++ )
			{
				if (ForcesList(i) && ForcesList(i)->UpdateForceOn(A, Sc))
					ForcesList(i)->HandleForce(A, Delta);
			}
		}

		// Update scale glowing
		if( Sc<FadeInTime )
			Sc/=FadeInTime;
		else if( Sc<FadeOutTime )
			Sc = 1;
		else Sc = 1.f-(Sc-FadeOutTime)/(1.f-FadeOutTime);

		if (FadeStyle != STY_None)
		{
			if (Sc < 1.f)
				A->Style = FadeStyle;
			else A->Style = ParticleStyle;
		}

		// Distance fade-off
		if( CullDistanceFadeDist<1.f )
		{
			FLOAT DistScale = (A->Location - Render->Frame->Coords.Origin).Size() / CullDistance;
			if (DistScale > CullDistanceFadeDist)
				Sc *= 1.f - (DistScale - CullDistanceFadeDist) / (1.f - CullDistanceFadeDist);
		}
		A->ScaleGlow = Clamp(Sc*FadeInMaxAmount,0.f,2.f);

		// Handle trail.
		if (A->LatentActor)
		{
			if (A->LatentActor->bAnimByOwner)
				A->LatentActor->ScaleGlow = A->ScaleGlow;
			A->LatentActor->Location = A->Location;
			A->LatentActor->Rotation = A->Rotation;
			A->LatentActor->NetTag = (INT)GFrameNumber;
		}

		// Add combiner
		if( TLifeTimeC.Num() )
		{
			A->NextCombinerTime-=Delta;
			if(A->NextCombinerTime<=0 )
			{
				SpawnChildPart(A->Location,TLifeTimeC);
				A->NextCombinerTime = ParticleLifeTimeSDelay.GetValue();
			}
		}
		if( bAutoVisibilityBox )
		{
			RendBoundingBox += (A->Location + VisibilityBox.Min * A->DrawScale);
			RendBoundingBox += (A->Location + VisibilityBox.Max * A->DrawScale);
		}
	END_PARTICLE_ITERATOR

	unguardSlow;
}
inline FVector GetRand2D()
{
	FLOAT Size;
	FVector Calc(0.f,0.f,0.f);
	do
	{
		Calc.Y = appFrand()*2.f - 1.f;
		Calc.Z = appFrand()*2.f - 1.f;
		Calc.NormalApprox();
		Size = (Square(Calc.Y) + Square(Calc.Z));
	} while (Size < KINDA_SMALL_NUMBER);
	return (Calc * appFastInvSqrt(Size));
}
inline FVector GetRand3D()
{
	FLOAT Size;
	FVector Calc(0.f,0.f,0.f);
	do
	{
		Calc.X = appFrand()*2.f - 1.f;
		Calc.Y = appFrand()*2.f - 1.f;
		Calc.Z = appFrand()*2.f - 1.f;
		Size = Calc.SizeSquared();
	} while(Size < KINDA_SMALL_NUMBER );
	return (Calc * appFastInvSqrt(Size));
}
FVector AXEmitter::GetSpawnPosition()
{
	FVector Res(0,0,0);
	switch( SpawnPosType )
	{
	case SP_Box:
		Res = BoxLocation.GetValue();
		break;
	case SP_BoxSphere:
		Res = BoxLocation.GetValue();
	case SP_Sphere:
		Res+=GetRand3D()*SphereCylinderRange.GetValue();
		break;
	case SP_BoxCylinder:
		Res = BoxLocation.GetValue();
	default:
		Res+=GetRand2D()*SphereCylinderRange.GetValue();
		break;
	}
	Res*=SpawnOffsetMultiplier;
	if( bRelativeToRotation )
		Res = Res.TransformVectorBy(CacheRot);
	return Res;
}
FVector AXEmitter::GetSpawnVelocity( FVector VelValue )
{
	FVector Res(0,0,0);
	if( bCylRangeBasedOnPos )
	{
		Res = VelValue;
		Res.Normalize();
		Res*=SphereCylVelocity.GetValue();
		Res+=BoxVelocity.GetValue();
		return Res;
	}
	switch( SpawnVelType )
	{
	case SP_Box:
		Res = BoxVelocity.GetValue();
		break;
	case SP_BoxSphere:
		Res = BoxVelocity.GetValue();
	case SP_Sphere:
		Res += GetRand3D() * SphereCylVelocity.GetValue();
		break;
	case SP_BoxCylinder:
		Res = BoxVelocity.GetValue();
	default:
		Res += GetRand2D() * SphereCylVelocity.GetValue();
		break;
	}
	if( bVelRelativeToRotation )
		Res = Res.TransformVectorBy(CacheRot);
	return Res;
}

FRotator AXEmitter::GetParticleRot(xParticle* A, FLOAT Dlt, FVector& Mvd, UEmitterRendering* Render)
{
	return FRotator(0,0,0);
}

void AXEmitter::ResetEmitter()
{
	guard(AXEmitter::ResetEmitter);
	AXParticleEmitter::ResetEmitter();

	if( PartPtr )
	{
		PartPtr->SetLen(MaxParticles);
		PartPtr->HideAllParts();
	}

	ImpactSound.InitSoundList();
	SpawnSound.InitSoundList();
	DestroySound.InitSoundList();
	if( ParticlesPerSec<=0 )
		SpawnInterval = LifetimeRange.Max/MaxParticles;
	else SpawnInterval = LifetimeRange.Max/ParticlesPerSec;
	NextParticleTime = 0.1;
	if( !bSpawnInitParticles )
		ActiveCount = MaxParticles;
	bHasLossVel = (VelocityLossRate!=FVector(0,0,0));
	bAllParticlesSpawned = FALSE;
	unguard;
}

UBOOL AXEmitter::ShouldRenderEmitter(FSceneNode* Frame)
{
	if (!bNoUpdateOnInvis)
		return IsVisible(Frame);
	else if (bDestruction && !IsVisible(Frame))
		return false;
	return true;
}
UBOOL AXEmitter::ShouldUpdateEmitter(FSceneNode* Frame)
{
	if( bDestruction )
		return true;
	if (bNoUpdateOnInvis)
		return IsVisible(Frame);
	return true;
}
UBOOL AXEmitter::IsVisible(FSceneNode* Frame)
{
	if (!bDisableRender && (GIsEditor || !bStasisEmitter || (XLevel->TimeSeconds - XLevel->Model->Zones[Region.ZoneNumber].LastRenderTime).GetFloat() < 3))
	{
		if (bDistanceCulling && (Frame->Coords.Origin - Location).SizeSquared() > Square(CullDistance))
			return FALSE;
		return TRUE;
	}
	return FALSE;
}
void AXEmitter::GenerateChildEmitter(UClass* EmitClass, TArray<AXEmitter*>& AppendArray)
{
	guardSlow(AXEmitter::GenerateChildEmitter);
	if (!EmitClass)
		return;
	AXEmitter* EX = ConstructObject<AXEmitter>(EmitClass, TopOuter(), NAME_None, RF_Transient);
	if( !EX )
		return;
	EX->bIsInternalEmitter = TRUE;
	EX->bIsTransientEmitter = TRUE;
	AppendArray.AddItem(EX);
	EX->CombinerList = ParentEmitter->CombinerList;
	ParentEmitter->CombinerList = EX;
	EX->TransientEmitters = ParentEmitter->TransientEmitters;
	ParentEmitter->TransientEmitters = EX;

	EX->InitializeEmitter(ParentEmitter);
	unguardSlow;
}

#define HANDLE_EMITTER(citem) \
	citem->bIsInternalEmitter = TRUE; \
	citem->CombinerList = ParentEmitter->CombinerList; \
	ParentEmitter->CombinerList = citem; \
	if (!citem->bHasInitialized) \
		citem->InitializeEmitter(ParentEmitter); \
	else citem->RelinkChildEmitters()

#define LOOP_COMBINERS(coldlist, cnewlist, clink) \
	for (i = (clink.Num() - 1); i >= 0; --i) \
		if (!clink(i) || !clink(i)->bIsTransientEmitter) \
			clink.Remove(i); \
	for (i = (coldlist.Num() - 1); i >= 0; --i) \
		if (coldlist(i)) \
			clink.AddItem(coldlist(i)); \
	for (i = (cnewlist.Num() - 1); i >= 0; --i) \
	{ \
		X = cnewlist(i); \
		if (X) \
		{ \
			clink.AddItem(X); \
			HANDLE_EMITTER(X); \
		} \
	}

void AXEmitter::RelinkChildEmitters()
{
	guardSlow(AXEmitter::RelinkChildEmitters);
	Super::RelinkChildEmitters();

	INT i;
	AXEmitter* X;

	LOOP_COMBINERS(SpawnCombiners, SpawnCombiner, TSpawnC);
	LOOP_COMBINERS(LifeTimeCombiners, LifeTimeCombiner, TLifeTimeC);
	LOOP_COMBINERS(DestructCombiners, KillCombiner, TDestructC);
	LOOP_COMBINERS(WallHitCombiners, WallHitCombiner, TWallHitC);

	if (ParticleTrail)
	{
		HANDLE_EMITTER(ParticleTrail);
	}
	unguardSlow;
}

#undef HANDLE_EMITTER
#undef LOOP_COMBINERS

#define ADD_COMBINER_REF(ctag,clist) \
	if (ctag != NAME_None && ctag == X->Tag) \
		clist.AddItem(X); \
	if (X->ctag != NAME_None && X->ctag == Tag) \
		X->clist.AddUniqueItem(this);

/* Editor macro's */
void AXEmitter::Modify()
{
	guard(AXEmitter::Modify);
	if( GIsEditor )
	{
		if (!ParentEmitter || !bHasInitialized)
			InitializeEmitter(ParentEmitter ? ParentEmitter : this);
		INT i;

		guardSlow(InitForces);
		ForcesList.Empty();
		UBOOL bResult = FALSE;
		for (i = 0; i < ARRAY_COUNT(ForcesTags); i++)
			if (ForcesTags[i] != NAME_None)
			{
				bResult = TRUE;
				break;
			}
		if (bResult)
		{
			for (TActorIterator<AXParticleForces> It(XLevel); It; ++It)
			{
				AXParticleForces* FR = *It;
				if (FR->IsPendingKill() || FR->Tag == NAME_None)
					continue;
				bResult = FALSE;
				for (i = 0; i < ARRAY_COUNT(ForcesTags); i++)
					if (ForcesTags[i] == FR->Tag)
					{
						bResult = TRUE;
						break;
					}
				if (!bResult)
					continue;
				ForcesList.AddItem(FR);
			}
		}
		unguardSlow;

		guardSlow(InitCombiners);
		SpawnCombiners.Empty();
		LifeTimeCombiners.Empty();
		DestructCombiners.Empty();
		WallHitCombiners.Empty();
		for (TActorIterator<AXEmitter> It(XLevel); It; ++It)
		{
			AXEmitter* X = *It;
			if( X->IsPendingKill() )
				continue;

			ADD_COMBINER_REF(ParticleSpawnTag, SpawnCombiners);
			ADD_COMBINER_REF(ParticleKillTag, DestructCombiners);
			ADD_COMBINER_REF(ParticleWallHitTag, WallHitCombiners);
			ADD_COMBINER_REF(ParticleLifeTimeTag, LifeTimeCombiners);
		}
		ParentEmitter->RelinkChildEmitters();
		unguardSlow;
	}
	Super::Modify();
	unguard;
}
#undef ADD_COMBINER_REF

void AXEmitter::PostScriptDestroyed()
{
	guardSlow(AXEmitter::PostScriptDestroyed);
	if (GIsEditor && !bIsInternalEmitter)
	{
		for (TActorIterator<AXEmitter> It(XLevel); It; ++It)
		{
			AXEmitter* EM = *It;
			if (EM == this || EM->IsPendingKill())
				continue;
			EM->CleanUpRefs(this);
		}
	}
	Super::PostScriptDestroyed();
	unguardSlow;
}

#define KILL_COMBINER_ITEM(citem) \
	citem->DestroyCombiners(); \
	citem->ConditionalDestroy(); \
	delete citem;
#define KILL_COMBINER_LIST(clist) \
	for (i = (clist.Num() - 1); i >= 0; --i) \
		if (clist(i)) \
		{ \
			KILL_COMBINER_ITEM(clist(i)); \
		} \
	clist.EmptyFArray();

void AXEmitter::DestroyCombiners()
{
	guardSlow(AXEmitter::DestroyCombiners);
	if (ParticleTrail)
	{
		KILL_COMBINER_ITEM(ParticleTrail);
		ParticleTrail = NULL;
	}
	INT i;
	KILL_COMBINER_LIST(SpawnCombiner);
	KILL_COMBINER_LIST(KillCombiner);
	KILL_COMBINER_LIST(WallHitCombiner);
	KILL_COMBINER_LIST(LifeTimeCombiner);
	TSpawnC.EmptyFArray();
	TLifeTimeC.EmptyFArray();
	TDestructC.EmptyFArray();
	TWallHitC.EmptyFArray();
	Super::DestroyCombiners();
	unguardSlow;
}

#define CLEANUP_REFS_FROM(carr) \
	for( i=(carr.Num()-1); i>=0; i-- ) \
		if (!carr(i) || carr(i) == X) \
			carr.Remove(i)

void AXEmitter::CleanUpRefs( AXEmitter* X )
{
	guardSlow(AXEmitter::CleanUpRefs);
	INT i;
	CLEANUP_REFS_FROM(SpawnCombiners);
	CLEANUP_REFS_FROM(LifeTimeCombiners);
	CLEANUP_REFS_FROM(DestructCombiners);
	CLEANUP_REFS_FROM(WallHitCombiners);
	CLEANUP_REFS_FROM(TSpawnC);
	CLEANUP_REFS_FROM(TLifeTimeC);
	CLEANUP_REFS_FROM(TDestructC);
	CLEANUP_REFS_FROM(TWallHitC);
	unguardobjSlow;
}
#undef CLEANUP_REFS_FROM

void AXEmitter::OnCreateObjectNew(UObject* ParentObject)
{
	guardSlow(AXEmitter::OnCreateObjectNew);
	Super::OnCreateObjectNew(ParentObject);

	// Setup good properties for child emitters.
	bSpawnInitParticles = FALSE;
	bRespawnParticles = FALSE;

	// Not needed on server!
	SetFlags(RF_NotForServer);
	ClearFlags(RF_LoadForServer);
	unguardSlow;
}

void AXEmitter::OnImportDefaults(UClass* OwnerClass)
{
	guard(AXEmitter::OnImportDefaults);
	Super::OnImportDefaults(OwnerClass);

	if (OwnerClass->IsChildOf(AXParticleEmitter::StaticClass()))
	{
		// Not needed on server!
		SetFlags(RF_NotForServer);
		ClearFlags(RF_LoadForServer);
	}
	unguard;
}

static UBOOL bHasDistFog;
static FFogSurf FogSurfaceEmitter;

inline void InitFog(FSceneNode* Frame, AActor* Owner)
{
	AZoneInfo* MyZone = Owner->Region.Zone; if (MyZone && !MyZone->bZoneBasedFog) MyZone = NULL;
	BYTE bCustomFog = (Frame->FrameModifier && Frame->FrameModifier->bOverrideDistanceFog);
	bHasDistFog = (bCustomFog ? Frame->FrameModifier->bDistanceFogActors : (MyZone ? MyZone->bDistanceFog : Frame->Viewport->Actor->bDistanceFogEnabled));
	if (bHasDistFog && GIsEditor && !(Frame->Viewport->Actor->ShowFlags & SHOW_DistanceFog))
		bHasDistFog = 0;
	if (bHasDistFog)
	{
		if (bCustomFog) Frame->FrameModifier->GetFog(&FogSurfaceEmitter);
		else if (!MyZone) Frame->Viewport->Actor->GetFog(&FogSurfaceEmitter);
		else MyZone->GetFog(&FogSurfaceEmitter);

		if (!FogSurfaceEmitter.IsValid()) bHasDistFog = 0;
		else FogSurfaceEmitter.FogDistanceEnd = 1.f / (FogSurfaceEmitter.FogDistanceEnd - FogSurfaceEmitter.FogDistanceStart);
	}
}

/* Particle corona rendering */
void AXEmitter::DrawCorona( FSceneNode* Frame, FLOAT Delta )
{
	guard(AXEmitter::DrawCorona);
	bHasDistFog = 2;
	if (bParticleCoronaEnabled)
	{
		InitFog(Frame, this);
		DrawPartCoronas(Frame, Delta, this);
	}
	if (CombinerList)
	{
		for (AXParticleEmitter* P = CombinerList; P; P = P->CombinerList)
			P->DrawPartCoronas(Frame, Delta, this);
	}
	unguard;
}
void AXEmitter::DrawPartCoronas(FSceneNode* Frame, FLOAT Delta, AXParticleEmitter* Parent)
{
	if (!bParticleCoronaEnabled || !CoronaTexture || bDeleteMe || !PartPtr)
		return;
	if (bHasDistFog == 2)
		InitFog(Frame, this);
	URenderDevice* RendDev = Frame->Viewport->RenDev;
	URenderBase* Render = UEngine::GEngine->Render;
	UBOOL bIsVisible = IsVisible(Frame);
	FVector CPos, Dir;
	FLOAT XPos,YPos,ScSize,XScl,YScl,ScaleGlw,DotDist;
	FTextureInfo* CorTex = CoronaTexture->GetTexture(INDEX_NONE, RendDev);
	DWORD TraceFlags = (bActorsBlockSight ? TRACE_ProjTargets : TRACE_VisBlocking);
	AActor* ViewActor = (Frame->Viewport->Actor->CalcCameraActor ? Frame->Viewport->Actor->CalcCameraActor : Frame->Viewport->Actor);

	BEGIN_PARTICLE_ITERATOR;

		if( bCOffsetRelativeToRot )
			CPos = A->Location + CoronaOffset.TransformVectorBy(GMath.UnitCoords/A->Rotation);
		else CPos = A->Location + CoronaOffset;

		Dir = CPos - Frame->Coords.Origin;
		DotDist = (Frame->Coords.ZAxis | Dir);
		if (DotDist < 0.f)
		{ // Behind the camera, no render.
			A->CoronaAlpha = 0.f;
			continue;
		}
		ScSize = 1.f;
		Render->Project(Frame, CPos, XPos, YPos, &ScSize);
		if (!bIsVisible || Dir.SizeSquared() > Square(MaxCoronaDistance) || XPos<0 || YPos<0
			|| XPos>Frame->X || YPos>Frame->Y || (bCheckLineOfSight
				&& !XLevel->FastLineCheck(CPos, Frame->Coords.Origin, TraceFlags, ViewActor)))
			A->CoronaAlpha = Max(A->CoronaAlpha - Delta * CoronaFadeTimeScale, 0.f);
		else if (A->CoronaAlpha < 1.f)
			A->CoronaAlpha = Min(A->CoronaAlpha + Delta * CoronaFadeTimeScale, 1.f);

		ScaleGlw = A->CoronaAlpha * A->ScaleGlow;
		if (bHasDistFog && ScaleGlw > 0.f)
			ScaleGlw *= Clamp(1.f - (DotDist - FogSurfaceEmitter.FogDistanceStart) * FogSurfaceEmitter.FogDistanceEnd, 0.f, 1.f);

		if(ScaleGlw <=DELTA)
			continue; // Already invisible.

		CoronaMaxScale = Clamp(CoronaMaxScale,0.f,65536.f); //protect from crash due to insane values...

		if( CoronaMaxScale>0 )
			ScSize = Min(ScSize*CoronaScaling,CoronaMaxScale);
		else ScSize*=CoronaScaling;
		XScl = FLOAT(CoronaTexture->USize)*ScSize;
		YScl = FLOAT(CoronaTexture->VSize)*ScSize;
		RendDev->DrawTile(Frame, *CorTex, XPos - XScl * 0.5, YPos - YScl * 0.5, XScl, YScl,
			0, 0, CoronaTexture->USize, CoronaTexture->VSize, NULL, 1.f,
			A->CoronaColor * ScaleGlw, FPlane(0, 0, 0, 0),
			(PF_TwoSided | PF_Translucent));
	
	END_PARTICLE_ITERATOR;
}

FBox AXEmitter::GetVisibilityBox()
{
	return (bAutoVisibilityBox ? RendBoundingBox : FBox(Location+VisibilityBox.Min,Location+VisibilityBox.Max));
}
