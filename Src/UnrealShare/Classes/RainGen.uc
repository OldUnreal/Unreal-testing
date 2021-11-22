//=============================================================================
// RainGen.
// author: c0mpi1e(Carlos Cuello)
// Total Time So Far: 20 hrs.
//
// legal: Everything in this class is 100% original and is the
//        property of me.  It was originally
//		  produced for the USCM:Infestation TC, and any revisions
//		  to this mod will be used in that.  This is the final
//		  version that I will release to the public.  You may use
//		  this in any map and release it as part of any map you
//		  create as long as you give me full credit.  If you need
//		  anything added in particular you can email me and I'll see
//		  what I can do.
// This is basically what controls the Rain and is the only thing you
// will have to work with.  I wanted to keep this something that anyone
// can use, tried to keep it very configurable and tried to make
// everything be handled from UnrealEd.  So for all you map makers,
// simply add as many raingen's to the ceiling of the sky where you want
// it to fall from.  The RainGen delivers a limited range of raindrops, so
// do not expect one raingen to create a monsoon.  To change the various
// settings for the rain, select all the RainGens in your map and click
// on the properties dialog box, then click on the several Rain propety
// menu's that appear(Rain_Behaviour, Rain_Looks, Rain_Sounds).  The
// intensity variable should be kept between 0 and 5 or so to keep
// rendering speed good.  DropSpeed should be negative for faster rain,
// and positive for slower rain, however beware that a positive integer
// greater than 100 or so will cause the raindrops to go up and hit the
// ceiling.
//
// note: for this release, lightning is not working, if you absolutley
// 		 need it, then email me and I'll see what I can do.
//
// ============================================================================
// Additions by }TCP{Wolf
// note file dependencies Packages: AmbOutside, rainT REPLACED by T_RainSnow, AmbAncient
// all original credits go to c0mpi1e(Carlos Cuello), changes I made were
// for the benefit and enhancement to Unreal
// also Krull added textures for different sprites
// changes:
//      client side effect generation
//      Krull: added snow textures
//      RainPuddle creation optional (setting: bCreatePuddles)
//      Raindrops now detect Zone change and create puddles on WATER SURFACES
//         rather than falling through
//      arbitrary raindrop sprite texture (switch RainDrawType to
//         Custom_Texture and put a valid texture in setting CustomTexture)
// re-release 2:
//      adjusted Physics of drops to make them fall at arbitrary speeds
// re-build 3 (}TCP{Wolf):
//      Thanks to Krull again otherwise I would probably never have noticed that
//      there was a problem.
//      - added needed initial replication settings
//=============================================================================
class RainGen expands Effects; // Wolf - old: extends

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Rain\RainDrop.wav" NAME="RainDrop" GROUP="Rain"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Rain\Rain.wav" NAME="Rain" GROUP="Rain"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Rain\WaterStream.wav" NAME="WaterStream" GROUP="Rain"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Rain\WaterStream2.wav" NAME="WaterStream2" GROUP="Rain"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Rain\Thunder.wav" NAME="Thunder" GROUP="Rain"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Rain\Thunder2.wav" NAME="Thunder2" GROUP="Rain"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Rain\RainFountain.wav" NAME="RainFountain" GROUP="Rain"
#exec Texture Import File=Textures\Raindrop.pcx Mips=Off
#exec Texture Import File=Textures\RainLong.pcx Mips=Off
#exec Texture Import File=Textures\RainLong2.pcx Mips=Off
#exec Texture Import File=Textures\SnowStar.pcx Mips=Off
#exec Texture Import File=Textures\Snow1.pcx Mips=Off
#exec Texture Import File=Textures\Snow2.pcx Mips=Off
#exec Texture Import File=Textures\Snow3.pcx Mips=Off
#exec Texture Import File=Textures\Raindrop.pcx Mips=Off
#exec Texture Import File=Textures\Raindrop.pcx Mips=Off


//Variables you can manipulate from UnrealED===================================
//this enum lets a mapper or whatnot choose between 3 different sprites
//for the rain drop.  The parenthesis after var tells unreal that this
//variable can be changed from Unrealed, if you put something in the
//parenthesis then that will be the parent menu of the variable.
var(Rain_Looks) enum ERainType
{
	Custom_Texture,
	Rain_Drop,
	Rain_Line,
	Rain_LongLine,
	Snow_Star,
	Snow_Round,
	Snow_ThickFlake,
	Snow_ThinFlake
} RainDrawType;
var(Rain_Looks) float DropSize;		//the size of each drop

var(Rain_Looks) bool bCreatePuddles;	// Wolf: set true to create RainPuddles on ground
var(Rain_Looks) Texture CustomTexture;	// Wolf: put a texture in here if you use "Custom_Texture" as RainDrawType



var(Rain_Behaviour) float intensity;	//the intensity of the rain // WOLF: changed: lower = more!
var float ticktime;

var(Rain_Behaviour) int DropSpeed;	//determines the drop speed. Neg numbers
//make it drop faster, positive slows it
//down, should be modified for the
//default properties dialog
var(Rain_Behaviour) int RainRadius; //The radius of the rain, which is
//random from 0 to RainRadius
var(Rain_Behaviour) bool bThunder;
var(Rain_Behaviour) bool bLightning;//not implemented yet
var(Rain_Behaviour) bool bLogSpawnfailures;	// Wolf: if flakes/drops fail to spawn, log it! For development
var(Rain_Sounds)	Sound ThunderSound1;
var(Rain_Sounds)	Sound ThunderSound2;
var(Rain_Sounds) nowarn int SoundRadius;
var(Rain_Sounds)	int RainVolume;
//=============================================================================

