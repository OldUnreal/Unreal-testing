//=============================================================================
// SkaarjBerserker.
//=============================================================================
class SkaarjBerserker extends SkaarjWarrior;

#exec TEXTURE IMPORT NAME=Skaarjw2 FILE=Models\Skar1.pcx GROUP=Skins DETAIL=Dirty

function WhatToDoNext(name LikelyState, name LikelyLabel)
{
	local Pawn aPawn;

	if ( Health >0 && !bDeleteme)
	{
		aPawn = Level.PawnList;
		while ( aPawn != None )
		{
			if ( (aPawn.IsA('PlayerPawn') || (aPawn.IsA('ScriptedPawn') && aPawn!=self))
					&& (VSize(Location - aPawn.Location) < 500)
					&& CanSee(aPawn) )
			{
				if ( SetEnemy(aPawn) )
				{
					GotoState('Attacking');
					return;
				}
			}
			aPawn = aPawn.nextPawn;
		}
	}
	Super.WhatToDoNext(LikelyState, LikelyLabel);
}

function eAttitude AttitudeToCreature(Pawn Other)
{
	if ( Other==self)
		return ATTITUDE_Friendly;
	else if ( Other.IsA('Pupae') )
		return ATTITUDE_Ignore;
	else
		return ATTITUDE_Hate;
}

function bool IsSameSpeciesAs( ScriptedPawn Other )
{
	return false;
}

defaultproperties
{
	LungeDamage=40
	SpinDamage=40
	ClawDamage=20
	VoicePitch=0.300000
	Aggressiveness=0.800000
	Health=320
	Skill=1.000000
	CombatStyle=1.000000
	Skin=Texture'UnrealI.Skins.Skaarjw2'
	DrawScale=1.200000
	Fatness=150
	CollisionHeight=56.000000
	Mass=180.000000
	Buoyancy=180.000000
	RotationRate=(Yaw=50000)
}
