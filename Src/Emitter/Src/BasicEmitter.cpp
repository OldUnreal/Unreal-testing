
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXParticleEmitter);
IMPLEMENT_CLASS(AXEmitter);
IMPLEMENT_CLASS(AEmitterRC);

void AXEmitter::InitView()
{
	guardSlow(AXEmitter::InitView);
	bFilterByVolume = ((bBoxVisibility || bAutoVisibilityBox) && !GIsEditor && ParticleStyle!=STY_AlphaBlend);
	if( bFilterByVolume && ParticleStyle==STY_Translucent )
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
	if( !RenderInterface )
	{
		MaxParticles = Count;
		return;
	}
	((UEmitterRendering*)RenderInterface)->ChangeParticleCount(Count);
	MaxParticles = Count;
	ActiveCount = Min(ActiveCount, Count);
	if( ParticlesPerSec<=0 )
		SpawnInterval = LifetimeRange.Max/Count;
}
void AXEmitter::execKill (FFrame& Stack, RESULT_DECL)
{
	guard (AXEmitter::execKill);
	P_FINISH;
	KillEmitter();
	unguardexec;
}
void AXEmitter::KillEmitter()
{
	guard(AXEmitter::KillEmitter);
	if( bDeleteMe )
		return;
	if( GIsEditor )
		XLevel->DestroyActor(this);
	else
	{
		UEmitterRendering* It = Cast<UEmitterRendering>(RenderInterface);
		if( !It || !It->HasAliveParticles() )
			XLevel->DestroyActor(this);
		else bDestruction = 1;
	}
	unguard;
}
void AXEmitter::execEmTrigger (FFrame& Stack, RESULT_DECL)
{
	guard (AXEmitter::execEmTrigger);
	P_FINISH;
	TriggerEmitter();
	unguardexec;
}
void AXEmitter::TriggerEmitter()
{
	switch( TriggerAction )
	{
	case ETR_ToggleDisabled:
		bDisabled = !bDisabled;
		break;
	case ETR_ResetEmitter:
		if( RenderInterface )
			((UEmitterRendering*)RenderInterface)->HideAllParticles();
		ActiveCount = 0;
		break;
	default:
		SpawnMoreParticles(SpawnParts.GetValue());
		break;
	}
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
void AXEmitter::UpdateEmitter( const float DeltaTime, UEmitterRendering* Sender )
{
	guard(AXEmitter::UpdateEmitter);
	CacheRot = (GMath.UnitCoords * Rotation);
	if( bAutoReset && ResetTimer>0 )
	{
		ResetTimer-=DeltaTime;
		if( ResetTimer<=0 )
			ActiveCount = 0;
	}
	if( Sender->PartPtr->bHadDelaySpawn )
	{
		FVector* TransPose=NULL;
		Sender->PartPtr->bHadDelaySpawn = 0;
		int j=Sender->PartPtr->DelaySpawn.Num();
		for( int i=0; i<j; i++ )
		{
			for( int z=CombinedParticleCount.GetValue(); z>0; z-- )
				SpawnParticle(Sender,PSF_AbsolutePosition,TransPose,Sender->PartPtr->DelaySpawn(i));
		}
		Sender->PartPtr->DelaySpawn.Empty();
		if( TransPose )
			delete TransPose;
	}
	if( !bDisabled && !bDestruction )
	{
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
					if( !SpawnParticle(Sender,PSF_CheckRespawn,TransPose,(SpawnCoordsOffs*PCount)) )
						break;
					PCount--;
				}
			}
			else
			{
				while( PCount>0 )
				{
					if( !SpawnParticle(Sender,PSF_CheckRespawn,TransPose) )
						break;
					PCount--;
				}
			}
			if( TransPose )
				delete[] TransPose;
		}
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
	bHasAliveParticles = 0;
	UpdateParticles(DeltaTime, Sender);

	if( !bHasAliveParticles )
	{
		if( (bAutoDestroy && !bRespawnParticles && ActiveCount>=Sender->PartPtr->Len()) || bDestruction )
			bKillNextTick = 1;
		else if( bAutoReset && ResetTimer<=0 && ActiveCount>=Sender->PartPtr->Len() )
			ResetTimer = AutoResetTime.GetValue();
	}
	UpdateChildren(DeltaTime, Sender);
	unguardobj;
}
void AXEmitter::InitializeEmitter(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter)
{
	guard(AXEmitter::InitializeEmitter);
	Render->ChangeParticleCount(MaxParticles); // Allocate the emitter on startup.
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
	InitChildCombiners(Render, EmitterOuter);
	unguard;
}

