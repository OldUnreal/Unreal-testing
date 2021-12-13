
#include "EmitterPrivate.h"
#include "UnOctreeHash.h"

IMPLEMENT_CLASS(AXWeatherEmitter);

inline UBOOL AABBOverlaps(const FVector& Min1, const FVector& Max1, const FVector& Min2, const FVector& Max2)
{
#define CHECK_AXIS(axis) ((Min1.axis > Min2.axis) && (Min1.axis < Max2.axis) || (Min2.axis > Min1.axis) && (Min2.axis < Max1.axis))
	return CHECK_AXIS(X) && CHECK_AXIS(Y) && CHECK_AXIS(Z);
#undef CHECK_AXIS
}

struct FRainNode
{
	TArray<AXRainRestrictionVolume*> Volume;
	FVector Point, Extent;
	FRainNode* Children;
	INT Depth;
	UBOOL bHasContents;

	FRainNode()
		: Children(NULL), bHasContents(FALSE)
	{
	}
	FRainNode(const FVector& P, const FVector& E, INT NewDepth)
		: Point(P), Extent(E), Children(NULL), Depth(NewDepth), bHasContents(FALSE)
	{
	}
	~FRainNode()
	{
		if (Children)
			delete[] Children;
	}
	void AddVolume(AXRainRestrictionVolume* V)
	{
		bHasContents = TRUE;
		if (!Children)
			AddInternal(V);
		else
		{
			INT Item = INDEX_NONE;
			for (INT i = 0; i < 8; ++i)
				if (Children[i].Overlaps(V))
				{
					if (Item == INDEX_NONE)
						Item = i;
					else
					{
						Item = INDEX_NONE;
						Volume.AddItem(V);
						break;
					}
				}

			if (Item != INDEX_NONE)
				Children[Item].AddVolume(V);
		}
	}
	UBOOL IsBlocked(const FVector& P) const
	{
		INT i;

		for (i = (Volume.Num() - 1); i >= 0; --i)
		{
			if (Volume(i)->PointIsInside(P))
				return TRUE;
		}
		if (Children)
		{
			i = INT(P.Z > Point.Z) | (INT(P.Y > Point.Y) << 1) | (INT(P.X > Point.X) << 2);
			return (Children[i].bHasContents && Children[i].IsBlocked(P));
		}
		return FALSE;
	}
	void DrawDebug()
	{
		INT i;

		for (i = (Volume.Num() - 1); i >= 0; --i)
		{
			new FDebugLineData(Point, Volume(i)->Location, FPlane(1, 0, 0, 1), TRUE);
			FDebugLineData::DrawBox(Volume(i)->RainBounds.Min, Volume(i)->RainBounds.Max, FPlane(0, 0, 1, 1), TRUE);
		}
		if (Children)
		{
			for (i = 0; i < 8; ++i)
			{
				new FDebugLineData(Point, Children[i].Point, FPlane(1, 1, 1, 1), TRUE);
				Children[i].DrawDebug();
			}
		}
	}

private:
	inline UBOOL Overlaps(AXRainRestrictionVolume* V)
	{
		const FVector MinV(Point - Extent);
		const FVector MaxV(Point + Extent);
		return AABBOverlaps(MinV, MaxV, V->RainBounds.Min, V->RainBounds.Max);
	}
	void InitChildren()
	{
		Children = new FRainNode[8];

		// Setup children.
		FVector HalfExtent = (Extent * 0.5f);
		for (INT i = 0; i < 8; ++i)
		{
			Children[i].Point = FVector(Point.X + (((i & EBA_XMax) >> 1) - 1) * HalfExtent.X,
				Point.Y + (((i & EBA_YMax)) - 1) * HalfExtent.Y,
				Point.Z + (((i & EBA_ZMax) << 1) - 1) * HalfExtent.Z);
			Children[i].Extent = HalfExtent;
			Children[i].Depth = Depth - 1;
		}
	}

	void AddInternal(AXRainRestrictionVolume* V)
	{
		if (!Children && Volume.Num() >= 4 && Depth > 0)
		{
			InitChildren();

			TArray<AXRainRestrictionVolume*> TempArray(0);
			ExchangeArray(TempArray, Volume);

			for (INT i = 0; i < TempArray.Num(); ++i)
				AddVolume(TempArray(i));
			AddVolume(V);
		}
		else Volume.AddItem(V);
	}
};
struct FRainAreaTree
{
	AXWeatherEmitter* Emitter;
	FRainNode* MainNode;
	FVector RainAreaMin, RainAreaMax;

