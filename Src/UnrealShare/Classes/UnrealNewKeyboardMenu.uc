//=============================================================================
// UnrealNewKeyboardMenu
//=============================================================================
class UnrealNewKeyboardMenu extends UnrealKeyboardMenu;

var localized int MenuWidth;

var string RealKeyName[255];

struct FKeyEntry
{
	var string KeyCmd;
	var string KeyAlias;
	var int BoundKey1,BoundKey2;
};
struct FKeyGroupType
{
	var string GroupName;
	var int NumKeys;
	var array<FKeyEntry> Keys;
};
var array<FKeyGroupType> KeyGroups;
var int NumGroups,EditingGroup,EditingKey,DisplayRange[2];
var bool bEditingKey;

function SetUpMenu()
{
	local int i, j, z, pos;
	local string Alias;
	local string E,Desc,FE,FDesc,GroupN;
	local bool bTop,bResult;

	if( !bSetup )
	{
		bSetup = true;

		// Setup none group
		KeyGroups[0].GroupName = "";
		KeyGroups[0].NumKeys = 0;
		NumGroups = 1;
		bTop = true;
		MenuLength = 1;

		while( true )
		{
			GetNextIntDesc(string(Class'Input'),i,E,Desc);
			if( bTop )
			{
				FDesc = Desc;
				FE = E;
				bTop = False;
			}
			else if( FE==E || FDesc==Desc || Len(E)==0 )
				break;
			j = InStr(Desc,",");
			if( j==-1 )
			{
				KeyGroups[0].Keys[KeyGroups[0].NumKeys].KeyCmd = E;
				KeyGroups[0].Keys[KeyGroups[0].NumKeys].KeyAlias = Desc;
				KeyGroups[0].NumKeys++;
				MenuLength++;
			}
			else
			{
				GroupN = Left(Desc, j);
				if (GroupN ~= "Console")
				{
					++i;
					continue;
				}
				GroupN = "    " $ Caps(GroupN);
				Desc = Mid(Desc,j+1);
				bResult = false;
				for( j=1; j<NumGroups; j++ )
				{
					if( KeyGroups[j].GroupName==GroupN )
					{
						KeyGroups[j].Keys[KeyGroups[j].NumKeys].KeyCmd = E;
						KeyGroups[j].Keys[KeyGroups[j].NumKeys].KeyAlias = Desc;
						KeyGroups[j].NumKeys++;
						bResult = true;
						MenuLength++;
						break;
					}
				}
				if( !bResult )
				{
					KeyGroups[NumGroups].GroupName = GroupN;
					KeyGroups[NumGroups].Keys[0].KeyCmd = E;
					KeyGroups[NumGroups].Keys[0].KeyAlias = Desc;
					KeyGroups[NumGroups].NumKeys = 1;
					NumGroups++;
					MenuLength+=2;
				}
			}
			i++;
		}
		for ( i=0; i<255; i++ )
			RealKeyName[i] = PlayerOwner.ConsoleCommand( "KEYNAME "$i );
	}
	else
	{
		for (i=0; i<NumGroups; i++)
		{
			for( j=0; j<KeyGroups[i].NumKeys; j++ )
			{
				KeyGroups[i].Keys[j].BoundKey1 = 0;
				KeyGroups[i].Keys[j].BoundKey2 = 0;
			}
		}
	}

	for ( i=0; i<255; i++ )
	{
		if ( Len(RealKeyName[i])>0 )
		{
			Alias = PlayerOwner.ConsoleCommand( "KEYBINDING "$RealKeyName[i] );
			if ( Alias != "" )
			{
				pos = InStr(Alias, " " );
				if ( pos != -1 )
				{
					if ( !(Left(Alias, pos) ~= "taunt") &&
					 !(Left(Alias, pos) ~= "getweapon") &&
					 !(Left(Alias, pos) ~= "viewplayernum") &&
					 !(Left(Alias, pos) ~= "button") &&
					 !(Left(Alias, pos) ~= "mutate"))
						Alias = Left(Alias, pos);
				}
				for (J=0; J<NumGroups; J++)
				{
					for( z=0; z<KeyGroups[j].NumKeys; z++ )
					{
						if ( KeyGroups[j].Keys[z].KeyCmd ~= Alias )
						{
							if ( KeyGroups[j].Keys[z].BoundKey1==0 || KeyGroups[j].Keys[z].BoundKey1==i )
								KeyGroups[j].Keys[z].BoundKey1 = i;
							else if ( KeyGroups[j].Keys[z].BoundKey2 == 0)
								KeyGroups[j].Keys[z].BoundKey2 = i;
						}
					}
				}
			}
		}
	}
}
final function bool FindSelection( int InIdx, out int iGroup, out int iKey )
{
	local int i;

	for (i=0; i<NumGroups; i++)
	{
		if( i>0 )
		{
			if( (InIdx--)==0 )
				return false;
		}
		if( KeyGroups[i].NumKeys<=InIdx )
			InIdx-=KeyGroups[i].NumKeys;
		else
		{
			iGroup = i;
			iKey = InIdx;
			return true;
		}
	}
	return false;
}
final function int FindKeyIndex( string S )
{
	local int i;

	for( i=0; i<255; i++ )
		if( RealKeyName[i]~=S )
			return i;
	return 0;
}
function AddPending( string newCommand )
{
	PendingCommands[Pending++] = newCommand;
	if ( Pending == ArrayCount(PendingCommands) )
		ProcessPending();
}

