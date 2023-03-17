
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXTrailEmitter);
IMPLEMENT_CLASS(UTrailMesh);
IMPLEMENT_CLASS(AXTrailParticle);

class FTrailParticle : public FParticlesDataBase
{
public:
	TArray<AXTrailParticle*> Particles;
	UTrailMesh* TrailMesh;

	FTrailParticle(AXTrailEmitter* E)
		: FParticlesDataBase(E)
		, TrailMesh(NULL)
	{
	}
	~FTrailParticle()
	{
		if (!GIsCollectingGarbage)
		{
			for (INT i = 0; i < Particles.Num(); ++i)
			{
				Particles(i)->ConditionalDestroy();
				delete Particles(i);
			}
			Particles.Empty();
			if (TrailMesh)
			{
				TrailMesh->ConditionalDestroy();
				delete TrailMesh;
				TrailMesh = nullptr;
			}
		}
	}
	UBOOL HasAliveParticles() const
	{
		for (INT i = 0; i < Particles.Num(); ++i)
			if (!Particles(i)->bHidden)
				return TRUE;
		return FALSE;
	}
	void HideAllParts()
	{
		for (INT i = 0; i < Particles.Num(); ++i)
		{
			Particles(i)->bHidden = TRUE;
			Particles(i)->Trail.Empty();
		}
	}
	void SetLen(INT GoalLen)
	{
	}
	void Serialize(FArchive& Ar)
	{
		UClass* C = AXTrailParticle::StaticClass();
		Ar << C;
		C = UTrailMesh::StaticClass();
		Ar << C;
		Ar << Particles << TrailMesh;
	}
	AXTrailParticle* GetFreeTrail(const FVector& Pos, const FRotator& Rot)
	{
		if (reinterpret_cast<AXEmitter*>(Owner->ParentEmitter)->bDisabled)
			return nullptr;

		for (INT i = 0; i < Particles.Num(); ++i)
		{
			if (Particles(i)->bHidden)
			{
				Particles(i)->Flush();
				Particles(i)->OldTrailSpot = Pos;
				Particles(i)->Location = Pos;
				Particles(i)->Rotation = Rot;
				return Particles(i);
			}
		}
		if (Particles.Num() >= reinterpret_cast<AXTrailEmitter*>(Owner)->MaxParticles)
			return nullptr;

		if (!TrailMesh)
			TrailMesh = new UTrailMesh();
		AXTrailParticle* Result = new AXTrailParticle(reinterpret_cast<AXTrailEmitter*>(Owner));
		Result->Mesh = TrailMesh;
		Result->OldTrailSpot = Pos;
		Result->Location = Pos;
		Result->Rotation = Rot;
		Particles.AddItem(Result);
		return Result;
	}
	AActor* GetRenderList(AActor* Last)
	{
		guardSlow(FTrailParticle::GetRenderList);
		for (INT i = 0; i < Particles.Num(); ++i)
		{
			if (Particles(i)->IsVisible())
			{
				Particles(i)->Target = Last;
				Last = Particles(i);
			}
		}
		return Last;
		unguardSlow;
	}
	void TickTrails(FLOAT DeltaTime)
	{
		guardSlow(FTrailParticle::TickTrails);
		AXTrailParticle* A;
		if (reinterpret_cast<AXTrailEmitter*>(Owner)->bSpawnInitParticles)
		{
			if (reinterpret_cast<AXEmitter*>(Owner->ParentEmitter)->bDisabled)
			{
				if (Particles.Num() && !Particles(0)->bHidden)
					Particles(0)->TickTrail(DeltaTime);
			}
			else
			{
				if (!Particles.Num())
					GetFreeTrail(Owner->Location, Owner->Rotation); // Must have valid first trail.
				A = Particles(0);
				A->bHidden = FALSE;
				A->ScaleGlow = Owner->ScaleGlow;
				A->NetTag = (INT)GFrameNumber;
				A->Location = Owner->Location;
				A->Rotation = Owner->Rotation;
				A->TickTrail(DeltaTime);
			}

			// Update any children.
			for (INT i = (Particles.Num() - 1); i > 0; --i)
			{
				A = Particles(i);
				if (!A->bHidden)
					A->TickTrail(DeltaTime);
			}
		}
		else
		{
			// Update any children.
			for (INT i = (Particles.Num() - 1); i >= 0; --i)
			{
				A = Particles(i);
				if (!A->bHidden)
					A->TickTrail(DeltaTime);
			}
		}
		unguardSlow;
	}
};

static FTransTexture TrailEmitterList[MAX_FULLPOLYLIST];
static FTransTexture RendParts[4];
static UBOOL bTexInit = FALSE;