	FRainAreaTree(AXWeatherEmitter* W)
		: Emitter(W), MainNode(NULL)
	{
		FLOAT fMin = Min(Min(W->Position.X.Min, W->Position.Y.Min), W->Position.Z.Min);
		FLOAT fMax = Max(Max(W->Position.X.Max, W->Position.Y.Max), W->Position.Z.Max);
		RainAreaMin = FVector(fMin, fMin, fMin);
		RainAreaMax = FVector(fMax, fMax, fMax);

		W->NoRainBounds.RemoveItem(NULL);
		if (!W->NoRainBounds.Num())
			return;

		// Start splitting from middle of our bounds.
		const FVector& MinP = W->VecArea[0];
		const FVector& MaxP = W->VecArea[1];
		FVector Ext((MaxP - MinP) * 0.5f);
		FVector Pos(Ext + MinP);

		for (INT i = 0; i < W->NoRainBounds.Num(); ++i)
		{
			AXRainRestrictionVolume* R = W->NoRainBounds(i);
			if (R->bDeleteMe)
				continue;
			if (R->bBoundsDirty)
				R->UpdateBounds();

			// Verify it fits within our bounding box.
			if (!AABBOverlaps(MinP, MaxP, R->RainBounds.Min, R->RainBounds.Max))
				continue;

			if (!MainNode)
				MainNode = new FRainNode(Pos, Ext, appFloor(Ext.Size() / 128.f));
			MainNode->AddVolume(R);
		}
		//if (MainNode)
		//	MainNode->DrawDebug();
	}
	~FRainAreaTree()
	{
		if (MainNode)
			delete MainNode;
	}
	inline UBOOL IsBlocked(const FVector& Point) const
	{
		return MainNode ? MainNode->IsBlocked(Point) : FALSE;
	}
	inline UBOOL RainVisible( const FVector& CamPos ) const
	{
		return AABBOverlaps(Emitter->VecArea[0], Emitter->VecArea[1], CamPos + RainAreaMin, CamPos + RainAreaMax);
	}
};

void AXWeatherEmitter::InitView()
{
	guardSlow(AXWeatherEmitter::InitView);
	bFilterByVolume = ((AppearAreaType != EWA_Zone) && !GIsEditor && PartStyle!=STY_AlphaBlend);
	if( bFilterByVolume )
		Style = PartStyle;
	unguardSlow;
}
bool AXWeatherEmitter::ShouldUpdateEmitter( UEmitterRendering* Sender )
{
	return (bIsEnabled && (GIsEditor || bUseAreaSpawns
		|| (XLevel->TimeSeconds - XLevel->Model->Zones[Region.ZoneNumber].LastRenderTime).GetFloat()<1) );
}

