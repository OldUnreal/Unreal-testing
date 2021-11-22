//=============================================================================
// BloodSpray.
//=============================================================================
class BloodSpray2 expands UnrealBlood
	NoUserCreate;

var() texture		BloodDrips[5];
var() texture		GrnBloodDrips[5];


#exec TEXTURE IMPORT NAME=BD3 FILE=Textures\BD3.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=BD4 FILE=Textures\BD4.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=BD6 FILE=Textures\BD6.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=BD9 FILE=Textures\BD9.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=BD10 FILE=Textures\BD10.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBD3 FILE=Textures\GrnBD3.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBD4 FILE=Textures\GrnBD4.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBD6 FILE=Textures\GrnBD6.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBD9 FILE=Textures\GrnBD9.bmp GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBD10 FILE=Textures\GrnBD10.bmp GROUP=BloodDecal

simulated function PostBeginPlay()
{
	if (class'GameInfo'.Default.bLowGore || class'GameInfo'.Default.bVeryLowGore)//Turn off Blood with low gore.
		destroy();

	Texture = BloodDrips[Rand(5)];
	SetPhysics(PHYS_Falling);
	Velocity.Z = 160;

	super.PostBeginPlay();
}

Simulated function Green()
{
	Texture = GrnBloodDrips[Rand(5)];
	bGreen=True;
}

simulated function Landed(vector HitNormal)
{
	local Bloodsplat2 B;
	if ( Level.NetMode != NM_DedicatedServer )
		B=Spawn(class'BloodSplat2',Owner,,Location+HitNormal,Rotator(HitNormal));
	if (bGreen && B != none)
		b.Green();

	PlaySound(Sound'BLUDSPLT',SLOT_None,0.1,false);

	Destroy();
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local Bloodsplat2 B;
	if ( Level.NetMode != NM_DedicatedServer )
		B=Spawn(class'BloodSplat2',Owner,,Location+HitNormal,Rotator(HitNormal));
	if (bGreen && B != none)
		b.Green();
	PlaySound(Sound'BLUDSPLT',SLOT_None,0.1,false);

	Destroy();

}

defaultproperties
{
	BloodDrips(0)=Texture'UnrealShare.BloodDecal.BD3'
	BloodDrips(1)=Texture'UnrealShare.BloodDecal.BD4'
	BloodDrips(2)=Texture'UnrealShare.BloodDecal.BD6'
	BloodDrips(3)=Texture'UnrealShare.BloodDecal.BD9'
	BloodDrips(4)=Texture'UnrealShare.BloodDecal.BD10'
	GrnBloodDrips(0)=Texture'UnrealShare.BloodDecal.GrnBD3'
	GrnBloodDrips(1)=Texture'UnrealShare.BloodDecal.GrnBD4'
	GrnBloodDrips(2)=Texture'UnrealShare.BloodDecal.GrnBD6'
	GrnBloodDrips(3)=Texture'UnrealShare.BloodDecal.GrnBD9'
	GrnBloodDrips(4)=Texture'UnrealShare.BloodDecal.GrnBD10'
	Physics=PHYS_Falling
	DrawType=DT_Sprite
	Style=STY_Masked
	Texture=Texture'UnrealShare.BloodDecal.BD3'
	DrawScale=0.350000
	AmbientGlow=56
	bUnlit=True
	bParticles=True
	CollisionRadius=1.000000
	CollisionHeight=1.000000
	bCollideActors=True
	bCollideWorld=True
}