bool AXTrailParticle::OverrideMeshRender( FSceneNode* Frame )
{
	guard(AXTrailParticle::OverrideMeshRender);
	URenderDevice* R = Frame->Viewport->RenDev;
	if (!Trail.Num() || !Emitter->ParticleTextures.Num())
		return true; // Can't render.

	FTextureInfo* Info;
	if( !bTexInit )
	{
		bTexInit = TRUE;
		for( BYTE i=0; i<4; ++i )
		{
			RendParts[i].Fog = FPlane(0,0,0,0);
			RendParts[i].U = 0.f;
			RendParts[i].V = 0.f;
		}
	}

	{
		UTexture* T = Emitter->ParticleTextures(0);
		if (!T)
			T = Level->DefaultTexture;
		Info = T->GetTexture(INDEX_NONE, R);
	}
	FLOAT UScale = (Info->UScale * Info->USize), VScale = (Info->VScale * Info->VSize);
	FLOAT VScaler = (VScale * (Emitter->TextureUV[0] + Emitter->TextureUV[2]));
	RendParts[0].U = VScale * Emitter->TextureUV[2];
	RendParts[2].V = VScale * Emitter->TextureUV[2];
	RendParts[1].V = VScaler;
	RendParts[3].V = VScaler;

	INT Size = Trail.Num();
	INT Final(Size-1);
	static FVector Next[4],Dir;
	FPlane Color;
	FLOAT UOffset = Emitter->TextureUV[3]*UScale;
	FLOAT UScalar = UScale * (Emitter->TextureUV[1] + Emitter->TextureUV[3]);
	if (!Emitter->bTexContinous)
		UScalar /= Size;
	DWORD DrawFlags=PF_TwoSided;
	switch (Emitter->ParticleStyle)
	{
	case STY_Translucent:
		DrawFlags |= PF_Translucent;
		break;
	case STY_Masked:
		DrawFlags |= PF_Masked;
		break;
	case STY_Modulated:
		DrawFlags |= PF_Modulated;
		break;
	case STY_AlphaBlend:
		DrawFlags |= PF_AlphaBlend;
		break;
	}

	// Setup distance fog
	bool bHardwareFogEnabled=false;
	AZoneInfo* Z=((Emitter->Region.Zone && Emitter->Region.Zone->bZoneBasedFog) ? Emitter->Region.Zone : Frame->Viewport->Actor->CameraRegion.Zone);
	FFogSurf FogSurface;
	if( Z && Z->bDistanceFog && R->SupportsDistanceFog && Emitter->ParticleStyle!=STY_Translucent )
	{
		FColor& DistCol(Z->FogColor);
		FPlane DistanceFogColor(DistCol.B/255.f,DistCol.G/255.f,DistCol.R/255.f,1.f);
		FogSurface.FogDistanceStart=Z->FogDistanceStart;
		FogSurface.FogDistanceEnd=Z->FogDistance;
		FogSurface.FogColor=DistanceFogColor;
		FogSurface.FogMode=Z->FogMode;
		FogSurface.FogDensity=Z->FogDensity;
		R->PreDrawGouraud(Frame,FogSurface);
		bHardwareFogEnabled = true;
	}

	if (Emitter->TrailType == TRAIL_Sheet)
	{
		FCoords DirCoords(GMath.UnitCoords);
		FVector OldAxis;

		// Figure out first direction.
		for( INT j=0; j<Size; ++j )
		{
			FTrailOffsetPart& T = Trail(j);
			const FVector& Desired(j==Final ? Location : Trail(j+1).Location);
			Dir = (Desired-T.Location);
			if( Dir.SizeSquared()>0.2f )
			{
				DirCoords = (GMath.UnitCoords/Dir.Rotation());
				const FVector UpDir(DirCoords.XAxis);
				GetFaceCoords(T.Location,Frame->Coords.Origin,UpDir,DirCoords);
				OldAxis = DirCoords.YAxis;
				DirCoords.ZAxis = DirCoords.YAxis;
				break;
			}
		}
		INT NumPts = 0;
		FTransTexture* TL = TrailEmitterList;
		for( INT i=0; i<Size; ++i )
		{
			FTrailOffsetPart& T = Trail(i);
			FLOAT Scale = T.Scale;
			if (Emitter->TimeScale.Num())
				Scale *= GetScalerValue(T.GetLifeSpanScaleNeq(), 1.f, Emitter->TimeScale.Num(), &Emitter->TimeScale(0).Time, &Emitter->TimeScale(0).DrawScaling, sizeof(FScaleRangeType));
			const FVector& Desired(i==Final ? Location : Trail(i+1).Location);
			if( !i )
			{
				if (Emitter->bTexContinous)
					UOffset = T.X;
				if( T.Z.IsZero() )
				{
					Next[0] = (T.Location+DirCoords.ZAxis*Scale);
					Next[1] = (T.Location-DirCoords.ZAxis*Scale);
				}
				else
				{
					Next[0] = (T.Location+T.Z*Scale);
					Next[1] = (T.Location-T.Z*Scale);
				}
				if (Emitter->bSmoothEntryPoint)
					Color = FPlane(0,0,0,0);
				else
				{
					FLOAT LifeScale = T.GetLifeSpanScaleNeq();
					FLOAT LightScale = LifeScale;
					if (LightScale < Emitter->FadeInTime)
						LightScale = LightScale / Emitter->FadeInTime;
					else if (LightScale > Emitter->FadeOutTime)
						LightScale = 2.f - LightScale / Emitter->FadeOutTime;
					else LightScale = 1.f;
					LightScale = Clamp(LightScale * (Emitter->FadeInMaxAmount * ScaleGlow), 0.f, 1.f);
					if (Emitter->ParticleColorScale.Num())
						Color = FPlane(T.Color * GetScalerValueColor(LifeScale, &Emitter->ParticleColorScale(0), Emitter->ParticleColorScale.Num()) * LightScale, LightScale);
					else Color = FPlane(T.Color * LightScale, LightScale);
				}
			}
			RendParts[0].Point = Next[0];
			RendParts[0].Light = Color;
			RendParts[0].U = UOffset;
			RendParts[1].Point = Next[1];
			RendParts[1].Light = Color;
			RendParts[1].U = UOffset;
			if( i!=Final )
			{
				FTrailOffsetPart& NT = Trail(i+1);
				FLOAT LifeScale = NT.GetLifeSpanScaleNeq();
				FLOAT LightScale = LifeScale;
				if (LightScale < Emitter->FadeInTime)
					LightScale = LightScale / Emitter->FadeInTime;
				else if (LightScale > Emitter->FadeOutTime)
					LightScale = 2.f - LightScale / Emitter->FadeOutTime;
				else LightScale = 1.f;
				LightScale = Clamp(LightScale * (Emitter->FadeInMaxAmount * ScaleGlow), 0.f, 1.f);
				if (Emitter->ParticleColorScale.Num())
					Color = FPlane(NT.Color * GetScalerValueColor(LifeScale, &Emitter->ParticleColorScale(0), Emitter->ParticleColorScale.Num()) * LightScale, LightScale);
				else Color = FPlane(NT.Color * LightScale, LightScale);
				if( i+1==Final )
					Dir = (Location-NT.Location);
				else Dir = (Trail(i+2).Location-NT.Location);
				if( Dir.SizeSquared()>0.2f )
				{
					DirCoords = (GMath.UnitCoords/Dir.Rotation());
					const FVector UpDir(DirCoords.XAxis);
					GetFaceCoords(T.Location,Frame->Coords.Origin,UpDir,DirCoords);
					DirCoords.ZAxis = (DirCoords.YAxis+OldAxis).SafeNormal();
					OldAxis = DirCoords.YAxis;
				}
				if (Emitter->bTexContinous)
					UOffset = NT.X;
				else UOffset+=UScalar;
			}
			else UOffset+=UScalar;
			if( T.Z.IsZero() )
			{
				RendParts[2].Point = (Desired+DirCoords.ZAxis*Scale);
				RendParts[3].Point = (Desired-DirCoords.ZAxis*Scale);
			}
			else
			{
				RendParts[2].Point = (Desired+T.Z*Scale);
				RendParts[3].Point = (Desired-T.Z*Scale);
			}
			RendParts[2].Light = Color;
			RendParts[2].U = UOffset;
			RendParts[3].Light = Color;
			RendParts[3].U = UOffset;
			Next[0] = RendParts[2].Point;
			Next[1] = RendParts[3].Point;
			for( BYTE j=0; j<4; ++j )
			{
				RendParts[j].Point = RendParts[j].Point.TransformPointBy(Frame->Coords);
				RendParts[j].Project(Frame);
			}

			*TL++ = RendParts[0];
			*TL++ = RendParts[1];
			*TL++ = RendParts[2];
			*TL++ = RendParts[1];
			*TL++ = RendParts[2];
			*TL++ = RendParts[3];
			NumPts += 6;

			if (NumPts >= MAX_FULLPOLYLIST - 6)
			{
				R->DrawGouraudPolyList(Frame, *Info, TrailEmitterList, NumPts, DrawFlags);
				NumPts = 0;
				TL = TrailEmitterList;
			}
		}
		if (NumPts>=3)
			R->DrawGouraudPolyList(Frame, *Info, TrailEmitterList, NumPts, DrawFlags);
	}
	else // Draw double sheet, independent from camera location.
	{
		FCoords& CD(Frame->Coords);
		INT NumPts = 0;
		FTransTexture* TL = TrailEmitterList;
		for( INT i=0; i<Size; ++i )
		{
			FTrailOffsetPart& T = Trail(i);
			FLOAT Scale = T.Scale;
			if (Emitter->TimeScale.Num())
				Scale *= GetScalerValue(T.GetLifeSpanScaleNeq(), 1.f, Emitter->TimeScale.Num(), &Emitter->TimeScale(0).Time, &Emitter->TimeScale(0).DrawScaling, sizeof(FScaleRangeType));
			const FVector& Desired(i==Final ? Location : Trail(i+1).Location);
			if( !i )
			{
				if (Emitter->bTexContinous)
					UOffset = T.X;
				Next[0] = (T.Location+CD.YAxis*Scale);
				Next[1] = (T.Location-CD.YAxis*Scale);
				Next[2] = (T.Location+CD.XAxis*Scale);
				Next[3] = (T.Location-CD.XAxis*Scale);
				if (Emitter->bSmoothEntryPoint)
					Color = FPlane(0, 0, 0, 0);
				else
				{
					FLOAT LifeScale = T.GetLifeSpanScaleNeq();
					FLOAT LightScale = LifeScale;
					if (LightScale < Emitter->FadeInTime)
						LightScale = LightScale / Emitter->FadeInTime;
					else if (LightScale > Emitter->FadeOutTime)
						LightScale = 2.f - LightScale / Emitter->FadeOutTime;
					else LightScale = 1.f;
					LightScale *= (Emitter->FadeInMaxAmount * ScaleGlow);
					if (Emitter->ParticleColorScale.Num())
						Color = FPlane(T.Color * GetScalerValueColor(LifeScale, &Emitter->ParticleColorScale(0), Emitter->ParticleColorScale.Num()) * LightScale, LightScale);
					else Color = FPlane(T.Color * LightScale, LightScale);
				}
			}

			// Draw first sheet.
			RendParts[0].Point = Next[0];
			RendParts[0].Light = Color;
			RendParts[0].U = UOffset;
			RendParts[1].Point = Next[1];
			RendParts[1].Light = Color;
			RendParts[1].U = UOffset;
			if( i!=Final )
			{
				FTrailOffsetPart& NT = Trail(i+1);
				FLOAT LifeScale = NT.GetLifeSpanScaleNeq();
				FLOAT LightScale = LifeScale;
				if (LightScale < Emitter->FadeInTime)
					LightScale = LightScale / Emitter->FadeInTime;
				else if (LightScale > Emitter->FadeOutTime)
					LightScale = 2.f - LightScale / Emitter->FadeOutTime;
				else LightScale = 1.f;
				LightScale *= (Emitter->FadeInMaxAmount * ScaleGlow);
				if(Emitter->ParticleColorScale.Num())
					Color = FPlane(NT.Color * GetScalerValueColor(LifeScale, &Emitter->ParticleColorScale(0), Emitter->ParticleColorScale.Num()) * LightScale, LightScale);
				else Color = FPlane(NT.Color * LightScale, LightScale);
				if (Emitter->bTexContinous)
					UOffset = NT.X;
				else UOffset+=UScalar;
			}
			else UOffset+=UScalar;

			RendParts[2].Point = (Desired+CD.YAxis*Scale);
			RendParts[2].Light = Color;
			RendParts[2].U = UOffset;
			RendParts[3].Point = (Desired-CD.YAxis*Scale);
			RendParts[3].Light = Color;
			RendParts[3].U = UOffset;
			Next[0] = RendParts[2].Point;
			Next[1] = RendParts[3].Point;
			for( BYTE k=0; k<4; ++k )
			{
				RendParts[k].Point = RendParts[k].Point.TransformPointBy(CD);
				RendParts[k].Project(Frame);
			}
			*TL++ = RendParts[0];
			*TL++ = RendParts[1];
			*TL++ = RendParts[2];

			*TL++ = RendParts[1];
			*TL++ = RendParts[2];
			*TL++ = RendParts[3];

			// Draw second sheet
			RendParts[0].Point = Next[2];
			RendParts[1].Point = Next[3];
			RendParts[2].Point = (Desired+CD.XAxis*Scale);
			RendParts[3].Point = (Desired-CD.XAxis*Scale);
			Next[2] = RendParts[2].Point;
			Next[3] = RendParts[3].Point;
			for( BYTE j=0; j<4; ++j )
			{
				RendParts[j].Point = RendParts[j].Point.TransformPointBy(CD);
				RendParts[j].Project(Frame);
			}

			*TL++ = RendParts[0];
			*TL++ = RendParts[1];
			*TL++ = RendParts[2];

			*TL++ = RendParts[1];
			*TL++ = RendParts[2];
			*TL++ = RendParts[3];
			NumPts += 12;

			if (NumPts >= MAX_FULLPOLYLIST-12)
			{
				R->DrawGouraudPolyList(Frame, *Info, TrailEmitterList, NumPts, DrawFlags);
				NumPts = 0;
				TL = TrailEmitterList;
			}
		}
		if (NumPts>=3)
			R->DrawGouraudPolyList(Frame, *Info, TrailEmitterList, NumPts, DrawFlags);
	}
	if( bHardwareFogEnabled )
		R->PostDrawGouraud(Frame, FogSurface);
	return true;
	unguard;
}