static void RecurseBSP(UModel* M, INT iNode, INT iZone, FBox& Result)
{
	while (iNode != INDEX_NONE)
	{
		const FBspNode& Node = M->Nodes(iNode);

		if (Node.NumVertices && (Node.iZone[0] == iZone || Node.iZone[1] == iZone))
		{
			FVert* GW = &M->Verts(Node.iVertPool);
			for (INT j = 0; j < Node.NumVertices; ++j)
				Result += M->Points(GW[j].pVertex);
		}
		if (Node.iFront != INDEX_NONE)
			RecurseBSP(M, Node.iFront, iZone, Result);
		if (Node.iBack != INDEX_NONE)
			RecurseBSP(M, Node.iBack, iZone, Result);
		iNode = Node.iPlane;
	}
}
inline void InitSpawnArea(AXWeatherEmitter* W)
{
	W->bUseAreaSpawns = (W->AppearAreaType != EWA_Zone);
	if (GIsEditor)
		W->RainVolume = NULL;

	if (W->AppearAreaType == EWA_Box)
	{
		W->VecArea[0] = FVector(W->AppearArea.X.Min, W->AppearArea.Y.Min, W->AppearArea.Z.Min) + W->Location;
		W->VecArea[1] = FVector(W->AppearArea.X.Max, W->AppearArea.Y.Max, W->AppearArea.Z.Max) + W->Location;
	}
	else if (W->AppearAreaType == EWA_Brush)
	{
		if (GIsEditor)
		{
			if (W->RainVolumeTag != NAME_None)
			{
				TTransArray<AActor*>& AR = W->XLevel->Actors;
				AActor* A;
				for (INT i = 0; i < AR.Num(); ++i)
				{
					A = AR(i);
					if (A && A->Tag == W->RainVolumeTag && !A->bDeleteMe && A->IsA(AVolume::StaticClass()) && A->Brush)
					{
						W->RainVolume = (AVolume*)A;
						break;
					}
				}
			}
		}
		if (W->RainVolume && W->RainVolume->Brush)
		{
			FBox B = W->RainVolume->Brush->GetCollisionBoundingBox(W);
			W->VecArea[0] = B.Min;
			W->VecArea[1] = B.Max;
		}
	}
	else if (W->AppearAreaType == EWA_Zone)
	{
		UModel* M = W->XLevel->Model;
		INT iZone = W->Region.ZoneNumber;
		if (iZone != 0)
		{
			if (M->RootOutside && (iZone == 1)) // Additive map
			{
				// All world space.
				W->VecArea[0] = GMath.WorldMin;
				W->VecArea[1] = GMath.WorldMax;
			}
			else
			{
				FBox Result(0);
				RecurseBSP(M, 0, iZone, Result);
				W->VecArea[0] = Result.Min;
				W->VecArea[1] = Result.Max;
			}
		}
	}

	W->bBoundsDirty = TRUE;
	W->SpawnInterval = W->Lifetime.Max / W->ParticleCount;
	W->bParticleColorEnabled = (W->ParticlesColor.X.Min || W->ParticlesColor.X.Max
		|| W->ParticlesColor.Y.Min || W->ParticlesColor.Y.Max
		|| W->ParticlesColor.Z.Min || W->ParticlesColor.Z.Max);
}
void AXWeatherEmitter::InitializeEmitter(UEmitterRendering* Render, AXParticleEmitter* EmitterOuter)
{
	guard(AXWeatherEmitter::InitializeEmitter);
	Render->ChangeParticleCount(ParticleCount); // Allocate the emitter on startup.
	NextParticleTime = 0.1;
	LastCamPosition = Render->Frame->Coords.Origin;
	InitSpawnArea(this);
	if (!GIsEditor)
	{
		PartTextures.RemoveItem(NULL);
		PartTextures.Shrink();
	}

	AActor* A;
	for( INT j=0; j<ParticleCount; j++ )
	{
		A = Render->PartPtr->GetA(j);
		if( WeatherType==EWF_Rain )
		{
			A->Mesh = SheetModel;
			A->DrawType = DT_Mesh;
			A->bTextureAnimOnce = TRUE;
		}
		else A->DrawType = DT_SpriteAnimOnce;
		A->Style = PartStyle;
		A->LightType = LT_None;
		if (PartTextures.Num())
			A->Skin = PartTextures(GetRandomVal(PartTextures.Num()));
		else A->Skin = NULL;
		if (GIsEditor && !A->Skin)
			A->Skin = AActor::StaticClass()->GetDefaultActor()->Texture;
		A->Texture = A->Skin;
		A->DrawScale = Size.GetValue();
	}
	unguard;
}
void AXWeatherEmitter::PostLoad()
{
	guard(AXWeatherEmitter::PostLoad);
	Super::PostLoad();
	for (INT i = 0; i < NoRainBounds.Num(); ++i)
	{
		AXRainRestrictionVolume* V = NoRainBounds(i);
		if (!V || V->bDeleteMe)
			NoRainBounds.Remove(i--);
		else V->Emitters.AddUniqueItem(this);
	}
	unguard;
}
void AXWeatherEmitter::PostScriptDestroyed()
{
	guard(AXWeatherEmitter::PostScriptDestroyed);
	Super::PostScriptDestroyed();
	for (INT i = 0; i < NoRainBounds.Num(); ++i)
		NoRainBounds(i)->Emitters.RemoveItem(this);
	unguard;
}
void AXWeatherEmitter::UpdateEmitter( const float DeltaTime, UEmitterRendering* Sender )
{
	guardSlow (AXWeatherEmitter::UpdateEmitter);
	if (!RainTree || bBoundsDirty)
	{
		if (RainTree)
			delete RainTree;
		RainTree = new FRainAreaTree(this);
		bBoundsDirty = FALSE;
	}

	const FVector& CamPos = UEmitterRendering::CamPos.Origin;
	FVector CamDelta = (CamPos-LastCamPosition)*10.f+CamPos;
	NextParticleTime-=DeltaTime;
	BYTE LCount=0;
	BYTE PCount=0;
	while( NextParticleTime<=0 && (LCount++)<200 )
	{
		PCount++;
		NextParticleTime+=SpawnInterval;
	}
	if (PCount && RainTree->RainVisible(CamDelta))
	{
		FRotator Rt = FCoords(FVector(0,0,0),Sender->Frame->Coords.ZAxis,Sender->Frame->Coords.XAxis,-Sender->Frame->Coords.YAxis).OrthoRotation();
		Rt.Pitch = 0;
		Rt.Roll = 0;
		TransfrmCoords = (GMath.UnitCoords * Rt);
		NextParticleTime = Max<FLOAT>(NextParticleTime,0.f);
		while( PCount>0 )
		{
			SpawnParticle(Sender,CamDelta);
			PCount--;
		}
	}
	LastCamPosition = CamPos;

	BEGIN_PARTICLE_ITERATOR
		// Particle died
		if( (D.LiftTime-=DeltaTime)<=0 )
		{
			D.DestroyParticle();
			continue;
		}

		// Update location
		float Sc=(1.f-D.LiftTime*D.LiftStartTime);
		if( A->bMovable )
		{
			switch( WeatherType )
			{
			case EWF_Snow:
				if( D.Scale<=0 )
				{
					A->Velocity = D.RevSp+VRand()*(D.RevSp.Size()/5);
					D.Scale+=appFrand()*0.5+0.1;
				}
				else D.Scale-=DeltaTime;
				break;
			case EWF_Dust:
				A->Velocity*=(1.f-DeltaTime*2.f);
				break;
			}
			D.Pos+=A->Velocity*DeltaTime;
			if (WallHitEvent || WallHitEmitters.Num())
			{
				if( WallHitEvent==HIT_Destroy || WallHitEvent==HIT_StopMovement )
				{
					if (WallHitEmitters.Num())
					{
						FCheckResult Hit;
						if (!XLevel->SingleLineCheck(Hit, this, D.Pos, A->Location, TRACE_VisBlocking | TRACE_SingleResult))
						{
							if (WallHitEmitters.Num() && WallHitMinZ < Hit.Normal.Z)
								SpawnChildPart(Hit.Location + Hit.Normal, WallHitEmitters);
							if (WallHitEvent == HIT_Destroy)
							{
								D.DestroyParticle();
								continue;
							}
							else
							{
								A->bMovable = 0;
								D.Pos = Hit.Location + Hit.Normal;
							}
						}
					}
					else if (!XLevel->FastLineCheck(A->Location, D.Pos, TRACE_VisBlocking, this))
					{
						if( WallHitEvent==HIT_Destroy )
						{
							D.DestroyParticle();
							continue;
						}
						else
						{
							A->bMovable = 0;
							D.Pos-=(A->Velocity*DeltaTime*0.5f);
						}
					}
				}
				else
				{
					FCheckResult Hit;
					if (!XLevel->SingleLineCheck(Hit, this, D.Pos, A->Location, TRACE_VisBlocking | TRACE_SingleResult))
					{
						if( WallHitEmitters.Num() && WallHitMinZ<Hit.Normal.Z )
							SpawnChildPart(Hit.Location+Hit.Normal,WallHitEmitters);
						if( WallHitEvent==HIT_Bounce )
						{
							D.Pos = Hit.Location+Hit.Normal;
							A->Velocity = A->Velocity.MirrorByVector(Hit.Normal);
						}
						else
						{
							D.Pos = Hit.Location;
							eventParticleWallHit(A,Hit.Normal,D.Pos);
							if( A->bHidden )
								continue;
						}
					}
				}
			}

			A->Location = D.Pos;
			if( WeatherType==EWF_Rain )
				A->Rotation = GetFaceRotation(A->Location,LastCamPosition,A->Velocity.SafeNormal());

			FPointRegion Reg = XLevel->Model->PointRegion(Level,D.Pos);
			if( Reg.iLeaf==-1 || !Reg.Zone ) // Fell out of world, kill it.
			{
				D.DestroyParticle();
				continue;
			}
			if( WaterHitEvent && Reg.Zone!=Region.Zone && Reg.Zone!=A->Region.Zone )
			{
				if( WaterHitEmitters.Num() && Reg.Zone->bWaterZone )
					SpawnChildPart(A->Location-A->Velocity*DeltaTime,WaterHitEmitters);
				switch( WaterHitEvent )
				{
				case HIT_Destroy:
					if( Reg.Zone->bWaterZone )
						D.DestroyParticle();
					break;
				case HIT_StopMovement:
					if( Reg.Zone->bWaterZone )
						A->bMovable = 0;
					break;
				case HIT_Bounce:
					if( Reg.Zone->bWaterZone )
					{
						A->Velocity.Z*=-1;
						A->Location.Z+=A->Velocity.Z*DeltaTime;
						D.Pos = A->Location;
					}
					break;
				default:
					eventParticleZoneHit(A,Reg.Zone);
				}
				if( A->bHidden )
					continue;
				A->Region.Zone = Reg.Zone;
			}
		}

		// Update scale glowing
		if( Sc<0.4 )
			Sc/=0.4;
		else if( Sc<0.6 )
			Sc = 1;
		else Sc = 1.f-(Sc-0.6)/0.4;
		if( FadeOutDistance.Max>0 )
		{
			FLOAT Dis=(LastCamPosition-D.Pos).SizeSquared();
			if( Dis>=Square(FadeOutDistance.Max) )
				Sc = 0.f;
			else if( Dis>Square(FadeOutDistance.Min) )
			{
				FLOAT fD = FadeOutDistance.Max - FadeOutDistance.Min;
				Sc *= Clamp<FLOAT>((fD - (appSqrt(Dis) - FadeOutDistance.Min)) / fD, 0.f, 1.f);
			}
		}
		A->ScaleGlow = Clamp(float(Sc*ScaleGlow),0.f,1.f);
	END_PARTICLE_ITERATOR

	unguardSlow;
}

