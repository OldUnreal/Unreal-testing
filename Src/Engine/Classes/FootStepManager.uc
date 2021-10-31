//========================================================
// FootStepManager
//========================================================

// Handle footsteps.
Class FootStepManager extends Object;

var() string FootStepSounds[44]; // Hold list of string names of footstep sounds.
var sound InitFootStepSounds[44]; // Hold list of loaded footstep sounds.
var() string FootDecalStr; // Class name of foot decal prints.
var class<FootDecalBase> FootDecalClass;
var sound LastSound;

// Client side:
simulated static function bool OverrideFootstep( Pawn Other, out Sound Step, out byte WetSteps )
{
	local Texture HitTexture;
	local FluidInfo F;
	
	if(Other == None || Other.bDeleteMe)
		return false;

	// Make ripplets
	foreach Other.TouchingActors(Class'FluidInfo',F)
	{
		if( F.Footstep(Other) )
			break;
	}
	if ( F!=None || Other.FootRegion.Zone.bWaterZone )
	{
		Other.PlaySound(Other.WaterStep, SLOT_Interact, 1, false, 1000.0, 1.0);
		WetSteps = 15;
		return true;
	}

	// Texture determination
	if( Other.GroundTexture!=None )
		HitTexture = Other.GroundTexture;
	else Other.TraceSurfHitInfo(Other.Location,Other.Location-vect(0,0,30),,,HitTexture);

	if( HitTexture!=None )
	{
		// Now use the Texture to load the sound...
		Step = PickSoundFrom(HitTexture);
		if( Step==None && HitTexture.SurfaceType>EST_Default && HitTexture.SurfaceType<EST_Custom00 )
			Step = GetDefaultSound(HitTexture);
	}

	// Create Footprints
	if ( WetSteps>0 )
	{
		// Make wet footprint
		WetSteps--;
		FootPrinter(true,Other);
	}
	else if ( HitTexture!=None && CausesDecals(HitTexture) )
		FootPrinter(false,Other);
	return (Step!=none);
}

// Server side:
static function PlayLandingNoise( Pawn Other, float VolAmp, float ImpactVel )
{
	local Texture HitTexture;
	local Sound Land;

	if ( Other.FootRegion.Zone.bWaterZone || impactVel<=0.01 )
		return;
	
	if( Other.GroundTexture!=None )
		HitTexture = Other.GroundTexture;
	else Other.TraceSurfHitInfo(Other.Location,Other.Location-vect(0,0,30),,,HitTexture);
	
	if( HitTexture!=None && HitTexture.HitSound!=None )
		Land = HitTexture.HitSound;
	else Land = Other.Land;
	Other.PlaySound(Land,SLOT_Interact,FClamp((4+VolAmp*0.5f) * ImpactVel,0.5,5+VolAmp), false,1000, 1.0);
}

// Check if texture surface type causes decal.
static final function bool CausesDecals( Texture T )
{
	return (T.SurfaceType==EST_Dirt || T.SurfaceType==EST_Snow || T.SurfaceType>=EST_Custom06);
}

// Pick a random footstep sound slot from the texture.
static final function Sound PickSoundFrom( Texture T )
{
	local byte i,j;

	for( i=0; i<ArrayCount(T.FootstepSound); i++ )
		if( T.FootstepSound[i]==None )
			break;
	if( i==0 )
		return None;
	else if( i==1 )
		return T.FootstepSound[0];
	j = Rand(i);
	if( T.FootstepSound[j]==Default.LastSound && ++j==i )
		j = 0;
	Default.LastSound = T.FootstepSound[j];
	return Default.LastSound;
}

// Pick default footstep sound for texture.
static final function Sound GetDefaultSound( Texture T )
{
	local byte i;

	i = (T.SurfaceType-1)*4+Rand(4);
	if( Default.InitFootStepSounds[i]==None )
		Default.InitFootStepSounds[i] = Sound(DynamicLoadObject(Default.FootStepSounds[i],Class'Sound'));
	return Default.InitFootStepSounds[i];
}

