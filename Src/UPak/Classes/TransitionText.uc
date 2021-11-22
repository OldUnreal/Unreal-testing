//=============================================================================
// TransitionText.
//=============================================================================
class TransitionText expands Info;

var() localized string MessageA;
var() localized string MessageB;
var() localized string MessageC;
var() localized string MessageD;
var() localized string MessageE;
var() localized string MessageF;
var() localized string MessageG;
var() localized string MessageH;
var() localized string MessageI;
var() localized string MessageJ;
var() localized string MessageK;
var() localized string MessageL;
var() localized string MessageM;
var() localized string MessageN;
var() localized string MessageO;

simulated function PostBeginPlay()
{
	Role = ROLE_Authority;
	if( Level.NetMode!=NM_DedicatedServer )
		SetTimer( 0.5, false );
}
simulated function Timer()
{
	local TransitionNullHUD P;
	
	foreach allactors( class'TransitionNullHUD', P )
	{
		P.Text1 = MessageA;
		P.Text2 = MessageB;
		P.Text3 = MessageC;
		P.Text4 = MessageD;
		P.Text5 = MessageE;
		P.Text6 = MessageF;
		P.Text7 = MessageG;
		P.Text8 = MessageH;
		P.Text9 = MessageI;
		P.Text10 = MessageJ;
		P.Text11 = MessageK;
		P.Text12 = MessageL;
		P.Text13 = MessageM;
		P.Text14 = MessageN;
		P.Text15 = MessageO;
	}
}

defaultproperties
{
	bNoDelete=True
	RemoteRole=ROLE_None
}