BYTE AXWeatherEmitter::SpawnParticle( UEmitterRendering* Render, const FVector &CDelta )
{
	guard(AXWeatherEmitter::SpawnParticle);

	if (!RainTree || bBoundsDirty)
	{
		if (RainTree)
			delete RainTree;
		RainTree = new FRainAreaTree(this);
		bBoundsDirty = FALSE;
	}

	int Act=-1;
	AActor* A=NULL;
	// Check if free particles
	int i;
	for( i=0; i<ActiveCount; i++ )
	{
		A = Render->PartPtr->GetA(i);
		if( A->bHidden )
		{
			Act = i;
			break;
		}
	}
	if( Act==-1 )
	{
		if( ActiveCount>=Render->PartPtr->Len() )
			return 0;
		else
		{
			Act = ActiveCount++;
			A = Render->PartPtr->GetA(Act);
		}
	}
	if( !A || !A->Texture )
		return 0;

	FVector SpP = Position.GetValue().TransformVectorBy(TransfrmCoords)+CDelta;
	// Validate spawn area.
	if( bUseAreaSpawns )
	{
		if (SpP.X<VecArea[0].X || SpP.Y<VecArea[0].Y || SpP.Z<VecArea[0].Z
			|| SpP.X>VecArea[1].X || SpP.Y>VecArea[1].Y || SpP.Z>VecArea[1].Z
			|| (RainVolume && !RainVolume->Encompasses(SpP)))
			return 0;
	}
	else
	{
		if( !XLevel || !XLevel->Model )
			return 0;
		FPointRegion RG=XLevel->Model->PointRegion(Level,SpP);
		if( RG.Zone!=Region.Zone || RG.iLeaf==-1 || RG.ZoneNumber!=Region.ZoneNumber )
			return 0;
	}

	// Check with the volumes
	if (RainTree->IsBlocked(SpP))
		return FALSE;

	PartsType& D = Render->PartPtr->Get(Act);
	A->bHidden = 0;
	A->Location = SpP;
	A->bMovable = 1;
	A->Region = Render->Frame->Viewport->Actor->CameraRegion;
	if (A->LightDataPtr)
		A->LightDataPtr->UpdateFrame = GFrameNumber - 500; // Force to recompute lighting rather then fade from previous particle.
	D.Pos = SpP;
	A->Velocity = Rotation.Vector() * speed.GetValue();
	if( bUSModifyParticles )
	{
		eventGetParticleProps(A,D.Pos,A->Velocity,A->Rotation);
		A->Location = D.Pos;
	}
	D.RevSp = A->Velocity;
	D.LiftTime = Lifetime.GetValue();
	D.LiftStartTime = 1.f/D.LiftTime;
	if( bParticleColorEnabled )
	{
		FVector Col = ParticlesColor.GetValue();
		A->ActorRenderColor = FColor(BYTE(Col.X*255.f),BYTE(Col.Y*255.f),BYTE(Col.Z*255.f),255);
		A->ActorGUnlitColor = A->ActorRenderColor;
	}
	A->bUnlit = bUnlit;
#if ENGINE_SUBVERSION>8
	A->bUseLitSprite = bUseLitSprite;
#endif
	if( bUSNotifyParticles )
		eventNotifyNewParticle(A);
	return 1;
	unguard;
}

