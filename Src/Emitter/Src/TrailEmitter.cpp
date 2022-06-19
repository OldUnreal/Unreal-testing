
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXTrailEmitter);

struct FTrailOffsetPart
{
	FVector Location,Velocity,Color,Accel,Z;
	float LifeSpan[3],Scale,X;

	inline FLOAT GetLifeSpanScale()
	{
		return (LifeSpan[0] / LifeSpan[1]);
	}
	inline FLOAT GetLifeSpanScaleNeq()
	{
		return 1.f - (LifeSpan[0] / LifeSpan[1]);
	}
	inline FLOAT GetEndTimeSpan()
	{
		return (LifeSpan[2] == 0 ? 1.f : LifeSpan[0] / LifeSpan[2]);
	}
	inline FLOAT GetEndTimeSpanReverse()
	{
		return (LifeSpan[2] == 0 ? 0.f : (1.f - LifeSpan[0] / LifeSpan[2]));
	}
};

class AXTrailParticle : public AInfo
{
private:
	AXTrailParticle() {}

public:
	DECLARE_CLASS(AXTrailParticle, AInfo, CLASS_Transient | CLASS_NoUserCreate, Emitter)

	TArray<FTrailOffsetPart> Trail;
	FVector OldTrailSpot;
	UBOOL bSettingTrail, bFreshParticle;
	FLOAT NextParticleTime, TexOffset;
	AXTrailEmitter* Emitter;
	FBox Bounds;

	AXTrailParticle(AXTrailEmitter* E)
		: bSettingTrail(FALSE), bFreshParticle(TRUE), NextParticleTime(0.f), TexOffset(0.f), Emitter(E)
	{
		XLevel = E->XLevel;
		Level = E->Level;
		HitActor = E;
		Style = E->ParticleStyle;
		DrawType = DT_Mesh;
		DrawScale3D = FVector(1.f, 1.f, 1.f);
		DrawScale = 1.f;
		ScaleGlow = 1.f;
		bHidden = FALSE;
		NetTag = (INT)GFrameNumber;
	}
	bool OverrideMeshRender(struct FSceneNode* Frame);

	void Serialize(FArchive& Ar)
	{
		guard(AXTrailParticle::Serialize);
		FName N = GetFName();
		Ar << N;
		unguard;
	}

	inline FVector GetTrailZ() const
	{
		if (Emitter->SheetUpdir.IsZero())
			return FVector(0, 0, 0);
		if (Emitter->bSheetRelativeToRotation)
			return Emitter->SheetUpdir.SafeNormal().TransformVectorBy(GMath.UnitCoords * Rotation);
		else return Emitter->SheetUpdir.SafeNormal();
	}

	inline void BeginNewTrailSeg()
	{
		FTrailOffsetPart& T = Trail(Trail.Add());
		T.Location = OldTrailSpot;
		T.Velocity = Emitter->GetSpawnVelocity(OldTrailSpot - Location);
		T.Color = Emitter->ParticleColor.GetValue();
		T.Accel = Emitter->ParticleAcceleration.GetValue();
		T.Z = GetTrailZ();
		T.LifeSpan[1] = Emitter->LifetimeRange.GetValue();
		T.LifeSpan[0] = T.LifeSpan[1];
		T.LifeSpan[2] = 0;
		if (Emitter->bTexContinous)
		{
			if (Trail.Num() == 1 && Emitter->ParticleTextures.Num() && Emitter->ParticleTextures(0))
				TexOffset += Emitter->ParticleTextures(0)->USize * Emitter->ParticleTextures(0)->DrawScale * Emitter->TextureUV[3];
			T.X = TexOffset;
			if (Emitter->ParticleTextures.Num() && Emitter->ParticleTextures(0))
				TexOffset += Emitter->ParticleTextures(0)->USize * Emitter->ParticleTextures(0)->DrawScale * (Emitter->TextureUV[1] + Emitter->TextureUV[3]);
			else TexOffset += 256.f;
		}
		T.Scale = Emitter->StartingScale.GetValue() * 8.f;
		bSettingTrail = TRUE;
	}

