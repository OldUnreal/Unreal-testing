//=============================================================================
// ClientFadeTrigger.
//=============================================================================
class ClientFadeTrigger expands Triggers;

var() bool bFadeToBlack;
var() bool bFadeToWhite;
var() float DelayTime;

var bool bBlack;
var bool bWhite;

var Pawn Victim;

var float ScaleModifier;

function PostBeginPlay()
{
	SearchPlayers();
	bFadeToBlack = false;
	bFadeToWhite = false;
}

function SearchPlayers()
{
	local PlayerPawn P;
	
	foreach allactors( class'PlayerPawn', P )
	{
		P.ClientAdjustGlow( -1, vect( 0, 0, 0 ) );
	}
}

function Touch( actor Other )
{
	Trigger( Other, Pawn( Other ) );
}

function UnTouch( actor Other )
{
	Trigger( Other, Pawn( Other ) );
}

function Trigger( actor Other, Pawn EventInstigator )
{
	Victim = EventInstigator;
	
	if( bBlack )
	{
		FadeInFromBlack( EventInstigator );
	}
	else if( bWhite )
	{
		FadeInFromWhite( EventInstigator );
	}
	else if( bFadeToBlack )
	{
		FadeToBlack();
				
		if( DelayTime == 0.0 )
		{
			DelayTime = 5.5;
		}
		SetTimer( DelayTime, false );
	}
	else if( bFadeToWhite )
	{
		FadeToWhite( EventInstigator );
		SetTimer( DelayTime, false );
	}
}


function Timer()
{	
	Trigger( Victim, Victim );
}

function FadeToBlack()
{
	if( Victim.IsA( 'PlayerPawn' ) )
	{
		PlayerPawn( Victim ).ClientAdjustGlow( -1.0, vect( 0, 0, 0 ) );
		bBlack = true;
	}
}
	
function FadeToWhite( pawn EventInstigator )
{
	local int i;
	
	if( EventInstigator.IsA( 'PlayerPawn' ) )
	{
		for( i = 0; i <= 4; i++ )
		{
			PlayerPawn( EventInstigator ).ClientAdjustGlow( 1.0, vect( 255, 255, 255 ) );
		}
		bWhite = true;
	}
}

function FadeInFromWhite( pawn EventInstigator )
{
	local int i;
	
	if( EventInstigator.IsA( 'PlayerPawn' ) )
	{
		for( i = 0; i <= 4; i++ )
		{
			PlayerPawn( EventInstigator ).ClientAdjustGlow( -1.0, vect( -255, -255, -255 ) );
		}
		bWhite = false;
	}
}

function FadeInFromBlack( pawn EventInstigator )
{
	if( EventInstigator.IsA( 'PlayerPawn' ) )
	{
		PlayerPawn( EventInstigator ).ClientAdjustGlow( 1.0, vect( 0, 0, 0 ) );
		bBlack = false;
	}
}

defaultproperties
{
     bFadeToBlack=True
     DelayTime=10.000000
}