UBOOL AXEmitter::RemoteSpawnParticle( FVector Position )
{
	if( !RenderInterface || bDisabled )
		return 0;
	((UEmitterRendering*) RenderInterface)->SpawnDelayedPart(Position);
	return 1;
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
		Result = E->Level->DefaultTexture;
	return Result;
}

BYTE AXEmitter::SpawnParticle( UEmitterRendering* Render, BYTE SpawnFlags, FVector*& TransPose, const FVector& SpawnOffs )
{
	guardSlow(AXEmitter::SpawnParticle);
	int Act=0;
	AActor* A = NULL;
	UTexture* Tex;
	if( bRespawnParticles || !(SpawnFlags & PSF_CheckRespawn) )
	{
		for( int i=0; i<ActiveCount; i++ )
		{
			if( !Render->PartPtr->AboutToDie(i) )
				continue;

			Tex = GetPartTexture(this);
			if (!Tex && bNeedsTexture)
				return FALSE;
			A = Render->PartPtr->GetA(i);
			Act = i;
			break;
		}
	}
	if (!A)
	{
		if (ActiveCount >= Render->PartPtr->Len())
			return FALSE;
		Tex = GetPartTexture(this);
		if (!Tex && bNeedsTexture)
			return FALSE;

		A = Render->PartPtr->GetA(ActiveCount);
		Act = ActiveCount;
		ActiveCount++;
		if (ActiveCount >= Render->PartPtr->Len())
		{
			if (FinishedSpawningTrigger)
				FinishedSpawningTrigger->eventTrigger(this, Instigator);
		}
	}
	const FVector& CurLocation = (SpawnFlags & PSF_AbsolutePosition) ? SpawnOffs : Location;
	PartsType& Data = Render->PartPtr->Get(Act);
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
				FBox BX=FBox(VertexLimitBBox.Min+Ad,VertexLimitBBox.Max+Ad);
				size_t sz = sizeof(INT) * c;
				INT* AvP = (INT*)appAlloca(sz);
				int num=0;
				for( int i=0; i<c; i++ )
				{
					if( BX.Min.X<=TransPose[i].X && BX.Max.X>=TransPose[i].X
						&& BX.Min.Y<=TransPose[i].Y && BX.Max.Y>=TransPose[i].Y
						&& BX.Min.Z<=TransPose[i].Z && BX.Max.Z>=TransPose[i].Z )
					{
						AvP[num] = i;
						num++;
					}
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
					FBox BX=FBox(VertexLimitBBox.Min,VertexLimitBBox.Max);
					size_t sz = sizeof(INT) * c;
					INT* AvP = (INT*)appAlloca(sz);
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
						{
							AvP[num] = i;
							num++;
						}
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

	Data.Pos = StartPos;
	A->DrawScale = StartingScale.GetValue();
	A->DrawScale3D = DrawScale3D * Scale3DRange.GetValue();
	Data.StartScale3D = A->DrawScale3D;
	A->Velocity = GetSpawnVelocity(A->Location-CurLocation);
	A->Acceleration = ParticleAcceleration.GetValue();
	if( bAccelRelativeToRot )
		A->Acceleration = A->Acceleration.TransformVectorBy(CacheRot);
	FVector Col = ParticleColor.GetValue();
	Data.ActorSColor = Col;
	A->ActorRenderColor = FColor(Col);
	A->ActorGUnlitColor = A->ActorRenderColor;
	A->bUnlit = bUnlit;
	A->bUseLitSprite = bUseLitSprite;

	if( bParticleCoronaEnabled )
	{
		FVector cCol = CoronaColor.GetValue();
		Data.CoronaColor = FPlane(cCol.X,cCol.Y,cCol.Z,1.f);
		Data.CoronaCScale = 0.f;
	}
	Data.LiftTime = LifetimeRange.GetValue();
	Data.LiftStartTime = 1.f/Data.LiftTime;
	Data.Scale = A->DrawScale;
	if( bRevolutionEnabled )
	{
		Data.RevOffs = (DesPos - CurLocation + RevolutionOffset.GetValue());
		Data.RevSp = RevolutionsPerSec.GetValue() * 65536.f;
	}
	ModifyParticle(A,&Data);
	if( bUSModifyParticles )
		eventGetParticleProps(A,Data.Pos,A->Velocity,A->Rotation);
	if (SpawnSound.SndCount)
		SpawnSound.PlaySoundEffect(A->Location, XLevel);
	if( TSpawnC.Num() )
		SpawnChildPart(A->Location,TSpawnC);
	if( TLifeTimeC.Num() )
		Data.NextCombinerTime = ParticleLifeTimeSDelay.GetValue();
	if (bEnablePhysX && XLevel->PhysicsScene)
		InitPhysXParticle(A, &Data);
	if( bUSNotifyParticles )
		eventNotifyNewParticle(A);

	if( WaterImpactAction!=HIT_DoNothing )
	{
		A->Region.Zone = XLevel->Model->PointRegion(Level,DesPos).Zone;
		if( A->Region.Zone )
		{
			switch( WaterImpactAction )
			{
			case HIT_Destroy:
				if( A->Region.Zone->bWaterZone )
				{
					Data.DestroyParticle();
					if( TDestructC.Num() )
						SpawnChildPart(A->Location,TDestructC);
					if (DestroySound.SndCount)
						DestroySound.PlaySoundEffect(A->Location, XLevel);
				}
				break;
			case HIT_StopMovement:
				if( A->Region.Zone->bWaterZone )
					A->bMovable = 0;
				break;
			}
		}
	}

	return 1;
	unguardSlow;
}
void AXEmitter::UpdateParticles( float Delta, UEmitterRendering* Sender )
{
	guardSlow(AXEmitter::UpdateParticles);

	BEGIN_PARTICLE_ITERATOR
		// Particle died
		if( (D.LiftTime-=Delta)<=0 )
		{
			D.DestroyParticle();
			if (DestroySound.SndCount)
				DestroySound.PlaySoundEffect(A->Location, XLevel);
			if( TDestructC.Num() )
				SpawnChildPart(A->Location,TDestructC);
		}
		bHasAliveParticles = 1;

		// Update location
		BYTE i=0;
		FLOAT Sc=(1.f-(D.LiftTime*D.LiftStartTime));
		A->OldLocation = A->Location;
		if (A->RbPhysicsData)
		{
			A->RbPhysicsData->Tick(Delta);
			if (bRotationRequest)
				A->Rotation = GetParticleRot(A, &D, Delta, A->Location, Sender);
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
					FCoords TC = (GMath.UnitCoords / FRotator(appFloor(D.RevSp.X * Delta * RevScale3D.X), appFloor(D.RevSp.Y * Delta * RevScale3D.Y), appFloor(D.RevSp.Z * Delta * RevScale3D.Z)));
					FVector NewR = D.RevOffs.TransformVectorBy(TC);
					if (bEffectsVelocity)
						A->Velocity = A->Velocity.TransformVectorBy(TC);
					if (NewR != D.RevOffs)
					{
						D.Pos += (NewR - D.RevOffs);
						D.RevOffs = NewR;
					}
				}
				FVector MoveDelta = A->Velocity * Delta * SpeedScale3D;
				if (bRevolutionEnabled)
					D.RevOffs += MoveDelta * RevolutionOffsetUnAxis;
				D.Pos += MoveDelta;
				FVector DesPos;
				if (bUseRelativeLocation)
					DesPos = Location + D.Pos.TransformVectorBy(CacheRot);
				else DesPos = D.Pos;
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
							D.DestroyParticle();
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
								D.Pos = DesPos;
							if (A->Velocity.SizeSquared() < Square(MinBounceVelocity))
								A->bMovable = 0;
						}
						break;
						default:
							if (!bUseRelativeLocation)
								D.Pos = HT.Location;
							eventParticleWallHit(A, HT.Normal, D.Pos);
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
					FPointRegion Reg = XLevel->Model->PointRegion(Level, A->Location);
					if (Reg.Zone && Reg.Zone != A->Region.Zone)
					{
						switch (WaterImpactAction)
						{
						case HIT_Destroy:
							if (!Reg.Zone->bWaterZone)
								break;
							D.DestroyParticle();
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
							D.Pos.Z -= A->Velocity.Z * Delta;
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
				A->Rotation = GetParticleRot(A, &D, Delta, A->Location, Sender);

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
			A->DrawScale = D.Scale * GetScalerValue(Sc, 1.f, TimeScale.Num(), &TimeScale(0).Time, &TimeScale(0).DrawScaling, sizeof(FScaleRangeType));
		if (TimeDrawScale3D.Num())
			A->DrawScale3D = D.StartScale3D * GetTimeScaleValue(Sc, &TimeDrawScale3D(0), TimeDrawScale3D.Num());

		// Update particle color scale
		if(ParticleColorScale.Num())
		{
			FVector GCol = D.ActorSColor * GetScalerValueColor(Sc, &ParticleColorScale(0), ParticleColorScale.Num());
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
				if( ForcesList(i) && ForcesList(i)->UpdateForceOn(A,Sc) )
					ForcesList(i)->HandleForce(&D,A,Delta);
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
			FLOAT DistScale = (A->Location-Sender->Frame->Coords.Origin).Size()/CullDistance;
			if( DistScale>CullDistanceFadeDist )
				Sc *= 1.f-(DistScale-CullDistanceFadeDist)/(1.f-CullDistanceFadeDist);
		}
		A->ScaleGlow = Clamp(Sc*FadeInMaxAmount,0.f,2.f);

		// Add combiner
		if( TLifeTimeC.Num() )
		{
			D.NextCombinerTime-=Delta;
			if( D.NextCombinerTime<=0 )
			{
				SpawnChildPart(A->Location,TLifeTimeC);
				D.NextCombinerTime = ParticleLifeTimeSDelay.GetValue();
			}
		}
		if( bAutoVisibilityBox )
		{
			RendBoundingBox+=(A->Location+VisibilityBox.Min*A->DrawScale);
			RendBoundingBox+=(A->Location+VisibilityBox.Max*A->DrawScale);
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
		Size = (Square(Calc.Y) + Square(Calc.Z));
	} while (Size < KINDA_SMALL_NUMBER);
	return (Calc / appSqrt(Size));
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
	return (Calc / appSqrt(Size));
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

FRotator AXEmitter::GetParticleRot( AActor* A, PartsType* Data, const float &Dlt, FVector &Mvd, UEmitterRendering* Render )
{
	return FRotator(0,0,0);
}

void AXEmitter::ResetEmitter()
{
	guard(AXEmitter::ResetEmitter);
	AXParticleEmitter::ResetEmitter();

	UEmitterRendering* Render = Cast<UEmitterRendering>(RenderInterface);
	if( Render )
	{
		Render->ChangeParticleCount(MaxParticles);
		Render->HideAllParticles();
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
	for (INT i = 0; i < PartCombiners.Num(); i++)
		if (PartCombiners(i))
		{
			PartCombiners(i)->bWasPostDestroyed = 1;
			delete PartCombiners(i);
		}
	PartCombiners.Empty();
	TSpawnC.Empty();
	TLifeTimeC.Empty();
	TDestructC.Empty();
	TWallHitC.Empty();
	InitChildCombiners(Render, this);
	unguard;
}

bool AXEmitter::ShouldRenderEmitter( UEmitterRendering* Sender )
{
	if( !bNoUpdateOnInvis )
		return IsVisible(Sender);
	else if( bDestruction && !IsVisible(Sender) )
		return false;
	return true;
}
bool AXEmitter::ShouldUpdateEmitter( UEmitterRendering* Sender )
{
	if( bDestruction )
		return true;
	if( bNoUpdateOnInvis )
		return IsVisible(Sender);
	return true;
}
bool AXEmitter::IsVisible( UEmitterRendering* Sender )
{
	if(!bDisableRender && (GIsEditor || !bStasisEmitter
		|| (XLevel->TimeSeconds - XLevel->Model->Zones[Region.ZoneNumber].LastRenderTime).GetFloat()<3) )
	{
		if( bDistanceCulling && (Sender->Frame->Coords.Origin-Location).SizeSquared()>Square(CullDistance) )
			return false;
		return true;
	}
	return false;
}
AXEmitter* AXEmitter::GenerateChildEmitter(UClass* EmitClass, UEmitterRendering* Render, AXParticleEmitter* EmitterOuter)
{
	guardSlow(AXEmitter::GenerateChildEmitter);
	if (!EmitClass)
		return NULL;
	AXEmitter* EX = ConstructObject<AXEmitter>(EmitClass, EmitterOuter, NAME_None, RF_Transient);
	if( !EX )
		return NULL;
	AActor* A=this;
	while( A->HitActor && A->HitActor!=A )
		A = A->HitActor;
	bHasSpecialParts = 1;
	EX->HitActor = A;
	EX->Level = Level;
	EX->XLevel = XLevel;
	EX->bHiddenEd = 1;
	EX->Location = Location;
	EX->Rotation = Rotation;
	EX->Region = Region;
	UEmitterRendering* R = ConstructObject<UEmitterRendering>(UEmitterRendering::StaticClass(), EX, NAME_None, RF_Transient);
	EX->RenderInterface = R;
	R->Frame = Render->Frame;
	R->Observer = Render->Observer;
	EX->bHasInitialized = TRUE;
	EX->InitializeEmitter(R, EmitterOuter);
	return EX;
	unguardSlow;
}

void AXEmitter::InitChildCombiners(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter)
{
	guard(AXEmitter::InitChildCombiners);
    INT i=0;

	/* add spawn combiners */
	for( i=0; i<ParticleSpawnCClass.Num(); i++ )
	{
		AXEmitter* X = GenerateChildEmitter(ParticleSpawnCClass(i), Render, EmitterOuter);
		if( X )
		{
			PartCombiners.AddItem(X);
			TSpawnC.AddItem(X);
		}
	}
	/* add kill combiners */
	for( i=0; i<ParticleKillCClass.Num(); i++ )
	{
		AXEmitter* X = GenerateChildEmitter(ParticleKillCClass(i), Render, EmitterOuter);
		if( X )
		{
			PartCombiners.AddItem(X);
			TDestructC.AddItem(X);
		}
	}
	/* add wallhit combiners */
	for( i=0; i<ParticleWallHitCClass.Num(); i++ )
	{
		AXEmitter* X = GenerateChildEmitter(ParticleWallHitCClass(i), Render, EmitterOuter);
		if( X )
		{
			PartCombiners.AddItem(X);
			TWallHitC.AddItem(X);
		}
	}
	/* add lifespan combiners */
	for( i=0; i<ParticleLifeTimeCClass.Num(); i++ )
	{
		AXEmitter* X = GenerateChildEmitter(ParticleLifeTimeCClass(i), Render, EmitterOuter);
		if( X )
		{
			PartCombiners.AddItem(X);
			TLifeTimeC.AddItem(X);
		}
	}
	/* Add in the standard ones */
	for( i=0; i<SpawnCombiners.Num(); i++ )
		if( SpawnCombiners(i) )
			TSpawnC.AddItem(SpawnCombiners(i));
	for( i=0; i<LifeTimeCombiners.Num(); i++ )
		if( LifeTimeCombiners(i) )
			TLifeTimeC.AddItem(LifeTimeCombiners(i));
	for( i=0; i<DestructCombiners.Num(); i++ )
		if( DestructCombiners(i) )
			TDestructC.AddItem(DestructCombiners(i));
	for( i=0; i<WallHitCombiners.Num(); i++ )
		if( WallHitCombiners(i) )
			TWallHitC.AddItem(WallHitCombiners(i));
	unguard;
}
void AXParticleEmitter::SpawnChildPart( const FVector Pos, TArray<AXEmitter*>& PartIdx )
{
	AXEmitter** F = &PartIdx(0);
	for( INT i=(PartIdx.Num()-1); i>=0; --i )
		if( F[i] )
			F[i]->RemoteSpawnParticle(Pos);
}

/* Editor macro's */
void AXEmitter::Modify()
{
	if( GIsEditor )
	{
		guard(AXEmitter::Modify);
		INT i;
		ForcesList.Empty();

		bool bResult=false;
		for( i=0; i<4; i++ )
			if( ForcesTags[i]!=NAME_None )
			{
				bResult = true;
				break;
			}
		if( bResult )
		{
			for( TObjectIterator<AXParticleForces> It; It; ++It )
			{
				AXParticleForces* FR = *It;
				if( FR->IsPendingKill() || FR->Tag==NAME_None )
					continue;
				bResult = false;
				for( i=0; i<4; i++ )
					if( ForcesTags[i]==FR->Tag )
					{
						bResult = true;
						break;
					}
				if( !bResult )
					continue;
				ForcesList.AddItem(FR);
			}
		}

		SpawnCombiners.Empty();
		LifeTimeCombiners.Empty();
		DestructCombiners.Empty();
		WallHitCombiners.Empty();
		for( TObjectIterator<AXEmitter> It; It; ++It )
		{
			AXEmitter* X = *It;
			if( X->IsPendingKill() )
				continue;
			if( ParticleSpawnTag!=NAME_None && ParticleSpawnTag==X->Tag )
				SpawnCombiners.AddItem(X);
			if( ParticleKillTag!=NAME_None && ParticleKillTag==X->Tag )
				DestructCombiners.AddItem(X);
			if( ParticleWallHitTag!=NAME_None && ParticleWallHitTag==X->Tag )
				WallHitCombiners.AddItem(X);
			if( ParticleLifeTimeTag!=NAME_None && ParticleLifeTimeTag==X->Tag )
				LifeTimeCombiners.AddItem(X);

			/* Now check the other way around */
			UBOOL bFoundResult = FALSE;
			if( X->ParticleSpawnTag!=NAME_None && X->ParticleSpawnTag==Tag )
			{
				for( i=0; i<X->SpawnCombiners.Num(); i++ )
				{
					if( X->SpawnCombiners(i)==this )
					{
						bFoundResult = TRUE;
						break;
					}
				}
				if( !bFoundResult)
				{
					X->SpawnCombiners.AddItem(this);
					X->ResetEmitter();
				}
			}
			else
			{
				for( i=0; i<X->SpawnCombiners.Num(); i++ )
				{
					if( X->SpawnCombiners(i)==this )
					{
						X->SpawnCombiners.Remove(i);
						X->ResetEmitter();
						break;
					}
				}
			}
			bFoundResult = FALSE;
			if( X->ParticleKillTag!=NAME_None && X->ParticleKillTag==Tag )
			{
				for( i=0; i<X->DestructCombiners.Num(); i++ )
				{
					if( X->DestructCombiners(i)==this )
					{
						bFoundResult = TRUE;
						break;
					}
				}
				if (!bFoundResult)
				{
					X->DestructCombiners.AddItem(this);
					X->ResetEmitter();
				}
			}
			else
			{
				for( i=0; i<X->DestructCombiners.Num(); i++ )
				{
					if( X->DestructCombiners(i)==this )
					{
						X->DestructCombiners.Remove(i);
						X->ResetEmitter();
						break;
					}
				}
			}
			bFoundResult = FALSE;
			if( X->ParticleWallHitTag!=NAME_None && X->ParticleWallHitTag==Tag )
			{
				for( i=0; i<X->WallHitCombiners.Num(); i++ )
				{
					if( X->WallHitCombiners(i)==this )
					{
						bFoundResult = TRUE;
						break;
					}
				}
				if (!bFoundResult)
				{
					X->WallHitCombiners.AddItem(this);
					X->ResetEmitter();
				}
			}
			else
			{
				for( i=0; i<X->WallHitCombiners.Num(); i++ )
				{
					if( X->WallHitCombiners(i)==this )
					{
						X->WallHitCombiners.Remove(i);
						X->ResetEmitter();
						break;
					}
				}
			}
			bFoundResult = FALSE;
			if( X->ParticleLifeTimeTag!=NAME_None && X->ParticleLifeTimeTag==Tag )
			{
				for( i=0; i<X->LifeTimeCombiners.Num(); i++ )
				{
					if( X->LifeTimeCombiners(i)==this )
					{
						bFoundResult = TRUE;
						break;
					}
				}
				if (!bFoundResult)
				{
					X->LifeTimeCombiners.AddItem(this);
					X->ResetEmitter();
				}
			}
			else
			{
				for( i=0; i<X->LifeTimeCombiners.Num(); i++ )
				{
					if( X->LifeTimeCombiners(i)==this )
					{
						X->LifeTimeCombiners.Remove(i);
						X->ResetEmitter();
						break;
					}
				}
			}
		}
		unguard;
	}
	Super::Modify();
}
void AXEmitter::PostScriptDestroyed()
{
	if( GIsEditor && !Cast<AXParticleEmitter>(GetOuter()) )
	{
		guard(AXEmitter::PostScriptDestroyed);
		for( TObjectIterator<AXEmitter> It; It; ++It )
		{
			AXEmitter* EM = *It;
			if( Cast<AXParticleEmitter>(EM->GetOuter()) || EM==this || EM->IsPendingKill() )
				continue;
			EM->CleanUpRefs(this);
		}
		unguard;
	}
	Super::PostScriptDestroyed();
}
void AXEmitter::CleanUpRefs( AXEmitter* X )
{
	INT i,j;
	j = SpawnCombiners.Num();
	for( i=0; i<j; i++ )
		if( !SpawnCombiners(i) || SpawnCombiners(i)==X )
		{
			SpawnCombiners.Remove(i);
			i--;
			j--;
		}
	j = LifeTimeCombiners.Num();
	for( i=0; i<j; i++ )
		if( !LifeTimeCombiners(i) || LifeTimeCombiners(i)==X )
		{
			LifeTimeCombiners.Remove(i);
			i--;
			j--;
		}
	j = DestructCombiners.Num();
	for( i=0; i<j; i++ )
		if( !DestructCombiners(i) || DestructCombiners(i)==X )
		{
			DestructCombiners.Remove(i);
			i--;
			j--;
		}
	j = WallHitCombiners.Num();
	for( i=0; i<j; i++ )
		if( !WallHitCombiners(i) || WallHitCombiners(i)==X )
		{
			WallHitCombiners.Remove(i);
			i--;
			j--;
		}
	j = TSpawnC.Num();
	for( i=0; i<j; i++ )
		if( !TSpawnC(i) || TSpawnC(i)==X )
		{
			TSpawnC.Remove(i);
			i--;
			j--;
		}
	j = TLifeTimeC.Num();
	for( i=0; i<j; i++ )
		if( !TLifeTimeC(i) || TLifeTimeC(i)==X )
		{
			TLifeTimeC.Remove(i);
			i--;
			j--;
		}
	j = TDestructC.Num();
	for( i=0; i<j; i++ )
		if( !TDestructC(i) || TDestructC(i)==X )
		{
			TDestructC.Remove(i);
			i--;
			j--;
		}
	j = TWallHitC.Num();
	for( i=0; i<j; i++ )
		if( !TWallHitC(i) || TWallHitC(i)==X )
		{
			TWallHitC.Remove(i);
			i--;
			j--;
		}
}

UBOOL bHasDistFog;
FFogSurf FogSurfaceEmitter;

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
		DrawPartCoronas(Frame->Viewport->Canvas, Delta);
	}
	if( PartCombiners.Num() )
	{
		INT l=PartCombiners.Num();
		AXEmitter** GEM = &PartCombiners(0);
		for( INT i=0; i<l; i++ )
			if (GEM[i] && GEM[i]->bParticleCoronaEnabled)
			{
				if (bHasDistFog == 2)
					InitFog(Frame, this);
				GEM[i]->DrawPartCoronas(Frame->Viewport->Canvas, Delta);
			}
	}
	unguard;
}
void AXEmitter::DrawPartCoronas( UCanvas* Camera, const FLOAT& Delta )
{
	if( !bParticleCoronaEnabled || !CoronaTexture || bDeleteMe )
		return;
	UEmitterRendering* Rend = Cast<UEmitterRendering>(RenderInterface);
	if( !Rend || !Rend->PartPtr )
		return;
	URenderDevice* RendDev = Camera->Viewport->RenDev;
	Rend->Frame = Camera->Frame;
	bool bIsVisible = IsVisible(Rend);
	ParticlesDataList* Ptr = Rend->PartPtr;
	INT l=Ptr->Len();
	AActor* A;
	PartsType* Data;
	FVector CPos, Dir;
	FLOAT XPos,YPos,ScSize,XScl,YScl,ScaleGlw,DotDist;
	FTextureInfo* CorTex = CoronaTexture->GetTexture(0, RendDev);
	DWORD TraceFlags = (bActorsBlockSight ? TRACE_ProjTargets : TRACE_VisBlocking);
	AActor* ViewActor = (Camera->Viewport->Actor->ViewTarget ? Camera->Viewport->Actor->ViewTarget : Camera->Viewport->Actor);
	for( INT i=0; i<l; i++ )
	{
		A = Ptr->GetA(i);
		if( A->bHidden )
			continue;
		Data = &Ptr->Get(i);
		if( bCOffsetRelativeToRot )
			CPos = A->Location + CoronaOffset.TransformVectorBy(GMath.UnitCoords/A->Rotation);
		else CPos = A->Location + CoronaOffset;

		Dir = CPos-Camera->Frame->Coords.Origin;
		DotDist = (Camera->Frame->Coords.ZAxis | Dir);
		if (DotDist < 0.f)
		{ // Behind the camera, no render.
			Data->CoronaCScale = 0.f;
			continue;
		}
		ScSize = 1.f;
		Camera->Render->Project(Camera->Frame,CPos,XPos,YPos,&ScSize);
		if( !bIsVisible || Dir.SizeSquared()>Square(MaxCoronaDistance) || XPos<0 || YPos<0
		 || XPos>Camera->Frame->X || YPos>Camera->Frame->Y || (bCheckLineOfSight
		 && !XLevel->FastLineCheck(CPos,Camera->Frame->Coords.Origin,TraceFlags,ViewActor)) )
			Data->CoronaCScale = Max(Data->CoronaCScale-Delta*CoronaFadeTimeScale,0.f);
		else if( Data->CoronaCScale<1.f )
			Data->CoronaCScale = Min(Data->CoronaCScale+Delta*CoronaFadeTimeScale,1.f);

		ScaleGlw = Data->CoronaCScale * A->ScaleGlow;
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
		RendDev->DrawTile(Camera->Frame, *CorTex, XPos - XScl * 0.5, YPos - YScl * 0.5, XScl, YScl,
			0, 0, CoronaTexture->USize, CoronaTexture->VSize, NULL, 1.f,
			Data->CoronaColor * ScaleGlw, FPlane(0, 0, 0, 0),
			(PF_TwoSided | PF_Translucent));
	}
}

void AXEmitter::ResetVars()
{
	guard(AXEmitter::ResetVars);
	Super::ResetVars();
	TSpawnC.Empty();
	TLifeTimeC.Empty();
	TDestructC.Empty();
	TWallHitC.Empty();
	unguard;
}
FBox AXEmitter::GetVisibilityBox()
{
	return (bAutoVisibilityBox ? RendBoundingBox : FBox(Location+VisibilityBox.Min,Location+VisibilityBox.Max));
}
