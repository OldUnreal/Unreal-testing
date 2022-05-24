// Stores some temp data which are about to be purged.
class EmitterGarbageCollector extends Info
	Native
	Transient;

var pointer<TArray<class FParticlesDataBase*>*> GarbagePtr;
var const uint CleanUpTime;

defaultproperties
{
	RemoteRole=ROLE_None
	bHiddenEd=True
}
