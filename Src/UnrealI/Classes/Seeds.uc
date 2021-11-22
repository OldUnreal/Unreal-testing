//=============================================================================
// Seeds.
//=============================================================================
class Seeds extends Pickup;

#exec Texture Import File=Textures\HD_Icons\I_HD_Seed.bmp Name=I_HD_Seed Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Seed FILE=Textures\Hud\i_seed.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Seed

//#exec AUDIO IMPORT FILE="Sounds\Pickups\naliseed.wav" NAME="naliseed" GROUP="Pickups"

#exec MESH IMPORT MESH=Seed ANIVFILE=Models\Seed_a.3d DATAFILE=Models\Seed_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=Seed X=0 Y=0 Z=0
#exec MESH SEQUENCE MESH=Seed SEQ=All STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jseed1 FILE=Models\seed.pcx GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=Seed X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=Seed NUM=1 TEXTURE=Jseed1

var vector X,Y,Z;
var Seeds f;
var float ShrinkTime;

state Activated  // Delete from inventory and toss in front of player.
{
	function Timer()
	{
		GoToState('Shrinking');
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Velocity = 0.6*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		bRotatetoDesired=True;
		bFixedRotationDir=False;
		DesiredRotation.Pitch=0;
		DesiredRotation.Yaw=FRand()*65536;
		DesiredRotation.Roll=0;
		RotationRate.Yaw = RotationRate.Yaw*0.75;
		RotationRate.Roll = RotationRate.Roll*0.75;
		RotationRate.Pitch = RotationRate.Pitch*0.75;
		If (VSize(Velocity) < 5)
		{
			bBounce = False;
			SetPhysics(PHYS_None);
			SetTimer(0.5,False);
		}
	}
Begin:
	if (NumCopies>0)
	{
		NumCopies--;
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		f=Spawn(class, Owner, '', Pawn(Owner).Location +10*Y - 20*Z );
		f.NumCopies=-10;
		f.GoToState('Activated');
		GoToState('');
	}
	else
	{
		Disable('Touch');
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		SetPhysics(PHYS_Falling);
		Velocity = Owner.Velocity + Vector(Pawn(Owner).ViewRotation) * 250.0;
		Velocity.z += 100;
		DesiredRotation = RotRand();
		RotationRate.Yaw = 200000*FRand() - 100000;
		RotationRate.Pitch = 200000*FRand() - 100000;
		RotationRate.Roll = 200000*FRand() - 100000;
		bFixedRotationDir=True;
		SetLocation(Owner.Location+Y*10-Z*20);
		if (NumCopies>-5)
			Pawn(Owner).DeleteInventory(Self);
		BecomePickup();
		bBounce=True;
		bCollideWorld=True;
	}
}


state Shrinking
{
	function Timer()
	{
		Spawn(class'NaliFruit',,,Location+Vect(0,0,20),Rotator(Vect(0,1,0)));
		Destroy();
	}
	function Tick(Float DeltaTime)
	{
		ShrinkTime += DeltaTime;
		DrawScale = 1.0 - fMin(ShrinkTime,0.95);
	}
Begin:
	ShrinkTime = 0;
	SetTimer(0.7,False);
}

// Fix for online games on 227:
simulated function HitWall( vector HitNormal, actor Wall )
{
	Velocity = 0.6*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	bRotatetoDesired=True;
	bFixedRotationDir=False;
	DesiredRotation.Pitch=0;
	DesiredRotation.Yaw=FRand()*65536;
	DesiredRotation.Roll=0;
	RotationRate.Yaw = RotationRate.Yaw*0.75;
	RotationRate.Roll = RotationRate.Roll*0.75;
	RotationRate.Pitch = RotationRate.Pitch*0.75;
	If (VSize(Velocity) < 5)
	{
		bBounce = False;
		SetPhysics(PHYS_None);
	}
}
simulated function SetInitialState()
{
	if ( Level.NetMode!=NM_Client )
		Super.SetInitialState();
}

defaultproperties
{
	bCanHaveMultipleCopies=True
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You got the Nali fruit seeds"
	RespawnTime=30.000000
	PickupViewMesh=Mesh'UnrealI.Seed'
	PickupSound=Sound'UnrealI.Pickups.GenPickSnd'
	Icon=Texture'UnrealI.Icons.I_Seed'
	RemoteRole=ROLE_DumbProxy
	Mesh=Mesh'UnrealI.Seed'
	bMeshCurvy=False
	CollisionRadius=12.000000
	CollisionHeight=4.000000
	bCollideWorld=True
	bProjTarget=True
}
