//=============================================================================
// BloodSpray.
//=============================================================================
class BloodSpray extends Blood2;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( (Level.NetMode != NM_DedicatedServer) && Level.bHighDetailMode )
		SpawnCloud();
	if ( !Region.Zone.bWaterZone )
		PlayAnim  ( 'Burst', 0.2 );
	else
		Destroy();
}

simulated function SpawnCloud()
{
	local Actor A;

	A = spawn(class'BloodPuff');
	A.RemoteRole = ROLE_None;
}

defaultproperties
{
	DrawScale=0.400000
	AmbientGlow=80
	bOwnerNoSee=true
}
