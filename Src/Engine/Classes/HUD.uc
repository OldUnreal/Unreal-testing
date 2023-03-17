//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends Actor
		abstract
		native
			config(user);

//=============================================================================
// Variables.

var globalconfig int HudMode;
var globalconfig int Crosshair;
var globalconfig float HudScaler, CrosshairScale;
var() class<menu> MainMenuType;
var() string HUDConfigWindowType;

var Menu MainMenu;
var array<HudOverlay> Overlays;

//=============================================================================
// Status drawing.

simulated event PreRender( canvas Canvas );
simulated event PostRender( canvas Canvas );
simulated function InputNumber(byte F);
simulated function ChangeHud(int d);
simulated function ChangeCrosshair(int d);
simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY);
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name N );

simulated function PlayReceivedMessage( string S, string PName, ZoneInfo PZone )
{
	PlayerPawn(Owner).ClientMessage(S);
	if (PlayerPawn(Owner).bMessageBeep)
		PlayerPawn(Owner).PlayBeepSound();
}

// DisplayMessages is called by the Console in PostRender.
// It offers the HUD a chance to deal with messages instead of the
// Console.  Returns true if messages were dealt with.
simulated function bool DisplayMessages(canvas Canvas)
{
	return false;
}

// 227f: Get console message color.
simulated function GetMessageColor( name MsgType, out color Colour )
{
	Colour.R = 255;
	Colour.G = 255;
	Colour.B = 255;
}

// HUD overlay API.
simulated final function HudOverlay AddOverlay( class<HudOverlay> Type, optional bool bUnique )
{
	local HudOverlay H;

	if( bUnique )
	{
		foreach Overlays(H)
			if( H.Class==Type )
				return H;
	}
	H = Spawn(Type,Owner);
	if( H==None )
	{
		Warn("Unable to spawn HudOverlay: "$Type);
		return None;
	}
	H.myHUD = Self;
	Overlays.Add(H);
	return H;
}
simulated final function RemoveOverlay( HudOverlay Other )
{
	Overlays.RemoveValue(Other);
}

simulated function PostRender2D( canvas Canvas, Pawn Other, vector Pos );

simulated event OnSubLevelChange( LevelInfo PrevLevel )
{
	local HudOverlay H;
	
	foreach Overlays(H)
		H.SendToLevel(Level, Location);
	Super.OnSubLevelChange(PrevLevel);
}

defaultproperties
{
	HUDConfigWindowType="UMenu.UMenuHUDConfigCW"
	bHidden=True
	RemoteRole=ROLE_SimulatedProxy
	HudScaler=1
	CrosshairScale=1
}