#pragma once

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

class EMITTER_API AXTrailParticle : public AInfo
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
	FLOAT RenderDelay;

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
		RenderDelay = E->StartupDelay.GetValue();
	}
	bool OverrideMeshRender(struct FSceneNode* Frame);

	void Serialize(FArchive& Ar)
	{
		guard(AXTrailParticle::Serialize);
		FName N = GetFName();
		Ar << N;
		unguard;
	}

	inline UBOOL IsVisible() const
	{
		return (!bHidden && RenderDelay <= 0.f);
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
		guardSlow(AXTrailParticle::TickTrail);
		if (RenderDelay > 0.f)
		{
			if ((RenderDelay -= DeltaTime) <= 0.f)
				bFreshParticle = TRUE;
			else return TRUE;
		}

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
		unguardSlow;
	}

	inline void Flush()
	{
		Trail.Empty();
		bHidden = FALSE;
		ScaleGlow = 1.f;
		bSettingTrail = FALSE;
		bFreshParticle = TRUE;
		NetTag = (INT)GFrameNumber;
		RenderDelay = Emitter->StartupDelay.GetValue();
	}
};
