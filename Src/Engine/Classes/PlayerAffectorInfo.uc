class PlayerAffectorInfo expands Info
	nousercreate;

var PlayerAffectorInfo NextAffector;
var PlayerPawn PlayerOwner;

final simulated function Init()
{
	PlayerOwner = PlayerPawn(Owner);
}

simulated event PostNetBeginPlay()
{
	if (bNetOwner)
		AddToPlayer(PlayerPawn(Owner));
}

simulated event Destroyed()
{
	ReleaseFromOwner();
}

final simulated function AddToPlayer(PlayerPawn Player)
{
	local PlayerAffectorInfo Affector;

	if (Player == none)
		return;

	for (Affector = Player.FirstPlayerAffector; Affector != none; Affector = Affector.NextAffector)
	{
		if (Affector == self)
			return;
		if (Affector.Class == Class && Affector.Role == ROLE_Authority && !Affector.bDeleteMe)
			Affector.Destroy();
	}

	SetOwner(Player);
	Init();

	NextAffector = Player.FirstPlayerAffector;
	Player.FirstPlayerAffector = self;
}

final simulated function ReleaseFromOwner()
{
	local PlayerAffectorInfo A;

	if (PlayerOwner == none)
		return;

	if (PlayerOwner.FirstPlayerAffector == self)
		PlayerOwner.FirstPlayerAffector = NextAffector;
	else
	{
		for (A = PlayerOwner.FirstPlayerAffector; A != none; A = A.NextAffector)
			if (A.NextAffector == self)
			{
				A.NextAffector = NextAffector;
				break;
			}
	}
	PlayerOwner = none;
}

function ClientAdjustPosition();
function ClientUpdatePlayer(float DeltaTime);
function bool PlayFootStepSound();
function bool ProcessMove(float DeltaTime, out vector NewAccel, out EDodgeDir DodgeMove, rotator DeltaRot);

defaultproperties
{
	RemoteRole=ROLE_None
}
