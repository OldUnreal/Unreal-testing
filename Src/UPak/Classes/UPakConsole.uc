//=============================================================================
// UPakConsole.uc
// $Author: Jcrable $
// $Date: 5/05/99 4:21p $
// $Revision: 3 $
//=============================================================================

class UPakConsole expands UnrealConsole;

// special handling for level transitions
var bool bTransition;
var string NextMap;

// Text selected with shift-arrow
var string SelectedText; 

// Used for text insertion, moving around with arrow keys, etc.
var string RightToLeft; 

var bool bSelecting;
var bool bSelectingLeft;
 
exec function Talk()
{
	if( !bTransition )
	{
		TypedStr="Say ";
		bNoStuff = true;
		GotoState( 'Typing' );
	}
}

exec function TeamTalk()
{
	if( !bTransition )
	{
		TypedStr="TeamSay ";
		bNoStuff = true;
		GotoState( 'Typing' );
	}
}

event bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
{
	// handle Intro and transition abort (left mouse click)
	if( Action==IST_Press && Key == EInputKey.IK_LeftMouse )
	{
		if( Viewport.Actor.Level.Game.IsA( 'CSMovie' ) )
		{
			Viewport.Actor.ShowMenu();
			return true;
		}
		if( bTransition )
		{
			bTransition = false;
			ViewPort.Actor.bFire = 0;
			ViewPort.Actor.bAltFire =0;
			TransitionNullHUD( ViewPort.Actor.myHUD ).EndLevel() ;
			return true;
		}
	}
	return Super.KeyEvent( Key, Action, Delta );
}

// Add localization to hardcoded strings!!
// Called after rendering the world view.
event PostRender( canvas C )
{
	local int YStart, YEnd;

	if(bNoDrawWorld)
	{
		C.SetPos(0,0);
		C.DrawPattern( Texture'Border', C.ClipX, C.ClipY, 1.0 );
	}

	if( TimeDemo != None )
		TimeDemo.PostRender( C );

	// call overridable "level action" rendering code to draw the "big message"
	DrawLevelAction( C );

	// If the console has changed since the previous frame, draw it.
	if ( ConsoleLines > 0 )
	{
		C.SetOrigin(0.0, ConsoleLines - FrameY*0.6);
		C.SetPos(0.0, 0.0);
		C.DrawTile( ConBackground, FrameX, FrameY*0.6, C.CurX, C.CurY, FrameX, FrameY );
	}

	// Draw border.
	YStart 	= BorderLines;
	YEnd 	= FrameY - BorderLines;
	if ( BorderLines > 0 || BorderPixels > 0 )
	{
		YStart += ConsoleLines;
		if ( BorderLines > 0 )
		{
			C.SetOrigin(0.0, 0.0);
			C.SetPos(0.0, 0.0);
			C.DrawPattern( Border, FrameX, BorderLines, 1.0 );
			C.SetPos(0.0, YEnd);
			C.DrawPattern( Border, FrameX, BorderLines, 1.0 );
		}
		if ( BorderPixels > 0 )
		{
			C.SetOrigin(0.0, 0.0);
			C.SetPos(0.0, YStart);
			C.DrawPattern( Border, BorderPixels, YEnd - YStart, 1.0 );
			C.SetPos( FrameX - BorderPixels, YStart );
			C.DrawPattern( Border, BorderPixels, YEnd - YStart, 1.0 );
		}
	}

	// Draw console text.
	C.SetOrigin(0.0, 0.0);
	if ( ConsoleLines > 0 )
		DrawConsoleView( C );
	else
		DrawSingleView( C );
}

defaultproperties
{
     MouseScale=1.300000
}
