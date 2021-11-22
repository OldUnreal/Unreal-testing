//=============================================================================
// BloodPoolSpawner.
//=============================================================================
class BloodPoolSpawner expands UnrealBlood
	NoUserCreate;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetPhysics(PHYS_Falling);

}

simulated function Green()
{
	bGreen=True;
}
simulated function Landed(vector HitNormal)
{
	local CarcassBloodPool B;
	if (Level.NetMode != NM_DedicatedServer)
		B=Spawn(class'CarcassBloodPool',Owner,,,rotator(Hitnormal));
	if (B != none && Bgreen)
		b.green();

	Destroy();
}

defaultproperties
{
	CollisionRadius=1.000000
	CollisionHeight=1.000000
	bCollideWorld=True
}
