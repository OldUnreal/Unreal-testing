//=============================================================================
// UBrowserToolbar - the toolbar!
//=============================================================================
class UBrowserBannerBar extends UWindowWindow;

var UBrowserBannerAd		BannerAdWindow;

function Paint(Canvas C, float X, float Y)
{
	C.Style = GetPlayerOwner().ERenderStyle.STY_Modulated;
	Tile(C, Texture'Background');
	C.Style = GetPlayerOwner().ERenderStyle.STY_Normal;
}


function Created()
{
	Super.Created();
	BannerAdWindow = UBrowserBannerAd(CreateWindow(class'UBrowserBannerAd', 0, 2, 256, 64));
}


function BeforePaint(Canvas C, float X, float Y)
{
	BannerAdWindow.WinLeft = (WinWidth - 256) / 2;
}

defaultproperties
{
}
