//=============================================================================
// VoiceBox.
//=============================================================================
class VoiceBox extends Pickup;

#exec Texture Import File=Textures\HD_Icons\I_HD_Voicebox.bmp Name=I_HD_Voicebox Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_VoiceBox FILE=Textures\Hud\i_voice.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Voicebox

#exec AUDIO IMPORT FILE="Sounds\Pickups\VOICEB1.wav" NAME="VoiceSnd" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Automag\Shot.wav" NAME="shot" GROUP="AutoMag"
#exec AUDIO IMPORT FILE="Sounds\Stinger\sshot10d.wav" NAME="StingerFire" GROUP="Stinger"
#exec AUDIO IMPORT FILE="Sounds\Flak\shot1.wav" NAME="shot1" GROUP="flak"
#exec AUDIO IMPORT FILE="Sounds\Flak\Explode1.wav" NAME="Explode1" GROUP="flak"
#exec AUDIO IMPORT FILE="Sounds\Flak\expl2.wav" NAME="expl2" GROUP="flak"

#exec MESH IMPORT MESH=VoiceBoxMesh ANIVFILE=Models\voice_a.3d DATAFILE=Models\voice_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=VoiceBoxMesh X=0 Y=0 Z=-15 YAW=64
#exec MESH SEQUENCE MESH=VoiceBoxMesh SEQ=All   STARTFRAME=0  NUMFRAMES=10
#exec MESH SEQUENCE MESH=VoiceBoxMesh SEQ=Pulse STARTFRAME=0  NUMFRAMES=10
#exec TEXTURE IMPORT NAME=Ainv1 FILE=Models\inv.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=VoiceBoxMesh X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=VoiceBoxMesh NUM=1 TEXTURE=Ainv1

var vector X,Y,Z;
var() sound BattleSounds[10];

state Activated  // Delete from inventory and toss in front of player.
{
	function HitWall (vector HitNormal, actor Wall)
	{
		Velocity = 0.5*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		//	PlaySound(Sound 'GrenadeFloor', SLOT_Misc, VSize(Velocity)/1300 );
		If (VSize(Velocity) < 20)
		{
			bBounce = False;
			bStasis = false;
			SetPhysics(PHYS_None);
			GoToState('Playing');
		}
	}
Begin:
	GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
	SetLocation(Pawn(Owner).Location+X*10+Y*8-Z*20);
	Disable('Touch');
	bBounce=True;
	Velocity = Owner.Velocity + Vector(Owner.Rotation) * 150.0;
	Velocity.z += 240;
	DesiredRotation = RotRand();
	RotationRate.Yaw = 20000*FRand() - 10000;
	RespawnTime = 0.0; //don't respawn
	SetPhysics(PHYS_Falling);
	RemoteRole = ROLE_DumbProxy;
	BecomePickup();
	bCollideWorld = true;
	Owner.PlaySound(ActivateSound);
	Pawn(Owner).DeleteInventory(Self);
	bStasis=false;
}


state Playing
{
	function Touch(Actor Other)
	{
		Super.Touch(Other);
	}

	function Timer()
	{
		local int i;

		if( Instigator!=None )
			MakeNoise(1.0);
		for (i=0 ; i<10 ; i++)
			if (FRand()<0.05 && BattleSounds[i]!=None) PlaySound(BattleSounds[i], SLOT_None, FRand()/2+0.5);
		Charge--;
		if (Charge<=0)
		{
			spawn(class'SpriteBallExplosion',,,Location + vect(0,0,1)*16);
			destroy();
		}
	}

	function BeginState()
	{
		bStasis = false;
		SetTimer(0.1,True);
		LoopAnim('Pulse');
	}
}

defaultproperties
{
	BattleSounds(0)=Sound'UnrealShare.AutoMag.shot'
	BattleSounds(1)=Sound'UnrealShare.flak.expl2'
	BattleSounds(2)=Sound'UnrealShare.AutoMag.shot'
	BattleSounds(3)=Sound'UnrealShare.AutoMag.shot'
	BattleSounds(4)=Sound'UnrealShare.flak.Explode1'
	BattleSounds(5)=Sound'UnrealShare.flak.expl2'
	BattleSounds(6)=Sound'UnrealShare.flak.shot1'
	BattleSounds(7)=Sound'UnrealShare.ASMD.TazerFire'
	BattleSounds(8)=Sound'UnrealShare.Stinger.Ricochet'
	BattleSounds(9)=Sound'UnrealShare.AutoMag.shot'
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up the Voice Box"
	RespawnTime=30.000000
	PickupViewMesh=Mesh'UnrealShare.VoiceBoxMesh'
	Charge=100
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	Icon=Texture'UnrealShare.Icons.I_VoiceBox'
	RemoteRole=ROLE_DumbProxy
	Mesh=Mesh'UnrealShare.VoiceBoxMesh'
	AmbientGlow=64
	bMeshCurvy=False
	CollisionRadius=18.000000
	CollisionHeight=8.000000
	bCollideWorld=True
}