void AXWeatherEmitter::ResetEmitter()
{
	guard(AXEmitter::ResetEmitter);
	AXParticleEmitter::ResetEmitter();
	UEmitterRendering* Render = (UEmitterRendering*)RenderInterface;
	if( Render )
	{
		Render->ChangeParticleCount(ParticleCount);
		Render->HideAllParticles();
		LastCamPosition = UEmitterRendering::CamPos.Origin;
		AActor* A;
		for( INT j=0; j<ParticleCount; j++ )
		{
			A = Render->PartPtr->GetA(j);
			if( WeatherType==EWF_Rain )
			{
				A->Mesh = SheetModel;
				A->DrawType = DT_Mesh;
				A->bUnlit = 1;
			}
			else A->DrawType = DT_SpriteAnimOnce;
			A->Style = PartStyle;
			A->LightType = LT_None;
			if (PartTextures.Num())
				A->Skin = PartTextures(GetRandomVal(PartTextures.Num()));
			else A->Skin = NULL;
			if (!A->Skin)
				A->Skin = Level->DefaultTexture;
			A->Texture = A->Skin;
			A->DrawScale = Size.GetValue();
		}
	}

	NextParticleTime = 0.1;
	InitSpawnArea(this);

	unguard;
}
void AXWeatherEmitter::Modify()
{
	Super::Modify();

	if( GIsEditor )
	{
		WallHitEmitters.Empty();
		WaterHitEmitters.Empty();

		if( WallHitEmitter!=NAME_None || WaterHitEmitter!=NAME_None )
		{
			for( TObjectIterator<AXEmitter> It; It; ++It )
			{
				AXEmitter* X = *It;
				if( X->bDeleteMe )
					continue;
				if( WallHitEmitter!=NAME_None && WallHitEmitter==X->Tag )
					WallHitEmitters.AddItem(X);
				if( WaterHitEmitter!=NAME_None && WaterHitEmitter==X->Tag )
					WaterHitEmitters.AddItem(X);
			}
		}
	}
}
void AXWeatherEmitter::RenderSelectInfo(FSceneNode* Frame)
{
	Super::RenderSelectInfo(Frame);
	if (AppearAreaType == EWA_Box)
		Frame->Level->Engine->Render->DrawBox(Frame, FPlane(1, 1, 0.5f, 1), 0, VecArea[0], VecArea[1]);
	if (RainVolume)
		Frame->Viewport->RenDev->Draw3DLine(Frame, FPlane(0.25f, 1, 0, 1), 0, Location, RainVolume->Location);
	for (INT i = 0; i < NoRainBounds.Num(); ++i)
		if (NoRainBounds(i))
			Frame->Viewport->RenDev->Draw3DLine(Frame, FPlane(0, 1, 0, 1), 0, Location, NoRainBounds(i)->Location);
}
FBox AXWeatherEmitter::GetVisibilityBox()
{
	guardSlow(AXWeatherEmitter::GetVisibilityBox);
	if (bUseAreaSpawns)
		return FBox(VecArea[0], VecArea[1]);
	else if ((Level->TimeSeconds - XLevel->Model->Zones[Region.ZoneNumber].LastRenderTime) < 1.f)
		return FBox(FVector(-65536.f, -65536.f, -65536.f), FVector(65536.f, 65536.f, 65536.f)); // Cover the entire world.
	else return FBox(Location, Location);
	unguardSlow;
}

