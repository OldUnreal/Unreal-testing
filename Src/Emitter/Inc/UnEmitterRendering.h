/*=============================================================================
	UEmitterRendering.h.
=============================================================================*/

class FParticlesDataBase
{
protected:
	AXParticleEmitter* Owner;

public:
	FParticlesDataBase(AXParticleEmitter* E)
		: Owner(E)
	{}
	virtual ~FParticlesDataBase() noexcept(false) {}
	virtual UBOOL HasAliveParticles() const _VF_BASE_RET(FALSE);
	virtual void AddDelayedSpawn(const FVector& Pos) {}
	virtual AActor* GetRenderList(AActor* Last) _VF_BASE_RET(nullptr);
	virtual void Serialize(FArchive& Ar) {}
	virtual void HideAllParts() _VF_BASE;
	virtual void ScaleParticles(FLOAT SpeedScale, FLOAT DrawScale) {}
	virtual void SetLen(INT GoalLen) _VF_BASE;
	virtual void DrawRbDebug() {}

	inline AXParticleEmitter* GetOwner() const
	{
		return Owner;
	}
private:
	FParticlesDataBase() {}
};

struct FBeamDataType
{
	FVector* DataArray;
	_WORD SetupPoints;
	FBox Bounds;

	inline void InitForSeg( _WORD Segments )
	{
		if( !DataArray || SetupPoints!=Segments )
		{
			if( DataArray )
				delete[] DataArray;
			DataArray = new FVector[Segments];
			SetupPoints = Segments;
		}
	}
	FBeamDataType()
		: DataArray(NULL)
	{}
	~FBeamDataType()
	{
		if( DataArray )
			delete[] DataArray;
	}
};

class xParticle : public AActor
{
	friend class ParticlesDataList;

private:
	// Linked list of alive or dead particles.
	xParticle* NextParticle;

public:
	FVector Pos, RevOffs, RevSp, RotSp, StartScale3D;
	FLOAT Scale, LifeTime, LifeStartTime, NextCombinerTime;
	FCoords PRot;
	UBOOL bDoRot;
	UTexture* PartBitmap;
	FVector ActorSColor;
	FPlane CoronaColor;
	FBeamDataType* BeamData;

	inline xParticle* GetNext() const
	{
		return NextParticle;
	}

	inline void InitParticle(AXParticleEmitter* Emitter)
	{
		// Initilize the particles to have good default values.
		DrawScale3D = Emitter->DrawScale3D;
		Owner = Emitter;
		bHidden = TRUE;
		LifeSpan = 1.f;
		HitActor = Emitter->GetHitActor();
		SetClass(AEmitterRC::StaticClass());
		XLevel = Emitter->XLevel;
		AnimSequence = NAME_None;
		LODBias = 1.f;
		Texture = GetDefault<AActor>()->Texture;
		Skin = Texture;
		Region = Emitter->Region;
		for (INT j = 0; j < 8; j++)
			MultiSkins[j] = Emitter->MultiSkins[j];
	}
	inline void DestroyParticle()
	{
		guardSlow(xParticle::DestroyParticle);
		bHidden = TRUE;
		if (RbPhysicsData)
		{
			delete RbPhysicsData;
			RbPhysicsData = nullptr;
		}
		if (LatentActor && LatentActor->bAnimByOwner)
			LatentActor->bHidden = TRUE;
		LatentActor = nullptr;
		unguardSlow;
	}
	inline void CleanUpActor()
	{
		guardSlow(xParticle::CleanUpActor);
		if (BeamData)
		{
			delete BeamData;
			BeamData = NULL;
		}
		CleanupCache(1);
		if (RbPhysicsData)
		{
			delete RbPhysicsData;
			RbPhysicsData = nullptr;
		}
		unguardSlow;
	}
	inline void DrawRbDebug() const
	{
		if (RbPhysicsData)
			RbPhysicsData->DrawDebug();
	}
};

class ParticlesDataList : public FParticlesDataBase
{
	friend class xParticle;

private:
	INT DataLen;
	xParticle* Data;
	xParticle* AliveList;
	xParticle* DeadList;

public:
	TArray<FVector> DelaySpawn;
	UBOOL bAllSpawned;

	inline xParticle* GetFirstAlive() const
	{
		return AliveList;
	}
	inline xParticle* GetFirstDead() const
	{
		return DeadList;
	}

	inline void VerifyParticleLoop() const
	{
#if DO_GUARD_SLOW
		guardSlow(ParticlesDataList::VerifyParticleLoop);
		static INT LastLoop = 1;
		++LastLoop;
		for (xParticle* P = AliveList; P; P = P->NextParticle)
		{
			verifyf(P->LatentInt != LastLoop, TEXT("Infinite alive loop on %ls (%i/%i)"), Owner->GetFullName(), P->NetTag, DataLen);
			P->LatentInt = LastLoop;
		}
		for (xParticle* P = DeadList; P; P = P->NextParticle)
		{
			verifyf(P->LatentInt != LastLoop, TEXT("Infinite dead loop on %ls (%i/%i)"), Owner->GetFullName(), P->NetTag, DataLen);
			P->LatentInt = LastLoop;
		}
		unguardSlow;
#endif
	}

