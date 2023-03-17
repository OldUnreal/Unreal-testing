//=============================================================================
// GiantExplosion.
//=============================================================================
class GiantExplosion expands Effects;

var() int	 	ExpDuration;
var() int 	 	ExpRadius;
var() float	 	ExpPeriod;
var() int		Damage;

var float	 	ExpStartTime;

auto state Start
{
	function Trigger(actor Other, Pawn EventInstigator)
	{
		GotoState('BlowingUp');
	}
}

state BlowingUp
{
	function ShootFlame()
	{
		local FireBurst F;
		
		F = Spawn(class'FireBurst',,,,RotRand(true));
		if( F )
		{
			F.MaxSize = 3;
			F.ExpandRate = 0.25;
			F.DrawScale = 1;
		}
	}
	function SpawnExp()
	{
		local SpriteBallExplosion E;
		local vector v,hl,hn;
		local Actor a;

		v = Location;
		v.X += Rand(expRadius);
		v.Y += Rand(expRadius);
		v.Z += Rand(expRadius);

		a = Trace(hl,hn,v,location);
		if( a )
			v = hl+hn;

		HurtRadius(damage, Damage+100, 'Detonated', 1000, Location);
		E = Spawn(class'SpriteBallExplosion',,,v);
		if( E )
			E.DrawScale = Rand(20)+10;

		if (Rand(10) < 4)
			PlaySound(sound 'Expl2',,3);
	}
	function Reset()
	{
		GoToState('Start');
	}
begin:
	ExpStartTime = (Level.TimeSeconds+ExpDuration);
	while( Level.TimeSeconds<=ExpStartTime )
	{
		SpawnExp();
		ShootFlame();
		Sleep(ExpPeriod);
	}
}

defaultproperties
{
	DrawType=DT_Sprite
	bHidden=True
	RemoteRole=ROLE_None
}
