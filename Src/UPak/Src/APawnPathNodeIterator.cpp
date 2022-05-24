//=============================================================================
// APawnPathNodeIterator.cpp: UPak-APawnPathNodeIterator
//=============================================================================

#include "UPak.h"
IMPLEMENT_CLASS(APawnPathNodeIterator);

void APawnPathNodeIterator::BuildPath( FVector Start, FVector End )
{
	if( !Pawn || Pawn->bDeleteMe )
	{
		Super::BuildPath(Start,End);
		return;
	}
	FVector RealPos = Pawn->Location;

	// Adjust offset.
	if( XLevel->FarMoveActor(Pawn,Start,1) )
		Start = Pawn->Location;
	FCheckResult Hit;
	if( !XLevel->SingleLineCheck(Hit,Pawn,End-FVector(0,0,Pawn->CollisionHeight),End,TRACE_VisBlocking,FVector(Pawn->CollisionRadius,Pawn->CollisionRadius,1)) )
		End.Z = Hit.Location.Z+Pawn->CollisionHeight;
	if( XLevel->FarMoveActor(Pawn,End,1) )
		End = Pawn->Location;

	ANavigationPoint *StartAnchor=NULL,*EndAnchor=NULL;
	INT BestStartDist=1000000,BestEndDist=1000000;
	for( ANavigationPoint* N=Level->NavigationPointList; N; N=N->nextNavigationPoint )
	{
		N->taken = 0;
		N->nextOrdered = NULL;
		N->prevOrdered = NULL;
		N->previousPath = NULL;
		N->visitedWeight = 100000000;
		N->bEndPoint = 0;
		N->cost = 0;

		INT Dist = appFloor((N->Location-Start).SizeSquared());
		if( BestStartDist>Dist && XLevel->FastLineCheck(Start,N->Location,TRACE_VisBlocking,N) && XLevel->FarMoveActor(Pawn,Start,1,1)
			&& Pawn->actorReachable(N,1) )
		{
			StartAnchor = N;
			BestStartDist = Dist;
		}
		Dist = appFloor((N->Location-End).SizeSquared());
		if( BestEndDist>Dist && XLevel->FastLineCheck(End,N->Location,TRACE_VisBlocking,N) && XLevel->FarMoveActor(Pawn,N->Location,1,0)
			&& Pawn->pointReachable(End,1) )
		{
			N->bEndPoint = 1;
			EndAnchor = N;
			BestEndDist = Dist;
		}
	}

	if( !StartAnchor || !EndAnchor )
	{
		XLevel->FarMoveActor(Pawn,RealPos,1,1);
		return;
	}
	ANavigationPoint* Result = breathPathTo(StartAnchor,Pawn);
	XLevel->FarMoveActor(Pawn,RealPos,1,1);
	if( Result )
	{
		// Find shortest path.
		for( ANavigationPoint* N=StartAnchor->nextOrdered; N; N=N->nextOrdered )
		{
			if( !Pawn->actorReachable(N) )
				break;
			N->previousPath = NULL;
		}
		BuildPathCache(Result);
	}
}

bool APawnPathNodeIterator::IsPathValid( FVector Start, FVector End, bool FullCheck )
{
	guard(IsPathValid::PawnPathNodeIterator);

	return 0;
	unguard;
}

bool APawnPathNodeIterator::IsPathValid( ANavigationPoint* Start, FVector End, bool FullCheck )
{
	guard(IsPathValid::PawnPathNodeIterator);

	return 0;
	unguard;
}

bool APawnPathNodeIterator::IsPathValid( FVector Start, ANavigationPoint* End, bool FullCheck )
{
	guard(IsPathValid::PawnPathNodeIterator);

	return 0;
	unguard;
}

bool APawnPathNodeIterator::IsPathValid( FReachSpec* ReachSpec )
{
	guard(IsPathValid::PawnPathNodeIterator);

	return 0;
	unguard;
}

bool APawnPathNodeIterator::IsPathHeightValid( FVector Start, FVector End )
{
	guard(IsPathValid::PawnPathNodeIterator);

	return 0;
	unguard;
}

void APawnPathNodeIterator::execSetPawn( FFrame& Stack, RESULT_DECL )
{
	guardSlow(APawnPathNodeIterator::execSetPawn);
	P_GET_OBJECT(APawn,P);
	P_FINISH;

	Pawn = P;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( APawnPathNodeIterator, INDEX_NONE, execSetPawn );

