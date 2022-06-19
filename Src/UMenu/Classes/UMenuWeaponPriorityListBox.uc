class UMenuWeaponPriorityListBox extends UWindowListBox;

var string WeaponClassParent;
var UMenuWeaponPriorityMesh MeshWindow;

var localized string WeaponPriorityHelp;

function Created()
{
	local name PriorityName;
	local string WeaponClassName,S;
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
		L.CurrentPriority = 200-i;
	}

	foreach P.IntDescIterator(WeaponClassParent,WeaponClassName,,true)
	{
		S = P.GetItemName(WeaponClassName);
		for (L = UMenuWeaponPriorityList(Items.Next); L; L = UMenuWeaponPriorityList(L.Next))
		{
			if ( string(L.PriorityName) ~= S )
			{
				L.WeaponClassName = WeaponClassName;
				L.bFound = True;
				if ( L.ShowThisItem() )
				{
					WeaponClass = class<Weapon>(DynamicLoadObject(WeaponClassName, class'Class'));
					if( WeaponClass )
						ReadWeapon(L, WeaponClass);
				}
				else
					L.bFound = False;
				break;
			}
		}
		if( !L )
		{
			WeaponClass = class<Weapon>(DynamicLoadObject(WeaponClassName, class'Class'));
			if( WeaponClass && WeaponClass.Default.PickupViewMesh )
			{
				L = UMenuWeaponPriorityList(Items.Insert(ListClass));
				L.PriorityName = WeaponClass.Name;
				ReadWeapon(L, WeaponClass);
				if( WeaponClass.Outer.Name=='UnrealShare' || WeaponClass.Outer.Name=='UnrealI' )
					L.CurrentPriority = 100 - WeaponClass.Default.AutoSwitchPriority;
				else L.CurrentPriority = -WeaponClass.Default.AutoSwitchPriority;
				L.bFound = True;
			}
		}
	}
	Sort();
}

final function ReadWeapon(UMenuWeaponPriorityList L, class<Weapon> WeaponClass)
{
	L.WeaponName = WeaponClass.default.ItemName$" ("$string(WeaponClass.Outer.Name)$")";
	L.WeaponMesh = WeaponClass.default.PickupViewMesh;
	L.WeaponScale = WeaponClass.default.PickupViewScale;
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
function SaveConfigs()
{
	local byte i;
	local UMenuWeaponPriorityList L;
	local PlayerPawn P;
	local bool bNetwork,bDirty;

	P = GetPlayerOwner();
	bNetwork = (P.Level.NetMode==NM_Client);

	for (L = UMenuWeaponPriorityList(Items.Last); L && L!=Items && i<ArrayCount(P.WeaponPriority); L=UMenuWeaponPriorityList(L.Prev), ++i)
	{
		if( P.WeaponPriority[i]!=L.PriorityName )
		{
			bDirty = true;
			P.WeaponPriority[i] = L.PriorityName;
			if( bNetwork )
				P.ServerSetWeaponPriority(i, P.WeaponPriority[i]);
		}
	}
	for(; i<ArrayCount(P.WeaponPriority); ++i )
	{
		if( P.WeaponPriority[i]!='' )
		{
			P.WeaponPriority[i] = '';
			bDirty = true;
		}
	}
	if( bDirty )
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
	MeshWindow.MeshActor.DrawScale = MeshWindow.MeshActor.Default.DrawScale * UMenuWeaponPriorityList(SelectedItem).WeaponScale;
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
