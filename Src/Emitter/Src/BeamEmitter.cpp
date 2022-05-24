
#include "EmitterPrivate.h"
#include "XBeamEmitterMdl.h"

IMPLEMENT_CLASS(AXBeamEmitter);

void AXBeamEmitter::InitializeEmitter(AXParticleEmitter* Parent)
{
	guardSlow(AXBeamEmitter::InitializeEmitter);
	Super::InitializeEmitter(Parent);
	CalcSegmentScales();
	unguardSlow;
}
void AXBeamEmitter::ResetEmitter()
{
	guard(AXBeamEmitter::ResetEmitter);
	Super::ResetEmitter();
	if( RenderDataModel )
		RenderDataModel->SetSegments(Segments,TextureUV,StartTexture,EndTexture);
	CalcSegmentScales();
	unguard;
}
void AXBeamEmitter::PostScriptDestroyed()
{
	guardSlow(AXBeamEmitter::PostScriptDestroyed);
	Super::PostScriptDestroyed();
	if( RenderDataModel && !GIsEditor )
	{
		delete RenderDataModel;
		RenderDataModel = NULL;
	}
	unguardSlow;
}
void AXBeamEmitter::Serialize(FArchive& Ar)
{
	guardSlow(AXBeamEmitter::Serialize);
	Super::Serialize(Ar);
	if (Ar.SerializeRefs())
		Ar << RenderDataModel;
	unguardSlow;
}
void AXBeamEmitter::GetBeamFrame( FVector* Verts, INT Size, FCoords& Coords, xParticle* Particle, INT FrameVerts )
{
	guardSlow(AXBeamEmitter::GetBeamFrame);
	Coords = Coords * Particle->Location;

	FVector MoveDir(Particle->Velocity);
	if( BeamTargetType==BEAM_BeamActor || BeamTargetType==BEAM_OffsetAsAbsolute )
		MoveDir-=Particle->Location;
	else if( bUseRelativeLocation )
		MoveDir = MoveDir.TransformVectorBy(CacheRot);
	if( MoveDir.IsNearlyZero() )
	{
		// Fake move.
		for( INT i=0; i<FrameVerts; i++ )
		{
			*Verts = FVector(0,0,0).TransformPointBy(Coords);
			*(BYTE**)&Verts += Size;
		}
		return;
	}
	FBeamDataType& Data = *Particle->BeamData;

	FVector* GVerts = Data.DataArray;
	FCoords RotCrds;
	INT vOffset=0,FinalOffset=Data.SetupPoints;
	if (bDynamicNoise)
		FinalOffset = (FinalOffset >> 1);

	FLOAT SplitDist = MoveDir.Size()/FinalOffset;
	FVector LookDir(Rotation.Vector()),Current,NextCurrent(0,0,0);
	FLOAT ScaleMulti = 1.f;
	INT SegCalcs=0;
	FBox& BX = Data.Bounds;
	BX.IsValid = 0;
	FLOAT* seqScales = (RenderDataModel && RenderDataModel->SegmentScales.Num()) ? &RenderDataModel->SegmentScales(0) : nullptr;

	for( INT i=0; i<FrameVerts; i++ )
	{
		FVector& Vert = *Verts;
		if( i & 1 )
			Vert = Current+RotCrds.YAxis*Particle->DrawScale*ScaleMulti;
		else
		{
			// Setup segment time scaling
			if (seqScales)
				ScaleMulti = seqScales[SegCalcs++];

			Current = NextCurrent;
			if( bDirectional )
				LookDir = (LookDir+(MoveDir-NextCurrent).SafeNormal()*TurnRate).SafeNormal();
			else LookDir = (MoveDir-NextCurrent).SafeNormal();
			NextCurrent+=LookDir*SplitDist;
			if (bDoBeamNoise && vOffset < FinalOffset)
				NextCurrent+=GVerts[vOffset++]*Particle->TimerRate;
			if (bEndPointFixed && i == (FrameVerts - 4))
				NextCurrent = MoveDir - LookDir;

			RotCrds = GMath.UnitCoords/(NextCurrent-Current).Rotation();

			FVector UpDir(RotCrds.XAxis);
			GetFaceCoords(Current,Coords.Origin,UpDir,RotCrds);
			Vert = Current-RotCrds.YAxis*Particle->DrawScale*ScaleMulti;

#if 0 //_DEBUG
			new FDebugLineData(Current, NextCurrent, FPlane(1, 1, 0, 1));
#endif
		}
		BX += (Vert + Particle->Location);
		Vert = Vert.TransformPointBy(Coords);
		*(BYTE**)&Verts += Size;
	}
	BX = BX.ExpandBy(Particle->DrawScale);
	unguardSlow;
}
void AXBeamEmitter::ResetVars()
{
	guard(AXBeamEmitter::ResetVars);
	RenderDataModel = NULL;
	Super::ResetVars();
	unguard;
}
void AXBeamEmitter::UpdateParticles(FLOAT Delta, UEmitterRendering* Render)
{
	guardSlow(AXBeamEmitter::UpdateParticles);

	Super::UpdateParticles(Delta, Render);

	BEGIN_PARTICLE_ITERATOR
#if 0 //_DEBUG
		FBox& BX = A->BeamData->Bounds;
		XLevel->Engine->Render->DrawBox(Sender->Frame,FPlane(1,1,1,1),0,BX.Min,BX.Max);
#endif
		A->AmbientGlow = Min<INT>((INT)A->ScaleGlow*255,254);
		if (bUseRelativeLocation)
			A->Location = Location + A->Pos.TransformVectorBy(CacheRot);
		if (BeamTargetType == BEAM_BeamActor && BeamTarget.IsValidIndex(A->CollisionTag))
		{
			const FFBeamTargetPoint& T = BeamTarget(A->CollisionTag);
			if (T.TargetActor && !T.TargetActor->bDeleteMe)
				A->Velocity = T.TargetActor->Location+T.Offset;
		}
		if (bDoBeamNoise && NoiseTimeScale.Num())
		{
			A->TimerRate = GetTimeScaleValue((1.f - A->LifeTime * A->LifeStartTime), &NoiseTimeScale(0), NoiseTimeScale.Num());
		}
		if( bDynamicNoise )
		{
			A->TimerCounter +=Delta;
			INT TotalPoint = A->BeamData->SetupPoints;
			INT HalfPoint = TotalPoint*0.5;
			FVector* GPoints = A->BeamData->DataArray;
			if( A->TimerCounter >=NoiseSwapTime )
			{
				A->TimerCounter = 0.f;
				for( INT i=0; i<HalfPoint; i++ )
					GPoints[i] = GPoints[HalfPoint+i];
				for( INT j=HalfPoint; j<TotalPoint; j++ )
					GPoints[j] = NoiseRange.GetValue();
			}
			else
			{
				FLOAT Alpha = A->TimerCounter / NoiseSwapTime;
				for( INT i=0; i<HalfPoint; i++ )
					GPoints[i]+=(GPoints[HalfPoint+i]-GPoints[i])*Alpha;
			}
		}
	END_PARTICLE_ITERATOR
	unguardSlow;
}
void AXBeamEmitter::ModifyParticle(xParticle* A)
{
	guardSlow(AXBeamEmitter::ModifyParticle);
	if( !RenderDataModel )
	{
		UBeamMesh* BM = GetBeamingModel(this);
		BM->SetSegments(Segments,TextureUV,StartTexture,EndTexture);
		RenderDataModel = BM;
	}
	A->MultiSkins[0] = StartTexture;
	A->MultiSkins[1] = EndTexture;
	A->DrawType = DT_Mesh;
	A->Mesh = RenderDataModel;
	A->Fatness = 128;
	A->bUnlit = 1;
	A->AmbientGlow = 0;
	A->bMeshEnviroMap = bMeshEnviroMap;
	A->bMovable = 0;
	A->bTextureAnimOnce = (SpriteAnimationType != SAN_LoopAnim);
	A->TimerRate = 1.f;
	A->TimerCounter = 0.f; // Interpolation timer for dynamic noise.
	if (!A->BeamData)
		A->BeamData = new FBeamDataType();

	FBox& BX = A->BeamData->Bounds;
	BX.IsValid = 0;
	BX+=A->Location;
	FVector MoveDir(A->Velocity);

	if( BeamTargetType!=BEAM_Velocity && BeamTarget.Num() )
	{
		A->CollisionTag = GetRandomVal(BeamTarget.Num());
		const FFBeamTargetPoint& T = BeamTarget(A->CollisionTag);
		if( BeamTargetType==BEAM_Offset || BeamTargetType==BEAM_OffsetAsAbsolute )
		{
			A->Velocity = T.Offset;
			if( BeamTargetType==BEAM_Offset )
				MoveDir = T.Offset;
			else MoveDir = T.Offset-A->Location;
		}
		else if( T.TargetActor )
			MoveDir = T.TargetActor->Location+T.Offset-A->Location;
	}
	if( bUseRelativeLocation && BeamTargetType!=BEAM_OffsetAsAbsolute && BeamTargetType!=BEAM_BeamActor )
		MoveDir = MoveDir.TransformVectorBy(CacheRot);
	BX+=(MoveDir+A->Location);
	BX = BX.ExpandBy(A->DrawScale);
	INT NumPts = Segments+1;
	if( bDynamicNoise )
		NumPts*=2; // Allocate space for interpolation between 2 poses.
	A->BeamData->InitForSeg(NumPts);
	FVector* GPoints = A->BeamData->DataArray;

	if( bDoBeamNoise )
	{
		for( INT i=0; i<NumPts; ++i )
			GPoints[i] = NoiseRange.GetValue();
	}
	unguardSlow;
}
void AXBeamEmitter::CalcSegmentScales()
{
	guard(AXBeamEmitter::CalcSegmentScales);
	if (!RenderDataModel)
	{
		UBeamMesh* BM = GetBeamingModel(this);
		BM->SetSegments(Segments, TextureUV, StartTexture, EndTexture);
		RenderDataModel = BM;
	}
	RenderDataModel->SegmentScales.Empty();
	if( !BeamPointScaling.Num() )
		return;
	INT TotalCorners = Segments+2;
	FLOAT SegmentTimeSpace = 1.f/FLOAT(TotalCorners-1);
	RenderDataModel->SegmentScales.Add(TotalCorners);
	FLOAT TimeCalc = (BeamPointScaling.Num()>1 ? 1.f/FLOAT(BeamPointScaling.Num()-1) : 0.f);
	for( INT i=0; i<TotalCorners; ++i )
		RenderDataModel->SegmentScales(i) = GetTimeScaleValueSingle(SegmentTimeSpace*i,&BeamPointScaling(0),BeamPointScaling.Num(),TimeCalc);
	unguard;
}
