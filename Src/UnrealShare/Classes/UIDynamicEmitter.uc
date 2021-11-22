/*
   This emitter can be destroyed but it can not be modified
   in UED (every propersties have to be scripted). It also contain
   no replication.
*/
class UIDynamicEmitter extends UIParticleEmitter;

defaultproperties
{
	bNoDelete=false
	bStasis=false
}
