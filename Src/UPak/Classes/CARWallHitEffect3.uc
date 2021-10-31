//=============================================================================
// CARWallHitEffect3.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class CARWallHitEffect3 expands HeavyWallHitEffect;

simulated function SpawnEffects()
{
	local vector HL,HN;

	if ( Level.Netmode!= NM_DedicatedServer)
	{
	// Trace in a 6 dir cross and see if theres a wall around.
	if ( Trace(HL,HN,Location+vect(0,15,0),,False)!=None || Trace(HL,HN,Location+vect(0,-15,0),,False)!=None
			|| Trace(HL,HN,Location+vect(15,0,0),,False)!=None || Trace(HL,HN,Location+vect(-15,0,0),,False)!=None
			|| Trace(HL,HN,Location+vect(0,0,15),,False)!=None || Trace(HL,HN,Location+vect(0,0,-15),,False)!=None )
		Spawn(Class'SmallBlastMark',,,,rotator(HN));
	}
}

defaultproperties
{
     DrawScale=1.5
}
