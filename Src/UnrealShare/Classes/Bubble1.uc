//=============================================================================
// Bubble1.
//=============================================================================
class Bubble1 extends Effects
	transient;

#exec Texture Import File=Models\bubble1.pcx  Name=S_bubble1 Mips=Off Flags=2
#exec Texture Import File=Models\bubble2.pcx  Name=S_bubble2 Mips=Off Flags=2
#exec Texture Import File=Models\bubble3.pcx  Name=S_bubble3 Mips=Off Flags=2

simulated function ZoneChange( ZoneInfo NewZone )
{
	if ( !NewZone.bWaterZone )
	{
		Destroy();
		PlaySound (EffectSound1);
	}
}

simulated function BeginPlay()
{
	Super.BeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlaySound(EffectSound2); //Spawned Sound
		LifeSpan = 3 + 4 * FRand();
		Buoyancy = Mass + FRand()+0.1;
		if (FRand()<0.3) Texture = texture'S_Bubble2';
		else if (FRand()<0.3) Texture = texture'S_Bubble3';
		DrawScale += FRand()*DrawScale/2;
	}
}

defaultproperties
{
	Physics=PHYS_Falling
	DrawType=DT_Sprite
	Style=STY_Translucent
	Texture=Texture'UnrealShare.S_bubble1'
	Mass=3.000000
	Buoyancy=3.750000
	bNetOptional=true
	LifeSpan=2.000000
	RemoteRole=ROLE_SimulatedProxy
}
