class UMenuWeaponPriorityListBox extends UWindowListBox;

var string WeaponClassParent;
var UMenuWeaponPriorityMesh MeshWindow;

var localized string WeaponPriorityHelp;

function Created()
{
	local name PriorityName;
	local string WeaponClassName;
	local class<Weapon> WeaponClass;
	local int i;
	local UMenuWeaponPriorityList L;
	local PlayerPawn P;

	Super.Created();

	SetHelpText(WeaponPriorityHelp);

	P = GetPlayerOwner();

	// Load weapons into the list
	for (i=0; i<ArrayCount(P.WeaponPriority); i++)
	{
		PriorityName = P.WeaponPriority[i];
		if (PriorityName == 'None') break;
		L = UMenuWeaponPriorityList(Items.Insert(ListClass));
		L.PriorityName = PriorityName;
		L.WeaponName = "(unk) "$PriorityName;
	}

	foreach P.IntDescIterator(WeaponClassParent,WeaponClassName,,true)
	{
		for (L = UMenuWeaponPriorityList(Items.Next); L != None; L = UMenuWeaponPriorityList(L.Next))
		{
			if ( string(L.PriorityName) ~= P.GetItemName(WeaponClassName) )
			{
				L.WeaponClassName = WeaponClassName;
				L.bFound = True;
				if ( L.ShowThisItem() )
				{
					WeaponClass = class<Weapon>(DynamicLoadObject(WeaponClassName, class'Class'));
					if( WeaponClass!=None )
						ReadWeapon(L, WeaponClass);
				}
				else
					L.bFound = False;
				break;
			}
		}
	}
}

final function ReadWeapon(UMenuWeaponPriorityList L, class<Weapon> WeaponClass)
{
	L.WeaponName = WeaponClass.default.ItemName;
	L.WeaponMesh = WeaponClass.default.Mesh;
	L.WeaponSkin = WeaponClass.default.Skin;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	if (UMenuWeaponPriorityList(Item).bSelected)
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 128;
		DrawStretchedTexture(C, X, Y, W, H-1, Texture'WhiteTexture');
		C.DrawColor.r = 255;
		C.DrawColor.g = 255;
		C.DrawColor.b = 255;
	}
	else
	{
		C.DrawColor.r = 0;
		C.DrawColor.g = 0;
		C.DrawColor.b = 0;
	}


	C.Font = Root.Fonts[F_Normal];

	ClipText(C, X+1, Y, UMenuWeaponPriorityList(Item).WeaponName);
}
final function UpdateWeaponPriorities( PlayerPawn P, byte FinalIndex )
{
	local byte i;

	for ( i=0; i<FinalIndex; i++ )
		P.ServerSetWeaponPriority(i, P.WeaponPriority[i]);
}
function SaveConfigs()
{
	local byte i;
	local UMenuWeaponPriorityList L;
	local PlayerPawn P;

	P = GetPlayerOwner();

	for (L = UMenuWeaponPriorityList(Items.Last); L != None && L != Items; L = UMenuWeaponPriorityList(L.Prev))
	{
		P.WeaponPriority[i] = L.PriorityName;
		i++;
	}
	if( P.Level.NetMode!=NM_Client )
		UpdateWeaponPriorities(P,i);
	while( i<ArrayCount(P.WeaponPriority) )
	{
		P.WeaponPriority[i] = 'None';
		i++;
	}
	P.SaveConfig();
	Super.SaveConfigs();
}

function LMouseDown(float X, float Y)
{
	Super.LMouseDown(X, Y);

	if (SelectedItem != None)
		SelectWeapon();
}

function SelectWeapon()
{
	if (MeshWindow == None)
		MeshWindow = UMenuWeaponPriorityMesh(GetParent(class'UMenuWeaponPriorityCW').FindChildWindow(class'UMenuWeaponPriorityMesh'));

	MeshWindow.MeshActor.Mesh = UMenuWeaponPriorityList(SelectedItem).WeaponMesh;
	MeshWindow.MeshActor.Skin = UMenuWeaponPriorityList(SelectedItem).WeaponSkin;
}

defaultproperties
{
	WeaponClassParent="Engine.Weapon"
	WeaponPriorityHelp="Click and drag a weapon name in the list on the left to change its priority.  Weapons higher in the list have higher priority."
	ItemHeight=13.000000
	bCanDrag=True
	ListClass=Class'UMenu.UMenuWeaponPriorityList'
}
