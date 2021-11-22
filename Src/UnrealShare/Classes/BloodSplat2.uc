//=============================================================================
// BloodSplat2.
// A random decal.
//=============================================================================
class BloodSplat2 expands Scorch;


var()		texture		BloodSplats[13];
var()		texture		GrnBloodSplats[13];

#exec AUDIO IMPORT FILE="Sounds\PODDIE3.wav" NAME="PODDIE3" GROUP="BloodDecal"
#exec AUDIO IMPORT FILE="Sounds\BLUDSPLT.wav" NAME="BLUDSPLT" GROUP="BloodDecal"

#exec TEXTURE IMPORT NAME=GrnBloodPool6 FILE=Textures\GrnBloodPool6.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodPool7 FILE=Textures\GrnBloodPool7.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodPool9 FILE=Textures\GrnBloodPool9.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat1 FILE=Textures\GrnBloodSplat1.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat2 FILE=Textures\GrnBloodSplat2.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat3 FILE=Textures\GrnBloodSplat3.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat4 FILE=Textures\GrnBloodSplat4.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat5 FILE=Textures\GrnBloodSplat5.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat6 FILE=Textures\GrnBloodSplat6.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat7 FILE=Textures\GrnBloodSplat7.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat8 FILE=Textures\GrnBloodSplat8.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat9 FILE=Textures\GrnBloodSplat9.pcx GROUP=BloodDecal
#exec TEXTURE IMPORT NAME=GrnBloodSplat10 FILE=Textures\GrnBloodSplat10.pcx GROUP=BloodDecal


simulated function PostBeginPlay()
{
	if (level.netmode == NM_DedicatedServer)
	{
		log("What the hell? Die.");
		destroy();
	}
	if (class'GameInfo'.Default.bLowGore || class'GameInfo'.Default.bVeryLowGore)//Turn off Blood with low gore.
	{
		destroy();
	}

	Texture = BloodSplats[Rand(13)];

	if (Class'Scorch'.Default.DecalLifeSpan < 0.0)
		SetTimer(1.0, false);
	else
		LifeSpan=fmax(0,Class'Scorch'.Default.DecalLifeSpan);

	AttachToSurface();
}
simulated function Green()
{
	DetachDecal();
	Texture = GrnBloodSplats[Rand(13)];
	AttachToSurface();
}

defaultproperties
{
	BloodSplats(0)=Texture'UnrealShare.BloodSplat1'
	BloodSplats(1)=Texture'UnrealShare.BloodSplat2'
	BloodSplats(2)=Texture'UnrealShare.BloodSplat3'
	BloodSplats(3)=Texture'UnrealShare.BloodSplat4'
	BloodSplats(4)=Texture'UnrealShare.BloodSplat5'
	BloodSplats(5)=Texture'UnrealShare.BloodSplat6'
	BloodSplats(6)=Texture'UnrealShare.BloodSplat7'
	BloodSplats(7)=Texture'UnrealShare.BloodSplat8'
	BloodSplats(8)=Texture'UnrealShare.BloodSplat9'
	BloodSplats(9)=Texture'UnrealShare.BloodPool6'
	BloodSplats(10)=Texture'UnrealShare.BloodPool7'
	BloodSplats(11)=Texture'UnrealShare.BloodPool9'
	BloodSplats(12)=Texture'UnrealShare.BloodSplat10'
	GrnBloodSplats(0)=Texture'UnrealShare.BloodDecal.GrnBloodSplat1'
	GrnBloodSplats(1)=Texture'UnrealShare.BloodDecal.GrnBloodSplat2'
	GrnBloodSplats(2)=Texture'UnrealShare.BloodDecal.GrnBloodSplat3'
	GrnBloodSplats(3)=Texture'UnrealShare.BloodDecal.GrnBloodSplat4'
	GrnBloodSplats(4)=Texture'UnrealShare.BloodDecal.GrnBloodSplat5'
	GrnBloodSplats(5)=Texture'UnrealShare.BloodDecal.GrnBloodSplat6'
	GrnBloodSplats(6)=Texture'UnrealShare.BloodDecal.GrnBloodSplat7'
	GrnBloodSplats(7)=Texture'UnrealShare.BloodDecal.GrnBloodSplat8'
	GrnBloodSplats(8)=Texture'UnrealShare.BloodDecal.GrnBloodSplat9'
	GrnBloodSplats(9)=Texture'UnrealShare.BloodDecal.GrnBloodPool6'
	GrnBloodSplats(10)=Texture'UnrealShare.BloodDecal.GrnBloodPool7'
	GrnBloodSplats(11)=Texture'UnrealShare.BloodDecal.GrnBloodPool9'
	GrnBloodSplats(12)=Texture'UnrealShare.BloodDecal.GrnBloodSplat10'
	Texture=Texture'UnrealShare.BloodSplat1'
	DrawScale=0.400000
}
