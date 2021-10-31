class UBrowserOpenBar extends UWindowDialogClientWindow;

var UWindowComboControl 		OpenCombo;

var localized string	OpenText;
var localized string	OpenHelp;
var config string		OpenHistory[10];
// var UBrowserBrowserButton	Logo;

function Created()
{
	local float EditWidth;
	local int i;
	local Color TC;

	Super.Created();

	EditWidth = WinWidth - 140;

	OpenCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', 20, 20, EditWidth, 1));
	OpenCombo.SetText(OpenText);
	OpenCombo.SetHelpText(OpenHelp);
	OpenCombo.SetFont(F_Normal);
	OpenCombo.SetEditable(True);
	for (i=0; i<10; i++)
		if (OpenHistory[i] != "")
			OpenCombo.AddItem(OpenHistory[i]);

	TC.R = 255;
	TC.G = 255;
	TC.B = 255;
	OpenCombo.SetTextColor(TC);

	//Logo = UBrowserBrowserButton(CreateWindow(class'UBrowserBrowserButton', WinWidth-WinHeight, 0, WinHeight, WinHeight));
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float EditWidth;
	local float XL, YL;

	C.Font = Root.Fonts[OpenCombo.Font];
	TextSize(C, OpenCombo.Text, XL, YL);

	EditWidth = WinWidth - 140;

	OpenCombo.WinLeft = (WinWidth - EditWidth - 80) / 2;
	OpenCombo.WinTop = (WinHeight-OpenCombo.WinHeight) / 2;
	OpenCombo.SetSize(EditWidth, OpenCombo.WinHeight);
	OpenCombo.EditBoxWidth = OpenCombo.WinWidth - XL - 20;

//	Logo.WinLeft = WinWidth - WinHeight - 2;
//	Logo.WinTop = 2;
//	Logo.SetSize(WinHeight-4, WinHeight-4);
//	Logo.bSpin = True;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch (E)
	{
	case DE_EnterPressed:
		switch (C)
		{
		case OpenCombo:
			OpenURL();
			break;
		}
	}
}

function OpenURL()
{
	local int i;
	local bool HistoryItem;
	local UWindowComboListItem Item;


	for (i=0; i<10; i++)
	{
		if (OpenHistory[i] ~= OpenCombo.GetValue())
			HistoryItem = True;
	}
	if (!HistoryItem)
	{
		OpenCombo.InsertItem(OpenCombo.GetValue());
		while (OpenCombo.List.Items.Count() > 10)
			OpenCombo.List.Items.Last.Remove();

		Item = UWindowComboListItem(OpenCombo.List.Items.Next);
		for (i=0; i<10; i++)
		{
			if (Item != None)
			{
				OpenHistory[i] = Item.Value;
				Item = UWindowComboListItem(Item.Next);
			}
			else
				OpenHistory[i] = "";
		}
	}
	SaveConfig();

//	Log("Opening URL: "$OpenCombo.GetValue());

	if ( Left(OpenCombo.GetValue(), 7) ~= "http://" )
		GetPlayerOwner().ConsoleCommand("start "$OpenCombo.GetValue());
	else if ( Left(OpenCombo.GetValue(), 9) ~= "unreal://" )
		GetPlayerOwner().ClientTravel(OpenCombo.GetValue(), TRAVEL_Absolute, false);
	else
		GetPlayerOwner().ClientTravel("unreal://"$OpenCombo.GetValue(), TRAVEL_Absolute, false);

	GetParent(class'UWindowFramedWindow').Close();
	Root.Console.CloseUWindow();

	OpenCombo.ClearValue();
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
}

defaultproperties
{
	OpenText="Open:"
	OpenHelp="Enter a standard URL, or select one from the URL history.  Press Enter to activate."
}