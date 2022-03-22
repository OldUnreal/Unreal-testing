//=============================================================================
// scorch
//=============================================================================
class Scorch expands Decal Config;

var bool bAttached, bStartedLife, bImportant;
var(Decal) GlobalConfig Float DecalLifeSpan;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Class'Scorch'.Default.DecalLifeSpan<0)
		SetTimer(1.0, false); //Default
	else
		LifeSpan=fmax(0,Class'Scorch'.Default.DecalLifeSpan); //Stay around as long as the user wants in seconds. 0 = Forever.
}


simulated function Timer()
{
	// Check for nearby players, if none then destroy self

	if ( !bAttached )
	{
		Destroy();
		return;
	}

	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
		if ( Level.bDropDetail )
			SetTimer(5.0 + 2 * FRand(), false);
		else
			SetTimer(18.0 + 5 * FRand(), false);
		return;
	}
	if ( Level.bDropDetail && (MultiDecalLevel < 6) )
	{
		if ( (Level.TimeSeconds - LastRenderedTime > 0.35)
				|| (!bImportant && (FRand() < 0.2)) )
			Destroy();
		else
		{
			SetTimer(1.0, true);
			return;
		}
	}
	else if ( Level.TimeSeconds - LastRenderedTime < 1 )
	{
		SetTimer(5.0, true);
		return;
	}
	Destroy();
}

simulated function Reset()
{
	Destroy();
}

defaultproperties
{
	MultiDecalLevel=4
	bStatic=False
	bStasis=False
	DecalLifeSpan=-1.0
	bAttached=True
	bImportant=True
}
