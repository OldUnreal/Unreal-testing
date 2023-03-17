//========================================================
// class        : VegetationGenerator
// file         : VegetationGenerator.uc
// author       : Raven
// game         : The Chosen One
// description  : Spawn Vegetation (plants) in the effect area
// version      : 1.1
//========================================================
// version history:
// 1.1
//     - added few optimalizations
// 1.0
//     - CutVegetation and VegetationVisibility
//     - Bush Sound
// 0.9
//     - Most of the var's is now in struct
//     - Many new options
// 0.8
//     - first version :)
//========================================================
class UIVegetationGenerator extends Actor;
//====================================================================================================
#exec TEXTURE IMPORT NAME=VegetationGenerator FILE="Textures\Icons\VegetationGen.bmp" GROUP=Icons LODSET=2
//====================================================================================================
// main var's
//====================================================================================================
enum EPlayType
{
	PT_Loop,
	PT_Play
};

struct SPlants
{
	var() class<UIFlora> PlantClass;       // gras to spawn
	var() float VegetationScale;                // Vegetation scale
	var() float VegetationScaleVariance;        // Vegetation scale variance
	var() bool bUseCustomGlow;             // should we use custom glow
	var() float VegetationGlow;                 // scale glow
	var() float VegetationGlowVariance;         // scale glow variance
	var() bool bUseCustomAmbientGlow;      // should we use custom Ambient Glow
	var() byte VegetationAmbientGlow;           // ambient glow
	var() bool bUnlitVegetation;                // gras should be unlit?
	var() bool bRandomRotation;            // use random rotation
	var() bool bUseCustomRotation;         // use custom rotation (cant be used with random rotation)
	var() rotator CustomRotation;          // custom rotation
	var() bool CullVegetation;                  // planst will be hidden if we are too far from them (VegetationVisibilityRadius)
	var() float CullRadius;                // radius in which Vegetation will be visible
	var() float CullHeight;                // radius in which Vegetation will be visible
	var() bool PlayBushSound;              // playing bush sound
	var() sound BushSound1;                // bush sound
	var() sound BushSound2;                // bush sound
	var() sound BushSound3;                // bush sound
	var() float BushSoundVolume;
	var() bool bAlignToGround;             // aligns plant to ground
	var() bool bOverrideEffectArea;        // uses effectarea defined in template
	var() vector EffectArea;               // area in which we will spawn Vegetation
	var() bool bOverrideIntensity;         // intensity per template :)
	var() int VegetationIntensity;              // how many plants we have to spawn
	var() bool bOverrideBushSettings;      // oberrides bush settings
	var() vector SpawnOffset;              // spawn offset
	var() bool bUsePhysicsPostAlign;       // set PHYS_Falling in order to fix location
	var() mesh CustomMesh;                 // ustom mesh
	var() bool bUseCustomCollision;        // should use custom collision
	var() float CustomCollisionRadius;     // custom collision radius
	var() float CustomCollisionHeight;     // custom collision height
	var() texture CustomTexture;           // custom texture
	var() texture CustomMultiSkins[8];     // custom multi skins :)
	var() int MultiskinsNum;               // number of multiskins :)
	var() bool bUseAnim;                   // should animation be used
	var() EPlayType PlayType;              // play type
	var() float PlayRate;                  // play rate
	var() float PlayTween;                 // play tween
	var() name AnimName;                   // animation name
	var() bool bOverrideRenderStake;
	var() ERenderStyle PlantRenderStyle;
};
var() SPlants Plants[128];					// plants :)
var() int VegetationIntensity;				// how many plants we have to spawn
var() int NumberOfErrors;					// how much Vegetation can be spawned outside geometry before script stops
var() vector EffectArea;					// area in which we will spawn Vegetation
var() int NumPlants;
var() enum Select
{
	SELECT_Linear,                                                    // cyclically iterate through Plants
	SELECT_Random                                                     // randomly pick a particle from Plants
} SelectionMethod;
var(Advanced) bool bDebug;
var int ChosenTemplate;                                               // current template

