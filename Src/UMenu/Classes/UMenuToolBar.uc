class UMenuToolBar extends UWindowWindow
			config;

#exec TEXTURE IMPORT NAME=TempBG FILE=Textures\TempBG.pcx GROUP="Icons" MIPS=OFF

function Created()
{
	bAlwaysOnTop = True;
}

function Paint(Canvas C, float X, float Y)
{
	//C.Style = ERenderStyle.STY_Translucent;
	Tile(C, Texture'TempBG');
	//C.Style = ERenderStyle.STY_Normal;
}

defaultproperties
{
}
