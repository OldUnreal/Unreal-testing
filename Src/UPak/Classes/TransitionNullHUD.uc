//=============================================================================
///// TransitionNullHUD.
//=============================================================================
class TransitionNullHUD expands UnrealHUD;

#exec Texture Import File=Textures\Intermission\black.pcx Name=CS_LetterBox
#exec OBJ LOAD FILE=UPakFonts.utx

// 30ms
var float TimeMetric1;
var float TimeMetric2;
var int TextIncrementer;

var() localized string Title;
var() localized string Message1;
var() localized string Message2;
var() localized string Message3;
var() localized string Message4;
var() localized string Message5;

var localized string Text1;
var localized string Text2;
var localized string Text3;
var localized string Text4;
var localized string Text5;
var localized string Text6;
var localized string Text7;
var localized string Text8;
var localized string Text9;
var localized string Text10;
var localized string Text11;
var localized string Text12;
var localized string Text13;
var localized string Text14;
var localized string Text15;
var localized string Text16;
var float LastX;

var() localized string Statheader;
var() localized string CARStat;
var() localized string RLStat;
var() localized string GLStat;
var() localized string ASMDStat;
var() localized string AutomagStat;
var() localized string DispersionStat;
var() localized string EightballStat;
var() localized string FlakCannonStat;
var() localized string GESBioRifleStat;
var() localized string MinigunStat;
var() localized string RazorjackStat;
var() localized string RifleStat;
var() localized string StingerStat;
var() localized string TotalStat;
var() localized string LogEntryMsg;

var int BlinkTracker;
var string TestURL;
var bool bInitialized, bDisplayText;
var PlayerPawn TargetPlayer;
var UPakPlayer UPakOwner;
var string AppendURL;
var bool bDisplayStats, bBlackScreenFade, bFrozen, bFading, bDisplayLogMessage, bStatsDisplayed, bStats;
var bool bWaitingToEnd, bStatsReady, bFinished;
var float ScaleModifier;
var string ForceMap;

var int ScrollSpeedModifier;
var int ScrollCounter;

var bool bLogMessageDisplayed;

function PostBeginPlay()
{
	local PlayerPawn P;

	Super.PostBeginPlay();
	bFading = true;
	foreach AllActors(class'PlayerPawn', P)
	{
		TargetPlayer = P;
	}
	ScrollSpeedModifier = 25;
	SetTimer( 0.1, True);
	CheckDisplayStats();
}


simulated function DrawMOTD(canvas Canvas);


simulated function Timer()
{
	if( bFading )
	{
		if( ScaleModifier <= 1.0 )
		{
			PlayerPawn( Owner ).ClientAdjustGlow( ScaleModifier, vect( 0, 0, 0 ) );
			ScaleModifier += 0.05;
		}
		else
		{
			PlayerPawn( Owner ).ClientAdjustGlow( 1.0, vect( 0, 0, 0 ) );
			ScaleModifier = 0.0;
			bFading = false;
			bStatsReady = true;
			SetTimer( 2.0, false );
		}
	}
	else if( !bFading && bStatsReady )
	{
		if( !bLogMessageDisplayed )
		{
			bDisplayLogMessage = true;
			if (Level.Outer.Name != 'InterIntro')
			{
				SetTimer( 3.0, false );
				return;
			}
		}

		if( bDisplayStats && !bStatsDisplayed )
		{
			bStats = true;
			bWaitingToEnd = true;
			SetTimer( 100.0, false );
		}
		else if( !bDisplayStats && !bFinished )
		{
			SetTimer( 100.0, false );
			bWaitingToEnd = true;
			bFinished = true;
		}
		else if( bWaitingToEnd )
		{
			EndLevel();
		}
	}
}

