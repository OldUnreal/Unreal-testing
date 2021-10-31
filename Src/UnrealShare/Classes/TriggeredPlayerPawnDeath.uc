class TriggeredPlayerPawnDeath extends Info
	NoUserCreate;

var PlayerPawn Victim;
var TriggeredDeath TriggeredDeath;
var float TimePassed;

event Tick(float DeltaTime)
{
	local float CurScale;
	local vector CurFog;
	local float TimeRatio;

	if (Victim == none || Victim.bDeleteMe || Victim.Health > 1 || TriggeredDeath == none || TriggeredDeath.bDeleteMe)
	{
		Destroy();
		return;
	}

	// Check the timing
	TimePassed += DeltaTime;
	if (TimePassed >= TriggeredDeath.ChangeTime)
	{
		Victim.ClientFlash(TriggeredDeath.EndFlashScale, 1000 * TriggeredDeath.EndFlashFog);
		if (Victim.Health > 0)
			KillVictim();
		Destroy();
	}
	else
	{
		// Continue the screen flashing
		TimeRatio = TimePassed / TriggeredDeath.ChangeTime;
		CurScale = (TriggeredDeath.EndFlashScale - TriggeredDeath.StartFlashScale) * TimeRatio + TriggeredDeath.StartFlashScale;
		CurFog   = (TriggeredDeath.EndFlashFog   - TriggeredDeath.StartFlashFog  ) * TimeRatio + TriggeredDeath.StartFlashFog;
		Victim.ClientFlash(CurScale, 1000 * CurFog);
	}
}

function KillVictim()
{
	local int OldHealth;

	if (Victim.Health <= 0)
		return;
	OldHealth = Victim.Health;
	Victim.Health = -1;
	Victim.Died(None, TriggeredDeath.DeathName, Victim.Location);
	if (Victim.Health > 0)
		Victim.Health = OldHealth;
}

defaultproperties
{
	RemoteRole=ROLE_None
}