// ===========================================================================
// Project: Native Emitter
// ===========================================================================

#include "Engine.h"
#include "UnRender.h"

enum EParticleSpawnFlags
{
	PSF_None=0,
	PSF_CheckRespawn=(1<<0),
	PSF_AbsolutePosition=(1<<1),
};

class UEmitterRendering;
struct PartsType;
struct FRainAreaTree;

#include "EmitterClasses.h"

#include "UnEmitterRendering.h"

// Local functions ===================================================

#define BEGIN_PARTICLE_ITERATOR \
{ \
	AActor* A; \
	for( INT ip=0; (ip<ActiveCount && !bDeleteMe); ip++ ) { \
		A = Sender->PartPtr->GetA(ip); \
		if( A->bHidden ) continue; \
		PartsType& D = Sender->PartPtr->Get(ip);
#define END_PARTICLE_ITERATOR }}

#define GetRandomVal(MaxVal) (MaxVal==1 ? 0 : (appRand() % MaxVal))
#define InvertedCoords FCoords(FVector(0,0,0),FVector(-1,0,0),FVector(0,-1,0),FVector(0,0,-1))

template< class T > inline T GetScalerValue( const FLOAT InTime, const T& InitValue, INT Count, FLOAT* Times, T* Values, INT Stride )
{
	FLOAT* PrevTime=NULL;
	T* PrevValue=NULL;
	for( INT i=0; i<Count; i++ )
	{
		if( *Times>InTime )
		{
			if( i==0 )
			{
				FLOAT Scale = InTime/(*Times);
				return Scale*(*Values)+(1.f-Scale)*InitValue;
			}
			FLOAT Scale = (InTime-(*PrevTime))/((*Times)-(*PrevTime));
			return Scale*(*Values)+(1.f-Scale)*(*PrevValue);
		}
		PrevTime = Times;
		PrevValue = Values;
		Times = (FLOAT*)(((BYTE*)Times) + Stride);
		Values = (T*)(((BYTE*)Values) + Stride);
	}
	return (*PrevValue);
}

inline FVector GetScalerValueColor(const FLOAT InTime, FColorScaleRangeType* Values, INT Count)
{
	if (Count == 0)
		return FVector(1.f, 1.f, 1.f);
	for (INT i = 0; i < Count; i++)
	{
		if (Values[i].Time > InTime)
		{
			if (i == 0)
			{
				FLOAT Scale = InTime / Values[i].Time;
				return Scale * Values[i].ColorScaling + (1.f - Scale) * FVector(1.f, 1.f, 1.f);
			}
			FLOAT Scale = (InTime - Values[i-1].Time) / (Values[i].Time - Values[i-1].Time);
			return Scale * Values[i].ColorScaling + (1.f - Scale) * Values[i-1].ColorScaling;
		}
	}
	return Values[Count - 1].ColorScaling;
}

inline FRotator TransformForRot( const INT CurrentYaw, const FVector& MoveNormal )
{
	FCoords C(GMath.UnitCoords / FRotator(0,CurrentYaw,0));

	// translate view direction
	const FVector CrossDir = FVector(MoveNormal.Y,-MoveNormal.X,0.f).UnsafeNormal();
	const FVector FwdDir = CrossDir ^ MoveNormal;
	const FVector OldFwdDir = FVector(CrossDir.Y,-CrossDir.X,0.f);
	C.XAxis = (CrossDir * (CrossDir | C.XAxis) + FwdDir * (OldFwdDir | C.XAxis)).UnsafeNormal();
	C.ZAxis = MoveNormal;
	C.YAxis = (MoveNormal ^ C.XAxis);
	return C.OrthoRotation();
}
inline void TransformForCoords( const INT CurrentYaw, const FVector& MoveNormal, FCoords &C )
{
	C = GMath.UnitCoords / FRotator(0,CurrentYaw,0);

	// translate view direction
	const FVector CrossDir = FVector(MoveNormal.Y,-MoveNormal.X,0.f).UnsafeNormal();
	const FVector FwdDir = CrossDir ^ MoveNormal;
	const FVector OldFwdDir = FVector(CrossDir.Y,-CrossDir.X,0.f);
	C.XAxis = (CrossDir * (CrossDir | C.XAxis) + FwdDir * (OldFwdDir | C.XAxis)).UnsafeNormal();
	C.ZAxis = MoveNormal;
	C.YAxis = (MoveNormal ^ C.XAxis);
}

inline FVector GetTimeScaleValue( FLOAT InTime, FSpeed3DType* Scales, INT Num )
{
	if( !Num )
		return FVector(1,1,1);
	if( Num==1 || Scales[0].Time>InTime )
		return Scales[0].VelocityScale;
	for( INT i=1; i<Num; ++i )
	{
		if( Scales[i].Time>InTime )
		{
			FLOAT Alpha = (InTime-Scales[i-1].Time)/(Scales[i].Time-Scales[i-1].Time);
			return Scales[i].VelocityScale*Alpha+Scales[i-1].VelocityScale*(1.f-Alpha);
		}
	}
	return Scales[Num-1].VelocityScale;
}
inline FLOAT GetTimeScaleValue( FLOAT InTime, FScaleRangeType* Scales, INT Num )
{
	if( !Num )
		return 1.f;
	if( Num==1 || Scales[0].Time>InTime )
		return Scales[0].DrawScaling;
	for( INT i=1; i<Num; ++i )
	{
		if( Scales[i].Time>InTime )
		{
			FLOAT Alpha = (InTime-Scales[i-1].Time)/(Scales[i].Time-Scales[i-1].Time);
			return Scales[i].DrawScaling*Alpha+Scales[i-1].DrawScaling*(1.f-Alpha);
		}
	}
	return Scales[Num-1].DrawScaling;
}
inline FLOAT GetTimeScaleValueSingle( FLOAT InTime, FLOAT* Values, INT Num, FLOAT CalcTime )
{
	if( !Num )
		return 1.f;
	if( Num==1 )
		return Values[0];
	FLOAT NextTime;
	for( INT i=1; i<Num; ++i )
	{
		NextTime = (CalcTime*i);
		if( NextTime>InTime )
		{
			FLOAT Alpha = (NextTime-InTime)/CalcTime;
			return Values[i-1]*Alpha+Values[i]*(1.f-Alpha);
		}
	}
	return Values[Num-1];
}

inline FCoords GetFacingCoords( const FVector& UpDir )
{
	FCoords C;

	// translate view direction
	const FVector CrossDir(FVector(UpDir.Y,-UpDir.X,0.f).UnsafeNormal());
	const FVector FwdDir = CrossDir ^ UpDir;
	C.XAxis = (CrossDir*CrossDir.X + FwdDir*CrossDir.Y).UnsafeNormal();
	C.ZAxis = UpDir;
	C.YAxis = (UpDir ^ C.XAxis);
	return C;
}

inline FRotator GetFaceRotation( const FVector& Spot, const FVector& Cam, const FVector& Up )
{
	FVector DeltaDir = (Cam-Spot);

	if( Up.Z>=0.999f )
		return FRotator(0,DeltaDir.Rotation().Yaw,0);
	else if( Up.Z<=-0.999f )
		return FRotator(0,DeltaDir.Rotation().Yaw,32768);
	return TransformForRot(DeltaDir.TransformVectorBy(GetFacingCoords(Up)).Rotation().Yaw,Up);
}
inline void GetFaceCoords( const FVector& Spot, const FVector& Cam, const FVector& Up, FCoords& Result )
{
	FVector DeltaDir = (Cam-Spot);

	if( Up.Z>=0.999f )
		Result = (GMath.UnitCoords / FRotator(0,DeltaDir.Rotation().Yaw,0));
	else if( Up.Z<=-0.999f )
		Result = (GMath.UnitCoords / FRotator(0,DeltaDir.Rotation().Yaw,32768));
	else TransformForCoords(DeltaDir.TransformVectorBy(GetFacingCoords(Up)).Rotation().Yaw,Up,Result);
}

inline void AXParticleEmitter::UpdateChildren(float Delta, UEmitterRendering* Render)
{
	guardSlow(AXParticleEmitter::UpdateChildren);
	// Update combiners.
	if (bHasSpecialParts)
	{
		INT i;
		INT l = PartCombiners.Num();
		AXEmitter** PA = &PartCombiners(0);
		UEmitterRendering* R;
		for (i = 0; i < l; i++)
			if (PA[i] && !PA[i]->bHurtEntry)
			{
				PA[i]->Location = Location;
				PA[i]->Rotation = Rotation;
				R = (UEmitterRendering*)PA[i]->RenderInterface;
				R->Frame = Render->Frame;
				R->Observer = Render->Observer;
				PA[i]->bHurtEntry = TRUE;
				PA[i]->UpdateEmitter(Delta, R);
				PA[i]->bHurtEntry = FALSE;
			}
	}
	unguardSlow;
}
