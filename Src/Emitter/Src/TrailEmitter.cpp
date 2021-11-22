
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXTrailEmitter);
IMPLEMENT_CLASS(AXTrailParticle);
IMPLEMENT_CLASS(UTrailEmitterRender);

class EMITTER_API UTrailMesh : public UMesh
{
	DECLARE_CLASS(UTrailMesh, UMesh, CLASS_Transient, Emitter)

	UTrailMesh()
		: UMesh()
	{}
	FBox GetRenderBoundingBox( const AActor* Owner, UBOOL Exact )
	{
		return BoundingBox;
	}
};

IMPLEMENT_CLASS(UTrailMesh);

AActor* UTrailEmitterRender::GetActors()
{
	guard(UTrailEmitterRender::GetActors);
	if( !Owner )
	{
		guard(InitTrailEmitter);
		Owner = CastChecked<AXTrailEmitter>(GetOuter());
		Particle = new(Owner,AXTrailParticle::StaticClass()->GetFName()) AXTrailParticle();
		Particle->XLevel = Owner->XLevel;
		Particle->Level = Owner->Level;
		Particle->HitActor = Owner;
		Particle->Style = Owner->ParticleStyle;
		Particle->Mesh = new(Owner)UTrailMesh();
		Owner->ParticleData = Particle;
		Owner->InitTrailEmitter();
		unguard;
	}
	Particle->Location = Owner->Location;

	AActor* Result = Particle;
	if (Observer->ShowFlags & SHOW_InGameMode)
		Result->Target = NULL;
	else
	{
		Result->Target = Owner;
		Owner->Target = NULL;
	}
	return Result;
	unguard;
}
void UTrailEmitterRender::Destroy()
{
	if( Particle && !GIsRequestingExit )
	{
		if( Owner )
			Owner->ParticleData = NULL;
		delete Particle;
		Particle = NULL;
	}
	Super::Destroy();
}
void AXTrailParticle::Destroy()
{
	if( Mesh && !GIsRequestingExit )
	{
		delete Mesh;
		Mesh = NULL;
	}
	Super::Destroy();
}

