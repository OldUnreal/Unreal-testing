//=============================================================================
// RainDropSplash.
//=============================================================================
class RainDropSplash extends UISpawnableAdvancedCombiner;

defaultproperties
{
	Probability(0)=(bUseProbability=True,SpawnProbability=0.750000)
	Probability(1)=(bUseProbability=True,SpawnProbability=0.750000)
	EmitterConfig(0)=(ParticleEmitter=Class'UnrealShare.RainDropRing')
	EmitterConfig(1)=(ParticleEmitter=Class'UnrealShare.RainDropSparks',EmitterOffset=(Z=4.000000),EmittterRotationOffset=(Pitch=16384),RoataionType=ROT_Custom)
	bDestroy=True
	NumEmitters=2
	bHidden=True
	InitialState=NoRotation
}