static final function FootPrinter( bool bWetPainter, Pawn Other )
{
	local float strafemag;
	local FootDecalBase fp;
	local vector rot, vel, footpos;
	local float FD;
	local Vector X, Y, Z;
	local rotator R;

	if( Default.FootDecalClass==None )
		Default.FootDecalClass = Class<FootDecalBase>(DynamicLoadObject(Default.FootDecalStr,Class'Class'));
	if( Default.FootDecalClass==None )
		return;

	R.Yaw = Other.Rotation.Yaw;
	GetAxes(R, X, Y, Z); // Only use Yaw component.
	FD=FRand();

	vel = Other.velocity; //direction
	vel.z = 0;
	vel = Normal(vel);
	rot = X; //direction

	strafemag = rot dot vel; // the angle between the way im facing and travelling
	// dot value cosine  of the 2 directions
	if  (strafemag > 0.8 || strafemag < -0.8) //determine if player is strafing
	{
		if( Other.AnimFrame<0.5f ) // left foot or right foot?
		{
			footpos = Other.Location - Other.CollisionRadius*FD*Y - Other.CollisionHeight*z;
			fp = Other.Spawn(Default.FootDecalClass,,, footpos, rot(16384,0,0));
			if( bWetPainter )
				fp.AssignFootType(3,Other);
			else fp.AssignFootType(2,Other);
		}
		else
		{
			footpos = Other.Location + Other.CollisionRadius*FD*Y - Other.CollisionHeight*z;
			fp = Other.Spawn(Default.FootDecalClass,,, footpos, rot(16384,0,0));
			if( bWetPainter )
				fp.AssignFootType(1,Other);
			else fp.AssignFootType(0,Other);
		}
	}
	else //Player is strafing, so create footprints for both feet.
	{
		footpos = Other.Location - Other.CollisionRadius*FD*Y - Other.CollisionHeight*z;
		fp = Other.Spawn(Default.FootDecalClass,,, footpos, rot(16384,0,0));
		if( bWetPainter )
			fp.AssignFootType(3,Other);
		else fp.AssignFootType(2,Other);
		footpos = Other.Location + Other.CollisionRadius*FD*Y - Other.CollisionHeight*z;
		fp = Other.Spawn(Default.FootDecalClass,,, footpos, rot(16384,0,0));
		if( bWetPainter )
			fp.AssignFootType(1,Other);
		else fp.AssignFootType(0,Other);
	}
}

defaultproperties
{
	FootStepSounds(0)="Footsteps.stone3_01" // Rock
	FootStepSounds(1)="Footsteps.stone3_02"
	FootStepSounds(2)="Footsteps.stone3_03"
	FootStepSounds(3)="Footsteps.stone3_04"
	FootStepSounds(4)="Footsteps.sand1_01" // Dirt
	FootStepSounds(5)="Footsteps.sand1_02"
	FootStepSounds(6)="Footsteps.sand1_03"
	FootStepSounds(7)="Footsteps.sand1_04"
	FootStepSounds(8)="Footsteps.metal5_01" // Metal
	FootStepSounds(9)="Footsteps.metal5_02"
	FootStepSounds(10)="Footsteps.metal5_03"
	FootStepSounds(11)="Footsteps.metal5_04"
	FootStepSounds(12)="Footsteps.wood7_01" // Wood
	FootStepSounds(13)="Footsteps.wood7_02"
	FootStepSounds(14)="Footsteps.wood7_03"
	FootStepSounds(15)="Footsteps.wood7_04"
	FootStepSounds(16)="Footsteps.Grass1_01" // Plant
	FootStepSounds(17)="Footsteps.Grass1_02"
	FootStepSounds(18)="Footsteps.Grass1_01"
	FootStepSounds(19)="Footsteps.Grass1_02"
	FootStepSounds(20)="Footsteps.shrub1_01" // Flesh
	FootStepSounds(21)="Footsteps.shrub1_02"
	FootStepSounds(22)="Footsteps.shrub1_03"
	FootStepSounds(23)="Footsteps.shrub1_04"
	FootStepSounds(24)="Footsteps.stone5_01" // Ice
	FootStepSounds(25)="Footsteps.stone5_02"
	FootStepSounds(26)="Footsteps.stone5_03"
	FootStepSounds(27)="Footsteps.stone5_04"
	FootStepSounds(28)="Footsteps.snow-flat1_05" // Snow
	FootStepSounds(29)="Footsteps.snow-flat1_06"
	FootStepSounds(30)="Footsteps.snow-flat1_07"
	FootStepSounds(31)="Footsteps.snow-flat1_08"
	FootStepSounds(32)="UnrealShare.LSplash" // Water
	FootStepSounds(33)="UnrealShare.LSplash"
	FootStepSounds(34)="UnrealShare.LSplash"
	FootStepSounds(35)="UnrealShare.LSplash"
	FootStepSounds(36)="Footsteps.stone5_01" // Glass
	FootStepSounds(37)="Footsteps.stone5_02"
	FootStepSounds(38)="Footsteps.stone5_03"
	FootStepSounds(39)="Footsteps.stone5_04"
	FootStepSounds(40)="Footsteps.carpet1_03" // Carpet
	FootStepSounds(41)="Footsteps.carpet1_04"
	FootStepSounds(42)="Footsteps.carpet1_05"
	FootStepSounds(43)="Footsteps.carpet1_06"
	FootDecalStr="UnrealShare.FootDecal"
}