//====================================================================================================
// pick up random meshes
//====================================================================================================
simulated function int PickTemplate()
{
	if (NumPlants <= 0) return 0;
	if (SelectionMethod == SELECT_Random) return Rand(NumPlants);
	if (SelectionMethod == SELECT_Linear)
	{
		if (ChosenTemplate == NumPlants-1) ChosenTemplate=0;
		else ChosenTemplate++;
		return ChosenTemplate;
	}
	return 0;
}
//====================================================================================================
// we need to do everythig when game begins, and after this delete generator form the game
//====================================================================================================
simulated function PostBeginPlay()
{
	local int i, j, k;
	local int ChosenPlant, TIntensity;
	
	if (NumPlants > 128)//must fit Plants array size.
		NumPlants=128;

	if (NumPlants <=0) 
		Destroy();
		
	j=0;
	for (k=0; k<NumPlants; k++)
	{
		ChosenPlant=PickTemplate();
		if (Plants[ChosenPlant].bOverrideIntensity) TIntensity=Plants[ChosenPlant].VegetationIntensity;
		else TIntensity = VegetationIntensity;
		i=0;
		while (i<TIntensity)
		{
			if (j>NumberOfErrors) //when too much Vegetation is spawned outside geometry
			{
				Destroy();     //we need to be destroyed, because we may occur critical error
			}
			SpawnPlant(ChosenPlant, j);
			i++;
		}

	}
	Destroy(); //this actor should be destroyed, beacouse it is no longer used
}
//====================================================================================================
// spawns plant
//====================================================================================================
simulated function SpawnPlant(int ChosenPlant, out int j)
{
	local int i, RD;
	local UIFlora SpawnedVegetation;
	local vector TempLoc, RealLoc;
	local rotator NewRot;
	local float GS;
	local Actor HitActor;
	local Vector HitNormal,HitLocation, StartTrace, EndTrace;

	//Pick up new location
	if (Plants[ChosenPlant].bOverrideEffectArea)
	{
		TempLoc.X = Location.X + (1 - FRand() * 2) * Plants[ChosenPlant].EffectArea.X;
		TempLoc.Y = Location.Y + (1 - FRand() * 2) * Plants[ChosenPlant].EffectArea.Y;
		TempLoc.Z = Location.Z; //Z doesnt need to be changed
	}
	else
	{
		TempLoc.X = Location.X + (1 - FRand() * 2) * EffectArea.X;
		TempLoc.Y = Location.Y + (1 - FRand() * 2) * EffectArea.Y;
		TempLoc.Z = Location.Z; //Z doesnt need to be changed
	}
	//trace for ground
	StartTrace = TempLoc;
	EndTrace = StartTrace;
	EndTrace.Z = EndTrace.Z - 300;
	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);

	TempLoc.Z=HitLocation.Z;
	TempLoc+=Plants[ChosenPlant].SpawnOffset;

	SpawnedVegetation = spawn(Plants[ChosenPlant].PlantClass,,,TempLoc,);
	
