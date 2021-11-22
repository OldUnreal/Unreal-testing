//=============================================================================
// UBrowserBannerAd
//=============================================================================
class UBrowserBannerAd extends UWindowWindow;

#exec TEXTURE IMPORT NAME=BannerAd FILE=Textures\logo3.pcx GROUP="Icons" FLAGS=2 MIPS=OFF

var string URL;

function Created()
{
	URL = "http://www.unreal.com";
	Cursor = Root.HandCursor;
}

function Paint(Canvas C, float X, float Y)
{
	DrawClippedTexture(C, 0, 0, Texture'BannerAd');
}

function Click(float X, float Y)
{
	Root.Console.ViewPort.Actor.ConsoleCommand("start "$URL);
}

function MouseLeave()
{
	Super.MouseLeave();
	ToolTip("");
}

function MouseEnter()
{
	Super.MouseLeave();
	ToolTip(URL);
}

defaultproperties
{
}
