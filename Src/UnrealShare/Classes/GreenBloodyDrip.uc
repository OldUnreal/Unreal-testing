//=============================================================================
// GreenBloodyDrip.
//=============================================================================
class GreenBloodyDrip expands RedBloodyDrip;


#exec TEXTURE IMPORT NAME=GrnJmisc1 FILE=Textures\GrnJmisc1.pcx GROUP=BloodDecal


auto state FallingState
{

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local SmallBloodSplat2 b;
		if (Level.Netmode != NM_DedicatedServer && (!class'Gameinfo'.default.bLowGore && !class'Gameinfo'.default.bVeryLowGore ))
			b=Spawn(class'SmallBloodSplat2',Owner,,Location+HitNormal,Rotator(HitNormal));
		if (b != none)
			b.green();
		PlaySound(Sound'BLDDRP');
		Destroy();
	}


}

defaultproperties
{
	Texture=Texture'GrnJmisc1'
	Skin=Texture'GrnJmisc1'
	bNetTemporary=False
	RemoteRole=ROLE_SimulatedProxy
	Style=STY_Modulated
	DrawScale=0.500000
}
