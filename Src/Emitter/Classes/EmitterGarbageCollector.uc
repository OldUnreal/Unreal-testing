// Stores some temp data which are about to be purged.
class EmitterGarbageCollector extends Info
	Native
	Transient;

var pointer<TArray<class ParticlesDataList*>*> GarbagePtr;
var const bool bCleanUp;
var const float CleanUpTime;

defaultproperties
{
	RemoteRole=ROLE_None
	bHiddenEd=True
}
