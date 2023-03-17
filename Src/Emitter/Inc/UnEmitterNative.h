/*=============================================================================
	UnEmitterNative.h: Native function lookup table for static libraries.
	Copyright 2022 OldUnreal. All Rights Reserved.

	Revision history:
		* Created by Stijn Volckaert
=============================================================================*/

#ifndef UNEMITTERNATIVE_H
#define UNEMITTERNATIVE_H

DECLARE_NATIVE_TYPE(Emitter,AXRopeDeco);
DECLARE_NATIVE_TYPE(Emitter,AXEmitter);
DECLARE_NATIVE_TYPE(Emitter,AXParticleEmitter);
DECLARE_NATIVE_TYPE(Emitter,AXWeatherEmitter);

#define AUTO_INITIALIZE_REGISTRANTS_EMITTER		\
	AXRainRestrictionVolume::StaticClass();		\
	AEmitterGarbageCollector::StaticClass();	\
	AXRopeDeco::StaticClass();					\
	ADistantLightActor::StaticClass();			\
	AXParticleEmitter::StaticClass();			\
	AXWeatherEmitter::StaticClass();			\
	AXEmitter::StaticClass();					\
	AXTrailEmitter::StaticClass();				\
	AXSpriteEmitter::StaticClass();				\
	AXMeshEmitter::StaticClass();				\
	AXBeamEmitter::StaticClass();				\
	AXParticleForces::StaticClass();			\
	AVelocityForce::StaticClass();				\
	AParticleConcentrateForce::StaticClass();	\
	AKillParticleForce::StaticClass();			\
	AEmitterRC::StaticClass();					\
	UEmitterRendering::StaticClass();			\
	UActorFaceCameraRI::StaticClass();			\
	URopeMesh::StaticClass();					\
	AXTrailParticle::StaticClass();				\
	UTrailMesh::StaticClass();					\
	UBeamMesh::StaticClass(); 
#endif
