//by Raven
class UIThunder extends UIBeamEmitter;

var(Thunder) float ThunderLifeTime;
var(Thunder) float RandomFactor;

simulated state() ThunderRandom
{
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		GoToState('Randomize');
	}
Begin:
	if (RandomFactor <= 0 || ThunderLifeTime <= 0) Destroy();
}


simulated state Randomize
{
Begin:
	if (Beam == none) MakeBeam();
	Sleep(ThunderLifeTime+FRand()*RandomFactor);
	if (Beam != none)
	{
		Beam.Destroy();
		Beam=none;
	}
	GoToState('ThunderRandom');
}

defaultproperties
{
	ThunderLifeTime=0.1
	bKeepShape=true
	InitialState=ThunderRandom
	RandomFactor=0.9
}