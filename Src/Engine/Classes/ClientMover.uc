//=============================================================================
// ClientSide mover
// To be used for non-interactive client side background decos in maps.
//=============================================================================
Class ClientMover extends Mover;

simulated function BeginPlay()
{
	Role = ROLE_Authority;

	// Init key info.
	KeyNum         = Clamp( KeyNum, 0, ArrayCount(KeyPos)-1 );
	PhysAlpha      = 0.0;

	// Set initial location/rotation.
	Move( BasePos + KeyPos[KeyNum] - Location, BaseRot + KeyRot[KeyNum] );
	
	if( Level.NetMode==NM_DedicatedServer )
		SetCollision(false, false, false);
}
function PostBeginPlay();
function PreBeginPlay();
function bool EncroachingOn( actor Other );
function Bump( actor Other );
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType);
function Reset();
function Trigger( actor Other, pawn EventInstigator );
function bool HandleDoor(pawn Other);

simulated function SetInitialState()
{
	if( Level.NetMode!=NM_DedicatedServer )
		Super.SetInitialState();
}

simulated function FinishedOpening()
{
	// Update sound effects.
	PlaySound( OpenedSound, SLOT_None );
}

state() ConstantLoop
{
Ignores UnTrigger,Trigger,Reset,MakeGroupStop,MakeGroupReturn;

	simulated function DoOpen()
	{
		local byte i;
		
		if( bOpening )
		{
			i = KeyNum + 1;
			if ( i >= NumKeys ) i = 0;
			PlaySound( OpeningSound );
		}
		else
		{
			i = PrevKeyNum;
			bOpening = true;
			PlaySound( ClosingSound );
		}
		bDelaying = false;
		InterpolateTo( i, MoveTime );
		AmbientSound = MoveAmbientSound;
	}
}

defaultproperties
{
	RemoteRole=ROLE_None
	bAlwaysRelevant=false
	bBlockActors=false
	bBlockPlayers=false
	bProjTarget=false
	bCollideActors=false
	MoverEncroachType=ME_IgnoreWhenEncroach
	InitialState="ConstantLoop"
}