//Private Variables we want to keep to ourselves===============================
//var	  int ct;						//misc counter variable, used for
//for loops, rather have it as a global
//variable because we might use it more
//than once. **UNUSED**
//var	  Effects   L;					//used for lightining // WOLF: NOT USED!?
//=============================================================================



replication
{
	Reliable if (Role == Role_Authority)
		RainDrawType, DropSize, bCreatePuddles, CustomTexture, intensity, DropSpeed,
		RainRadius, bThunder, bLightning, ThunderSound1, ThunderSound2, SoundRadius,
		RainVolume, bLogSpawnfailures;
}




//set all our variables.
simulated function PreBeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer) return; // Wolf

	Super.PreBeginPlay();
	//we want to enable tick and timer
	//Enable('Tick');
	Enable('Timer');
	//set the timer for every ten clicks we want the thunder to be
	//handled here, randomly.  If you put this into the tick function
	//it slows things down considerably.
	SetTimer(10, true);
	//play the rain sound, using the Ambient slot
	PlaySound(EffectSound1, Slot_Ambient, RainVolume,, SoundRadius);

	//log(role@self@" PREBEGIN PLAY ------------------------- # # # # # #");
}

//find a random number from -Max to Max
simulated function int RandomNeg(int Max)
{
	local int k;

	k = Rand(Max + 1);
	if (Rand(2) == 1)
		k = -k;

//log(role@self@" RandomNeg ------------------------- # # # # # # "$k);
	return k;
}

//this is where thunder and lightning are handled
simulated function Timer()
{
	if (Level.NetMode == NM_DedicatedServer) return; // Wolf
//log(role@self@" TIMER ------------------------- # # # # # #");

	Super.Timer();
	if (bThunder == true && Rand(5) < 3)
	{
		//randomly choose which thunder sound to use
		if (Frand() < 0.5)
			PlaySound(ThunderSound1, Slot_Misc, 25, true);
		else
			PlaySound(ThunderSound2, Slot_Misc, 25, true);
	}

	if (bThunder == false)
		//if we go into the timer, but have bthunder set to false
		//then we no longer want to call the timer, we can put this before
		//in PreBeginPlay, but because we use default properties
		//to handle everything, we will not know then.
		Disable('Timer');
}

//===========================================================================



//this is where everything takes place
simulated function Tick(float deltatime)
{
	local RainDrops D;	//the actual raindrop -- Wolf: changed from class Effects to RainDrops
	local vector NewLoc;	//the location of the random rain drop

	if (Level.NetMode == NM_DedicatedServer) return; // Wolf
	ticktime += deltatime;
	//log(role@self@" TICK TICK TICK ------------------------- # # # # # # "$deltatime@ticktime@intensity);
	if (intensity < 0.0001) intensity = 0.0001;
	if (ticktime < intensity) return; // WOLF

	//for the number of intensity that is set from UnrealEd, then
	//spawn a new raindrop
	//find a new location for the spawned RainDrop, using my
	//function RandomNeg() and base it off of the current Location
	//we only want to produce one on the horizontal plane of
	//sky or ceiling, so we leave the Z axes alone.
	while (ticktime >= intensity)
	{
		NewLoc.X = Location.X + RandomNeg(RainRadius);
		NewLoc.Y = Location.Y + RandomNeg(RainRadius);
		NewLoc.Z = Location.Z;

		//spawn a raindrop at NewLoc
		d = Spawn(class'RainDrops',,,NewLoc);
		if (d != none)
		{
			//set the size to what the user specified
			d.DrawScale = DropSize;
			//same with the speeed
			d.Velocity.Z = DropSpeed*(-1);
			// wolf: set it to spawn puddle or not
			d.bDoCreatePuddle = bCreatePuddles;
			//Depending on what you choose for RainDrawType then set
			//the appropriate Texture.
			switch RainDrawType
		{
			// Wolf: added custom texture feature
		case Custom_Texture:
			d.Texture = CustomTexture;
			break;
		case Rain_Drop:
			d.Texture = Texture'Raindrop';
			break;
		case Rain_Line:
			d.Texture = Texture'RainLong';
			break;
		case Rain_LongLine:
			d.Texture = Texture'RainLong2';
			break;
			// remaing ones added by wolf
		case Snow_Star:
			d.Texture = Texture'SnowStar';
			break;
		case Snow_Round:
			d.Texture = Texture'Snow1';
			break;
		case Snow_ThickFlake:
			d.Texture = Texture'Snow2';
			break;
		case Snow_ThinFlake:
			d.Texture = Texture'Snow3';
			break;
		default:
			d.Texture = Texture'Raindrop';
		}
	}
	else
	{
		if (bLogSpawnfailures)
				log(self@" at "$location$" failed to spawn drop/flake at "$NewLoc,'RAIN');
		}
		ticktime -= intensity;
	}
}


// Wolf: should we use bAlwaysRelevant?
//       as if rain would restart on clients the moment they go into view
//       of the generator, not before.... worth thinking about

defaultproperties
{
	RemoteRole=Role_SimulatedProxy
	DropSize=0.090000
	bCreatePuddles=true
	RainDrawType=Rain_Drop
	bLogSpawnfailures=false
	intensity=0.02
	DropSpeed=200
	RainRadius=50
	bThunder=True
	bLightning=True
	ThunderSound1=Sound'UnrealShare.Thunder'
	ThunderSound2=Sound'UnrealShare.Thunder2'
	SoundRadius=500
	RainVolume=25
	EffectSound1=Sound'UnrealShare.WaterStream2'
	EffectSound2=Sound'UnrealShare.RainFountain'
	bHidden=True
	Velocity=(X=5.000000,Y=20.000000,Z=50.000000)
	DrawType=DT_Sprite
	Texture=Texture'Engine.S_Player'
	AmbientSound=Sound'UnrealShare.WaterStream'
}