void AXWeatherEmitter::PostEditMove()
{
	guard(AXWeatherEmitter::PostEditMove);
	Super::PostEditMove();
	InitSpawnArea(this);
	unguard;
}

void AXWeatherEmitter::Destroy()
{
	guard(AXWeatherEmitter::Destroy);
	if (RainTree)
	{
		delete RainTree;
		RainTree = NULL;
	}
	Super::Destroy();
	unguard;
}

// Rain restriction volumes
IMPLEMENT_CLASS(AXRainRestrictionVolume);

inline bool AXRainRestrictionVolume::PointIsInside( FVector Point )
{
	if (Brush)
		return Brush->PointCheckFast(Point, this);
	Point-=Location;
	if( bDirectional )
		Point = Point.TransformVectorBy(GMath.UnitCoords/Rotation);
	return (Point.X>BoundsMin.X && Point.Y>BoundsMin.Y && Point.Z>BoundsMin.Z
		&& Point.X<BoundsMax.X && Point.Y<BoundsMax.Y && Point.Z<BoundsMax.Z);
}
void AXRainRestrictionVolume::RenderSelectInfo( FSceneNode* Frame )
{
	Super::RenderSelectInfo(Frame);
	if (bBoundsDirty)
		UpdateBounds();

	if (Brush || bDirectional)
		Frame->Level->Engine->Render->DrawBox(Frame, FPlane(0.85f, 0.f, 0.f, 1.f), 0, RainBounds.Min, RainBounds.Max);

	if (Brush)
		return;
	const FPlane LineColors(0.25,0.8,0.25,1);
	if( bDirectional )
	{
		URenderDevice* R = Frame->Viewport->RenDev;
		FVector Points[8]={BoundsMin,FVector(BoundsMax.X,BoundsMin.Y,BoundsMin.Z)
						,FVector(BoundsMin.X,BoundsMax.Y,BoundsMin.Z)
						,FVector(BoundsMin.X,BoundsMin.Y,BoundsMax.Z)
						,FVector(BoundsMin.X,BoundsMax.Y,BoundsMax.Z)
						,FVector(BoundsMax.X,BoundsMin.Y,BoundsMax.Z)
						,FVector(BoundsMax.X,BoundsMax.Y,BoundsMin.Z),BoundsMax};

		FCoords RelC = GMath.UnitCoords * Location * Rotation;
		for( BYTE i=0; i<8; i++ )
			Points[i] = Points[i].TransformPointBy(RelC);

		R->Draw3DLine(Frame,LineColors,0,Points[0],Points[1]);
		R->Draw3DLine(Frame,LineColors,0,Points[0],Points[2]);
		R->Draw3DLine(Frame,LineColors,0,Points[0],Points[3]);
		R->Draw3DLine(Frame,LineColors,0,Points[1],Points[6]);
		R->Draw3DLine(Frame,LineColors,0,Points[1],Points[5]);
		R->Draw3DLine(Frame,LineColors,0,Points[2],Points[6]);
		R->Draw3DLine(Frame,LineColors,0,Points[2],Points[4]);
		R->Draw3DLine(Frame,LineColors,0,Points[3],Points[5]);
		R->Draw3DLine(Frame,LineColors,0,Points[3],Points[4]);
		R->Draw3DLine(Frame,LineColors,0,Points[4],Points[7]);
		R->Draw3DLine(Frame,LineColors,0,Points[5],Points[7]);
		R->Draw3DLine(Frame,LineColors,0,Points[6],Points[7]);
	}
	else Frame->Level->Engine->Render->DrawBox(Frame,LineColors,0,BoundsMin+Location,BoundsMax+Location);
}
void AXRainRestrictionVolume::Modify()
{
	guardSlow(AXRainRestrictionVolume::Modify);
	Super::Modify();
	bBoundsDirty = TRUE;
	if( !GIsEditor )
		return;
	TTransArray<AActor*>& AR = XLevel->Actors;
	for( INT i=0; i<AR.Num(); ++i )
	{
		AXWeatherEmitter* W = Cast<AXWeatherEmitter>(AR(i));
		if( !W || W->bDeleteMe )
			continue;
		if (Tag == NAME_None || W->Tag == Tag)
		{
			Emitters.AddUniqueItem(W);
			W->NoRainBounds.AddItem(this);
		}
		else
		{
			Emitters.RemoveItem(W);
			W->NoRainBounds.RemoveItem(this);
		}
	}
	unguardSlow;
}
void AXRainRestrictionVolume::PostScriptDestroyed()
{
	guard(AXRainRestrictionVolume::PostScriptDestroyed);
	for (INT i = 0; i < Emitters.Num(); ++i)
	{
		Emitters(i)->NoRainBounds.RemoveItem(this);
		Emitters(i)->bBoundsDirty = TRUE;
	}
	Super::PostScriptDestroyed();
	unguard;
}
void AXRainRestrictionVolume::NotifyActorMoved()
{
	guardSlow(AXRainRestrictionVolume::NotifyActorMoved);
	bBoundsDirty = TRUE;
	unguardSlow;
}
void AXRainRestrictionVolume::PostEditMove()
{
	guardSlow(AXRainRestrictionVolume::PostEditMove);
	Super::PostEditMove();
	bBoundsDirty = TRUE;
	unguardSlow;
}
void AXRainRestrictionVolume::UpdateBounds()
{
	guard(AXRainRestrictionVolume::UpdateBounds);
	if (Brush)
		RainBounds = Brush->GetCollisionBoundingBox(this);
	else
	{
		RainBounds = FBox(BoundsMin, BoundsMax);
		if (bDirectional)
			RainBounds.TransformBy(GMath.UnitCoords * Rotation);
		RainBounds.Min += Location;
		RainBounds.Max += Location;
	}
	for (INT i = 0; i < Emitters.Num(); ++i)
		Emitters(i)->bBoundsDirty = TRUE;
	bBoundsDirty = FALSE;
	unguard;
}
UBOOL AXRainRestrictionVolume::Tick(FLOAT DeltaTime, ELevelTick TickType)
{
	guardSlow(AXRainRestrictionVolume::Tick);
	if (bBoundsDirty)
		UpdateBounds();
	return Super::Tick(DeltaTime, TickType);
	unguardSlow;
}
void AXRainRestrictionVolume::PostLoad()
{
	guardSlow(AXRainRestrictionVolume::PostLoad);
	Super::PostLoad();
	bBoundsDirty = TRUE;
	unguardSlow;
}

