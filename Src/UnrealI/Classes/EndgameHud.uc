//=============================================================================
// EndgameHud.
//=============================================================================
class EndgameHud extends UnrealHUD
	NoUserCreate;

var() localized string Message1;
var() localized string Message2;
var() localized string Message3;
var() localized string Message4;
var() localized string Message5;
var() localized string Message6;
var() localized string Message7;

var() int MessageNumber;

simulated function DrawMOTD(canvas Canvas);

simulated function Timer()
{
	MessageNumber++;
}

simulated function PostRender( canvas Canvas )
{
	local InterpolationPoint i;
	local int TempX,TempY;
	local Decoration D;

	HUDSetup(canvas);

	if ( PlayerPawn(Owner) != None )
	{
		i = InterpolationPoint(PlayerPawn(Owner).Target);


		if ( PlayerPawn(Owner).bShowMenu  )
		{
			DisplayMenu(Canvas);
			return;
		}

		if (i!=None && i.Position==50) PlayerPawn(Owner).AmbientSound=None;

		else if (i!=None && i.Position > 51)
		{
			if (MessageNumber==0)
			{
				MessageNumber++;
				SetTimer(17.0,True);
			}
			HudSetup(Canvas);
			Canvas.bCenter = false;
			Canvas.Font = Canvas.MedFont;
			TempX = Canvas.ClipX;
			TempY = Canvas.ClipY;
			Canvas.SetOrigin(20,Canvas.ClipY-64);

			if (Canvas.ClipX >= 1024 && Canvas.ClipY >= 768)
				Canvas.Font = Font(DynamicLoadObject("UWindowFonts.Tahoma20", class'Font'));
			else Canvas.Font = Canvas.MedFont;
			Canvas.SetClip(Canvas.ClipX-20,220);

			Canvas.SetPos(0,0);
			Canvas.Style = 1;
			if (MessageNumber == 1) Canvas.DrawText(Message1, False);
			else if (MessageNumber == 2) Canvas.DrawText(Message2, False);
			else if (MessageNumber == 3) Canvas.DrawText(Message3, False);
			else if (MessageNumber == 4) Canvas.DrawText(Message4, False);
			else if (MessageNumber == 5) Canvas.DrawText(Message5, False);
			else if (MessageNumber == 6) Canvas.DrawText(Message6, False);
			else if (MessageNumber == 7) Canvas.DrawText(Message7, False);
			else if (MessageNumber > 7)
			{
				foreach AllActors( class 'Decoration', D)
				D.Destroy();
				if (PlayerPawn(Owner).bfire != 0)
					PlayerPawn(Owner).ClientTravel("Unreal",TRAVEL_Absolute,false);
			}
			Canvas.SetOrigin(0,0);
			Canvas.SetClip(TempX,TempY);
		}
	}
}

defaultproperties
{
	Message1="The Skaarj escape pod has broken free from the planet's gravitational pull... barely.  Yet it's fuel has depleted and you drift aimlessly."
	Message2="From where many have died, you have escaped.  You laugh to yourself; so much has happened, but little has changed."
	Message3="Before the crash landing, you were trapped in a cramped cell.  Now, once again you are confined in a prison."
	Message4="But, you feel confident that someone will come upon your small vessel... eventually."
	Message5="Until then, you drift and hope."
	Message6="To Be Continued..."
	Message7="Press fire to restart"
	Event=EndShip
}
