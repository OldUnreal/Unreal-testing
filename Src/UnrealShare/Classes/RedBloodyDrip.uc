//=============================================================================
// RedBloodyDrip.
//=============================================================================
class RedBloodyDrip expands Drip;


#exec AUDIO IMPORT FILE="Sounds\BLDDRP1.wav" NAME="BLDDRP" GROUP="BloodDecal"


auto state FallingState
{
	simulated function Landed( vector HitNormal )
	{
		HitWall(HitNormal, None);
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		local SmallBloodSplat2 b;
		if (Level.Netmode != NM_DedicatedServer && (!class'Gameinfo'.default.bLowGore && !class'Gameinfo'.default.bVeryLowGore ))
			b=Spawn(class'SmallBloodSplat2',Owner,,Location+HitNormal,Rotator(HitNormal));
		if (b != none)
			b.RemoteRole=Role_None;
		PlaySound(Sound'BLDDRP');
		Destroy();
	}

	simulated singular function touch(actor Other)
	{
		if ( Role < ROLE_Authority )
			PlaySound(sound'BLDDRP');
		Destroy();
	}

Begin:
	PlayAnim('Dripping',0.3);
}

defaultproperties
{
	bNetTemporary=False
	RemoteRole=ROLE_SimulatedProxy
	Style=STY_Modulated
	DrawScale=0.500000
}
