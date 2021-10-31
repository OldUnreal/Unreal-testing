AEmitterGarbageCollector() {}
UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
void Destroy();
void CleanUpGarbage();
void AddGarbage( class ParticlesDataList* Ptr );
