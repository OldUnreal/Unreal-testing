//=============================================================================
// UnrealShortMenu
//
// Short menus, like the player mesh/skin selection screen and the
// individual bot configuration screen. These menus do not have a background.
//=============================================================================
class UnrealShortMenu extends UnrealMenu;

var float PulseTime;
var bool bPulseDown;
var float TitleFadeTime;
var float MenuFadeTimes[24];

// Fade title.
function DrawFadeTitle(canvas Canvas)
{
	local float XL, YL;
	local color DrawColor;

	Canvas.Font = Font'WhiteFont';
	Canvas.StrLen(MenuTitle, XL, YL);

	DrawColor.R = 0;
	DrawColor.G = 255;
	DrawColor.B = 0;

	DrawFadeString(Canvas, MenuTitle, TitleFadeTime, Canvas.ClipX/2 - XL/2, 32, DrawColor);
}

// Fade list.
function DrawFadeList(canvas Canvas, int Spacing, int StartX, int StartY)
{
	local int i;
	local color DrawColor;

	Canvas.Font = Font'WhiteFont';
	for (i=0; i< (MenuLength); i++ )
	{
		if (i == Selection - 1)
		{
			DrawColor.R = PulseTime * 10;
			DrawColor.G = 255;
			DrawColor.B = PulseTime * 10;
		}
		else
		{
			DrawColor.R = 0;
			DrawColor.G = 150;
			DrawColor.B = 0;
		}
		DrawFadeString(Canvas, MenuList[i + 1], MenuFadeTimes[i + 1], StartX, StartY + Spacing * i, DrawColor);
	}
}

// Fades in a string to the specified color.
function DrawFadeString( canvas Canvas, string FadeString, out float FadeTime, float XStart, float YStart, color DrawColor )
{
	local float FadeCount, XL, YL;
	local int FadeChar;

	Canvas.SetPos(XStart, YStart);
	Canvas.DrawColor = DrawColor;

	if (FadeTime == -1.0)
	{
		// If first update, just set the FadeTime to zero.
		FadeTime = 0.0;
		return;
	}
	else if (FadeTime == -2.0)
	{
		Canvas.SetPos(XStart, YStart);
		Canvas.DrawColor = DrawColor;
		Canvas.DrawText(FadeString, false);
		return;
	}

	// Update FadeString.
	for ( FadeChar = 0; FadeTime - (FadeChar * 0.1) > 0.0; FadeChar++ )
	{
		FadeCount = FadeTime - (FadeChar * 0.1);
		if (FadeCount > 1.0)
			FadeCount = 1.0;

		if ((FadeChar == Len(FadeString) - 1) && (255 * (1.0 - FadeCount) == 0))
			FadeTime = -2.0;

		Canvas.DrawColor.R = Max(255 * (1.0 - FadeCount), DrawColor.R);
		Canvas.DrawColor.G = Max(255 * (1.0 - FadeCount), DrawColor.G);
		Canvas.DrawColor.B = Max(255 * (1.0 - FadeCount), DrawColor.B);
		Canvas.DrawText(Mid(FadeString, FadeChar, 1));
		Canvas.StrLen(Left(FadeString, FadeChar+1), XL, YL);
		Canvas.SetPos(XStart + XL, YStart);
	}
}

// The help panel for short menus.  Oriented somewhat differently
// because it is not restricted by the green background.
function DrawHelpPanel(canvas Canvas, int StartY, int XClip)
{
	local int StartX, OldXClip, OldYClip;
	local float XL, YL;

	StartX = 0.5 * Canvas.ClipX - 128;
	OldXClip = Canvas.ClipX;
	OldYClip = Canvas.ClipY;

	Canvas.bCenter = false;
	Canvas.Font = Canvas.MedFont;
	Canvas.SetOrigin(StartX + 18, StartY + 16);
	Canvas.SetClip(XClip, 128);
	Canvas.SetPos(0,0);
	Canvas.Style = 1;
	if ( Selection < 20 )
	{
		Canvas.StrLen(HelpMessage[Selection], XL, YL);
		if (YL <= Canvas.ClipY)
		{
			if (Canvas.OrgY + YL > OldYClip)
				Canvas.OrgY = OldYClip - YL;
			Canvas.DrawText(HelpMessage[Selection], False);
		}
	}
	Canvas.SetPos(0,32);
}

// Short menus are used for displaying a mesh and some information
// about that mesh (for example, picking your class and skin before
// a game or setting up bots).  This rotates the displayed mesh.
function MenuTick( float DeltaTime )
{
	local rotator newRot;
	local float RemainingTime;

	if ( Level.Pauser == "" )
		return;

	// Update PulseTime.
	if (bPulseDown)
	{
		if (PulseTime > 0.0)
		{
			PulseTime -= DeltaTime * 30;
			if (PulseTime < 0.0)
				PulseTime = 0.0;
		}
		else
		{
			PulseTime = 0.0;
			bPulseDown = false;
		}
	}
	else
	{
		if (PulseTime < 25.5)
		{
			PulseTime += DeltaTime * 30;
			if (PulseTime > 25.5)
				PulseTime = 25.5;
		}
		else
		{
			PulseTime = 25.5;
			bPulseDown = true;
		}
	}

	// explicit rotation, since game is paused
	newRot = Rotation;
	newRot.Yaw = newRot.Yaw + RotationRate.Yaw * DeltaTime;
	SetRotation(newRot);

	//explicit animation
	RemainingTime = DeltaTime * 0.5;
	while ( RemainingTime > 0 )
	{
		if ( AnimFrame < 0 )
		{
			AnimFrame += TweenRate * RemainingTime;
			if ( AnimFrame > 0 )
				RemainingTime = AnimFrame/TweenRate;
			else
				RemainingTime = 0;
		}
		else
		{
			AnimFrame += AnimRate * RemainingTime;
			if ( AnimFrame > 1 )
			{
				RemainingTime = (AnimFrame - 1)/AnimRate;
				AnimFrame = 0;
			}
			else
				RemainingTime = 0;
		}
	}
}

defaultproperties
{
}