	inline xParticle* GetA( INT i )
	{
		return &Data[i];
	}
	UBOOL HasAliveParticles() const
	{
		guardSlow(ParticlesDataList::HasAliveParticles);
		return (!bAllSpawned || DelaySpawn.Num() || (AliveList != NULL));
		unguardSlow;
	}
	inline bool AboutToDie( INT i ) const // Return true if particle is dead or very close to dying.
	{
		return (Data[i].bHidden || Data[i].LifeTime<0.025f);
	}
	void AddDelayedSpawn(const FVector& Pos)
	{
		DelaySpawn.AddItem(Pos);
	}
	inline INT Len()
	{
		return DataLen;
	}
	void SetLen( INT GoalLen )
	{
		guard(ParticlesDataList::SetLen);
		if( Data )
		{
			for( int i=0; i<DataLen; i++ )
				Data[i].CleanUpActor(); // Make sure we allow actors to make possible cleanups.
			appFree(Data);
		}

		AliveList = nullptr;
		DeadList = nullptr;
		if (GoalLen)
		{
			Data = reinterpret_cast<xParticle*>(appMalloc(sizeof(xParticle) * GoalLen, TEXT("Emitter")));
			appMemzero(Data, sizeof(xParticle) * GoalLen);
			for (INT i = 0; i < GoalLen; ++i)
			{
				Data[i].InitParticle(Owner);
				Data[i].NetTag = i;
				Data[i].NextParticle = DeadList;
				DeadList = &Data[i];
			}
		}
		else Data = NULL;
		DataLen = GoalLen;
		unguard;
	}
	void HideAllParts()
	{
		guardSlow(ParticlesDataList::HideAllParts);
		xParticle* NP;
		for (xParticle* P = AliveList; P; P = NP)
		{
			NP = P->NextParticle;
			P->NextParticle = DeadList;
			DeadList = P;
			P->DestroyParticle();
		}
		AliveList = nullptr;
#if DO_GUARD_SLOW
		VerifyParticleLoop();
#endif
		unguardSlow;
	}

	inline xParticle* GrabDeadParticle()
	{
		guardSlow(ParticlesDataList::GrabDeadParticle);
		if (DeadList)
		{
			xParticle* Result = DeadList;
			DeadList = Result->NextParticle;
			Result->NextParticle = AliveList;
			AliveList = Result;
			return Result;
		}
		return nullptr;
		unguardSlow;
	}

	AActor* GetRenderList(AActor* Last)
	{
		guard(ParticlesDataList::GetRenderList);
		xParticle* Prev = NULL;
		xParticle* NP;
		for (xParticle* P = AliveList; P; P = NP)
		{
			NP = P->NextParticle;
			if (P->bHidden)
			{
				// Particle has died here, move to destroyed list.
				if (Prev)
					Prev->NextParticle = NP;
				else AliveList = NP;
				P->NextParticle = DeadList;
				DeadList = P;
				P->DestroyParticle();
			}
			else if (P->bAssimilated)
			{
				Prev = P;
				P->Target = Last;
				Last = P;
			}
		}
#if DO_GUARD_SLOW
		VerifyParticleLoop();
#endif
		return Last;
		unguard;
	}

	void ScaleParticles(FLOAT SpeedScale, FLOAT DrawScale)
	{
		guard(ParticlesDataList::ScaleParticles);
		for (xParticle* P = AliveList; P; P = P->NextParticle)
		{
			P->Velocity *= SpeedScale;
			P->Acceleration *= SpeedScale;
			P->DrawScale *= DrawScale;
			P->Scale *= DrawScale;
		}
		unguard;
	}

	void DrawRbDebug()
	{
		guardSlow(ParticlesDataList::DrawRbDebug);
		for (xParticle* P = AliveList; P; P = P->NextParticle)
			P->DrawRbDebug();
		unguardSlow;
	}

	// Destructor
	~ParticlesDataList() noexcept(false)
	{
		guard(ParticlesDataList::~ParticlesDataList);
		if( Data )
		{
			for( int i=0; i<DataLen; i++ )
				Data[i].CleanUpActor();
			appFree(Data);
		}
		unguard;
	}
	// Constructor
	ParticlesDataList(AXParticleEmitter* E)
		: FParticlesDataBase(E)
		, DataLen(0)
		, Data(nullptr)
		, AliveList(nullptr)
		, DeadList(nullptr)
		, bAllSpawned(TRUE)
	{
	}
};
