//=============================================================================
// LightWallHitEffect.
//=============================================================================
class LightWallHitEffect extends WallHitEffect;

simulated function SpawnEffects()
{
	local Actor A;
	local float decision;
	local vector HL,HN;

	decision = FRand();
	if (decision<0.2)
		PlaySound(sound'ricochet',, 1,,1200, 0.5+FRand());
	else if ( decision < 0.4 )
		PlaySound(sound'Impact1',, 3.0,,800);
	else if ( decision < 0.6 )
		PlaySound(sound'Impact2',, 3.0,,800);

	if (FRand()< 0.2)
	{
		A = spawn(class'Chip');
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	if (FRand()< 0.2)
	{
		A = spawn(class'SmallSpark',,,,Rotation + RotRand());
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	// Trace in a 6 dir cross and see if theres a wall around.
	if ( Level.Netmode!= NM_DedicatedServer)
	{
	if ( Trace(HL,HN,Location+vect(0,15,0),,False)!=None || Trace(HL,HN,Location+vect(0,-15,0),,False)!=None
			|| Trace(HL,HN,Location+vect(15,0,0),,False)!=None || Trace(HL,HN,Location+vect(-15,0,0),,False)!=None
			|| Trace(HL,HN,Location+vect(0,0,15),,False)!=None || Trace(HL,HN,Location+vect(0,0,-15),,False)!=None )
		Spawn(Class'lpock',,,,rotator(HN));
	}
}

defaultproperties
{
}
