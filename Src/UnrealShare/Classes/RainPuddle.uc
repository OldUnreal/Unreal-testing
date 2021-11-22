//=============================================================================
// RainPuddle.
// most of the code here is copied from the RingExplosion code, basically
// I just changed the DrawScale to a smaller value, I do not take
// any credit for this outside of that, its makes a very nice effect.
//=============================================================================
class RainPuddle expands Effects
	transient;

var bool bSpawnOnce;

simulated function Timer()
{
	local WaterRing r;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		r = Spawn(class'WaterRing',,,,rotang(90,0,0));
		r.DrawScale = 0.02;
		r.RemoteRole = ROLE_None;
	}
	else
		Destroy();
	if (bSpawnOnce) Destroy();
	bSpawnOnce=True;
}


simulated function PostBeginPlay()
{
	SetTimer(0.3,True);
}

defaultproperties
{
}
