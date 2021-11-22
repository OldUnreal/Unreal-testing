//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CSMaleOne ]
//
// Simply a subclass (it's 100% exact to the original Unreal Code) for handling players.
//=============================================================================

class CSMaleOne expands CSMale;

simulated function PlayMetalStep()
{
	local sound step;
	local float decision;

	if ( Role < ROLE_Authority )
		return;
	if ( !bIsWalking && (Level.Game.Difficulty > 1) && ((Weapon == None) || !Weapon.bPointing) )
		MakeNoise(0.05 * Level.Game.Difficulty);
	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(sound 'LSplash', SLOT_Interact, 1, false, 1000.0, 1.0);
		return;
	}

	decision = FRand();
	if ( decision < 0.34 )
		step = sound'MetWalk1';
	else if (decision < 0.67 )
		step = sound'MetWalk2';
	else
		step = sound'MetWalk3';

	if ( bIsWalking )
		PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else 
		PlaySound(step, SLOT_Interact, 1, false, 800.0, 1.0);
}

defaultproperties
{
     CarcassType=Class'UnrealI.MaleOneCarcass'
     Skin=Texture'UnrealShare.Skins.Kurgan'
     Mesh=Mesh'UnrealI.Male1'
}
