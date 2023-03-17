/*=============================================================================
	UnUPakNative.cpp: Native function lookup table for static libraries.
	Copyright 2022 OldUnreal. All Rights Reserved.

	Revision history:
		* Created by Stijn Volckaert
=============================================================================*/

#include "UPakPrivate.h"

#if __STATIC_LINK
#include "UnUPakNative.h"

APawnPathNodeIteratorNativeInfo GUPakAPawnPathNodeIteratorNatives[] =
{
	MAP_NATIVE(APawnPathNodeIterator, execSetPawn)
	{NULL, NULL}
};
IMPLEMENT_NATIVE_HANDLER(UPak, APawnPathNodeIterator);

APathNodeIteratorNativeInfo GUPakAPathNodeIteratorNatives[] =
{
	MAP_NATIVE(APathNodeIterator, execBuildPath)
	MAP_NATIVE(APathNodeIterator, execGetFirst)
	MAP_NATIVE(APathNodeIterator, execGetPrevious)
	MAP_NATIVE(APathNodeIterator, execGetCurrent)
	MAP_NATIVE(APathNodeIterator, execGetNext)
	MAP_NATIVE(APathNodeIterator, execGetLast)
	MAP_NATIVE(APathNodeIterator, execGetLastVisible)
	MAP_NATIVE(APathNodeIterator, execCheckUPak)
	{NULL, NULL}
};
IMPLEMENT_NATIVE_HANDLER(UPak, APathNodeIterator);

#endif
