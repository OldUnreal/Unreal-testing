//=============================================================================
// TriggeredDeath.
// When triggered, kills the player, causing screen flashes and sounds.
//=============================================================================
class TriggeredDeath extends Triggers;

var() Sound  MaleDeathSound;
var() Sound  FemaleDeathSound;
var() float  StartFlashScale;
var() Vector StartFlashFog;
var() float  EndFlashScale;
var() Vector EndFlashFog;
var() float  ChangeTime;
var() Name   DeathName;
var() bool   bDestroyItems;	// destroy any items which may touch it as well

var float TimePassed[8];
var PlayerPawn Victim[8];

auto state Enabled
{
	function Touch( Actor Other )
	{
		local inventory Inv;
		local Pawn P;
		local GameRules GR;

		// Something has contacted the death trigger.
		// If it is a PlayerPawn, have it screen flash and
		// die.
		if ( Other.bIsPawn )
		{
			P = Pawn(Other);
			if (P.Health <= 0)
				return;

			for (GR = Level.Game.GameRules; GR != none; GR = GR.NextRules )
				if (GR.bHandleDeaths && GR.PreventDeath(P, none, DeathName))
					return;

			P.Weapon = None;
			P.SelectedItem = None;
			foreach P.AllInventory(class'Inventory',Inv)
				Inv.Destroy();

			if (PlayerPawn(Other) != none)
				InitTriggeredPlayerPawnDeath(PlayerPawn(Other));
			else
				KillVictim(P);
		}
		else if ( bDestroyItems )
			Other.Destroy();
	}

	function InitTriggeredPlayerPawnDeath(PlayerPawn P)
	{
		local TriggeredPlayerPawnDeath TriggeredPlayerPawnDeath;
		local int VNum;

		if (Class == class'TriggeredDeath')
		{
			foreach P.ChildActors(class'TriggeredPlayerPawnDeath', TriggeredPlayerPawnDeath)
				return;
			TriggeredPlayerPawnDeath = Spawn(class'TriggeredPlayerPawnDeath', P);
		}
		if (TriggeredPlayerPawnDeath != none)
		{
			TriggeredPlayerPawnDeath.Victim = P;
			TriggeredPlayerPawnDeath.TriggeredDeath = self;
		}
		else
		{
			Enable('Tick');
			While ( (VNum < 7) && (Victim[VNum] != None) )
			VNum++;
			Victim[Vnum] = P;
			TimePassed[VNum] = 0;
		}

		P.Health = 1;
		if ( P.bIsFemale )
			P.PlaySound( FemaleDeathSound, SLOT_Talk );
		else
			P.PlaySound( MaleDeathSound, SLOT_Talk );
	}

	function KillVictim(Pawn Victim)
	{
		local int OldHealth;

		if (Victim.Health <= 0)
			return;
		OldHealth = Victim.Health;
		Victim.NextState = '';
		Victim.Health = -1;
		Victim.Died(None, DeathName, Victim.Location);
		if (Victim.Health > 0)
			Victim.Health = OldHealth;
	}

	function Tick( float DeltaTime )
	{
		local Float CurScale;
		local vector CurFog;
		local float  TimeRatio;
		local int i;
		local bool bFoundVictim;

		for ( i=0; i<8; i++ )
			if ( Victim[i] != None )
			{
				if ( Victim[i].Health > 1 )
					Victim[i] = None;
				else
				{
					// Check the timing
					TimePassed[i] += DeltaTime;
					if ( TimePassed[i] >= ChangeTime )
					{
						Victim[i].ClientFlash( EndFlashScale, 1000 * EndFlashFog );
						if ( Victim[i].Health > 0 )
							KillVictim(Victim[i]);
						Victim[i] = None;
					}
					else
					{
						bFoundVictim = true;
						// Continue the screen flashing
						TimeRatio = TimePassed[i]/ChangeTime;
						CurScale = (EndFlashScale-StartFlashScale)*TimeRatio + StartFlashScale;
						CurFog   = (EndFlashFog  -StartFlashFog  )*TimeRatio + StartFlashFog;
						Victim[i].ClientFlash( CurScale, 1000 * CurFog );
					}
				}
			}
		if ( !bFoundVictim )
			Disable('Tick');
	}
}

defaultproperties
{
}