void AXWeatherEmitter::execAddNoRainBounds(FFrame& Stack, RESULT_DECL)
{
	guard(AXWeatherEmitter::execAddNoRainBounds);
	P_GET_OBJECT(AXRainRestrictionVolume, NewVolume);
	P_FINISH;

	if (!NewVolume || NewVolume->bDeleteMe)
		return;
	if (NoRainBounds.FindItemIndex(NewVolume) == INDEX_NONE)
	{
		NoRainBounds.AddItem(NewVolume);
		NewVolume->Emitters.AddUniqueItem(this);
		bBoundsDirty = TRUE;
	}
	unguardexec;
}
void AXWeatherEmitter::execRemoveNoRainBounds(FFrame& Stack, RESULT_DECL)
{
	guard(AXWeatherEmitter::execRemoveNoRainBounds);
	P_GET_OBJECT(AXRainRestrictionVolume, OldVolume);
	P_FINISH;

	if (!OldVolume)
		return;
	if (NoRainBounds.RemoveItem(OldVolume))
	{
		OldVolume->Emitters.RemoveItem(this);
		bBoundsDirty = TRUE;
	}
	unguardexec;
}
void AXWeatherEmitter::execSetRainVolume(FFrame& Stack, RESULT_DECL)
{
	guard(AXWeatherEmitter::execSetRainVolume);
	P_GET_OBJECT(AVolume, NewVolume);
	P_FINISH;

	if (RainVolume == NewVolume)
		return;

	RainVolume = NewVolume;
	if (GIsClient)
		InitSpawnArea(this);
	unguardexec;
}
