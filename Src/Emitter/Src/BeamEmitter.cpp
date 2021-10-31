
#include "EmitterPrivate.h"
#include "XBeamEmitterMdl.h"

IMPLEMENT_CLASS(AXBeamEmitter);

void AXBeamEmitter::InitializeEmitter(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter)
{
	Super::InitializeEmitter(Render, EmitterOuter);
	CalcSegmentScales();
}
void AXBeamEmitter::ResetEmitter()
{
	guard(AXBeamEmitter::ResetEmitter);
	Super::ResetEmitter();
	if( RenderDataModel )
		((UBeamMesh*)RenderDataModel)->SetSegments(Segments,TextureUV,StartTexture,EndTexture);
	CalcSegmentScales();
	unguard;
}
void AXBeamEmitter::PostScriptDestroyed()
{
	Super::PostScriptDestroyed();
	if( RenderDataModel && !GIsEditor )
	{
		delete (UBeamMesh*)RenderDataModel;
		RenderDataModel = NULL;
	}
}
void AXBeamEmitter::GetBeamFrame( FVector* Verts, INT Size, FCoords& Coords, AActor* Particle, INT FrameVerts )
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
	FBeamDataType& Data = *((UEmitterRendering*)RenderInterface)->PartPtr->Get(Particle->NetTag).BeamData;

	FVector* GVerts = Data.DataArray;
	FCoords RotCrds;
	INT vOffset=0,FinalOffset=Data.SetupPoints;
	if( bDynamicNoise )
		FinalOffset*=0.5;

	FLOAT SplitDist = MoveDir.Size()/FinalOffset;
	FVector LookDir(Rotation.Vector()),Current,NextCurrent(0,0,0);
	FLOAT ScaleMulti = 1.f;
	INT SegCalcs=0;
	FBox& BX = *(FBox*)&Particle->RotationRate;
	BX.IsValid = 0;

	for( INT i=0; i<FrameVerts; i++ )
	{
		FVector& Vert = *Verts;
		if( i & 1 )
			Vert = Current+RotCrds.YAxis*Particle->DrawScale*ScaleMulti;
		else
		{
			// Setup segment time scaling
			if( SegmentScales.Num() )
				ScaleMulti = SegmentScales(SegCalcs++);

			Current = NextCurrent;
			if( bDirectional )
				LookDir = (LookDir+(MoveDir-NextCurrent).SafeNormal()*TurnRate).SafeNormal();
			else LookDir = (MoveDir-NextCurrent).SafeNormal();
			NextCurrent+=LookDir*SplitDist;
			if( bDoBeamNoise && vOffset<FinalOffset )
				NextCurrent+=GVerts[vOffset++]*Particle->DrawScale3D.X;

			RotCrds = GMath.UnitCoords/(NextCurrent-Current).Rotation();

			FVector UpDir(RotCrds.XAxis);
			GetFaceCoords(Current,Coords.Origin,UpDir,RotCrds);
			Vert = Current-RotCrds.YAxis*Particle->DrawScale*ScaleMulti;
		}
		BX+=(Vert+Particle->Location);
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
void AXBeamEmitter::UpdateParticles( float Delta, UEmitterRendering* Sender )
{
	guardSlow(AXBeamEmitter::UpdateParticles);

	Super::UpdateParticles(Delta,Sender);

	BEGIN_PARTICLE_ITERATOR
#if 0 //_DEBUG
		FBox& BX = *(FBox*)&A->RotationRate;
		XLevel->Engine->Render->DrawBox(Sender->Frame,FPlane(1,1,1,1),0,BX.Min,BX.Max);
#endif
		A->AmbientGlow = Min<INT>((INT)A->ScaleGlow*255,254);
		if( bUseRelativeLocation )
			A->Location = Location+D.Pos.TransformVectorBy(CacheRot);
		if (BeamTargetType == BEAM_BeamActor && BeamTarget.IsValidIndex(A->CollisionTag))
		{
			const FFBeamTargetPoint& T = BeamTarget(A->CollisionTag);
			if (T.TargetActor && !T.TargetActor->bDeleteMe)
				A->Velocity = T.TargetActor->Location+T.Offset;
		}
		if (bDoBeamNoise && NoiseTimeScale.Num())
		{
			A->DrawScale3D.X = GetTimeScaleValue((1.f - D.LiftTime * D.LiftStartTime), &NoiseTimeScale(0), NoiseTimeScale.Num());
		}
		if( bDynamicNoise )
		{
			A->DrawScale3D.Y+=Delta;
			INT TotalPoint = D.BeamData->SetupPoints;
			INT HalfPoint = TotalPoint*0.5;
			FVector* GPoints = D.BeamData->DataArray;
			if( A->DrawScale3D.Y>=NoiseSwapTime )
			{
				A->DrawScale3D.Y = 0.f;
				for( INT i=0; i<HalfPoint; i++ )
					GPoints[i] = GPoints[HalfPoint+i];
				for( INT j=HalfPoint; j<TotalPoint; j++ )
					GPoints[j] = NoiseRange.GetValue();
			}
			else
			{
				FLOAT Alpha = A->DrawScale3D.Y/NoiseSwapTime;
				for( INT i=0; i<HalfPoint; i++ )
					GPoints[i]+=(GPoints[HalfPoint+i]-GPoints[i])*Alpha;
			}
		}
	END_PARTICLE_ITERATOR
	unguardSlow;
}
void AXBeamEmitter::ModifyParticle( AActor* A, PartsType* Data )
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
	A->Mesh = (UMesh*)RenderDataModel;
	A->Fatness = 128;
	A->bUnlit = 1;
	A->AmbientGlow = 0;
	A->bMeshEnviroMap = bMeshEnviroMap;
	A->bMovable = 0;
	A->bTextureAnimOnce = (SpriteAnimationType != SAN_LoopAnim);
	A->DrawScale3D.X = 1.f;
	A->DrawScale3D.Y = 0.f; // Interpolation timer for dynamic noise.

	FBox& BX = *(FBox*)&A->RotationRate; // Overwrite on some useless variables of Actor.
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
	if( !Data->BeamData )
		Data->BeamData = new FBeamDataType();
	INT NumPts = Segments+1;
	if( bDynamicNoise )
		NumPts*=2; // Allocate space for interpolation between 2 poses.
	Data->BeamData->InitForSeg(NumPts);
	FVector* GPoints = Data->BeamData->DataArray;

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
	SegmentScales.Empty();
	if( !BeamPointScaling.Num() )
		return;
	INT TotalCorners = Segments+2;
	FLOAT SegmentTimeSpace = 1.f/FLOAT(TotalCorners-1);
	SegmentScales.Add(TotalCorners);
	FLOAT TimeCalc = (BeamPointScaling.Num() ? 1.f/FLOAT(BeamPointScaling.Num()-1) : 0.f);
	for( INT i=0; i<TotalCorners; ++i )
		SegmentScales(i) = GetTimeScaleValueSingle(SegmentTimeSpace*i,&BeamPointScaling(0),BeamPointScaling.Num(),TimeCalc);
	unguard;
}
