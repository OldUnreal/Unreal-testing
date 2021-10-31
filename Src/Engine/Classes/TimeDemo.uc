//=============================================================================
// TimeDemo - calculate and display framerate
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class TimeDemo extends Info
	native
	transient;

// Native
var pointer<FArchive*> FileAr;

var float TimePassed;
var float TimeDilation; // unused, preserved for compatibility

var float StartTime;
var float LastSecTime;
var float LastCycleTime;
var float LastFrameTime;
var float SquareSum;

var int FrameNum;
var int FrameLastSecond;	// Frames in the last second
var int FrameLastCycle;		// Frames in the last cycle
var int CycleCount;
var int QuitAfterCycles;

var string CycleMessage;
var string CycleResult;

var bool bSaveToFile;
var bool bFirstFrame;

var float LastSec;
var float MinFPS;
var float MaxFPS;

var InterpolationPoint OldPoint;
var TimeDemoInterpolationPoint NewPoint;

var Console Console;

native final function OpenFile();
native final function WriteToFile( string Text );
native final function CloseFile();

function DoSetup( Console C, optional bool bSave, optional int QuitAfter )
{
	local InterpolationPoint	I;

	Console = C;
	bSaveToFile = bSave;
	QuitAfterCycles = QuitAfter;

	bFirstFrame = True;
	OldPoint = None;

	// Find the first interpolation point, and replace it with one of ours.
	foreach Console.ViewPort.Actor.AllActors( class 'InterpolationPoint', I, 'Path' )
	{
		if (I.Position == 0)
		{
			OldPoint = I;
			break;
		}
	}

	if (OldPoint != None)
	{

		Log("*************************");
		Console.Viewport.Actor.StartWalk();
		Console.Viewport.Actor.SetLocation(OldPoint.Location);

		// We've got a flyby sequence - break into it
		OldPoint.Tag = 'OldPath';

		NewPoint = Console.ViewPort.Actor.Spawn(class 'TimeDemoInterpolationPoint', OldPoint.Owner);
		NewPoint.SetLocation(OldPoint.Location, OldPoint.Rotation);
		NewPoint.Position = 0;
		NewPoint.RateModifier = OldPoint.RateModifier;
		NewPoint.bEndOfPath = OldPoint.bEndOfPath;
		NewPoint.Tag = 'Path';
		NewPoint.Next = OldPoint.Next;
		NewPoint.Prev = OldPoint.Prev;
		NewPoint.Prev.Next = NewPoint;
		NewPoint.Next.Prev = NewPoint;
		NewPoint.T = Self;
	}
}

function DoShutdown()
{
	Local float Avg;

	if (OldPoint != None)
	{
		NewPoint.Destroy();
		OldPoint.Tag = 'Path';
		OldPoint.Prev.Next = OldPoint;
		OldPoint.Next.Prev = OldPoint;
		OldPoint = None;
	}

	Avg = FrameNum / (TimePassed - StartTime);
	Console.Viewport.Actor.ClientMessage(FrameNum @ "frames rendered in" @ (TimePassed - StartTime) @ "seconds." @ Avg @ "FPS average.");
	Console.TimeDemo = None;
	Destroy();
}

