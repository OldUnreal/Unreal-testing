//=============================================================================
// FireBurst.
//=============================================================================
class FireBurst expands fireball;

var nowarn int i;
var float MaxSize;
var float ExpandRate;

function Timer()
{
    if (i < 6)
    {
		Texture = SpriteAnim[i];
		i++;
	}
}


//change to slow down the fire
function PostBeginPlay()
{
	//slow down fire
	if ( ScriptedPawn(Instigator) != None )
		Speed = ScriptedPawn(Instigator).ProjectileSpeed / 2;
	PlaySound(SpawnSound);
	Velocity = Vector(Rotation) * speed;
	MakeNoise ( 1.0 );
	Texture = SpriteAnim[2];
	i=1;
	SetTimer(0.15,True);
	startcount = 0;
	Super.PostBeginPlay();
}

auto state Flying
{
	//what happens when our shot hits a wall
	simulated function HitWall( vector HitNormal, actor Wall )
	{
		//for a cool effect if the smoke hits the wall
		//or the floor then start a smoke puff that keeps
		//going for a while
		
	
	
		spawn(class'ShortSmokeGen',,,Location+HitNormal * 9);
		Explode(Location,HitNormal);
		
	}
	
	//what happens if it hits another actor and not a wall or
	//floor
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
	   if (Other==Owner)
	     return;
	 
	     
       Explode(HitLocation,Vect(0,0,0));
	}
	
	//on every tick increase the size of the shot
	function Tick(float DeltaTime)
	{

		//every tick, increase the size
		
		if (startcount < 1)
			startcount ++;
		else if (DrawScale<MaxSize)
		{
			DrawScale += ExpandRate;
			SetCollisionSize(DrawScale, DrawScale);
		}
			
	}
	
    function Explode(vector HitLocation, vector HitNormal)
    {
 	   	HurtRadius(15,64.0,'exploded',MomentumTransfer,HitLocation);
		Destroy();
	}
	


Begin:
	
	Sleep(7.0);
	Explode(Location, Vect(0,0,0));

}

defaultproperties
{
     DrawScale=0.150000
}