simulated function PostRender( canvas Canvas )
{
	local int FontSize;
	local float XL, YL, YL2;

	class'UPakHUD'.static.DrawLetterBox(Canvas);    

	if( !bBlackScreenFade )
	{
		bBlackScreenFade = true;
		ScaleModifier += 0.001;
		SetTimer( 0.1, true );
	}

	if( bDisplayLogMessage )
	{
		if( BlinkTracker > 50 )
		{
			YL2 += YL + FontSize;
			Canvas.SetPos(0.0, YL2 + 96 );
			Canvas.Style = 3;
		    Canvas.Font = Font'Arial';
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;
			Canvas.bCenter = true;
			Canvas.DrawText( LogEntryMsg, true );
			Canvas.StrLen( LogEntryMsg, XL, YL );
			bLogMessageDisplayed = true;
			Canvas.bCenter = false;
			bStatsReady = true;
			if( BlinkTracker > 130 )
			{
				BlinkTracker = 0;
			}
		}
		BlinkTracker++;
	}

	if( bStats )
	{
		if( bDisplayStats && UPakPlayer( Owner ) != none )
		{
			bStatsDisplayed = true;
			Canvas.Style = 3;
			Canvas.Font = font'Arial';
			Canvas.DrawColor.R = 255;
			Canvas.DrawColor.G = 0;
			Canvas.DrawColor.B = 0;

			YL2 += 160;
			Canvas.SetPos( 80.0, YL2 );
			Canvas.DrawText( StatHeader, true );
			Canvas.StrLen( StatHeader, XL, YL );
			YL2 += YL + FontSize;
			Canvas.SetPos( 100.0, YL2 );
			Canvas.Style = 3;
			Canvas.Font = Font'SmallFont';
			Canvas.Style = 1;
			Canvas.DrawColor.R = 0;
			Canvas.DrawColor.G = 128;
			Canvas.DrawColor.B = 255;

			Canvas.DrawText( CARStat, false );
			Canvas.StrLen( CARStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer( Owner ).CARKills, true);
			Canvas.StrLen( " : "$UPakPlayer(  Owner ).CARKills, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( RLStat, false );
			Canvas.StrLen( RLSTat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).RLKills, true);
			Canvas.StrLen( " : "$UPakPlayer(  Owner ).RLKills, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( GLStat, false );
			Canvas.StrLen( GLStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).GLKills, true);
			Canvas.StrLen( " : "$GLStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( ASMDStat, false );
			Canvas.StrLen( ASMDStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).ASMDKills, true);
			Canvas.StrLen( " : "$ASMDStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( AutoMagStat, false );
			Canvas.StrLen( AutoMagStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).AutomagKills, true);
			Canvas.StrLen( " : "$AutomagStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( DispersionStat, false );
			Canvas.StrLen( DispersionStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).DispersionKills, true);
			Canvas.StrLen( " : "$DispersionStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( EightballStat, false );
			Canvas.StrLen( EightballStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).EightballKills, true);
			Canvas.StrLen( " : "$EightballStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( FlakCannonStat, false );
			Canvas.StrLen( FlakCannonStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).FlakCannonKills, true );
			Canvas.StrLen( " : "$FlakCannonStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( MinigunStat, false );
			Canvas.StrLen( MinigunStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).MinigunKills, true);
			Canvas.StrLen( " : "$MinigunStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2);

			Canvas.DrawText( RazorjackStat, false );
			Canvas.StrLen( RazorjackStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).RazorjackKills, true);
			Canvas.StrLen( " : "$RazorjackStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2 );

			Canvas.DrawText( RifleStat, false );
			Canvas.StrLen( RifleStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).RifleKills, true);
			Canvas.StrLen( " : "$RifleStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2 );

			Canvas.DrawText( GESBioRifleStat, false );
			Canvas.StrLen( GESBioRifleStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).BioRifleKills, true);
			Canvas.StrLen( " : "$GESBioRifleStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2 );

			Canvas.DrawText( StingerStat, false );
			Canvas.StrLen( StingerStat, XL, YL );
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).StingerKills, true);
			Canvas.StrLen( " : "$StingerStat, XL, YL);
			YL2 += YL;
			Canvas.SetPos( 100.0, YL2 );

			Canvas.DrawText( TotalStat, false );
			Canvas.StrLen(Message5, XL, YL);
			Canvas.SetPos( 240.0, YL2 );
			Canvas.DrawText( " : "$UPakPlayer(  Owner ).TotalKills );
			Canvas.StrLen( " : "$TotalStat, XL, YL );
			YL2 += YL * 10;
			Canvas.SetPos( 100.0, YL2 );
		}
	}

	Canvas.Reset();
}