function PostRender( canvas C )
{
	local float Avg, RMS;
	local float XL, YL, MaxWidth;

	if (Console.Viewport != None)
        TimeDilation = Console.Viewport.Actor.Level.TimeDilation; // unused, preserved for compatibility

	if (bFirstFrame)
	{
		StartTime = TimePassed;
		LastSecTime = TimePassed;
		LastFrameTime = TimePassed;

		FrameNum = 0;
		FrameLastSecond = 0;
		FrameLastCycle = 0;
		CycleCount = 0;

		LastSec = 0;
		LastCycleTime = 0;
		CycleMessage = "";
		CycleResult = "";

		SquareSum = 0;

		MinFPS = 0;
		MaxFPS = 0;

		bFirstFrame = False;

		return;
	}

	FrameNum++;
	FrameLastSecond++;
	FrameLastCycle++;

	SquareSum = SquareSum + (LastFrameTime - TimePassed) * (LastFrameTime - TimePassed);
	RMS = 1 / sqrt(SquareSum / FrameNum);

	LastFrameTime = TimePassed;

	Avg = FrameNum / (TimePassed - StartTime);

	if (TimePassed - LastSecTime > 1)
	{
		LastSec = FrameLastSecond / (TimePassed - LastSecTime);
		FrameLastSecond = 0;
		LastSecTime = TimePassed;
	}

	if (LastSec < MinFPS || MinFPS == 0) MinFPS = LastSec;
	if (LastSec > MaxFPS) MaxFPS = LastSec;


	if (Console.ViewPort.Actor.bShowMenu) return;

	C.Reset();
	C.bNoSmooth = true;
	C.DrawColor = MakeColor(255, 255, 255);
	C.Font = C.MedFont;
	C.StrLen("T", XL, YL);
	YL += FMax(1, YL / 3);

	C.SetPos(1, 48);
	DrawTextLineExt(C, "Average:", YL, MaxWidth);
	DrawTextLineExt(C, "RMS:", YL, MaxWidth);
	DrawTextLineExt(C, "Last Second:", YL, MaxWidth);
	DrawTextLineExt(C, "Lowest:", YL, MaxWidth);
	DrawTextLineExt(C, "Highest:", YL, MaxWidth);
	DrawTextLineExt(C, CycleMessage, YL, MaxWidth);

	C.SetPos(MaxWidth + XL + 1, 48);
	DrawTextLineExt(C, Avg $ " FPS.", YL);
	DrawTextLineExt(C, RMS $ " FPS.", YL);
	DrawTextLineExt(C, LastSec $ " FPS.", YL);
	DrawTextLineExt(C, MinFPS $ " FPS.", YL);
	DrawTextLineExt(C, MaxFPS $ " FPS.", YL);
	DrawTextLineExt(C, CycleResult, YL);
}

function DrawTextLineExt(canvas C, string S, float DY, optional out float MaxWidth)
{
	local float X, Y, XL, YL;
	C.StrLen(S, XL, YL);
	X = C.CurX;
	Y = C.CurY;
	C.DrawText(S);
	C.SetPos(X, Y + DY);
	if (MaxWidth < XL)
		MaxWidth = XL;
}

function TickTimeDemo(float Delta) // Delta is measured in real seconds
{
	TimePassed = TimePassed + Delta;
}

function StartCycle()
{
	local string Temp;

	if (LastCycleTime == 0)
	{
		CycleMessage = "Cycle #1:";
		CycleResult = "Timing...";
	}
	else
	{
		CycleMessage = "Cycle #" $ CycleCount $ ":";
		CycleResult = FrameLastCycle / (TimePassed - LastCycleTime)
					  $ " FPS (" $ FrameLastCycle $ " frames, " $
					  (TimePassed - LastCycleTime) $ " seconds)";

		Log("Cycle #" $ CycleCount $ ": "
			$ FrameLastCycle / (TimePassed - LastCycleTime)
			$ " FPS (" $ FrameLastCycle $ " frames, " $
			(TimePassed - LastCycleTime) $ " seconds)");

		if (bSaveToFile)
		{
			OpenFile();
			Temp = string(int(100 * FrameLastCycle / (TimePassed - LastCycleTime)));
			WriteToFile( Left(Temp, Len(Temp) - 2)$"."$Right(Temp, 2) $ " Unreal "$Console.Viewport.Actor.Level.EngineVersion);
			Temp = string(int(100 * MinFPS));
			WriteToFile(Left(Temp, Len(Temp) - 2)$"."$Right(Temp, 2) $ " Min");
			Temp = string(int(100 * MaxFPS));
			WriteToFile(Left(Temp, Len(Temp) - 2)$"."$Right(Temp, 2) $ " Max");
			CloseFile();
		}
		if ( CycleCount == QuitAfterCycles )
			Console.Viewport.Actor.ConsoleCommand("exit");
	}
	LastCycleTime = TimePassed;
	FrameLastCycle = 0;
	CycleCount++;
}

defaultproperties
{
}
