//=============================================================================
// UnrealSlotMenu
//=============================================================================
class UnrealSlotMenu extends UnrealLongMenu;

var transient string SlotNames[9]; // Legacy compatibility
var localized string MonthNames[12];
var localized string EmptySlot;

struct FSaveSlot
{
	var string Name,Date,Extra;
	var Texture Screenshot;
	var int Index;
};
var array<FSaveSlot> Slots;
var bool bSaveGame;

function BeginPlay()
{
	local GameInfo.SavedGameInfo S;
	local int Index,FreeIndex,i;
	
	Super.BeginPlay();

	FreeIndex = 1;
	foreach class'GameInfo'.Static.AllSavedGames(S,Index)
	{
		if( bSaveGame && Index==0 ) continue;
		
		Slots[i].Name = S.MapTitle;
		Slots[i].Date = S.Timestamp;
		Slots[i].Extra = (S.ExtraInfo!="") ? ("["$S.ExtraInfo$"] ") : "";
		Slots[i].Screenshot = S.Screenshot;
		Slots[i].Index = Index;
		if( FreeIndex==Index )
			++FreeIndex;
		++i;
	}
	
	MenuLength = i+1;
	if( bSaveGame )
	{
		Slots[i].Name = EmptySlot;
		Slots[i].Index = FreeIndex;
		++i;
	}
}
function DrawSlots(canvas Canvas)
{
	local int StartX, StartY, Spacing, i, IconSize;

	Spacing = Clamp(0.05 * Canvas.ClipY, 12, 32);
	StartX = Max(20, 0.5 * (Canvas.ClipX - 206));
	StartY = Max(40, 0.5 * (Canvas.ClipY - MenuLength * Spacing-40));
	Canvas.Font = Canvas.MedFont;
	
	IconSize = (0.5 * Canvas.ClipX) - 148;

	for (i = 0; i < Array_Size(Slots); ++i)
	{
		Canvas.SetPos(StartX, StartY);
		Canvas.DrawText(Slots[i].Extra$Slots[i].Name@Slots[i].Date, false);
		
		if( (Selection-1)==i )
		{
			// show selection
			Canvas.SetPos( StartX - 20, StartY);
			Canvas.DrawText("[]", false);

			if( Slots[i].Screenshot!=None )
			{
				Canvas.bNoSmooth = false;
				Canvas.SetPos(10, (Canvas.ClipY-IconSize)*0.5 );
				Canvas.DrawRect(Slots[i].Screenshot, IconSize, IconSize);
				Canvas.SetPos(12, (Canvas.ClipY-IconSize)*0.5 + 2 );
				Canvas.DrawText(Slots[i].Name, false);
			}
		}
		StartY+=Spacing;
	}
	if( !bSaveGame )
	{
		StartY+=(Spacing*0.5);
		
		Canvas.SetPos(StartX, StartY);
		Canvas.DrawText(class'UnrealLoadMenu'.Default.RestartString$Level.TitleOrName(), false);
		if( (Selection-1)==i )
		{
			// show selection
			Canvas.SetPos( StartX - 20, StartY);
			Canvas.DrawText("[]", false);
		}
	}
}

defaultproperties
{
	MonthNames(0)="January"
	MonthNames(1)="February"
	MonthNames(2)="March"
	MonthNames(3)="April"
	MonthNames(4)="May"
	MonthNames(5)="June"
	MonthNames(6)="July"
	MonthNames(7)="August"
	MonthNames(8)="September"
	MonthNames(9)="October"
	MonthNames(10)="November"
	MonthNames(11)="December"
	MenuLength=9
	EmptySlot="..Empty.."
}
