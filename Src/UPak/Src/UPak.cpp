/*=============================================================================
	Upak.cpp: Unreal Upak support.

	Revision history:
		* Created by Smirftsch
=============================================================================*/

#include "UPak.h"

/*-----------------------------------------------------------------------------
	Unreal package implementation.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(UPak);

ANavigationPoint* APathNodeIterator::breathPathTo( ANavigationPoint* Start, APawn* Scout )
{
	guard(APathNodeIterator::breathPathTo);

	if (!bUPakBuild)
	{
		appErrorf(TEXT("Invalid system call"));
	}
	Start->visitedWeight = 0;
	ANavigationPoint* currentnode = Start;
	ANavigationPoint* nextnode = NULL;
	ANavigationPoint* LastAdd = currentnode;
	ANavigationPoint* BestDest = NULL;

	INT moveFlags = (Scout ? Scout->calcMoveFlags() : (APawn::R_WALK+APawn::R_SWIM+APawn::R_JUMP+APawn::R_SPECIAL+APawn::R_DOOR));
	INT iRadius = (Scout ? appFloor(Scout->CollisionRadius) : 8);
	INT iHeight = (Scout ? appFloor(CollisionHeight) : 8);
	FReachSpec* GReachSpecs = &XLevel->ReachSpecs(0);
	INT FinalSpec = XLevel->ReachSpecs.Num();

	while ( currentnode )
	{
		currentnode->taken = 1;
		if( currentnode->bEndPoint && (!BestDest || BestDest->visitedWeight>currentnode->visitedWeight) )
			BestDest = currentnode;
		INT nextweight = 0;

		for ( BYTE i=0; i<16; i++ )
		{
			if( currentnode->Paths[i]<0 || currentnode->Paths[i]>=FinalSpec )
				break;
			FReachSpec &spec = GReachSpecs[currentnode->Paths[i]];
			ANavigationPoint* endnode = (ANavigationPoint*)spec.End;
			if ( endnode && !endnode->taken && endnode->cost!=-1 && spec.supports(iRadius, iHeight, moveFlags) )
			{
				if( endnode->cost==0 )
				{
					if ( endnode->bSpecialCost )
					{
						INT SpecialCostValue = (Scout ? endnode->eventSpecialCost(Scout) : 0);
						if( SpecialCostValue<0 )
						{
							endnode->cost = -1;
							continue;
						}
						endnode->cost = Max(1,SpecialCostValue+endnode->ExtraCost);
					}
					else endnode->cost = Max(1,endnode->ExtraCost);
				}
				nextweight = spec.distance + endnode->cost;
				INT newVisit = nextweight + currentnode->visitedWeight;

				if ( endnode->visitedWeight > newVisit )
				{
					// found a better path to endnode
					endnode->previousPath = currentnode;
					if ( endnode->prevOrdered ) //remove from old position
					{
						endnode->prevOrdered->nextOrdered = endnode->nextOrdered;
						if (endnode->nextOrdered)
							endnode->nextOrdered->prevOrdered = endnode->prevOrdered;
						if ( (LastAdd == endnode) || (LastAdd->visitedWeight > endnode->visitedWeight) )
							LastAdd = endnode->prevOrdered;
						endnode->prevOrdered = NULL;
						endnode->nextOrdered = NULL;
					}
					endnode->visitedWeight = newVisit;

					// LastAdd is a good starting point for searching the list and inserting this node
					nextnode = LastAdd;
					if ( nextnode->visitedWeight <= newVisit )
					{
						while (nextnode->nextOrdered && (nextnode->nextOrdered->visitedWeight < newVisit))
							nextnode = nextnode->nextOrdered;
					}
					else
					{
						while ( nextnode->prevOrdered && (nextnode->visitedWeight > newVisit) )
							nextnode = nextnode->prevOrdered;
					}

					if (nextnode->nextOrdered != endnode)
					{
						if (nextnode->nextOrdered)
							nextnode->nextOrdered->prevOrdered = endnode;
						endnode->nextOrdered = nextnode->nextOrdered;
						nextnode->nextOrdered = endnode;
						endnode->prevOrdered = nextnode;
					}
					LastAdd = endnode;
				}
			}
		}
		currentnode = currentnode->nextOrdered;
	}
	if( BestDest && Scout )
	{
		// Create inverse ordered lookup.
		ANavigationPoint* Cur=BestDest,*Prev=NULL;
		for(; Cur; Cur=Cur->previousPath )
		{
			Cur->nextOrdered = Prev;
			Prev = Cur;
		}
	}
	return BestDest;
	unguard;
}

void APathNodeIterator::BuildPathCache( ANavigationPoint* End )
{
	NodeCount = 0;
	ANavigationPoint* N=NULL;
	for( N=End; N; N=N->previousPath )
		++NodeCount;
	NodePath.Empty(NodeCount);
	NodePath.Add(NodeCount);
	NodeIndex = NodeCount-1;
	for( N=End; N; N=N->previousPath )
	{
		NodePath(NodeIndex--) = N;
		NodeCost = N->visitedWeight;
	}
	NodeIndex = 0;
}

void APathNodeIterator::execBuildPath( FFrame& Stack, RESULT_DECL )
{
	guard(APathNodeIterator::execBuildPath);
	P_GET_VECTOR(Start);
	P_GET_VECTOR(End);
	P_FINISH;

	NodePath.Empty();
	NodeCount = 0;
	NodeIndex = 0;
	NodeCost = 0;
	NodeStart = Start;
	if( Level->NavigationPointList )
		BuildPath(Start,End);
	unguardexec;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execBuildPath );

void APathNodeIterator::execGetFirst( FFrame& Stack, RESULT_DECL )
{
	guard(APathNodeIterator::execGetFirst);
	P_FINISH;

	*(ANavigationPoint**)Result = NULL;
	if( !NodeCount || NodeCount!=NodePath.Num() )
		return;
	NodeIndex = 0;
	*(ANavigationPoint**)Result = NodePath(0);
	unguardexec;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execGetFirst );

void APathNodeIterator::execGetPrevious(FFrame& Stack, RESULT_DECL)
{
	guard(APathNodeIterator::execGetPrevious);
	P_FINISH;

	*(ANavigationPoint**)Result = NULL;
	if (!NodeCount || NodeCount != NodePath.Num())
		return;
	--NodeIndex;
	if (NodeIndex >= 0 && NodeIndex<NodeCount)
		*(ANavigationPoint**)Result = NodePath(NodeIndex);
	unguardexec;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execGetPrevious );

void APathNodeIterator::execGetCurrent( FFrame& Stack, RESULT_DECL )
{
	guard(APathNodeIterator::execGetCurrent);
	P_FINISH;

	*(ANavigationPoint**)Result = NULL;
	if( !NodeCount || NodeCount!=NodePath.Num() )
		return;
	if( NodeIndex>=0 && NodeIndex<NodeCount )
		*(ANavigationPoint**)Result = NodePath(NodeIndex);
	unguardexec;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execGetCurrent );

void APathNodeIterator::execGetNext(FFrame& Stack, RESULT_DECL)
{
	guard(APathNodeIterator::execGetNext);
	P_FINISH;

	*(ANavigationPoint**)Result = NULL;
	if (!NodeCount || NodeCount != NodePath.Num())
		return;
	++NodeIndex;
	if (NodeIndex >= 0 && NodeIndex<NodeCount)
		*(ANavigationPoint**)Result = NodePath(NodeIndex);
	unguardexec;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execGetNext );

void APathNodeIterator::execGetLast( FFrame& Stack, RESULT_DECL )
{
	guard(APathNodeIterator::execGetLast);
	P_FINISH;

	*(ANavigationPoint**)Result = NULL;
	if( !NodeCount || NodeCount!=NodePath.Num() )
		return;
	NodeIndex = (NodeCount-1);
	*(ANavigationPoint**)Result = NodePath(NodeIndex);
	unguardexec;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execGetLast );

void APathNodeIterator::execGetLastVisible( FFrame& Stack, RESULT_DECL )
{
	guard(APathNodeIterator::execGetLastVisible);
	P_FINISH;

	*(ANavigationPoint**)Result = NULL;
	if( !NodeCount || NodeCount!=NodePath.Num() || !NodePath(NodeIndex) )
		return;
	FVector CurPoint = NodePath(NodeIndex)->Location;
	INT OldPoint = NodeIndex;
	for( INT i=(NodeIndex+1); i<NodeCount; ++i )
	{
		if( NodePath(i) && XLevel->FastLineCheck(CurPoint,NodePath(i)->Location,TRACE_VisBlocking,NodePath(i)) )
			NodeIndex = i;
		else break;
	}
	if( OldPoint!=NodeIndex )
		*(ANavigationPoint**)Result = NodePath(NodeIndex);
	unguardexec;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execGetLastVisible );

void APathNodeIterator::execCheckUPak( FFrame& Stack, RESULT_DECL )
{
	guardSlow(APathNodeIterator::execCheckUPak);
	P_FINISH;
	unguardexecSlow;
}
IMPLEMENT_FUNCTION( APathNodeIterator, INDEX_NONE, execCheckUPak );

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
