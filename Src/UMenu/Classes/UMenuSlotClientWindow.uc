class UMenuSlotClientWindow extends UMenuDialogClientWindow;

var transient string SlotNames[9]; // Legacy compatibility
var localized string SlotHelp;
var localized string FoundOldGameSavesTitle;
var localized string FoundOldGameSavesText;

var UWindowScrollingDialogClient ScrollClient;
var UWindowDialogClientWindow ScrollPage;
var array<UMenuRaisedButton> Slots;
var array<UWindowBitmap> SlotImages;
var int ImageSize,BottonSpace;
var bool bSaveGame;

function Created()
{
	Super.Created();

	DesiredWidth = 300;
	DesiredHeight = 320;
	
	ScrollClient = UWindowScrollingDialogClient(CreateWindow(class'UWindowScrollingDialogClient', 6, 6, WinWidth-12, WinHeight-BottonSpace-12));
	ScrollPage = ScrollClient.ClientArea;
	ScrollClient.bAllowsMouseWheelScrolling = true;
	SetAcceptsFocus();

	WindowShown();
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key)
{
	if (Msg == WM_KeyDown)
	{
		ScrollClient.WindowEvent(Msg, C, X, Y, Key);
		Root.bHandledWindowEvent = true;
	}
	super.WindowEvent(Msg, C, X, Y, Key);
}

function WindowShown()
{
	local int ButtonWidth, ButtonLeft, ButtonTop, i, Index, FreeIndex;
	local GameInfo.SavedGameInfo S;
	local string str;

	super.WindowShown();

	ButtonWidth = ScrollPage.WinWidth - 8 - ImageSize;
	ButtonLeft = ImageSize + 2 + (ScrollPage.WinWidth - ImageSize - ButtonWidth)/2;
	ButtonTop = 3;
	FreeIndex = 1;

	foreach class'GameInfo'.Static.AllSavedGames(S,Index)
	{
		if( bSaveGame && Index==0 ) continue;
		
		if(Slots[i]==None)
		{
			Slots[i] = UMenuRaisedButton(ScrollPage.CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop+8, ButtonWidth, 1));
			Slots[i].NotifyWindow = Self;
			SlotImages[i] = UWindowBitmap(ScrollPage.CreateWindow(class'UWindowBitmap', 3, ButtonTop, ImageSize, ImageSize));
			SlotImages[i].bStretch = true;
		}
		else if( !Slots[i].bWindowVisible )
		{
			Slots[i].ShowWindow();
			SlotImages[i].ShowWindow();
		}
		str = S.MapTitle@S.Timestamp;
		if( S.ExtraInfo!="" )
			str = "["$S.ExtraInfo$"] "$str;
		Slots[i].SetText(str);
		Slots[i].SetHelpText(SlotHelp @ "[" $ S.MapTitle $ "]");
		Slots[i].Index = Index;
		if( FreeIndex==Index )
			++FreeIndex;

		SlotImages[i].FitTexture((S.Screenshot!=None) ? S.Screenshot : Texture'S_Flag');
		ButtonTop+=(ImageSize+2);
		++i;
	}
	
	if( bSaveGame )
	{
		if(Slots[i]==None)
		{
			Slots[i] = UMenuRaisedButton(ScrollPage.CreateControl(class'UMenuRaisedButton', ButtonLeft, ButtonTop+8, ButtonWidth, 1));
			Slots[i].NotifyWindow = Self;
			SlotImages[i] = UWindowBitmap(ScrollPage.CreateWindow(class'UWindowBitmap', 3, ButtonTop, ImageSize, ImageSize));
			SlotImages[i].bStretch = true;
		}
		else if( !Slots[i].bWindowVisible )
		{
			Slots[i].ShowWindow();
			SlotImages[i].ShowWindow();
		}
		Slots[i].SetText("New save...");
		Slots[i].SetHelpText("Create a new save slot!");
		Slots[i].Index = FreeIndex;

		SlotImages[i].FitTexture(Texture'S_Teleport');
		ButtonTop+=(ImageSize+2);
		++i;
	}
	ScrollPage.DesiredHeight = ButtonTop;
	
	for( i=i; i<Slots.Size(); ++i)
	{
		if( Slots[i].bWindowVisible )
		{
			Slots[i].HideWindow();
			SlotImages[i].HideWindow();
		}
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	local int ButtonWidth, ButtonLeft, i;

	ScrollClient.SetSize(WinWidth-12, WinHeight-12-BottonSpace);
	ButtonWidth = ScrollPage.WinWidth - 16 - ImageSize - ScrollClient.VertSB.WinWidth;
	ButtonLeft = ImageSize + 8;

	for( i=i; i<Slots.Size(); ++i)
	{
		if( Slots[i].bWindowVisible )
		{
			Slots[i].SetSize(ButtonWidth, 1);
			Slots[i].WinLeft = ButtonLeft;
		}
	}
}

defaultproperties
{
	ImageSize=64
	SlotHelp="Press to activate this slot. (Save/Load)"
	FoundOldGameSavesTitle="Old game saves found..."
	FoundOldGameSavesText="Found some game saves created with an older engine version than the current. These files are unusable now with this version."
}