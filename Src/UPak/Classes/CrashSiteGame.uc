//=============================================================================
// CrashSiteGame.
//=============================================================================
class CrashSiteGame expands UPakSinglePlayer;

var() float ReduceFallingDam;
var() float AffectedVelocity;

function int ReduceDamage( int Damage, name DamageType, pawn injured, pawn instigatedBy )
{
	if( DamageType == 'fell' && VSize( Injured.Velocity )>=AffectedVelocity )
	{
		if( !Injured.IsA( 'SpaceMarine' ) )
		{
			Damage *= ReduceFallingDam;
			return Damage;
		}
		else
		{
			Injured.GotoState( 'Dying' );
			Damage *= 50;
			return Damage;
		}
	}
	
	if( injured.Region.Zone.bNeutralZone )
		return 0;	
	return Damage;
}

//
// Return whether an item should respawn.
//
function bool ShouldRespawn( actor Other )
{
	if( Other.IsA( 'UPakHealth' ) && UPakHealth( Other ).bRespawnInSP )
		return (UPakHealth(Other).RespawnTime!=0.0);
	else if( Level.NetMode == NM_StandAlone )
		return false;
	return (Inventory(Other)!=None && Inventory(Other).ReSpawnTime!=0.0);
}

defaultproperties
{
     ReduceFallingDam=3.500000
     AffectedVelocity=150.000000
}
