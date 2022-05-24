class UMenuScreenshotCW expands UWindowDialogClientWindow;

var Texture Screenshot;
var string MapTitle;
var string MapAuthor;
var string IdealPlayerCount;

var localized string PlayersText;

function SetMap(string MapName)
{
	local LevelSummary L;

	if( Right(MapName,4)~=".unr" )
		MapName = Left(MapName, Len(MapName)-4);

	Screenshot = Texture(DynamicLoadObject(MapName$".Screenshot", class'Texture',true));
	if( Screenshot==None ) // Try using fallback.
		Screenshot = Texture(DynamicLoadObject("DefPreview."$MapName$"Shot", class'Texture',true));

	L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary',true));
	if (L != None)
	{
		MapTitle = L.Title;
		MapAuthor = L.Author;
		IdealPlayerCount = L.IdealPlayerCount;
	}
	else
	{
		MapTitle = Localize("LevelInfo0","Title",MapName,MapName);
		MapAuthor = Localize("LevelInfo0","Author",MapName," ");
		if( MapAuthor==" " )
			MapAuthor = "";
		IdealPlayerCount = Localize("LevelInfo0","IdealPlayerCount",MapName," ");
		if( IdealPlayerCount==" " )
			IdealPlayerCount = "";
	}
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	Screenshot = None;
}

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, W, H;

	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	if (Screenshot != None)
	{
		W = Min(WinWidth, Screenshot.USize);
		H = Min(WinHeight, Screenshot.VSize);

		if (W > H)
			W = H;
		if (H > W)
			H = W;

		X = (WinWidth - W) / 2;
		Y = (WinHeight - H) / 2;

		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;

		DrawStretchedTexture(C, X, Y, W, H, Screenshot);

		C.Font = Root.Fonts[F_Normal];

		if (IdealPlayerCount != "")
		{
			TextSize(C, IdealPlayerCount@PlayersText, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*2;
			ClipText(C, X, Y, IdealPlayerCount@PlayersText);
		}

		if (MapAuthor != "")
		{
			TextSize(C, MapAuthor, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*3;
			ClipText(C, X, Y, MapAuthor);
		}

		if (MapTitle != "")
		{
			TextSize(C, MapTitle, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*4;
			ClipText(C, X, Y, MapTitle);
		}
	}
}

defaultproperties
{
	PlayersText="Players"
}
