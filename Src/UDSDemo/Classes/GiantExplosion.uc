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
		ExpStartTime = Level.TimeSeconds;
		GotoState('BlowingUp');
	}

begin:
	ExpStartTime = -1;	

}

state BlowingUp
{

	function ShootFlame()
	{
	
		local FireBurst F;
		local Rotator R;

		r = Rotator(vrand());		
		f = Spawn(class 'FireBurst',self,,location,r);
		f.MaxSize = 3;
		f.ExpandRate = 0.25;
		f.DrawScale =1;
	}


	function SpawnExp()
	{
	
		local SpriteBallExplosion	E;
		local Vector 				v,hl,hn;
		local Actor					a;

		v = Location;
		v.X += Rand(expRadius);
		v.Y += Rand(expRadius);
		v.Z += Rand(expRadius);

				
				
		a = Trace(hl,hn,v,location);
		if (a!=None)
		  v = hl;
		  
	    E = Spawn(class 'SpriteBallExplosion',self,,v,rotation);
    	HurtRadius(damage, Damage+100, 'Detonated', 1000, Location);
		E.DrawScale = Rand(20)+10;
		
		if (Rand(100) < 40)
		{
			PlaySound(sound 'Expl2',,3);
		}
		

	}


begin:

	SpawnExp();
	ShootFlame();
	sleep(ExpPeriod);
	
	if ( (Level.TimeSeconds - ExpStartTime) < ExpDuration )
	  Goto('Begin');

	Destroy();

}

defaultproperties
{
     DrawType=DT_Sprite
	 bHidden=True
}
