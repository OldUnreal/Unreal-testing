//=============================================================================
// MOffsetScrollbar - Music offset scrollbar.
//=============================================================================
class MOffsetScrollbar extends UWindowHScrollBar;

var MMControlsClient Controller;

function bool Scroll(float Delta)
{
	if( Super.Scroll(Delta) )
		return true;
	if( !bDisabled )
		Controller.ChangeMusicOffset(int(Pos));
	return false;
}
final function bool ScrollNoEvent( float Delta )
{
	return Super.Scroll(Delta);
}

function BeforePaint(Canvas C, float X, float Y)
{
	if( !bDisabled && !bDragging )
		Pos = FClamp(float(GetPlayerOwner().ConsoleCommand("GetMusicOffset")), MinPos, MaxPos);
	if( bDragging && !bMouseDown )
		MouseMove(0,0);
	CheckRange();
}

function MouseMove(float X, float Y)
{
	if (bDragging && bMouseDown && !bDisabled)
	{
		while (X < (ThumbStart+DragX) && Pos > MinPos)
		{
			ScrollNoEvent(-1);
		}

		while (X > (ThumbStart+DragX) && Pos < MaxPos)
		{
			ScrollNoEvent(1);
		}
	}
	else if( bDragging )
	{
		if( !bDisabled )
			Controller.ChangeMusicOffset(int(Pos));
		bDragging = False;
	}
}

function Created()
{
	Super(UWindowWindow).Created();
}

function CheckRange()
{
	if (Pos < MinPos)
	{
		Pos = MinPos;
	}
	else
	{
		if (Pos > MaxPos) Pos = MaxPos;
	}

	bDisabled = (MaxPos <= MinPos);

	if (bDisabled)
	{
		Pos = 0;
	}
	else
	{
		ThumbStart = ((Pos - MinPos) * WinWidth) / (MaxPos + MaxVisible - MinPos);
		ThumbWidth = (MaxVisible * WinWidth) / (MaxPos + MaxVisible - MinPos);

		if (ThumbWidth < LookAndFeel.Size_MinScrollbarHeight)
			ThumbWidth = LookAndFeel.Size_MinScrollbarHeight;

		if ( ThumbWidth + ThumbStart > WinWidth )
			ThumbStart = WinWidth;
	}
}

defaultproperties
{
}
