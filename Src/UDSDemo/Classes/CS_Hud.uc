//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_HUD ]
//
// The CS_Hud holds all the code for creating the special hud effects.
//=============================================================================

#exec OBJ LOAD FILE=UPakFonts.utx PACKAGE=UPakFonts

class CS_Hud expands UnrealHUD;

var int MessageNumber, CreditNumber;
var bool bPause;
var float PauseDelay;
var bool bForceLetterBox;
var bool bFadingIn;

var() localized string Credits1;
var() localized string Credits2;
var() localized string Credits3;
var() localized string Credits4;
var() localized string GameTitle;

var() string EndCredits1;
var() string EndCredits2;
var() string EndCredits3;
var() string EndCredits4;
var() string EndCredits5;
var() string EndCredits6;
var() string EndCredits7;

#forceexec Texture Import File=Textures\black.pcx Name=CS_LetterBox

simulated function PostBeginPlay()
{
	MOTDFadeOutTime = 0;
	bPause = true;
	bFadingIn = true;

	if( class'CSPlayer'.Static.LevelIsIntro1(Level) )
	{
		SetTimer( 6.0, false );
	}
	else if( !class'CSPlayer'.Static.LevelIsIntro2(Level) )
	{
		SetTimer( 107.0, false );
	}
}

simulated function ChangeHud(int d)
{
	HudMode = HudMode + d;
	if ( HudMode>5 ) HudMode = 0;
	else if ( HudMode < 0 ) HudMode = 5;
}

simulated function HUDSetup(canvas canvas)
{
	// Setup the way we want to draw all HUD elements
	Canvas.Reset();
	Canvas.SpaceX=0;
	Canvas.bNoSmooth = True;
	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;
	Canvas.Font = Canvas.LargeFont;
}


function Timer()
{
	MessageNumber++;
	MOTDFadeOutTime = 0.1;
	bFadingIn = true;
	bPause = false;
}

simulated function PostRender( canvas Canvas )
{
	HUDSetup(canvas);

	if( MOTDFadeOutTime != 0.0 && class'CSPlayer'.Static.LevelIsIntro1(Level) )
	{
		DrawMessage( Canvas, MessageNumber );
	}
	else if( MOTDFadeOutTime != 0.0 && !class'CSPlayer'.Static.LevelIsIntro2(Level) )
	{
		DrawCredits( Canvas, MessageNumber );
	}

	else if( !bPause )
	{
		bPause = true;
		SetTimer( PauseDelay, false );
	}

    // A letterboxed screen
	class'UPakHUD'.static.DrawLetterBox(Canvas);

	if (CSPlayer(Owner).bCSInDebug)
		DrawCSDebug(Canvas, class'UPakHUD'.static.GetLetterBoxHeight(Canvas));
}

simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY )
{
	local PlayerPawn P;

    if (CSPlayer(Owner).bCSCAmeraMode) return;

	if (Crosshair>5) Return;
	Canvas.SetPos(StartX, StartY );
	Canvas.Style = 2;
	P = PlayerPawn(Owner);
	if ( (P.Weapon != None) && !P.bShowMenu
		&& P.Weapon.bLockedOn && P.Weapon.bPointing)
		Canvas.DrawIcon(Texture'Crosshair6', 1.0);
	else if (Crosshair==0) 	Canvas.DrawIcon(Texture'Crosshair1', 1.0);
	else if (Crosshair==1) 	Canvas.DrawIcon(Texture'Crosshair2', 1.0);
	else if (Crosshair==2) 	Canvas.DrawIcon(Texture'Crosshair3', 1.0);
	else if (Crosshair==3) 	Canvas.DrawIcon(Texture'Crosshair4', 1.0);
	else if (Crosshair==4) 	Canvas.DrawIcon(Texture'Crosshair5', 1.0);
	else if (Crosshair==5) 	Canvas.DrawIcon(Texture'Crosshair7', 1.0);
	Canvas.Style = 1;
}

function DrawCSDebug(Canvas Canvas, int TX)
{

	local int i,x;
	local string s;

	Canvas.Font = Font'MedFont';

	// Display the Current Camera;

	Canvas.SetPos(5,TX-20);
	Canvas.DrawText("Current Camera: "$CSPlayer(Owner).CSCamera);

	Canvas.SetPos(5,TX-10);
	Canvas.DrawText("Last Action   : "$CSPlayer(Owner).CSLastAction);

	// Display any debug messages;

	x = Canvas.ClipY - 60;

	for (i=0;i<CSPlayer(Owner).CSDebugCnt;i++)
	{
		Canvas.SetPos(5,X);
		switch (i)
		{
			case 0 : s = CSPlayer(Owner).CSDebug1;break;
			case 1 : s = CSPlayer(Owner).CSDebug2;break;
			case 2 : s = CSPlayer(Owner).CSDebug3;break;
			case 3 : s = CSPlayer(Owner).CSDebug4;break;
			case 4 : s = CSPlayer(Owner).CSDebug5;break;
		}

		Canvas.DrawText(s);
		x+=10;
	}

}