//            RealLoc=SpawnedVegetation.Location;
//            RealLoc.Z+=SpawnedVegetation.CollisionHeight;
//            SpawnedVegetation.SetLocation(RealLoc);
	if (SpawnedVegetation != none) //if Vegetation exists in the game
	{
		if (Plants[ChosenPlant].bAlignToGround)
		{
			SpawnedVegetation.SetRotation(rotator(HitNormal));
		}
		GS=Plants[ChosenPlant].VegetationScale + (1-FRand()*2) * Plants[ChosenPlant].VegetationScaleVariance;
		SpawnedVegetation.bUnlit=Plants[ChosenPlant].bUnlitVegetation;
		if (!Plants[ChosenPlant].bUsePhysicsPostAlign && Plants[ChosenPlant].bAlignToGround)
		{
			RealLoc.Z=HitLocation.Z;
			RealLoc.Z-=SpawnedVegetation.CollisionHeight;
		}
		if (GS != SpawnedVegetation.DrawScale && Plants[ChosenPlant].bAlignToGround)
		{
			RealLoc=SpawnedVegetation.Location;
			if (SpawnedVegetation.DrawScale < GS)
			{
				RealLoc.Z+=SpawnedVegetation.CollisionHeight*abs(GS-SpawnedVegetation.DrawScale);
			}
			else
			{
				RealLoc.Z-=SpawnedVegetation.CollisionHeight/GS;
			}
			SpawnedVegetation.SetLocation(RealLoc);
		}
		SpawnedVegetation.DrawScale=GS;
		if (Plants[ChosenPlant].bUseCustomCollision) SpawnedVegetation.SetCollisionSize(Plants[ChosenPlant].CustomCollisionRadius*GS, Plants[ChosenPlant].CustomCollisionHeight*GS);
		else SpawnedVegetation.SetCollisionSize(SpawnedVegetation.default.CollisionRadius*GS, SpawnedVegetation.default.CollisionHeight*GS);
		if (Plants[ChosenPlant].bUsePhysicsPostAlign) SpawnedVegetation.SetPhysics(PHYS_Falling);
		if (Plants[ChosenPlant].bUseCustomGlow)
			SpawnedVegetation.ScaleGlow=Plants[ChosenPlant].VegetationGlow+(1-FRand()*2)*Plants[ChosenPlant].VegetationGlowVariance;
		if (Plants[ChosenPlant].bUseCustomAmbientGlow)
			SpawnedVegetation.AmbientGlow=Plants[ChosenPlant].VegetationAmbientGlow;
		if (Plants[ChosenPlant].bRandomRotation)
		{
			RD=Rand(5);
			switch (RD)
			{
			case 0: //45
				NewRot=SpawnedVegetation.Rotation;
				NewRot.Yaw=8192;
				SpawnedVegetation.SetRotation(NewRot);
				break;
			case 1: //90
				NewRot=SpawnedVegetation.Rotation;
				NewRot.Yaw=16384;
				SpawnedVegetation.SetRotation(NewRot);
				break;
			case 2: //180
				NewRot=SpawnedVegetation.Rotation;
				NewRot.Yaw=32768;
				SpawnedVegetation.SetRotation(NewRot);
				break;
			case 3: //270
				NewRot=SpawnedVegetation.Rotation;
				NewRot.Yaw=49152;
				SpawnedVegetation.SetRotation(NewRot);
				break;
			case 4: //360
				NewRot=SpawnedVegetation.Rotation;
				NewRot.Yaw=65536;
				SpawnedVegetation.SetRotation(NewRot);
				break;

			}
		}
		if (Plants[ChosenPlant].bUseCustomRotation)
		{
			SpawnedVegetation.SetRotation(SpawnedVegetation.Rotation+Plants[ChosenPlant].CustomRotation);
		}
		if (Plants[ChosenPlant].CullVegetation)
		{
			SpawnedVegetation.VisibilityRadius=Plants[ChosenPlant].CullRadius;
			SpawnedVegetation.VisibilityHeight=Plants[ChosenPlant].CullHeight;
		}

		if (Plants[ChosenPlant].CustomMesh != none) SpawnedVegetation.Mesh=Plants[ChosenPlant].CustomMesh;
		if (Plants[ChosenPlant].CustomTexture != none)
		{
			SpawnedVegetation.Texture=Plants[ChosenPlant].CustomTexture;
			SpawnedVegetation.Skin=Plants[ChosenPlant].CustomTexture;
		}
		if (Plants[ChosenPlant].MultiskinsNum > 0 && Plants[ChosenPlant].MultiskinsNum < 8)
		{
			for (i=0; i<Plants[ChosenPlant].MultiskinsNum; i++) SpawnedVegetation.MultiSkins[i]=Plants[ChosenPlant].CustomMultiSkins[i];
		}
		if (Plants[ChosenPlant].bOverrideBushSettings)
		{
			SpawnedVegetation.bBushSound=Plants[ChosenPlant].PlayBushSound;
			if (Plants[ChosenPlant].BushSound1 != none)
				SpawnedVegetation.SSound1=Plants[ChosenPlant].BushSound1;
			if (Plants[ChosenPlant].BushSound2 != none)
				SpawnedVegetation.SSound2=Plants[ChosenPlant].BushSound2;
			if (Plants[ChosenPlant].BushSound2 != none)
				SpawnedVegetation.SSound3=Plants[ChosenPlant].BushSound3;
			if (Plants[ChosenPlant].BushSoundVolume > 0)
				SpawnedVegetation.SSoundVolume=Plants[ChosenPlant].BushSoundVolume;

		}
		if (Plants[ChosenPlant].bUseAnim && SpawnedVegetation.HasAnim(Plants[ChosenPlant].AnimName))
		{
			if (Plants[ChosenPlant].PlayType == PT_Loop) SpawnedVegetation.LoopAnim(Plants[ChosenPlant].AnimName, Plants[ChosenPlant].PlayRate, Plants[ChosenPlant].PlayTween);
			else SpawnedVegetation.PlayAnim(Plants[ChosenPlant].AnimName, Plants[ChosenPlant].PlayRate, Plants[ChosenPlant].PlayTween);
		}
		if (Plants[ChosenPlant].bOverrideRenderStake)
		{
			SpawnedVegetation.Style=Plants[ChosenPlant].PlantRenderStyle;

		}
	}
	else
	{
		if (bDebug) log("Error: Vegetation no. "$ChosenPlant$" ("$Plants[ChosenPlant].PlantClass$") from "$self$" can not be spawned - wrong location.",'VegetationGenerator');
		j++;
	}
}
//====================================================================================================
defaultproperties
{
	VegetationIntensity=5
	NumberOfErrors=15
	EffectArea=(X=256.000000,Y=256.000000,Z=0.000000)
	bHidden=true
	Texture=Texture'Unrealshare.Icons.VegetationGenerator'
	Style=STY_Masked
//====================================================================================================
// basic configuration (BaseScale=1.0 VegetationScaleVariance=0.2 and BushSound=true)
//====================================================================================================
	Plants(0)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(1)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(2)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(3)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(4)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(5)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(6)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(7)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(8)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(9)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(10)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(11)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(12)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(13)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(14)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	Plants(15)=(VegetationScale=1.000000,VegetationScaleVariance=0.200000,PlayBushSound=true,BushSound1=Sound'Unrealshare.shrub.shrub1',BushSound2=Sound'Unrealshare.shrub.shrub2',BushSound3=Sound'Unrealshare.shrub.shrub3',VegetationIntensity=5,bAlignToGround=true,bUseCustomRotation=true,CustomRotation=(Pitch=-16384),bUsePhysicsPostAlign=false,BushSoundVolume=64)
	bNoDelete=true
	RemoteRole=ROLE_SimulatedProxy
}
