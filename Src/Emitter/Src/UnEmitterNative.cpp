/*=============================================================================
	UnEmitterNative.cpp: Native function lookup table for static libraries.
	Copyright 2022 OldUnreal. All Rights Reserved.

	Revision history:
		* Created by Stijn Volckaert
=============================================================================*/

#include "EmitterPrivate.h"

#if __STATIC_LINK
#include "UnEmitterNative.h"

AXRopeDecoNativeInfo GEmitterAXRopeDecoNatives[] =
{
	MAP_NATIVE(AXRopeDeco, execResetRope)
	MAP_NATIVE(AXRopeDeco, execSetStartLocation)
	MAP_NATIVE(AXRopeDeco, execSetEndLocation)
	MAP_NATIVE(AXRopeDeco, execBreakRope)
	{NULL, NULL}
};
IMPLEMENT_NATIVE_HANDLER(Emitter,AXRopeDeco);

AXEmitterNativeInfo GEmitterAXEmitterNatives[] =
{
	MAP_NATIVE(AXEmitter, execSpawnParticles)
	MAP_NATIVE(AXEmitter, execSetMaxParticles)
	MAP_NATIVE(AXEmitter, execKill)
	MAP_NATIVE(AXEmitter, execEmTrigger)
	{NULL, NULL}
};
IMPLEMENT_NATIVE_HANDLER(Emitter,AXEmitter);

AXParticleEmitterNativeInfo GEmitterAXParticleEmitterNatives[] =
{
	MAP_NATIVE(AXParticleEmitter, execSetParticlesProps)
	MAP_NATIVE(AXParticleEmitter, execAllParticles)
	{NULL, NULL}
};
IMPLEMENT_NATIVE_HANDLER(Emitter,AXParticleEmitter);

AXWeatherEmitterNativeInfo GEmitterAXWeatherEmitterNatives[] =
{
	MAP_NATIVE(AXWeatherEmitter, execAddNoRainBounds)
	MAP_NATIVE(AXWeatherEmitter, execRemoveNoRainBounds)
	MAP_NATIVE(AXWeatherEmitter, execSetRainVolume)
	{NULL, NULL}
};
IMPLEMENT_NATIVE_HANDLER(Emitter,AXWeatherEmitter);

#endif