bool AXTrailParticle::OverrideMeshRender( FSceneNode* Frame )
{
	guard(AXTrailParticle::OverrideMeshRender);
	AXTrailEmitter* E = (AXTrailEmitter*)GetOuter();
	URenderDevice* R = Frame->Viewport->RenDev;
	if (!E->trail.Num() || !E->ParticleTextures.Num())
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
		UTexture* T = E->ParticleTextures(0);
		if (!T)
			T = Level->DefaultTexture;
		Info = T->GetTexture(INDEX_NONE, R);
	}
	FLOAT UScale=(Info->UScale*Info->USize),VScale=(Info->VScale*Info->VSize);
	FLOAT VScaler(VScale*(E->TextureUV[0]+E->TextureUV[2]));
	RendParts[0].U = VScale*E->TextureUV[2];
	RendParts[2].V = VScale*E->TextureUV[2];
	RendParts[1].V = VScaler;
	RendParts[3].V = VScaler;

	INT Size = E->trail.Num();
	INT Final(Size-1);
	static FVector Next[4],Dir;
	FPlane Color;
	FLOAT UOffset = E->TextureUV[3]*UScale;
	FLOAT UScalar = UScale*(E->TextureUV[1]+E->TextureUV[3]);
	if( !E->bTexContinous )
		UScalar/=Size;
	DWORD DrawFlags=PF_TwoSided;
	switch( E->ParticleStyle )
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
	AZoneInfo* Z=((E->Region.Zone && E->Region.Zone->bZoneBasedFog) ? E->Region.Zone : Frame->Viewport->Actor->CameraRegion.Zone);
	FFogSurf FogSurface;
	if( Z && Z->bDistanceFog && R->SupportsDistanceFog && E->ParticleStyle!=STY_Translucent )
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

	if( E->TrailType==TRAIL_Sheet )
	{
		FCoords DirCoords(GMath.UnitCoords);
		FVector OldAxis;

		// Figure out first direction.
		for( INT j=0; j<Size; ++j )
		{
			FTrailOffsetPart& T = E->trail(j);
			const FVector& Desired(j==Final ? E->Location : E->trail(j+1).Location);
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
			FTrailOffsetPart& T = E->trail(i);
			FLOAT Scale = T.Scale;
			if (E->TimeScale.Num())
				Scale *= GetScalerValue(T.GetLifeSpanScaleNeq(), 1.f, E->TimeScale.Num(), &E->TimeScale(0).Time, &E->TimeScale(0).DrawScaling, sizeof(FScaleRangeType));
			const FVector& Desired(i==Final ? E->Location : E->trail(i+1).Location);
			if( !i )
			{
				if( E->bTexContinous )
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
				if( E->bSmoothEntryPoint )
					Color = FPlane(0,0,0,0);
				else
				{
					FLOAT LifeScale = T.GetLifeSpanScaleNeq();
					FLOAT LightScale = LifeScale;
					if( LightScale<E->FadeInTime )
						LightScale = LightScale/E->FadeInTime;
					else if( LightScale>E->FadeOutTime )
						LightScale = 2.f-LightScale/E->FadeOutTime;
					else LightScale = 1.f;
					LightScale*=E->FadeInMaxAmount;
					if (E->ParticleColorScale.Num())
						Color = FPlane(T.Color * GetScalerValueColor(LifeScale, &E->ParticleColorScale(0), E->ParticleColorScale.Num()) * LightScale, LightScale);
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
				FTrailOffsetPart& NT = E->trail(i+1);
				FLOAT LifeScale = NT.GetLifeSpanScaleNeq();
				FLOAT LightScale = LifeScale;
				if( LightScale<E->FadeInTime )
					LightScale = LightScale/E->FadeInTime;
				else if( LightScale>E->FadeOutTime )
					LightScale = 2.f-LightScale/E->FadeOutTime;
				else LightScale = 1.f;
				LightScale*=E->FadeInMaxAmount;
				if (E->ParticleColorScale.Num())
					Color = FPlane(NT.Color * GetScalerValueColor(LifeScale, &E->ParticleColorScale(0), E->ParticleColorScale.Num()) * LightScale, LightScale);
				else Color = FPlane(NT.Color * LightScale, LightScale);
				if( i+1==Final )
					Dir = (E->Location-NT.Location);
				else Dir = (E->trail(i+2).Location-NT.Location);
				if( Dir.SizeSquared()>0.2f )
				{
					DirCoords = (GMath.UnitCoords/Dir.Rotation());
					const FVector UpDir(DirCoords.XAxis);
					GetFaceCoords(T.Location,Frame->Coords.Origin,UpDir,DirCoords);
					DirCoords.ZAxis = (DirCoords.YAxis+OldAxis).SafeNormal();
					OldAxis = DirCoords.YAxis;
				}
				if( E->bTexContinous )
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
			FTrailOffsetPart& T = E->trail(i);
			FLOAT Scale = T.Scale;
			if (E->TimeScale.Num())
				Scale *= GetScalerValue(T.GetLifeSpanScaleNeq(), 1.f, E->TimeScale.Num(), &E->TimeScale(0).Time, &E->TimeScale(0).DrawScaling, sizeof(FScaleRangeType));
			const FVector& Desired(i==Final ? E->Location : E->trail(i+1).Location);
			if( !i )
			{
				if( E->bTexContinous )
					UOffset = T.X;
				Next[0] = (T.Location+CD.YAxis*Scale);
				Next[1] = (T.Location-CD.YAxis*Scale);
				Next[2] = (T.Location+CD.XAxis*Scale);
				Next[3] = (T.Location-CD.XAxis*Scale);
				if( E->bSmoothEntryPoint )
					Color = FPlane(0,0,0,0);
				else
				{
					FLOAT LifeScale = T.GetLifeSpanScaleNeq();
					FLOAT LightScale = LifeScale;
					if( LightScale<E->FadeInTime )
						LightScale = LightScale/E->FadeInTime;
					else if( LightScale>E->FadeOutTime )
						LightScale = 2.f-LightScale/E->FadeOutTime;
					else LightScale = 1.f;
					LightScale*=E->FadeInMaxAmount;
					if(E->ParticleColorScale.Num())
						Color = FPlane(T.Color * GetScalerValueColor(LifeScale, &E->ParticleColorScale(0), E->ParticleColorScale.Num()) * LightScale, LightScale);
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
				FTrailOffsetPart& NT = E->trail(i+1);
				FLOAT LifeScale = NT.GetLifeSpanScaleNeq();
				FLOAT LightScale = LifeScale;
				if( LightScale<E->FadeInTime )
					LightScale = LightScale/E->FadeInTime;
				else if( LightScale>E->FadeOutTime )
					LightScale = 2.f-LightScale/E->FadeOutTime;
				else LightScale = 1.f;
				LightScale*=E->FadeInMaxAmount;
				if(E->ParticleColorScale.Num())
					Color = FPlane(NT.Color * GetScalerValueColor(LifeScale, &E->ParticleColorScale(0), E->ParticleColorScale.Num()) * LightScale, LightScale);
				else Color = FPlane(NT.Color * LightScale, LightScale);
				if( E->bTexContinous )
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

inline void AXTrailEmitter::BeginNewTrailSeg()
{
	FTrailOffsetPart& T = trail(trail.Add());
	T.Location = OldTrailSpot;
	T.Velocity = GetSpawnVelocity(OldTrailSpot-Location);
	T.Color = ParticleColor.GetValue();
	T.Accel = ParticleAcceleration.GetValue();
	T.Z = SheetUpdir.SafeNormal();
	T.LifeSpan[1] = LifetimeRange.GetValue();
	T.LifeSpan[0] = T.LifeSpan[1];
	T.LifeSpan[2] = 0;
	if( bTexContinous )
	{
		T.X = TexOffset;
		if (ParticleTextures.Num() && ParticleTextures(0))
			TexOffset += ParticleTextures(0)->USize * ParticleTextures(0)->DrawScale * (TextureUV[1] + TextureUV[3]);
		else TexOffset += 256.f;
	}
	T.Scale = StartingScale.GetValue() * 8.f;
	bSettingTrail = 1;
}
UBOOL AXTrailEmitter::Tick( FLOAT DeltaTime, ELevelTick TickType )
{
	UBOOL bRes = Super::Tick(DeltaTime,TickType);
	if( (!GIsEditor && TickType!=LEVELTICK_All) || !ParticleTextures.Num() )
		return bRes;

	guard(AXTrailEmitter::Tick);
	// Update trail...
	for( INT i=0; i<trail.Num(); ++i )
	{
		FTrailOffsetPart& T = trail(i);
		T.LifeSpan[0]-=DeltaTime;
		T.Location+=(T.Velocity*DeltaTime);
		T.Velocity+=(T.Accel*DeltaTime);
	}
	if( trail.Num() && trail(0).LifeSpan[0]>0.f ) // Make last trail orient in towards second last.
	{
		FTrailOffsetPart& T = trail(0);
		if( T.LifeSpan[2]==0 )
			T.LifeSpan[2] = T.LifeSpan[0];
		else
		{
			FLOAT Scale = (T.LifeSpan[0]/T.LifeSpan[2]);
			FVector& Spot((trail.Num()==1) ? Location : trail(1).Location);
			T.Location = Spot*(1.f-Scale)+T.Location*Scale;
		}
	}
	if( !bDestruction && !bDisabled )
	{
		if( bDynamicParticleCount && Location!=OldTrailSpot )
		{
			FVector Delta(OldTrailSpot-Location);
			FLOAT DistSq(Delta.SizeSquared());
			if( bSettingTrail && !trail.Num() )
				bSettingTrail = 0;
			if( bSettingTrail )
			{
				FTrailOffsetPart& LastT = trail(trail.Num()-1);
				if( DistSq>Square(MaxTrailLength) ) // End trail here.
				{
					OldTrailSpot = Location;
					BeginNewTrailSeg();
				}
				else if( LastT.LifeSpan[0]<=0 )
				{
					if( DistSq<Square(TrailTreshold) )
						bSettingTrail = 0;
					else
					{
						OldTrailSpot = Location;
						BeginNewTrailSeg();
					}
				}
			}
			else if( DistSq>Square(TrailTreshold) )
			{
				OldTrailSpot = Location;
				BeginNewTrailSeg();
			}
		}
		else if( !bDynamicParticleCount )
		{
			if( (NextParticleTime-=DeltaTime)<=0.f )
			{
				OldTrailSpot = Location;
				BeginNewTrailSeg();
				NextParticleTime = SpawnInterval;
			}
		}
	}
	for( INT j=0; j<trail.Num(); ++j )
		if( trail(j).LifeSpan[0]<=0.f )
			trail.Remove(j--);
	if( bDestruction && !trail.Num() && !bDeleteMe )
	{
		XLevel->DestroyActor(this);
		return bDeleteMe;
	}

	// Update render bounds
	if( ParticleData && ParticleData->Mesh )
	{
		FBox Result(0);
		if( !trail.Num() )
			Result+=Location;
		else
		{
			for( INT i=0; i<trail.Num(); ++i )
				Result+=trail(i).Location;
		}
		ParticleData->Mesh->BoundingBox = Result.ExpandBy(StartingScale.Max*10.f);
	}
	unguard;
	return bRes;
}
void AXTrailEmitter::KillEmitter()
{
	guard(AXTrailEmitter::KillEmitter);
	if( bDeleteMe )
		return;
	if( GIsEditor )
		XLevel->DestroyActor(this);
	else
	{
		if( !trail.Num() )
			XLevel->DestroyActor(this);
		else bDestruction = 1;
	}
	unguard;
}
void AXTrailEmitter::TriggerEmitter()
{
	switch( TriggerAction )
	{
	case ETR_ToggleDisabled:
		bDisabled = !bDisabled;
		break;
	case ETR_ResetEmitter:
		trail.Empty();
		break;
	}
}
void AXTrailEmitter::InitTrailEmitter()
{
	if( !bDynamicParticleCount )
	{
		if( ParticlesPerSec<=0 )
			SpawnInterval = LifetimeRange.Max/MaxParticles;
		else SpawnInterval = LifetimeRange.Max/ParticlesPerSec;
	}
	if (bTexContinous && ParticleTextures.Num() && ParticleTextures(0))
		TexOffset += ParticleTextures(0)->USize * ParticleTextures(0)->DrawScale * TextureUV[3];
}
void AXTrailEmitter::ResetEmitter()
{
	Super::ResetEmitter();
	trail.Empty();
	InitTrailEmitter();
}