function bool ProcessSelection()
{
	if ( Selection == 1 )
	{
		Pending = 0;
		PlayerOwner.ResetKeyboard();
		SetupMenu();
		return true;
	}
	else if( !FindSelection((Selection-2),EditingGroup,EditingKey) )
		return true;
	if( KeyGroups[EditingGroup].Keys[EditingKey].BoundKey1!=0 && KeyGroups[EditingGroup].Keys[EditingKey].BoundKey2!=0 )
	{
		AddPending( "SET Input"@RealKeyName[KeyGroups[EditingGroup].Keys[EditingKey].BoundKey1]$" ");
		AddPending( "SET Input"@RealKeyName[KeyGroups[EditingGroup].Keys[EditingKey].BoundKey2]$" ");
		KeyGroups[EditingGroup].Keys[EditingKey].BoundKey1 = 0;
		KeyGroups[EditingGroup].Keys[EditingKey].BoundKey2 = 0;
	}
	bEditingKey = true;
	PlayerOwner.Player.Console.GotoState('KeyMenuing');
	return true;
}

function ProcessMenuKey( int KeyNo, string KeyName )
{
	local int i,j;

	if( !bEditingKey )
		return;
	bEditingKey = false;
	if ( KeyNo==0 || (Len(KeyName) == 0) || (KeyName == "Escape") )
		return;

	// make sure no overlapping
	for (i=0; i<NumGroups; i++)
	{
		for (j=0; j<KeyGroups[i].NumKeys; j++)
		{
			if( i==EditingGroup && j==EditingKey )
				continue;
			if( KeyGroups[i].Keys[j].BoundKey2==KeyNo )
				KeyGroups[i].Keys[j].BoundKey2 = 0;
			if( KeyGroups[i].Keys[j].BoundKey1==KeyNo )
			{
				KeyGroups[i].Keys[j].BoundKey1 = KeyGroups[i].Keys[j].BoundKey2;
				KeyGroups[i].Keys[j].BoundKey2 = 0;
			}
		}
	}
	if( KeyGroups[EditingGroup].Keys[EditingKey].BoundKey1==KeyNo )
		return;
	else if( KeyGroups[EditingGroup].Keys[EditingKey].BoundKey1==0 )
	{
		AddPending( "SET Input"@RealKeyName[KeyNo]@KeyGroups[EditingGroup].Keys[EditingKey].KeyCmd);
		KeyGroups[EditingGroup].Keys[EditingKey].BoundKey1 = KeyNo;
	}
	else
	{
		AddPending( "SET Input"@RealKeyName[KeyNo]@KeyGroups[EditingGroup].Keys[EditingKey].KeyCmd);
		KeyGroups[EditingGroup].Keys[EditingKey].BoundKey2 = KeyNo;
	}
}

