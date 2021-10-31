//=============================================================================
// QueenProjectile.
//=============================================================================
class QueenProjectile extends SkaarjProjectile;

auto state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local vector momentum;

		if ( !Other.IsA('Queen') )
		{
			if ( Role == ROLE_Authority )
			{
				momentum = 10000.0 * Normal(Velocity);
				Other.TakeDamage(Damage, instigator, HitLocation, momentum, 'zapped');
			}
			Destroy();
		}
	}
}

defaultproperties
{
	MaxSpeed=+02000.000000
}