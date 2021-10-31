//=============================================================================
// UnrealTeamHUD
//=============================================================================
class UnrealTeamHUD extends UnrealHUD
	NoUserCreate;

#exec Texture Import File=Textures\HD_Icons\I_HD_SkullBlue.bmp Name=I_HD_SkullBlue Group="HD" Mips=Off
#exec Texture Import File=Textures\HD_Icons\I_HD_SkullGreen.bmp Name=I_HD_SkullGreen Group="HD" Mips=Off
#exec Texture Import File=Textures\HD_Icons\I_HD_SkullRed.bmp Name=I_HD_SkullRed Group="HD" Mips=Off
#exec Texture Import File=Textures\HD_Icons\I_HD_SkullYellow.bmp Name=I_HD_SkullYellow Group="HD" Mips=Off

#exec TEXTURE IMPORT NAME=BlueSkull FILE=Textures\Hud\i_skullb.pcx GROUP="Icons" MIPS=OFF HD=I_HD_SkullBlue
#exec TEXTURE IMPORT NAME=GreenSkull FILE=Textures\Hud\i_skullg.pcx GROUP="Icons" MIPS=OFF HD=I_HD_SkullGreen
#exec TEXTURE IMPORT NAME=RedSkull FILE=Textures\Hud\i_skullr.pcx GROUP="Icons" MIPS=OFF HD=I_HD_SkullRed
#exec TEXTURE IMPORT NAME=YellowSkull FILE=Textures\Hud\i_skully.pcx GROUP="Icons" MIPS=OFF HD=I_HD_SkullYellow

simulated function DrawFragCount(Canvas Canvas, int X, int Y)
{
	local texture SkullTexture;

	SkullTexture = texture'IconSkull';

	if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "red" )
		SkullTexture = texture'RedSkull';
	else if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "blue" )
		SkullTexture = texture'BlueSkull';
	else if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "green" )
		SkullTexture = texture'GreenSkull';
	else if ( Pawn(Owner).PlayerReplicationInfo.TeamName ~= "yellow" )
		SkullTexture = texture'YellowSkull';

	DrawSkull(Canvas, X, Y, SkullTexture);
}

function DrawSkull(Canvas Canvas, int X, int Y, texture SkullTexture)
{
	Canvas.SetPos(X,Y);
	Canvas.DrawIcon(SkullTexture, 1.0);
	Canvas.CurX -= 19;
	Canvas.CurY += 23;
	Canvas.Font = Font'TinyWhiteFont';
	if (Pawn(Owner).PlayerReplicationInfo.Score<100) Canvas.CurX+=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<10) Canvas.CurX+=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<0) Canvas.CurX-=6;
	if (Pawn(Owner).PlayerReplicationInfo.Score<-9) Canvas.CurX-=6;
	Canvas.DrawText(int(Pawn(Owner).PlayerReplicationInfo.Score),False);

}

simulated function DrawIdentifyInfo(canvas Canvas, float PosX, float PosY)
{
	local float XL, YL, XOffset;

	if (!TraceIdentify(Canvas))
		return;

	if (IdentifyTarget.IsA('PlayerPawn'))
		if (PlayerPawn(IdentifyTarget).PlayerReplicationInfo.bFeigningDeath)
			return;

	Canvas.Font = Font'WhiteFont';
	Canvas.Style = 3;

	XOffset = 0.0;
	Canvas.StrLen(IdentifyName$": "$IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 74);

	if (IdentifyTarget.PlayerReplicationInfo.PlayerName != "")
	{
		Canvas.DrawColor = AltTeamColor[IdentifyTarget.PlayerReplicationInfo.Team];
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0;
		Canvas.StrLen(IdentifyName$": ", XL, YL);
		XOffset += XL;
		Canvas.DrawText(IdentifyName$": ");
		Canvas.SetPos(XOffset, Canvas.ClipY - 74);
		Canvas.DrawColor = TeamColor[IdentifyTarget.PlayerReplicationInfo.Team];
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0;
		Canvas.StrLen(IdentifyTarget.PlayerReplicationInfo.PlayerName, XL, YL);
		Canvas.DrawText(IdentifyTarget.PlayerReplicationInfo.PlayerName);
	}

	XOffset = 0.0;
	Canvas.StrLen(IdentifyHealth$": "$IdentifyTarget.Health, XL, YL);
	XOffset = Canvas.ClipX/2 - XL/2;
	Canvas.SetPos(XOffset, Canvas.ClipY - 64);

	if (Pawn(Owner).PlayerReplicationInfo.Team == IdentifyTarget.PlayerReplicationInfo.Team)
	{
		Canvas.DrawColor = AltTeamColor[IdentifyTarget.PlayerReplicationInfo.Team];
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0;
		Canvas.StrLen(IdentifyHealth$": ", XL, YL);
		XOffset += XL;
		Canvas.DrawText(IdentifyHealth$": ");
		Canvas.SetPos(XOffset, Canvas.ClipY - 64);
		Canvas.DrawColor = TeamColor[IdentifyTarget.PlayerReplicationInfo.Team];
		Canvas.DrawColor.R = Canvas.DrawColor.R * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.G = Canvas.DrawColor.G * IdentifyFadeTime / 3.0;
		Canvas.DrawColor.B = Canvas.DrawColor.B * IdentifyFadeTime / 3.0;
		Canvas.StrLen(IdentifyTarget.Health, XL, YL);
		Canvas.DrawText(IdentifyTarget.Health);
	}

	Canvas.Style = 1;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
}

defaultproperties
{
}
