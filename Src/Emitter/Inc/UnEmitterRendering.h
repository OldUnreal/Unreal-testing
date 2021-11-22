/*=============================================================================
	UEmitterRendering.h.
=============================================================================*/
#define MAX_DELTA_TIME 0.2f

struct FBeamDataType
{
	FVector* DataArray;
	_WORD SetupPoints;

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
struct PartsType : public FActorBuffer
{
public:
	FVector Pos,RevOffs,RevSp,RotSp,StartScale3D;
	FLOAT Scale,LiftTime,LiftStartTime,NextCombinerTime;
	FCoords PRot;
	UBOOL bDoRot;
	UTexture* PartBitmap;
	FVector ActorSColor;
	FPlane CoronaColor;
	FLOAT CoronaCScale;
	FBeamDataType* BeamData;

	inline void DestroyParticle()
	{
		AActor* A = Actor();
		A->bHidden = TRUE;
		if (A->RbPhysicsData)
		{
			delete A->RbPhysicsData;
			A->RbPhysicsData = nullptr;
		}
	}
	inline void CleanUpActor()
	{
		if( BeamData )
		{
			delete BeamData;
			BeamData = NULL;
		}
		AActor* A = Actor();
		A->CleanupCache(1);
		if (A->RbPhysicsData)
		{
			delete A->RbPhysicsData;
			A->RbPhysicsData = nullptr;
		}
	}
};

class ParticlesDataList
{
private:
	INT DataLen;
	PartsType* Data;
public:
	TArray<FVector> DelaySpawn;
	bool bHadDelaySpawn;
	inline PartsType& Get( INT i )
	{
		return Data[i];
	}
	inline AActor* GetA( INT i )
	{
		return Data[i].Actor();
	}
	inline bool AboutToDie( INT i ) const // Return true if particle is dead or very close to dying.
	{
		return (Data[i].Actor()->bHidden || Data[i].LiftTime<0.025f);
	}
	inline INT Len()
	{
		return DataLen;
	}
	void SetLen( INT GoalLen )
	{
		if( Data )
		{
			for( int i=0; i<DataLen; i++ )
				Data[i].CleanUpActor(); // Make sure we allow actors to make possible cleanups.
			delete[] Data;
		}
		if( GoalLen )
			Data = new PartsType[GoalLen];
		else Data = NULL;
		if( Data )
		{
			appMemzero(Data,sizeof(PartsType)*GoalLen);
			DataLen = GoalLen;
		}
		else DataLen = 0;
	}
	void HideAllParts()
	{
		for( INT i=0; i<DataLen; i++ )
			Data[i].DestroyParticle();
	}

	// Destructor
	~ParticlesDataList()
	{
		if( Data )
		{
			for( int i=0; i<DataLen; i++ )
				Data[i].CleanUpActor();
			delete[] Data;
			Data = NULL;
		}
		DataLen = 0;
		DelaySpawn.Empty();
	}
	// Constructor
	ParticlesDataList()
		: DataLen( 0 )
		, Data( NULL )
		, bHadDelaySpawn( 0 )
	{
	}
};
