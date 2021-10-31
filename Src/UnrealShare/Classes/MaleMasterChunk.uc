//=============================================================================
// MaleMasterChunk
//=============================================================================
class MaleMasterChunk extends MasterCreatureChunk;

simulated function ClientExtraChunks(bool bSpawnChunks)
{
	local carcass carc;
	local bloodspurt b;
	local Pawn P;

	If ( Level.NetMode == NM_DedicatedServer )
	return;

	bMustSpawnChunks = false;
	b = Spawn(class 'Bloodspurt',,,,rotang(90,0,0));
	if ( bGreenBlood )
		b.GreenBlood();
	b.RemoteRole = ROLE_None;

	if ( !bSpawnChunks )
		return;

	if ( (CarcassAnim != 'Dead4') && (CarcassAnim != 'Dead5') )
	{
		carc = Spawn(class'MaleHead');
		if ( carc != None )
		{
			carc.Initfor(self);
			carc.RemoteRole = ROLE_None;
			if ( PlayerRep != None ) //check if local player owner
			{
				P = PlayerPawn(PlayerRep.Owner);
				if ( (P != None) && P.IsInState('Dying') )
					PlayerPawn(P).ViewTarget = carc;
			}
		}
	}

	if ( CarcassAnim != 'Dead5' )
	{
		if ( Level.bHighDetailMode )
		{
			if ( FRand() < 0.3 )
			{
				carc = Spawn(class 'Liver');
				if (carc != None)
				{
					carc.Initfor(self);
					carc.RemoteRole = ROLE_None;
				}
			}
			else if ( FRand() < 0.5 )
			{
				carc = Spawn(class 'Stomach');
				if (carc != None)
				{
					carc.Initfor(self);
					carc.RemoteRole = ROLE_None;
				}
			}
			else
			{
				carc = Spawn(class 'PHeart');
				if (carc != None)
				{
					carc.Initfor(self);
					carc.RemoteRole = ROLE_None;
				}
			}
			if ( FRand() < 0.5 )
			{
				carc = Spawn(class 'Leg1');
				if (carc != None)
				{
					carc.Initfor(self);
					carc.RemoteRole = ROLE_None;
				}
			}
		}
		carc = Spawn(class 'CreatureChunks');
		if (carc != None)
		{
			carc.Mesh = mesh 'CowBody1';
			carc.Initfor(self);
			carc.RemoteRole = ROLE_None;
		}
		carc = Spawn(class 'Arm1');
		if (carc != None)
		{
			carc.Initfor(self);
			carc.fatness = 140;
			carc.RemoteRole = ROLE_None;
		}
	}
	carc = Spawn(class 'Leg1');
	if (carc != None)
	{
		carc.Initfor(self);
		carc.fatness = 140;
		carc.RemoteRole = ROLE_None;
	}

	carc = Spawn(class 'Thigh');
	if (carc != None)
	{
		carc.Initfor(self);
		carc.RemoteRole = ROLE_None;
	}
}

defaultproperties
{
}