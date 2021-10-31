//=============================================================================
// GiantGasbag.
//=============================================================================
class GiantGasbag extends Gasbag;

function SpawnBelch()
{
	local Gasbag G;
	local vector X,Y,Z, projStart;
	local actor P;

	GetAxes(Rotation,X,Y,Z);
	projStart = Location + 0.5 * CollisionRadius * X - 0.3 * CollisionHeight * Z;
	if ( (numChildren > 1+int(BonusSkill)) || Rand((BonusSkill>0.f) ? 2 : 5) )
	{
		P = spawn(RangedProjectile,,,projStart,AdjustAim(ProjectileSpeed, projStart, 400, bLeadTarget, bWarnTarget));
		if( P )
			P.DrawScale *= 2;
	}
	else
	{
		G = spawn(class'Gasbag' ,,,projStart + (0.6 * CollisionRadius + class'Gasbag'.Default.CollisionRadius) * X);
		if( G )
		{
			G.ParentBag = self;
			numChildren++;
		}
	}
}

defaultproperties
{
	PunchDamage=40
	PoundDamage=65
	Health=600
	CombatStyle=+00000.500000
	DrawScale=+00003.000000
	CollisionRadius=+00160.000000
	CollisionHeight=+00108.000000
}
