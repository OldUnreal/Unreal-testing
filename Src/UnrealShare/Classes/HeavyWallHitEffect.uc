//=============================================================================
// HeavyWallHitEffect.
//=============================================================================
class HeavyWallHitEffect extends WallHitEffect;

simulated function SpawnEffects()
{
	local Actor A;
	local float decision;
	local vector HL,HN;

	decision = FRand();
	if (decision<0.15)
		PlaySound(sound'ricochet',, 0.5,,1200, 0.3 + 0.7 * FRand());
	else if ( decision < 0.5 )
		PlaySound(sound'Impact1',, 4.0,,800);
	else if ( decision < 0.9 )
		PlaySound(sound'Impact2',, 4.0,,800);

	if (FRand()< 0.5)
	{
		A = spawn(class'Chip');
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	if (FRand()< 0.5)
	{
		A = spawn(class'Chip');
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	if (FRand()< 0.5)
	{
		A = spawn(class'Chip');
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	A = spawn(class'SmallSpark',,,,Rotation + RotRand());
	if ( A != None )
		A.RemoteRole = ROLE_None;
	// Trace in a 6 dir cross and see if theres a wall around.
	if ( Level.Netmode!= NM_DedicatedServer)
	{
	if ( Trace(HL,HN,Location+vect(0,15,0),,False)!=None || Trace(HL,HN,Location+vect(0,-15,0),,False)!=None
			|| Trace(HL,HN,Location+vect(15,0,0),,False)!=None || Trace(HL,HN,Location+vect(-15,0,0),,False)!=None
			|| Trace(HL,HN,Location+vect(0,0,15),,False)!=None || Trace(HL,HN,Location+vect(0,0,-15),,False)!=None )
		Spawn(Class'hpock',,,,rotator(HN));
	}
}

defaultproperties
{
}
