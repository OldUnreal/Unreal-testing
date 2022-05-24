//=============================================================================
// APathNodeIterator.cpp: UPak-APathNodeIterator
//=============================================================================

#include "UPak.h"
IMPLEMENT_CLASS(APathNodeIterator);

void APathNodeIterator::BuildPath( FVector Start, FVector End )
{
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
		if( BestStartDist>Dist && XLevel->FastLineCheck(Start,N->Location,TRACE_VisBlocking,N) )
		{
			StartAnchor = N;
			BestStartDist = Dist;
		}
		Dist = appFloor((N->Location-End).SizeSquared());
		if( BestEndDist>Dist && XLevel->FastLineCheck(End,N->Location,TRACE_VisBlocking,N) )
		{
			EndAnchor = N;
			BestEndDist = Dist;
		}
	}
	if( !StartAnchor || !EndAnchor )
		return;
	EndAnchor->bEndPoint = 1;
	ANavigationPoint* Result = breathPathTo(StartAnchor,NULL);
	if( Result )
		BuildPathCache(Result);
}

bool APathNodeIterator::IsPathValid( FVector Start, FVector End, bool FullCheck )
{
	guard(APathNodeIterator::IsPathValid);

	return 0;
	unguard;
}

bool APathNodeIterator::IsPathValid( ANavigationPoint* Start, FVector End, bool FullCheck )
{
	guard(APathNodeIterator::IsPathValid);

	return 0;
	unguard;
}

bool APathNodeIterator::IsPathValid( FVector Start, ANavigationPoint* End, bool FullCheck )
{
	guard(APathNodeIterator::IsPathValid);

	return 0;
	unguard;
}

bool APathNodeIterator::IsPathValid( FReachSpec* ReachSpec )
{
	guard(APathNodeIterator::IsPathValid);

	return 0;
	unguard;
}

bool APathNodeIterator::IsPathHeightValid( FVector Start, FVector End )
{
	guard(APathNodeIterator::IsPathHeightValid);

	return 0;
	unguard;
}

int APathNodeIterator::CalcNodeCost( FReachSpec* ReachSpec )
{
	guard(APathNodeIterator::CalcNodeCost);

	return 0;
	unguard;
}

