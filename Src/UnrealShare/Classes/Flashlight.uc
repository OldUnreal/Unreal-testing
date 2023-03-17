//=============================================================================
// flashlight
//=============================================================================
class Flashlight extends Pickup;

#exec AUDIO IMPORT FILE="Sounds\Pickups\FSHLITE1.wav" NAME="FSHLITE1"   GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\fshlite2.wav" NAME="FSHLITE2"   GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_FlashLight.bmp Name=I_HD_FlashLight Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Flashlight FILE=Textures\Hud\i_flash.pcx GROUP="Icons" MIPS=OFF HD=I_HD_FlashLight

#exec TEXTURE IMPORT NAME=JFlashl1HD FILE=Models\flashl.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JFlashl1 FILE=Models\flashl_old.pcx GROUP=Skins FLAGS=2 HD=JFlashl1HD

#exec MESH IMPORT MESH=Flashl ANIVFILE=Models\flashl_a.3d DATAFILE=Models\flashl_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Flashl X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=flashl SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec MESH SEQUENCE MESH=flashl SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec MESHMAP SCALE MESHMAP=Flashl X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=flashl NUM=1 TEXTURE=Jflashl1

var FlashLightBeam s;
var float TimeChange;
var vector HitNormal,HitLocation,EndTrace,StartTrace,X,Y,Z,NewHitLocation;

state Activated
{
	function endstate()
	{
		if( s && !s.bDeleteMe )
			s.Destroy();
		s = None;
		bActive = false;
	}

	function Tick( float DeltaTime )
	{
		TimeChange += DeltaTime*10;
		if (TimeChange > 1)
		{
			if ( s == None )
			{
				UsedUp();
				return;
			}
			Charge -= int(TimeChange);
			TimeChange = TimeChange - int(TimeChange);
		}

		if (!s) Return;

		if ( !Pawn(Owner) )
		{
			s.Destroy();
			UsedUp();
			return;
		}
		if (Charge<-0)
		{
			s.Destroy();
			UsedUp();
			return;
		}

		if (Charge<400) 
			s.LightBrightness=byte(Charge*0.6+10);
		else s.LightBrightness = s.default.LightBrightness; 

		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		EndTrace = Pawn(Owner).Location + 10000* Vector(Pawn(Owner).ViewRotation);
		Trace(HitLocation,HitNormal,EndTrace,Pawn(Owner).Location, True);
		s.SetLocation(HitLocation-vector(Pawn(Owner).ViewRotation)*64);
//		s.LightRadius = fmin(Vsize(HitLocation-Pawn(Owner).Location)/200,14) + 2.0;
	}

	function BeginState()
	{
		bActive = true;
		TimeChange = 0;
		Owner.PlaySound(ActivateSound);
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		EndTrace = Pawn(Owner).Location + 10000* Vector(Pawn(Owner).ViewRotation);
		Trace(HitLocation,HitNormal,EndTrace,Pawn(Owner).Location+Y*17);
		s = Spawn(class'FlashLightBeam',Owner, '', HitLocation+HitNormal*40);
		s.LightHue = LightHue;
		s.LightRadius = LightRadius;
		if (Charge<400) s.LightBrightness=byte(Charge*0.6+10);
		if (!s) GoToState('DeActivated');
	}

Begin:
}
state DeActivated
{
Begin:
	if (s)
	{
		s.Destroy();
		s = None;
	}
	Owner.PlaySound(DeActivateSound);
}

// 227j: Support switching sub-levels.
function OnSubLevelChange( LevelInfo PrevLevel )
{
	Super.OnSubLevelChange(PrevLevel);
	if( s && !s.bDeleteMe )
		s.SendToLevel(Level, Location);
}

defaultproperties
{
	ExpireMessage="Flashlight batteries have died."
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up the flashlight"
	RespawnTime=40.000000
	PickupViewMesh=Mesh'UnrealShare.Flashl'
	Charge=800
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ActivateSound=Sound'UnrealShare.Pickups.FSHLITE1'
	DeActivateSound=Sound'UnrealShare.Pickups.FSHLITE2'
	Icon=Texture'UnrealShare.Icons.I_Flashlight'
	RemoteRole=ROLE_DumbProxy
	Mesh=Mesh'UnrealShare.Flashl'
	AmbientGlow=96
	bMeshCurvy=False
	CollisionRadius=22.000000
	CollisionHeight=4.000000
	LightBrightness=100
	LightHue=33
	LightSaturation=187
	LightRadius=7
}
