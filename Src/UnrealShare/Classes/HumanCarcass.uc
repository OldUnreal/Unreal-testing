//=============================================================================
// HumanCarcass.
//=============================================================================
class HumanCarcass extends CreatureCarcass
			abstract;

var class<CreatureChunks> MasterReplacement;

function CreateReplacement()
{
	local CreatureChunks carc;

	if (bHidden)
		return;
	carc = Spawn(MasterReplacement,,, Location + ZOffset[0] * CollisionHeight * vect(0,0,1));
	if (carc != None)
	{
		carc.bMasterChunk = true;
		MasterCreatureChunk(carc).PlayerRep = PlayerOwner;
		carc.Initfor(self);
		carc.Bugs = Bugs;
		if ( Bugs != None )
			Bugs.SetBase(carc);
		Bugs = None;
	}
	else if ( Bugs != None )
		Bugs.Destroy();
}

function SpawnHead()
{
	local carcass carc;

	carc = Spawn(class'FemaleHead');
	if ( carc != None )
		carc.Initfor(self);
}

function Initfor(actor Other)
{
	local int i;

	PlayerOwner = Pawn(Other).PlayerReplicationInfo;
	bReducedHeight = false;
	PrePivot = vect(0,0,0);
	for ( i=0; i<4; i++ )
		Multiskins[i] = Pawn(Other).MultiSkins[i];
	Super.InitFor(Other);
}

function ReduceCylinder()
{
	Super.ReduceCylinder();
	PrePivot = PrePivot - vect(0,0,2);
}

state Dead
{
	function BeginState()
	{
		if ( bDecorative || bPermanent
		|| ((Level.NetMode == NM_Standalone) && Level.Game.IsA('SinglePlayer')) )
			lifespan = 0.0;
		else
		{
			if ( Mover(Base) != None )
			{
				ExistTime = FMax(12.0, 30.0 - 2 * DeathZone.NumCarcasses);
				SetTimer(3.0, true);
			}
			else
				SetTimer(FMax(12.0, 30.0 - 2 * DeathZone.NumCarcasses), false);
		}
	}

}

defaultproperties
{
	bReducedHeight=true
	PrePivot=(X=0.000000,Y=0.000000,Z=26.000000)
	CollisionHeight=+00013.000000
	CollisionRadius=+00027.000000
	bBlockActors=false
	bBlockPlayers=false
	flies=0
}
