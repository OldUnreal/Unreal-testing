//=======================================================
// class       : UIBeamEmitter
// file        : UIBeamEmitter.uc
// author      : Raven
// game        : Unreal 1 Patch v 227
// description : Spawns beam
//=======================================================
class UIBeamEmitter extends UIBeam;

#exec TEXTURE IMPORT NAME=BeamEmitter FILE="Textures\BeamEmitter.pcx" GROUP=Icons LODSET=2 FLAGS=2

#exec mesh import mesh=electric_beam anivfile=Models\electric_beam_a.3d datafile=Models\electric_beam_d.3d x=-512 y=0 z=0 mlod=0
#exec mesh origin mesh=electric_beam x=-512 y=0 z=0
#exec mesh sequence mesh=electric_beam seq=All startframe=0 numframes=1

#exec meshmap new meshmap=electric_beam mesh=electric_beam
#exec meshmap scale meshmap=electric_beam x=0.06250 y=0.06250 z=0.12500

enum ESizingType
{
	ST_BySize,
	ST_BySegments
};
//=============================================================================
// info about beam mesh
//=============================================================================
var(Beam_Mesh) mesh BeamMesh;                                // mesh
var(Beam_Mesh) float BeamMeshSize;                           // default mesh size (in uu)
var(Beam_Mesh) EMeshOrientation MeshOrientation;             // default mesh axis
//=============================================================================
// main beam info
//=============================================================================
var(Beam_Main) float BeamSize;                               // total beam size (in uu, if SizingType is ST_BySize) note that not final beam size is rounded
var(Beam_Main) int BeamSegments;                             // number of segments in beam (if SizingType is in ST_BySegemnts)
var(Beam_Main) ESizingType SizingType;                       // sizing type
var(Beam_Main) float BeamSprayFactor;                        // beam spray factor
var(Beam_Main) vector EffectArea;                            // effect area in which beam will be spawned (random place in that area)
var(Beam_Main) float BeamUpdateTime;                         // beam update time (lower value faster updates)
var(Beam_Main) bool bKeepShape;                              // should beam have one shape (once beam is created it'll not change). Good for lightnings
//=============================================================================
// World interaction
//=============================================================================
var(Beam_Interaction) bool bUseHitLocation;                  // should beam use HitLocation (if true, you can damage player)
var(Beam_Interaction) bool bStopOnCollision;                 // should beam stop on collision (eg. with Pawns)
//=============================================================================
// Effects
//=============================================================================
var(Beam_Effect) class<actor> WallHitEffect;                 // effect spawed when beam hit's wall
var(Beam_Effect) class<decal> WallHitDecal;                  // decal which beam
//=============================================================================
// Damage
//=============================================================================
var(Beam_Damage) bool bDamageActors;                         //
var(Beam_Damage) name BeamDamageType;                        //
var(Beam_Damage) int BeamDamage;                             //
var(Beam_Damage) float BeamMomentumTransfer;                 //
//=============================================================================
// Target
//=============================================================================
var(Beam_Target) actor BeamTarget;                           //
var(Beam_Target) float BeamTargetSpray;                      //
var(Beam_Target) bool bForceTargetClip;                      //
var(Beam_Target) float BeamTargetClipDistance;               //
//=============================================================================
// The way beam look
//=============================================================================
var(Beam_Look) float BeamDrawScale;                          //
var(Beam_Look) texture BeamSkin;                             //
var(Beam_Look) ERenderStyle BeamStyle;                       //
//=============================================================================
// Light
//=============================================================================
var(Beam_Light) bool bCastLight;                             // will cast light!!
//=============================================================================
// Light Color
//=============================================================================
var(Beam_LightColor) byte BeamLightBrightness;               // light brightness
var(Beam_LightColor) byte BeamLightHue;                      // light hue
var(Beam_LightColor) byte BeamLightSaturation;               // light satruation
//=============================================================================
// Light effects/type/radius/etc.
//=============================================================================
var(Beam_Lighting) ELightType  BeamLightType;                // light type (can lag :))
var(Beam_Lighting) ELightEffect BeamLightEffect;             // light effect (can lag :))
var(Beam_Lighting) byte BeamLightRadius;                     // light radius
var(Beam_Lighting) byte BeamLightPeriod;                     // light period
var(Beam_Lighting) byte BeamLightPhase;                      // light phase
var(Beam_Lighting) byte BeamLightCone;                       // light cone
var(Beam_Lighting) byte BeamVolumeBrightness;                // volume brightness
var(Beam_Lighting) byte BeamVolumeRadius;                    // volume radius
var(Beam_Lighting) byte BeamVolumeFog;                       // volume fog
var(Beam) bool IsActive;

