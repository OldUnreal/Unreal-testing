//=============================================================================
// DefaultBurstAlt.
//=============================================================================
class DefaultBurstAlt extends DefaultBurst;

function Timer()
{
	Spawn(class'RingExplosion');
}

Function PostBeginPlay()
{
	SetTimer(0.05,False);
	Super.PostBeginPlay();
}

defaultproperties
{
}
