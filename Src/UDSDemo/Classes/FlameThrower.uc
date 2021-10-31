//=============================================================================
// FlameThrower.
//=============================================================================
class FlameThrower expands Effects;

var() int 		FlameTime;  // How long should it send out flames.
var() float		FlamePeriod; // Spawn a burst every X seconds
var() float		FlameStartSize; // How big is the flame to begin with
var() float		FlameMaxSize; // How big should the flame expand
var() float 	FlameExpandRate; // How fast should it expand.

var	  float  	FlameStartTime;


auto state Start
{


begin:

	GotoState('Inactive');

}


state Inactive
{


	function Trigger(actor Other, pawn EventInstigator)
	{
	
		FlameStartTime = Level.TimeSeconds;
		GotoState('Active');

	}

begin:

	LightType = LT_None;
	LightEffect = LE_None;



}

state Active
{

	function Trigger(actor Other, pawn EventInstigator)
	{
	
		GotoState('InActive');

	}


	function FlameIt()
	{
	
		local FireBurst F;
	
		f = Spawn(class 'FireBurst',self,,location,rotation);
		if (f==None)
		  Log("Flame Thrower Error: Could not spawn Flame");
		else
		{
			f.MaxSize = FlameMaxSize;
			f.ExpandRate = FlameExpandRate;
			f.DrawScale = FlameStartSize;
		}
	}

	
begin:
		LightType = LT_Steady;
		LightEffect = LE_FireWaver;
		PlaySound(sound 'Flarel1',SLOT_INTERACT,1,false);

ShootFlame:
		FlameIt();
		
TestTime:

		if ( (FlameTime == -1) || ((Level.TimeSeconds - FlameStartTime) < FlameTime ) )
		{
		   sleep(FlamePeriod);
		   goto('ShootFlame');
		}
	
		PlaySound(sound 'Flares1',SLOT_INTERACT,1,false);
		GotoState('Inactive');

	
}

defaultproperties
{
     FlameTime=15
     FlamePeriod=0.350000
     bHidden=True
     bMovable=False
     bDirectional=True
     DrawType=DT_Sprite
     AmbientGlow=183
     LightBrightness=64
     LightSaturation=128
     LightRadius=32
     LightPeriod=32
     LightCone=128
     VolumeBrightness=64
}
