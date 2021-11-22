//=============================================================================
// UWindowMultimediaButton.
//=============================================================================
class UWindowMultimediaButton expands UWindowSmallButton;

var int MultimediaButtonIdx;

function Paint(Canvas C, float X, float Y)
{
	local Color MainDrawColor;

	super.Paint(C, X, Y);
	C.DrawColor = MakeColor(0, 0, 0);
	DrawStretchedTextureSegment(C, (WinWidth - 16) / 2, 0, 16, 16, 64 * MultimediaButtonIdx, 0, 64, 64, UpTexture);
	C.DrawColor = MainDrawColor;
}

function bool IsPressed()
{
	return bMouseDown || bRMouseDown;
}