function Destroyed()
{
	if( TargetPlayer != none )
		TargetPlayer.bShowMenu = false;
	super.destroyed();
}
function DisplayText( string Text, Canvas C )
{
	C.DrawText( Text, true );
}
function string GetText( int TextNum )
{
	switch TextNum
	{
		Case 0:
			return Text1;
		Case 1:
			return Text2;
		Case 2:
			return Text3;
		Case 3:
			return Text4;
		Case 4:
			return Text5;
		Case 5:
			return Text6;
		Case 6:
			return Text7;
		Case 7:
			return Text8;
		Case 8:
			return Text9;
		Case 9:
			return Text10;
		Case 10:
			return Text11;
		Case 11:
			return Text12;
		Case 12:
			return Text13;
		Case 13:
			return Text14;
		Case 14:
			return Text15;
		Case 15:
			return Text16;
	}
}
function bool RedirectorSearch()
{
	local TransitionRedirector TR;

	foreach allactors( class'TransitionRedirector', TR )
	{
		if( TR != none )
		{
			if( TR.bFirstTransition )
			{
				ForceMap = TR.MapToForce;
				if( UPakConsole( PlayerPawn( Owner ).Player.Console ) )
					UPakConsole( PlayerPawn( Owner ).Player.Console ).NextMap = ForceMap;
			}
			AppendURL = TR.URL;
			return true;
		}
	}
	return false;
}
function CheckDisplayStats()
{
	local StatsKiller SK;

	foreach allactors( class'StatsKiller', SK )
	{
		if( SK != none )
		{
			bDisplayStats = false;
			return;
		}
	}
	bDisplayStats = true;
}
function EndLevel()
{
	local string S;
	local int i;

	PlayerPawn( Owner ).bShowMenu = false;
	UPakOwner = UPakPlayer( Owner );
	UPakPlayer( Owner ).bTransition = false;
	if( UPakConsole(UPakPlayer( Owner ).Player.Console)!=None )
		UPakConsole( UPakPlayer( Owner ).Player.Console ).bTransition = false;
	S = Level.GetLocalURL();
	i = InStr(S,"?TransURL=");
	if( i==-1 )
		S = "DuskFalls";
	else
	{
		S = Mid(S,i+10);
		i = InStr(S,"?");
		if( i!=-1 )
			S = Left(S,i);
	}
	if( RedirectorSearch() )
	{
		if( ForceMap != "" )
			Level.Game.SendPlayer( PlayerPawn( Owner ), ForceMap$AppendURL );
		else Level.Game.SendPlayer( PlayerPawn( Owner ), S$AppendURL );
	}
	else
	{
		if( ForceMap != "" )
			Level.Game.SendPlayer( PlayerPawn( Owner ), ForceMap$AppendURL );
		else
		{
			if( Left(S,3)~="end" )
				Level.Game.SendPlayer( PlayerPawn( Owner ), S$"?game=udsdemo.csmovie" );
			else Level.Game.SendPlayer( PlayerPawn( Owner ), S$"?Game=UPak.UPakSinglePlayer" );
		}
	}
	PlayerPawn( Owner ).bShowMenu = false;
}

defaultproperties
{
	Statheader="Kill Statistics: "
	CARStat="Combat Assault Rifle"
	RLStat="RocketLauncher"
	GLStat="GrenadeLauncher"
	ASMDStat="ASMD"
	AutomagStat="Automag"
	DispersionStat="Dispersion Pistol"
	EightballStat="Eightball"
	FlakCannonStat="FlakCannon"
	GESBioRifleStat="GES BioRifle"
	MinigunStat="Minigun"
	RazorjackStat="Razorjack"
	RifleStat="Rifle"
	StingerStat="Stinger"
	TotalStat="Total Kills"
	LogEntryMsg="LOG ENTRY:"
}
