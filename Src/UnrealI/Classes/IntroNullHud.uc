//=============================================================================
// IntroNullHud.
//=============================================================================
class IntroNullHud extends UnrealHUD
	NoUserCreate;

#exec OBJ LOAD FILE=..\UnrealShare\Textures\menugr.utx PACKAGE=UnrealShare.MenuGfx
#exec Texture Import File=Textures\Hud\FModLogo.pcx Name=FModLogo Group=Logo Mips=Off Flags=2
#exec Texture Import File=Textures\Hud\NVIDIA_PhysX_Logo.pcx Name=PhysXLogo Group=Logo Mips=Off Flags=2
#exec Texture Import File=Textures\Hud\OpenALLogo.pcx Name=OpenALLogo Group=Logo Mips=Off Flags=2

var() localized string ESCMessage;

simulated function DrawMOTD(canvas Canvas);

simulated function PostRender( canvas Canvas )
{
	local float StartX,IconScale;
	local Engine E;
	local int i;
	local float X,Y,YS;
	local Texture T;

	HUDSetup(canvas);

	if ( (PlayerPawn(Owner) != None) && PlayerPawn(Owner).bShowMenu  )
	{
		DisplayMenu(Canvas);
		return;
	}
	else if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds )
		DisplayProgressMessage(Canvas);

	Canvas.Font = Canvas.MedFont;
	Canvas.SetPos(Canvas.ClipX/2.0-66,4);
	Canvas.DrawText(ESCMessage, False);

	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.SetPos(StartX,Canvas.ClipY-58);
	Canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawTile( Texture'MenuBarrier', 256, 64, 0, 0, 256, 64 );
	StartX = 0.5 * Canvas.ClipX - 128;
	Canvas.Style = 2;
	Canvas.SetPos(StartX,Canvas.ClipY-52);
	Canvas.DrawIcon(texture'Logo2', 1.0);

	if (Canvas.ClipX>790)
	{
		Canvas.SetPos(0,Canvas.ClipY-128);
		Canvas.DrawIcon(texture'DE', 1.0);
		Canvas.SetPos(0,Canvas.ClipY-256);
		Canvas.DrawIcon(texture'GT', 1.0);
		Canvas.SetPos(0,Canvas.ClipY-384);
		Canvas.DrawIcon(texture'Epic', 1.0);
		IconScale = 128.f;
	}
	else if (Canvas.ClipX>390)
	{
		Canvas.SetPos(0,Canvas.ClipY-64);
		Canvas.DrawIcon(texture'DE2', 1.0);
		Canvas.SetPos(0,Canvas.ClipY-128);
		Canvas.DrawIcon(texture'GT', 0.5);
		Canvas.SetPos(0,Canvas.ClipY-192);
		Canvas.DrawIcon(texture'Epic2', 1.0);
		IconScale = 64.f;
	}
	else IconScale = 32.f;

	// 227k: Draw driver specific logos.
	E = GetEngine();
	X = Canvas.ClipX-IconScale-1;
	Y = Canvas.ClipY-1;
	for( i=0; i<E.DriverCredits.Size(); ++i )
	{
		T = E.DriverCredits[i].Logo;
		if( !T )
			continue;
		
		if( T.USize==T.VSize )
		{
			Y-=IconScale;
			Canvas.SetPos(X,Y);
			Canvas.DrawRect(T,IconScale,IconScale);
		}
		else
		{
			YS = (float(T.VSize) / float(T.USize)) * IconScale;
			Y-=YS;
			Canvas.SetPos(X,Y);
			Canvas.DrawRect(T,IconScale,YS);
		}
	}
	Canvas.Style = 1;
}

defaultproperties
{
	ESCMessage="Press ESC to begin"
}