simulated function DrawMessage(Canvas Canvas, int MessageNumber )
{
	local float XL, YL;

	if(Owner == None) return;

	Canvas.Font = font'Papyrus';
	//Canvas.Font = Canvas.LargeFont; //UG
	Canvas.Style = 3;

	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;

	Canvas.bCenter = true;

	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = MOTDFadeOutTime / 2;
	Canvas.DrawColor.B = MOTDFadeOutTime;
	Canvas.SetPos(0.0, 32);
	Canvas.StrLen("TEST", XL, YL);

	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;
	Canvas.SetPos(0.0, Canvas.ClipY / 2 - 2 * YL);

	if( MessageNumber == 1 )
	{
		Canvas.DrawText( Credits1, true);
		PauseDelay = 1.75;
	}
	else if( MessageNumber == 2 )
	{
		Canvas.DrawText( Credits2, true );
		PauseDelay = 1.75;
	}
	else if( MessageNumber == 3 )
	{
		Canvas.DrawText( Credits3, true );
		PauseDelay = 1.75;
	}
	else if( MessageNumber == 4 )
	{
		Canvas.DrawText( Credits4, true );
		PauseDelay = 2.75;
	}
	else if( MessageNumber == 5 )
	{
		Canvas.Font = Font'Chiller';
		Canvas.DrawText( GameTitle, true );
		PauseDelay = 1;
	}

	Canvas.SetPos(0.0, 32 + 5*YL);
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = MOTDFadeOutTime / 2;
	Canvas.DrawColor.B = MOTDFadeOutTime;

	Canvas.bCenter = false;

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function DrawCredits(Canvas Canvas, int CredNumber )
{
	local float XL, YL;


	if(Owner == None) return;

	Canvas.Font = Canvas.LargeFont; //UG

	Canvas.Style = 3;

	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;

	Canvas.bCenter = true;

	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = MOTDFadeOutTime / 2;
	Canvas.DrawColor.B = MOTDFadeOutTime;
	Canvas.SetPos(0.0, 48);
	Canvas.StrLen("TEST", XL, YL);

	Canvas.DrawColor.R = MOTDFadeOutTime;
	Canvas.DrawColor.G = MOTDFadeOutTime;
	Canvas.DrawColor.B = MOTDFadeOutTime;
	Canvas.SetPos(0.0, 3.5 * YL);
	if( MessageNumber == 1 )
	{
        Canvas.Font = font'Arial';
		Canvas.DrawText( "PRODUCER", true);
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Mike Verdu", true );
		PauseDelay = 3.75;
	}
	else if( MessageNumber == 2 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "TECHNICAL ADVISOR", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Mark Poesch", true );
		PauseDelay = 6.75;
	}
	else if( MessageNumber == 3 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "LEVEL DESIGNERS", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "David Kelvin", true );
		Canvas.DrawText( "Matthias Worch", true );
		Canvas.Font = font'Arial';
		Canvas.DrawText( "ADDITIONAL LEVELS", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Mick Beard", true );
		Canvas.DrawText( "Warren Marshall", true );

		PauseDelay = 6.75;
	}
	else if( MessageNumber == 4 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "PROGRAMMERS", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Duane Beck", true );
		Canvas.DrawText( "Jess Crable", true );
		PauseDelay = 6.75;
	}
	else if( MessageNumber == 5 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "ART, MODELS, and ANIMATION", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "HEURISTIC PARK GRAPHIC PRODUCTION STUDIOS", true );
		Canvas.DrawText( "Chris Appel     Paul Neuhaus     Blanca Anson", true );
		Canvas.DrawText( "Suzanne Snelling     Joon Choi     Nathan Cheever", true );
		Canvas.DrawText( "Chris 'Xyle' Roberts", true );
		PauseDelay = 8.75;
	}
	else if( MessageNumber == 6 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "ADDITIONAL ART and MODELS", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Joel Walden", true );
		Canvas.DrawText( "Robert Wisnewski", true );
		Canvas.DrawText( "Matthias Worch", true );
		PauseDelay = 6.75;
	}
	else if( MessageNumber == 7 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "MUSIC", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Alexander Brandon", true );
		PauseDelay = 6.75;
	}
	else if( MessageNumber == 8 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "ASSOCIATE PRODUCER and TESTER", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Craig Lafferty", true );
		PauseDelay = 6.75;
	}
	else if( MessageNumber == 9 )
	{
		Canvas.Font = font'Arial';
		Canvas.DrawText( "CANDY AND PAYCHECKS", true );
		Canvas.Font = font'Garamond';
		Canvas.DrawText( "Rosie Freeman", true );
		PauseDelay = 6.75;
	}
	else if (MessageNumber == 10 )
	{
		CSPlayer(Owner).Fire();
	}

	Canvas.SetPos(0.0, 32 + 5*YL);
	Canvas.DrawColor.R = 0;
	Canvas.DrawColor.G = MOTDFadeOutTime / 2;
	Canvas.DrawColor.B = MOTDFadeOutTime;

	Canvas.bCenter = false;

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

simulated function Tick(float DeltaTime)
{
	IdentifyFadeTime -= DeltaTime;
	if (IdentifyFadeTime < 0.0)
		IdentifyFadeTime = 0.0;

	if( bFadingIn )
	{
		MOTDFadeOutTime += DeltaTime * 85;

		if( MOTDFadeOutTime > 180 )
		{
			MOTDFadeOutTime = 180;
			bFadingIn = false;
		}
	}
	else
	{
		MOTDFadeOutTime -= DeltaTime * 55;
		if (MOTDFadeOutTime < 0.0)
			MOTDFadeOutTime = 0.0;
	}
}

defaultproperties
{
     Credits1="GT INTERACTIVE"
     Credits2="LEGEND ENTERTAINMENT"
     Credits3="AND EPIC GAMES"
     Credits4="PRESENT"
     GameTitle="UNREAL: RETURN TO NA PALI"
     MainMenuType=class'Engine.Menu'
}