FParticlesDataBase* AXTrailEmitter::GetParticleInterface()
{
	guardSlow(AXTrailEmitter::GetParticleInterface);
	if (!PartPtr)
	{
		FTrailParticle* T = new FTrailParticle(this);
		PartPtr = T;
	}
	return PartPtr;
	unguardSlow;
}

void AXTrailEmitter::UpdateEmitter(FLOAT DeltaTime, UEmitterRendering* Render, UBOOL bSkipChildren)
{
	guard(AXTrailEmitter::UpdateEmitter);
	if (!PartPtr)
		GetParticleInterface();
	if (bAutoReset && ResetTimer > 0)
	{
		ResetTimer -= DeltaTime;
		if (ResetTimer <= 0)
			ActiveCount = 0;
	}
	if (bAutoVisibilityBox)
	{
		switch (SpawnPosType)
		{
		case SP_Box:
			RendBoundingBox.Min = FVector(BoxLocation.X.Min, BoxLocation.Y.Min, BoxLocation.Z.Min) + Location;
			RendBoundingBox.Max = FVector(BoxLocation.X.Max, BoxLocation.Y.Max, BoxLocation.Z.Max) + Location;
			break;
		default:
			RendBoundingBox.Min = FVector(SphereCylinderRange.Min, SphereCylinderRange.Min, SphereCylinderRange.Min) + Location;
			RendBoundingBox.Max = RendBoundingBox.Min;
			RendBoundingBox += Location + FVector(SphereCylinderRange.Max, SphereCylinderRange.Max, SphereCylinderRange.Max);
			RendBoundingBox += Location - FVector(SphereCylinderRange.Max, SphereCylinderRange.Max, SphereCylinderRange.Max);
		}
		RendBoundingBox = RendBoundingBox.ExpandBy(8.f);
	}
	reinterpret_cast<FTrailParticle*>(PartPtr)->TickTrails(DeltaTime);
	if (!bSkipChildren)
		UpdateChildren(DeltaTime, Render);
	unguardobj;
}

