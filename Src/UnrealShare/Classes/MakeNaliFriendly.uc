//=============================================================================
// MakeNaliFriendly
//  makes all fearful Nali friendly again.
// Use this when player "helps" nali, to make up for earlier killing one
// "accidentally"
//=============================================================================
class MakeNaliFriendly extends Keypoint;

function Trigger(actor Other, pawn EventInstigator)
{
	local Pawn aPawn;

	if ( EventInstigator.bIsPlayer )
	{
		aPawn = Level.PawnList;
		while ( aPawn != None )
		{
			if ( aPawn.IsA('Nali') )
			{
				aPawn.AttitudeToPlayer = ATTITUDE_Friendly;
				if (Nali(aPawn).OldEnemy!=none && Nali(aPawn).OldEnemy.bIsPlayer)
					Nali(aPawn).OldEnemy=none;
				if (Nali(aPawn).Enemy!=none && Nali(aPawn).Enemy.bIsPlayer)
				{
					Nali(aPawn).Enemy=none;
					if ( Nali(aPawn).IsInState('Retreating') || Nali(aPawn).IsInState('Acquisition')
							|| Nali(aPawn).IsInState('Threatening') || Nali(aPawn).IsInState('Charging')
							|| Nali(aPawn).IsInState('TacticalMove') || Nali(aPawn).IsInState('Hunting')
							|| Nali(aPawn).IsInState('StakeOut')  || Nali(aPawn).IsInState('MeleeAttack')
							|| Nali(aPawn).IsInState('RangedAttack') )
						Nali(aPawn).gotostate('Attacking');
				}
			}
			aPawn = aPawn.NextPawn;
		}
	}
}

defaultproperties
{
	bCollideActors=True
}
