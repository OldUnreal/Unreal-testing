//=============================================================================
// RainDrops.
// Wolf: added ZoneChange detection
//=============================================================================
class RainDrops expands Effects
	transient;

var effects d;
var bool bDoCreatePuddle;	// set by generator generating it


function PostBeginPlay()
{
	Super.PostBeginPlay();
	//make the rain actually fall :)
	//SetPhysics(PHYS_Falling);
	//SetPhysics(PHYS_Flying);
}

//==========================================================================
//when a drop hits a wall or lands on the ground then create
//a small rain puddle effect
function HitWall( vector HitNormal, actor HitWall )
{
	Super.HitWall(HitNormal, HitWall);
	//60% chance that there will be a puddle left on the ground
	//do this to keep performance up
	if (bDoCreatePuddle && (Frand() < 0.8))
	{
		spawn(class'RainPuddle',,,Location);
		//PlaySound (EffectSound1,,1.0, true);
	}
	Destroy();
}
//same for Landed
function Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	if (bDoCreatePuddle && (Frand() < 0.8))
	{
		spawn(class'RainPuddle',,,Location);
		//PlaySound (EffectSound1,,1.0, true);
	}
	Destroy();
}


// WOLF: SAME FOR ZONE CHANGE if new Zone is WATER!
simulated function ZoneChange( ZoneInfo NewZone )
{
//log(self@role@" zonechange :"$newzone$"  "$ newzone.bWaterZone);

	Super.ZoneChange(NewZone);

	if ( !NewZone.bWaterZone ) return; // if not waterzone... ignore...

	if (bDoCreatePuddle && (Frand() < 0.8))
	{
		spawn(class'RainPuddle',,,Location);
		//PlaySound (EffectSound1,,1.0, true);
	}
	Destroy();
}




defaultproperties
{
	Physics=PHYS_Projectile
	EffectSound1=Sound'UnrealShare.RainDrop'
	EffectSound2=Sound'UnrealShare.RainDrop'
	bTravel=True
	LifeSpan=600.000000
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=None
	DrawScale=0.500000
	Fatness=10
	bShadowCast=False
	bCollideActors=True
	bCollideWorld=True
}
