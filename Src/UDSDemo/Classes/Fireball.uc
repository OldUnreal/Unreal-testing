//=============================================================================
// FireBall.
// same as GasBagBelch only has a shorter life-time
//=============================================================================
class Fireball expands GasBagBelch;

#exec Texture Import File=Textures\flame0.pcx Name=FB_01 Group=FireBall Mips=Off Flags=2
#exec Texture Import File=Textures\flame1.pcx Name=FB_02 Group=FireBall Mips=Off Flags=2
#exec Texture Import File=Textures\flame2.pcx Name=FB_03 Group=FireBall Mips=Off Flags=2
#exec Texture Import File=Textures\flame3.pcx Name=FB_04 Group=FireBall Mips=Off Flags=2
#exec Texture Import File=Textures\flame4.pcx Name=FB_05 Group=FireBall Mips=Off Flags=2
#exec Texture Import File=Textures\flame5.pcx Name=FB_06 Group=FireBall Mips=Off Flags=2
#exec Texture Import File=Textures\flame6.pcx Name=FB_07 Group=FireBall Mips=Off Flags=2

var() int startcount;
var nowarn int i;

function Timer()
{
	Texture = SpriteAnim[i];
	i++;
	if (i>=6) i=0;
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
	Texture = SpriteAnim[0];
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
		Super.Tick(DeltaTime);

		//every tick, increase the size
		
		if (startcount < 1)
			startcount ++;
		else if (DrawScale<5.0)
		{
			DrawScale += 0.5;
			SetCollisionSize(DrawScale * 5, DrawScale *5);
		}

	
			
	}
	
    function Explode(vector HitLocation, vector HitNormal)
    {
 	   	HurtRadius(15,64.0,'exploded',MomentumTransfer,HitLocation);
 	   	spawn(class'FlameExplosion',,,HitLocation + HitNormal * 9);
		Destroy();
	}
	


Begin:
	
	Sleep(7.0);
	Explode(Location, Vect(0,0,0));

}

defaultproperties
{
     SpriteAnim(0)=None
     SpriteAnim(1)=None
     SpriteAnim(2)=None
     SpriteAnim(3)=None
     SpriteAnim(4)=None
     SpriteAnim(5)=None
     speed=800.000000
     Damage=20.000000
     MomentumTransfer=32000
     ImpactSound=None
     ExploWallOut=10.000000
     LifeSpan=6.000000
     DrawScale=0.500000
     AmbientGlow=187
     bMeshCurvy=True
     bFixedRotationDir=True
}
