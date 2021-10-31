//=============================================================================
// WallHitEffect.
//=============================================================================
class WallHitEffect extends SpriteSmokePuff;

#exec AUDIO IMPORT FILE="..\UnrealI\Sounds\Minigun\imp01.wav" NAME="Impact1" GROUP="Minigun"
#exec AUDIO IMPORT FILE="..\UnrealI\Sounds\Minigun\imp02.wav" NAME="Impact2" GROUP="Minigun"
#exec AUDIO IMPORT FILE="Sounds\Stinger\Ricochet.wav" NAME="Ricochet" GROUP="Stinger"

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Instigator != None )
		MakeNoise(0.3);

	SpawnEffects();
}

simulated function SpawnEffects()
{
	local Actor A;
	local float decision;
	local vector HL,HN;

	decision = FRand();
	if (decision<0.1)
		PlaySound(sound'ricochet',, 1,,1200, 0.5+FRand());
	else if ( decision < 0.35 )
		PlaySound(sound'Impact1',, 2.0,,1200);
	else if ( decision < 0.6 )
		PlaySound(sound'Impact2',, 2.0,,1200);

	if (FRand()< 0.3)
	{
		A = spawn(class'Chip');
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	if (FRand()< 0.3)
	{
		A = spawn(class'Chip');
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	if (FRand()< 0.3)
	{
		A = spawn(class'Chip');
		if ( A != None )
			A.RemoteRole = ROLE_None;
	}
	A = spawn(class'SmallSpark2',,,,Rotation + RotRand());
	if ( A != None )
		A.RemoteRole = ROLE_None;
	if ( Level.Netmode!= NM_DedicatedServer)
	{
	// Trace in a 6 dir cross and see if theres a wall around.
	if ( Trace(HL,HN,Location+vect(0,15,0),,False)!=None || Trace(HL,HN,Location+vect(0,-15,0),,False)!=None
			|| Trace(HL,HN,Location+vect(15,0,0),,False)!=None || Trace(HL,HN,Location+vect(-15,0,0),,False)!=None
			|| Trace(HL,HN,Location+vect(0,0,15),,False)!=None || Trace(HL,HN,Location+vect(0,0,-15),,False)!=None )
		Spawn(Class'pock',,,,rotator(HN));
	}		
}

defaultproperties
{
	bNetOptional=True
}
