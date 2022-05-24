//=============================================================================
// UnrealMutatorMenu
//=============================================================================
class UnrealMutatorMenu extends UnrealLongMenu
	config;

var() localized string InUseString,NotInUseString;
var globalconfig string UsedMutators;

struct FMutatorEntry
{
	var string ClassName,MutatorName,MutatorDesc;
	var bool bEnabled;
};
var array<FMutatorEntry> MutatorList;

function PostBeginPlay()
{
	local string N,D;
	local int i;
	
	Super.PostBeginPlay();
	MenuLength = 0;
	foreach IntDescIterator(string(Class'Mutator'),N,D,true)
	{
		MutatorList[MenuLength].ClassName = N;
		if( Len(D) )
		{
			i = InStr(D,",");
			if( i>0 )
			{
				MutatorList[MenuLength].MutatorName = Left(D,i);
				MutatorList[MenuLength].MutatorDesc = Mid(D,i+1);
			}
			else MutatorList[MenuLength].MutatorName = D;
		}
		else MutatorList[MenuLength].MutatorName = GetItemName(N);
		++MenuLength;
	}
	MenuLength++;

	N = UsedMutators;
	while( Len(N) )
	{
		i = InStr(N,",");
		if( i==-1 )
		{
			D = N;
			N = "";
		}
		else
		{
			D = Left(N,i);
			N = Mid(N,i+1);
		}
		
		for( i=(MutatorList.Size()-1); i>=0; --i )
			if( MutatorList[i].ClassName~=D )
			{
				MutatorList[i].bEnabled = true;
				break;
			}
		if( i<0 )
			bConfigChanged = true; // Mutator was no longer found, mark as dirty.
	}
}

function SaveConfigs()
{
	local int i;
	
	UsedMutators = "";
	for( i=0; i<MutatorList.Size(); ++i )
	{
		if( MutatorList[i].bEnabled )
		{
			if( Len(UsedMutators) )
				UsedMutators = UsedMutators$","$MutatorList[i].ClassName;
			else UsedMutators = MutatorList[i].ClassName;
		}
	}
	Default.UsedMutators = UsedMutators;
	SaveConfig();
}

function bool ProcessSelection()
{
	if ( Selection==1 )
	{
		ExitMenu();
		return true;
	}

	MutatorList[Selection-2].bEnabled = !MutatorList[Selection-2].bEnabled;
	bConfigChanged = true;
	return true;
}
function bool ProcessLeft()
{
	if ( Selection>1 )
	{
		if( MutatorList[Selection-2].bEnabled )
		{
			MutatorList[Selection-2].bEnabled = false;
			bConfigChanged = true;
		}
		return true;
	}
	return false;
}
function bool ProcessRight()
{
	if ( Selection>1 )
	{
		if( !MutatorList[Selection-2].bEnabled )
		{
			MutatorList[Selection-2].bEnabled = true;
			bConfigChanged = true;
		}
		return true;
	}
	return false;
}

function DrawMenu(canvas Canvas)
{
	DrawBackGround(Canvas, (Canvas.ClipY < 320));

	DrawTitle(Canvas);
	DrawSlots(Canvas);
	DrawHelpPanel(Canvas, Canvas.ClipY-100, 228);
}

function DrawHelpPanel(canvas Canvas, int MinStartY, int XClip)
{
	local int OldXClip, OldYClip;
	local int StartX, StartY;
	local float XL, YL;
	local string S;

	if ( Canvas.ClipY < 92 + MinStartY )
		return;
	
	if ( Selection == 1 )
		S = HelpMessage[0];
	else S = MutatorList[Selection-2].MutatorDesc;
	if( !Len(S) )
		return;

	StartX = 0.5 * Canvas.ClipX - 128;
	StartY = Canvas.ClipY - 92;
	OldXClip = Canvas.ClipX;
	OldYClip = Canvas.ClipY;

	Canvas.bCenter = false;
	Canvas.Font = Canvas.MedFont;
	Canvas.SetOrigin(StartX + 18, StartY);
	Canvas.SetClip(XClip,128);
	Canvas.SetPos(0,0);
	Canvas.Style = 1;
	SetFontBrightness(Canvas, true);
	Canvas.StrLen(S, XL, YL);
	if (YL <= Canvas.ClipY && MinStartY + YL <= OldYClip)
	{
		if (StartY + YL > OldYClip)
			Canvas.OrgY = OldYClip - YL;
		Canvas.DrawText(S, false);
	}
	SetFontBrightness(Canvas, false);
	Canvas.SetOrigin(0, 0);
	Canvas.SetClip(OldXClip,OldYClip);
}

function DrawSlots(canvas Canvas)
{
	local int StartX, EndX, StartY, Spacing, i;
	local float XL,YL;

	Canvas.Font = Canvas.MedFont;
	Canvas.TextSize("W",XL,YL);
	
	Spacing = Clamp((Canvas.ClipY - 120) / (MenuLength + 3), YL, 32);
	StartX = Max(20, 0.5 * (Canvas.ClipX - 206));
	EndX = Canvas.ClipX - StartX;
	StartY = Max(40, 0.5 * (Canvas.ClipY - (MenuLength + 2) * Spacing-40));
	Canvas.Font = Canvas.MedFont;
	
	SetFontBrightness(Canvas, true);
	Canvas.SetPos(StartX, StartY);
	Canvas.DrawText(NotInUseString, false);
	Canvas.TextSize(InUseString,XL,YL);
	Canvas.SetPos(EndX-XL, StartY);
	Canvas.DrawText(InUseString, false);
	StartY+=(Spacing*2);
	
	SetFontBrightness(Canvas, (Selection==1));
	Canvas.SetPos(StartX, StartY);
	Canvas.DrawText(MenuList[0], false);
	StartY+=Spacing;

	for (i = 0; i < MutatorList.Size(); ++i)
	{
		SetFontBrightness(Canvas, (Selection==(i+2)));
		if( MutatorList[i].bEnabled )
		{
			Canvas.TextSize(MutatorList[i].MutatorName,XL,YL);
			Canvas.SetPos(EndX-XL, StartY);
			Canvas.DrawText(MutatorList[i].MutatorName$">", false);
		}
		else
		{
			Canvas.SetPos(StartX-4, StartY);
			Canvas.DrawText("<"$MutatorList[i].MutatorName, false);
		}
		StartY+=Spacing;
	}
	SetFontBrightness(Canvas, false);
}

defaultproperties
{
	MenuTitle="MUTATORS"
	InUseString="In Use"
	NotInUseString="Inactive"
	MenuList(0)="Return"
	HelpMessage(0)="Return back to previous menu"
}