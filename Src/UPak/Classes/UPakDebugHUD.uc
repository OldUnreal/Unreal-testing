//=============================================================================
// UPakDebugHUD.
//=============================================================================
class UPakDebugHUD expands UnrealHUD;

var int Counter;
var bool bLockedTarget;

simulated function PostRender( canvas Canvas )
{
	if( IdentifyTarget != None )
		DisplayPawnStats( Canvas );
	MOTDFadeOutTime = 0.0;
	Super.PostRender( Canvas );
}

simulated function bool TraceIdentify(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;

	StartTrace = Owner.Location;
	StartTrace.Z += Pawn(Owner).BaseEyeHeight;

	EndTrace = StartTrace + vector(Pawn(Owner).ViewRotation) * 1000.0;

	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

	if ( (Pawn(Other) != None) && !bLockedTarget )
	{
		IdentifyTarget = Pawn(Other);
		IdentifyFadeTime = 0.1;
	}

	if ( IdentifyFadeTime == 0.0 )
		return false;

	if ( (IdentifyTarget == None) || (!IdentifyTarget.bIsPlayer) ||
		 (IdentifyTarget.bHidden) || (IdentifyTarget.PlayerReplicationInfo == None ))
		return false;

	return true;
}

simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
	local float XL, YL, XOffset;

	if (!TraceIdentify(Canvas))
		return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	XOffset = 0.0;
	Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 54);
	
	if(IdentifyTarget.PlayerReplicationInfo.PlayerName != "")
	{
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 160 * (IdentifyFadeTime / 3.0);
		Canvas.DrawColor.B = 0;

		Canvas.StrLen(IdentifyName$": ", XL, YL);
		XOffset += XL;
		Canvas.DrawText(IdentifyName$": ");
		Canvas.SetPos(XOffset, Canvas.ClipY - 54);

		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255 * (IdentifyFadeTime / 3.0);
		Canvas.DrawColor.B = 0;

		Canvas.StrLen(IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
		Canvas.DrawText(IdentifyTarget.PlayerReplicationInfo.PlayerName);
	}

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}


function DisplayPawnStats( canvas C )
{
	local float XL, YL;
	local int Incrementer;

	C.Font = C.SmallFont;		
		
	Incrementer = 2;
	
	C.StrLen("TEST", XL, YL);
	
	if( bLockedTarget )
	{
		C.Style = 2;
		C.DrawColor.R = 100;
		C.DrawColor.G = 150;
		C.DrawColor.B = 0;
		C.bCenter = True;
		C.SetPos( 0.0, 32 + 1 * YL );
		C.DrawText( "<><><> LOCKED ON TO "$IdentifyTarget.Name$" <><><>" );
	}
	else
	{
		C.Style = 2;
		C.DrawColor.R = 100;
		C.DrawColor.G = 150;
		C.DrawColor.B = 0;
		C.bCenter = True;
		C.SetPos(0.0, 32 + 1 * YL );
		C.DrawText( "Type [ LOCK ] to toggle locking to "$IdentifyTarget.Name );
	}	
	
	C.bCenter = false;
	C.Style = 3;
	C.Drawcolor.R = 150;
	C.DrawColor.B = 0;
	C.DrawColor.G = 95;
	C.SetPos(0.0, 32 + YL);

	C.SetPos( 0.0, 32 + Incrementer * YL );	
	C.DrawText( "Pawn................ "$IdentifyTarget.Name );
	Incrementer++;
	C.SetPos(0.0, 32 + Incrementer * YL);

	C.DrawText( "In State............ "$IdentifyTarget.GetStateName() );
	Incrementer++;
	C.SetPos(0.0, 32 + Incrementer * YL);
	
	C.DrawText( "Pawn Health......... "$IdentifyTarget.Health );
	Incrementer++;
	C.SetPos(0.0, 32 + Incrementer * YL);
	
	C.DrawText( "Animation........... "$IdentifyTarget.AnimSequence );
	Incrementer++;
	C.SetPos(0.0, 32 + Incrementer * YL);
	
	if( IdentifyTarget.Enemy != None )
	{
		C.DrawText( "Enemy............... "$IdentifyTarget.Enemy );
		Incrementer++;
		C.SetPos(0.0, 32 + Incrementer * YL);
	}
	
	if( IdentifyTarget.Target != None )
	{
		C.DrawText( "Target.............. "$IdentifyTarget.Target );
		Incrementer++;
		C.SetPos(0.0, 32 + Incrementer * YL);
	}
		
	C.DrawText( "Focus............... "$IdentifyTarget.Focus );
	Incrementer++;
	C.SetPos(0.0, 32 + Incrementer * YL);

	if( IdentifyTarget.Weapon != none )
	{
		C.DrawText( "Weapon.............. "$IdentifyTarget.Weapon );
		Incrementer++;
		C.SetPos(0.0, 32 + Incrementer * YL );
		
		C.DrawText( "Ammo................ "$IdentifyTarget.Weapon.AmmoType.AmmoAmount );
		Incrementer++;
		C.SetPos(0.0, 32 + Incrementer * YL );
	}
	
	if( Pawn( Owner ).Weapon != none )
	{
		C.DrawText( "Your Weapon State... "$Pawn( Owner ).Weapon.GetStateName() );
		Incrementer++;
		C.SetPos( 0.0, 32 + Incrementer * YL );
	}
	
	if ( IdentifyTarget.Health <= 0 )
	{
		C.SetPos( 0.0, 32 + 10 * YL );
		C.bCenter = True;
		C.Font = C.MedFont;
		C.DrawColor.B = 100;
		C.DrawColor.G = 100;
		C.DrawColor.R = 200;
		C.Style = 1;
		C.DrawText( ">>>> Pawn is DEAD <<<<" );
		Counter++;
		if ( Counter >= 500 )
		{
			if ( bLockedTarget )
			{
				bLockedTarget = False;
				if ( UPakDebugger( Owner.Inventory ).bLocked )
				{
					UPakDebugger( Owner.Inventory ).bLocked = False;
				}
			}
			IdentifyTarget = None;
			Counter = 0;
		}
	}
}

defaultproperties
{
}