	UBOOL TickTrail(FLOAT DeltaTime)
	{
		// Update trail...
		for (INT i = 0; i < Trail.Num(); ++i)
		{
			FTrailOffsetPart& T = Trail(i);
			T.LifeSpan[0] -= DeltaTime;
			T.Location += (T.Velocity * DeltaTime);
			T.Velocity += (T.Accel * DeltaTime);
		}
		if (Trail.Num() && Trail(0).LifeSpan[0] > 0.f) // Make last trail orient in towards second last.
		{
			FTrailOffsetPart& T = Trail(0);
			if (T.LifeSpan[2] == 0)
				T.LifeSpan[2] = T.LifeSpan[0];
			else
			{
				FLOAT Scale = (T.LifeSpan[0] / T.LifeSpan[2]);
				FVector& Spot((Trail.Num() == 1) ? Location : Trail(1).Location);
				T.Location = Spot * (1.f - Scale) + T.Location * Scale;
			}
		}
		UBOOL bUpdating = (!Emitter->bDestruction && !Emitter->bDisabled && (((INT)GFrameNumber) - NetTag) < 4);
		if (bUpdating)
		{
			if (bFreshParticle)
			{
				bFreshParticle = FALSE;
				OldTrailSpot = Location;
			}
			if (!Emitter->bDynamicParticleCount)
			{
				if ((NextParticleTime -= DeltaTime) <= 0.f)
				{
					OldTrailSpot = Location;
					BeginNewTrailSeg();
					NextParticleTime = Emitter->SpawnInterval;
				}
			}
			else if (Location != OldTrailSpot)
			{
				FVector Delta(OldTrailSpot - Location);
				FLOAT DistSq(Delta.SizeSquared());
				if (bSettingTrail && !Trail.Num())
					bSettingTrail = FALSE;
				if (bSettingTrail)
				{
					FTrailOffsetPart& LastT = Trail(Trail.Num() - 1);
					if (DistSq > Square(Emitter->MaxTrailLength)) // End trail here.
					{
						OldTrailSpot = Location;
						BeginNewTrailSeg();
					}
					else if (LastT.LifeSpan[0] <= 0)
					{
						if (DistSq < Square(Emitter->TrailTreshold))
							bSettingTrail = 0;
						else
						{
							OldTrailSpot = Location;
							BeginNewTrailSeg();
						}
					}
				}
				else if (DistSq > Square(Emitter->TrailTreshold))
				{
					OldTrailSpot = Location;
					BeginNewTrailSeg();
				}
			}
		}
		for (INT j = 0; j < Trail.Num(); ++j)
			if (Trail(j).LifeSpan[0] <= 0.f)
				Trail.Remove(j--);

		if (!Trail.Num())
		{
			if (!bUpdating)
				bHidden = TRUE;
			return FALSE;
		}

		// Update render bounds
		FBox Result(Location, Location);
		for (INT i = 0; i < Trail.Num(); ++i)
			Result += Trail(i).Location;
		Bounds = Result.ExpandBy(Emitter->StartingScale.Max * 10.f);
		return TRUE;
	}

	inline void Flush()
	{
		Trail.Empty();
		bHidden = FALSE;
		ScaleGlow = 1.f;
		bSettingTrail = FALSE;
		bFreshParticle = TRUE;
		NetTag = (INT)GFrameNumber;
	}
};
IMPLEMENT_CLASS(AXTrailParticle);

class UTrailMesh : public UMesh
{
	DECLARE_CLASS(UTrailMesh, UMesh, CLASS_Transient | CLASS_NoUserCreate, Emitter)

	UTrailMesh()
		: UMesh()
	{}
	FBox GetRenderBoundingBox( const AActor* Owner, UBOOL Exact )
	{
		return reinterpret_cast<const AXTrailParticle*>(Owner)->Bounds;
	}
	void Serialize(FArchive& Ar)
	{
		guard(AXTrailParticle::Serialize);
		FName N = GetFName();
		Ar << N;
		unguard;
	}
};
IMPLEMENT_CLASS(UTrailMesh);

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
			if (!Particles(i)->bHidden)
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
			if (!Particles.Num())
				GetFreeTrail(Owner->Location, Owner->Rotation); // Must have valid first trail.
			A = Particles(0);
			A->bHidden = FALSE;
			A->ScaleGlow = Owner->ScaleGlow;
			A->NetTag = (INT)GFrameNumber;
			A->Location = Owner->Location;
			A->Rotation = Owner->Rotation;
			A->TickTrail(DeltaTime);

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

bool AXTrailParticle::OverrideMeshRender( FSceneNode* Frame )
{
	guard(AXTrailParticle::OverrideMeshRender);
	URenderDevice* R = Frame->Viewport->RenDev;
	if (!Trail.Num() || !Emitter->ParticleTextures.Num())
		return true; // Can't render.

	static FTransTexture TrailEmitterList[MAX_FULLPOLYLIST];
	static FTransTexture RendParts[4];
	FTextureInfo* Info;
	static bool bTexInit=false;
	if( !bTexInit )
	{
		bTexInit = true;
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
	if (ParentEmitter)
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
