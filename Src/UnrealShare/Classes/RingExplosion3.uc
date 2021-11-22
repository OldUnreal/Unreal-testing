//=============================================================================
// RingExplosion3.
//=============================================================================
class RingExplosion3 extends RingExplosion;


#exec OBJ LOAD FILE=Textures\fireeffect55.utx PACKAGE=UnrealShare.Effect55


simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explosion', 0.15 );
		SpawnEffects();
	}
	if ( Instigator != None )
		MakeNoise(0.5);
}

defaultproperties
{
	DecalClass=Class'UnrealShare.BigEnergyImpact'
	Skin=UnrealShare.Effect55.fireeffect55
	DrawScale=+00001.250000
}
