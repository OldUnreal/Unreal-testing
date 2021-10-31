class DecalBloodPool2 expands DecalBloodPool;

simulated function Timer()
{
	// Check for nearby players, if none then destroy self

	if ( !bAttached )
	{
		Destroy();
		return;
	}

	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
	}
}

defaultproperties
{
	DrawScale=+0.68
	splats(0)=texture'Unrealshare.BloodSplat7'
	splats(1)=texture'Unrealshare.BloodSplat5'
	splats(2)=texture'Unrealshare.BloodSplat1'
	splats(3)=texture'Unrealshare.BloodSplat3'
	splats(4)=texture'Unrealshare.BloodSplat4'
}