var int RealNumSegments;
var UIStartBeam Beam;
var float ReturnNormalScale;
var bool bNoUpdates;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority ) IsActive;
}

simulated function PreBeginPlay()
{
	if (SizingType == ST_BySize) RealNumSegments=int(BeamSize/(BeamMeshSize*BeamDrawScale));
	else RealNumSegments=BeamSegments;
	if (RealNumSegments <= 0) RealNumSegments=1;
	ReturnNormalScale=BeamMeshSize*BeamDrawScale;
}

simulated function AddLight(UIBaseBeam A)
{
	A.LightType=BeamLightType;
	A.LightEffect=BeamLightEffect;
	A.LightBrightness=BeamLightBrightness;
	A.LightHue=BeamLightHue;
	A.LightSaturation=BeamLightSaturation;
	A.LightRadius=BeamLightRadius;
	A.LightPeriod=BeamLightPeriod;
	A.LightPhase=BeamLightPhase;
	A.LightCone=BeamLightCone;
	A.VolumeBrightness=BeamVolumeBrightness;
	A.VolumeRadius=BeamVolumeRadius;
	A.VolumeFog=BeamVolumeFog;
}
simulated function MakeBeam()
{

	Beam=Spawn(class'UIStartBeam',self,'',Location+RandLoc(EffectArea),Rotation);
	Beam.Mesh=BeamMesh;
	Beam.DrawScale=BeamDrawScale;
	Beam.Texture=BeamSkin;
	Beam.Skin=BeamSkin;
	Beam.Style=BeamStyle;
	if (bCastLight) AddLight(Beam);
}
//=============================================================================
// Beam is always on and can not be shut down
//=============================================================================
simulated state() AlwaysOn
{
	simulated function BeginState()
	{
		if (Beam == none) MakeBeam();
	}
}
//=============================================================================
// Beam is active at the begining and will be shut down by a trigger
//=============================================================================
simulated state() TriggerTurnsOff
{
	simulated function BeginState()
	{
		if (Beam == none) MakeBeam();
	}
	function Trigger(Actor Other, Pawn Instigator)
	{
		if (Beam != none)
		{
			Beam.Destroy();
			Beam=none;
		}
	}
}
//=============================================================================
// Beam isn't active and will be turn on by a trigger
//=============================================================================
simulated state() TriggerTurnsOn
{
	simulated function Trigger(Actor Other, Pawn Instigator)
	{
		if (Beam == none) MakeBeam();
	}
}
//=============================================================================
// Beam can be shut donwn/turn on by a trigger
//=============================================================================
simulated state() TriggerToggle
{
	simulated function Trigger(Actor Other, Pawn Instigator)
	{
		IsActive=!IsActive;
		if (IsActive)
		{
			if (Beam == none) MakeBeam();
		}
		else
		{
			if (Beam != none)
			{
				Beam.Destroy();
				Beam=none;
			}
		}
	}
}
//=============================================================================
// Start when triggered, Stop when get untriggered.
//=============================================================================
simulated state() TriggerControl
{
	simulated function Trigger( actor Other, pawn EventInstigator )
	{
		if (Beam == none) MakeBeam();
	}
	simulated function UnTrigger( actor Other, pawn EventInstigator )
	{
		if (Beam != none)
		{
			Beam.Destroy();
			Beam=none;
		}
	}
}

defaultproperties
{
	bHidden=True
	bDirectional=True
	Texture=Texture'BeamEmitter'
	BeamUpdateTime=0.03
	BeamTargetSpray=0.6
	BeamMesh=Mesh'electric_beam'
	BeamMeshSize=64.000000
	BeamSize=512.000000
	BeamSegments=5
	BeamSprayFactor=1.000000
	BeamDrawScale=0.50000
	//BeamSkin=Texture'bluestuff'
	BeamStyle=STY_Translucent
	BeamTargetClipDistance=64
	bNoDelete=true
}