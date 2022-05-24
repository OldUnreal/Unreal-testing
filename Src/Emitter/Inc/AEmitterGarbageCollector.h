	AEmitterGarbageCollector() {}
	UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
	void Destroy();
	void AddGarbage( class FParticlesDataBase* Ptr );
	void Serialize(FArchive& Ar);

	static void MarkGCParticles(ULevel* Map, class FParticlesDataBase* Ptr);