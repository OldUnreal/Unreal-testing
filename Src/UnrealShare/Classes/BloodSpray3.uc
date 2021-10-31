//=============================================================================
// BloodSpray3.
// Trailing blood that obeys phyiziks //modified for 227 by []KAOS[]Casey
//=============================================================================
class BloodSpray3 expands UnrealBlood
	NoUserCreate;

simulated function PostBeginPlay()
{
	if (class'GameInfo'.Default.bLowGore || class'GameInfo'.Default.bVeryLowGore)//Turn off Blood with low gore.
		destroy();
	SetPhysics(PHYS_Falling);
	Disable('AnimEnd');
	LoopAnim('Trail');
	Velocity.Z = 160;
	Super.PostBeginPlay();

}

Function Green()
{
	bGreen=true;
	Texture=Texture'GrnBD10';
	MultiSkins[0]=Texture'GrnBD10';
	MultiSkins[1]=Texture'GrnBD6';
	MultiSkins[2]=Texture'GrnBD4';
	MultiSkins[3]=Texture'GrnBD4';
	MultiSkins[4]=Texture'GrnBD9';
	MultiSkins[5]=Texture'GrnBD3';
	MultiSkins[6]=Texture'GrnBD3';
	MultiSkins[7]=Texture'GrnBD10';
}

simulated function Tick( float DeltaTime )
{
	SetRotation(Rotator(Velocity));
}

function AnimEnd()
{
	Disable('AnimEnd');
}

simulated function Landed(vector HitNormal)
{
	local Bloodsplat2 BS2;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		BS2=Spawn(class'BloodSplat2',Owner,,Location+HitNormal,Rotator(HitNormal));
		if (bGreen && BS2 != none)
			BS2.Green();
	}
	PlaySound(Sound'BLUDSPLT',SLOT_None,0.25,false);

	Destroy();
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local Bloodsplat2 BS2;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		BS2=Spawn(class'BloodSplat2',Owner,,Location+HitNormal,Rotator(HitNormal));
		if (bGreen && BS2 != none)
			BS2.Green();
	}

	PlaySound(Sound'BLUDSPLT',SLOT_None,0.25,false);

	Destroy();

}

defaultproperties
{
	Mesh=LodMesh'UnrealShare.BloodTrl'
	DrawScale=0.350000
	bRandomFrame=True
	MultiSkins(0)=Texture'UnrealShare.BloodDecal.BD10'
	MultiSkins(1)=Texture'UnrealShare.BloodDecal.BD6'
	MultiSkins(2)=Texture'UnrealShare.BloodDecal.BD4'
	MultiSkins(3)=Texture'UnrealShare.BloodDecal.BD4'
	MultiSkins(4)=Texture'UnrealShare.BloodDecal.BD9'
	MultiSkins(5)=Texture'UnrealShare.BloodDecal.BD3'
	MultiSkins(6)=Texture'UnrealShare.BloodDecal.BD3'
	MultiSkins(7)=Texture'UnrealShare.BloodDecal.BD10'
	CollisionRadius=1.000000
	CollisionHeight=1.000000
	bCollideWorld=True
}