function DrawValues(canvas Canvas, Font RegFont, int Spacing, int StartX, int StartY)
{
	local int g,k,i;
	local string S;

	Canvas.Font = RegFont;

	for (i=0; i< MenuLength; i++ )
	{
		if( i==0 )
			continue;
		else if( k==-1 )
		{
			k = 0;
			continue;
		}
		else
		{
			if( k==KeyGroups[g].NumKeys )
			{
				k = -1;
				g++;
				i--;
				continue;
			}
			if( bEditingKey && EditingGroup==g && EditingKey==k )
			{
				if( KeyGroups[g].Keys[k].BoundKey1==0 )
					S = "_";
				else S = RealKeyName[KeyGroups[g].Keys[k].BoundKey1]$OrString$"_";
			}
			else if( KeyGroups[g].Keys[k].BoundKey1==0 )
				S = "";
			else if( KeyGroups[g].Keys[k].BoundKey2==0 )
				S = RealKeyName[KeyGroups[g].Keys[k].BoundKey1];
			else S = RealKeyName[KeyGroups[g].Keys[k].BoundKey1]$OrString$RealKeyName[KeyGroups[g].Keys[k].BoundKey2];
			if( ++k==KeyGroups[g].NumKeys )
			{
				k = -1;
				g++;
			}
		}
		if( i<DisplayRange[0] || i>DisplayRange[1] )
			continue;
		if( Len(S)>0 )
		{
			SetFontBrightness( Canvas, (i == (Selection-1)) );
			Canvas.SetPos(StartX, StartY + Spacing * (i-DisplayRange[0]));
			Canvas.DrawText(S, false);
		}
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}
function DrawList(canvas Canvas, bool bLargeFont, int Spacing, int StartX, int StartY)
{
	local int g,k,i;
	local string S;

	Canvas.Font = Canvas.MedFont;

	for (i=0; i< MenuLength; i++ )
	{
		if( i==0 )
			S = MenuList[25];
		else if( k==-1 )
		{
			S = KeyGroups[g].GroupName;
			k = 0;
		}
		else
		{
			if( k==KeyGroups[g].NumKeys )
			{
				k = -1;
				g++;
				i--;
				continue;
			}
			S = KeyGroups[g].Keys[k++].KeyAlias;
			if( k==KeyGroups[g].NumKeys )
			{
				k = -1;
				g++;
			}
		}
		if( i<DisplayRange[0] || i>DisplayRange[1] )
			continue;
		if( Len(S)>0 )
		{
			SetFontBrightness( Canvas, (i == (Selection-1)) );
			Canvas.SetPos(StartX, StartY + Spacing * (i-DisplayRange[0]));
			Canvas.DrawText(S, false);
		}
	}
	Canvas.DrawColor = Canvas.Default.DrawColor;
}
function DrawMenu(canvas Canvas)
{
	local int StartX, StartY, Spacing, FinalSize;
	local float XL, YL;

	DrawStretchedBackground(Canvas);

	if( Canvas.ClipY<=640 )
	{
		Canvas.Font = Canvas.MedFont;
		Canvas.StrLen("T", XL, YL);
		Spacing = YL;
	}
	else
		Spacing = 16;
	StartX = 8 + Max(0, 0.5 * Canvas.ClipX - MenuWidth / 2);

	if ( Canvas.ClipY > 280 )
	{
		DrawTitle(Canvas);
		StartY = Max(36, 0.5 * (Canvas.ClipY - MenuLength * Spacing - MenuWidth / 2));
	}
	else
		StartY = Max(4, 0.5 * (Canvas.ClipY - MenuLength * Spacing - MenuWidth / 2));

	if ( !bSetup )
		SetupMenu();
	FinalSize = Max((Canvas.ClipY-StartY)/Spacing,8);
	if( Selection<(DisplayRange[0]+2) )
		DisplayRange[0] = Max(Selection-2,0);
	else if( Selection>(DisplayRange[1]-2) )
		DisplayRange[0] = Min(Selection-6,MenuLength-FinalSize);
	DisplayRange[1] = DisplayRange[0]+FinalSize;

	DrawList(Canvas, false, Spacing, StartX, StartY);
	DrawValues(Canvas, Canvas.MedFont, Spacing, StartX + MenuWidth / 2 - 16, StartY);

}

function DrawStretchedBackground(canvas Canvas)
{
	local int StartX, i, num;

	Canvas.DrawColor.r = 255;
	Canvas.DrawColor.g = 255;
	Canvas.DrawColor.b = 255;
	Canvas.bNoSmooth = True;

	StartX = 0.5 * Canvas.ClipX - MenuWidth / 2;
	Canvas.Style = 1;
	Canvas.SetPos(StartX, 0);
	Canvas.DrawIcon(texture'Menu2', MenuWidth / 256.);

	num = int(Canvas.ClipY / MenuWidth) + 1;
	StartX = 0.5 * Canvas.ClipX - MenuWidth / 2;
	for ( i=1; i<=num; i++ )
	{
		Canvas.SetPos(StartX, MenuWidth * i);
		Canvas.DrawIcon(texture'Menu2', MenuWidth / 256.);
	}
}

defaultproperties
{
	MenuWidth=340
}
