//=============================================================================
// UPakIntroNullHud.
//=============================================================================
class UPakIntroNullHud expands IntroNullHud;

#forceexec TEXTURE IMPORT NAME=Legend1 FILE=TEXTURES\Logo128a.pcx Group=Logo Mips=Off Flags=2
#forceexec TEXTURE IMPORT NAME=Legend2 FILE=TEXTURES\Logo64a.pcx Group=Logo Mips=Off Flags=2
#forceexec TEXTURE IMPORT NAME=Return FILE=TEXTURES\Return.pcx Group=Logo Mips=Off Flags=2
#forceexec TEXTURE IMPORT NAME=LInfogrames128 FILE=TEXTURES\Infogrames128.pcx Group=Logo Mips=Off Flags=2
#forceexec TEXTURE IMPORT NAME=LInfogrames64 FILE=TEXTURES\Infogrames64.pcx Group=Logo Mips=Off Flags=2

var int MenuCount;

function PostRender( Canvas Canvas )
{
	local float StartX;

	HUDSetup(canvas);

	Canvas.Font = Canvas.MedFont;

	StartX = 0.5 * Canvas.ClipX - 128;	
	Canvas.SetPos(StartX,Canvas.ClipY-58);
	Canvas.Style = ERenderStyle.STY_Translucent;	
	Canvas.DrawTile( Texture'MenuBarrier', 256, 64, 0, 0, 256, 64 );
	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.Style = 2;	
	Canvas.SetPos(StartX,Canvas.ClipY-52);
	Canvas.DrawIcon(texture'Return', 1.0);	

	if (Canvas.ClipX>790)
	{
		Canvas.SetPos(0,Canvas.ClipY-128);
		Canvas.DrawIcon(texture'Legend1', 1.0);		
		Canvas.SetPos(0,Canvas.ClipY-256);
		Canvas.DrawIcon(texture'LInfogrames128', 1.0);			
		Canvas.SetPos(0,Canvas.ClipY-384);
		Canvas.DrawIcon(texture'Epic', 1.0);
	}	
	else if (Canvas.ClipX>390)
	{
		Canvas.SetPos(0,Canvas.ClipY-64);
		Canvas.DrawIcon(texture'Legend2', 1.0);		
		Canvas.SetPos(0,Canvas.ClipY-128);
		Canvas.DrawIcon(texture'LInfogrames64', 1.0);			
		Canvas.SetPos(0,Canvas.ClipY-192);
		Canvas.DrawIcon(texture'Epic2', 1.0);
	}
	
	Canvas.Style = 1;

	if ( (PlayerPawn(Owner) != None) && PlayerPawn(Owner).bShowMenu  )
	{
		DisplayMenu(Canvas);
		return;
	}
	else if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds )
		DisplayProgressMessage(Canvas);
}

defaultproperties
{
}