void AXTrailEmitter::InitTrailEmitter()
{
	guardSlow(AXTrailEmitter::InitTrailEmitter);
	if( !bDynamicParticleCount )
	{
		if( ParticlesPerSec<=0 )
			SpawnInterval = LifetimeRange.Max/MaxParticles;
		else SpawnInterval = LifetimeRange.Max/ParticlesPerSec;
	}
	unguardSlow;
}
void AXTrailEmitter::ResetEmitter()
{
	guardSlow(AXTrailEmitter::ResetEmitter);
	Super::ResetEmitter();
	InitTrailEmitter();
	if (ParentEmitter && ParentEmitter != this)
		ParentEmitter->ResetEmitter();
	unguardSlow;
}
void AXTrailEmitter::InitializeEmitter(AXParticleEmitter* Parent)
{
	guardSlow(AXTrailEmitter::InitializeEmitter);
	Super::InitializeEmitter(Parent);
	InitTrailEmitter();
	unguardSlow;
}
AActor* AXTrailEmitter::GrabTrail(const FVector& Pos, const FRotator& Rot)
{
	guard(AXTrailEmitter::GrabTrail);
	if (!PartPtr)
		GetParticleInterface();
	return reinterpret_cast<FTrailParticle*>(PartPtr)->GetFreeTrail(Pos, Rot);
	unguard;
}
FLOAT AXTrailEmitter::GetMaxLifeTime() const
{
	guardSlow(AXTrailEmitter::GetMaxLifeTime);
	return Max(LifetimeRange.Min, LifetimeRange.Max);
	unguardSlow;
}
