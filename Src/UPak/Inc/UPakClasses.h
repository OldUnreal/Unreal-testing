﻿/*===========================================================================
    C++ class definitions exported from UnrealScript.
    This is automatically generated by the tools.
    DO NOT modify this manually! Edit the corresponding .uc files instead!
===========================================================================*/
#if ((_MSC_VER) || (HAVE_PRAGMA_PACK))
#pragma pack (push,OBJECT_ALIGNMENT)
#endif

#ifndef UPAK_API
#define UPAK_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern UPAK_API FName UPAK_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif


#ifndef NAMES_ONLY

class UPAK_API APathNodeIterator : public AActor
{
public:
	INT NodeCount GCC_PACK(INT_ALIGNMENT);
	INT NodeIndex;
	INT NodeCost;
	TArrayNoInit<class ANavigationPoint*> NodePath;
	FVector NodeStart;
	DECLARE_FUNCTION(execGetLastVisible);
	DECLARE_FUNCTION(execGetLast);
	DECLARE_FUNCTION(execGetNext);
	DECLARE_FUNCTION(execGetCurrent);
	DECLARE_FUNCTION(execGetPrevious);
	DECLARE_FUNCTION(execGetFirst);
	DECLARE_FUNCTION(execCheckUPak);
	DECLARE_FUNCTION(execBuildPath);
	DECLARE_CLASS(APathNodeIterator,AActor,CLASS_Transient,UPak)
	#include "APathNodeIterator.h"
};

class UPAK_API APawnPathNodeIterator : public APathNodeIterator
{
public:
	class APawn* Pawn GCC_PACK(INT_ALIGNMENT);
	DECLARE_FUNCTION(execSetPawn);
	DECLARE_CLASS(APawnPathNodeIterator,APathNodeIterator,CLASS_Transient,UPak)
	#include "APawnPathNodeIterator.h"
};

#endif

AUTOGENERATE_FUNCTION(APawnPathNodeIterator,-1,execSetPawn);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execGetLastVisible);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execGetLast);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execGetNext);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execGetCurrent);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execGetPrevious);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execGetFirst);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execCheckUPak);
AUTOGENERATE_FUNCTION(APathNodeIterator,-1,execBuildPath);

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif // NAMES_ONLY

#if ((_MSC_VER) || (HAVE_PRAGMA_PACK))
#pragma pack (pop)
#endif

#ifdef VERIFY_CLASS_SIZES
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,PawnPathNodeIterator,Pawn)
VERIFY_CLASS_SIZE_NODIE(APawnPathNodeIterator)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,PathNodeIterator,NodeCount)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,PathNodeIterator,NodeIndex)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,PathNodeIterator,NodeCost)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,PathNodeIterator,NodePath)
VERIFY_CLASS_OFFSET_NODIE_SLOW(A,PathNodeIterator,NodeStart)
VERIFY_CLASS_SIZE_NODIE(APathNodeIterator)
#endif // VERIFY_CLASS_SIZES
