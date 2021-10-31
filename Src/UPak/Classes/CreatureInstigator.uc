//=============================================================================
// CreatureInstigator.
//=============================================================================
class CreatureInstigator expands Info;

var() Pawn EnragedPawn;
var() Pawn PawnVictim[ 12 ];
var int CurrentVictim;

function PostBeginPlay()
{
	SetTimer( 0.25, false );
}

function Timer()
{
	if( PawnVictim[ CurrentVictim ] != none )
	{
		EnragedPawn.Enemy = PawnVictim[ CurrentVictim ];
		EnragedPawn.Target = PawnVictim[ CurrentVictim ];
		EnragedPawn.GotoState( 'Attacking' );
	}
}

function Tick( float DeltaTime )
{
	if( EnragedPawn.Health <= 0 )
		Destroy();
	else if( PawnVictim[ CurrentVictim ].Health <= 0 )
		AttackNextVictim();
}

function AttackNextVictim()
{
	CurrentVictim++;
	
	if( PawnVictim[ CurrentVictim ] != none )
	{
		EnragedPawn.Enemy = PawnVictim[ CurrentVictim ];
		EnragedPawn.Target = PawnVictim[ CurrentVictim ];
		EnragedPawn.GotoState( 'Attacking' );
	}
	else Destroy();
}

defaultproperties
{
}
