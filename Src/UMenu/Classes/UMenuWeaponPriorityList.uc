class UMenuWeaponPriorityList extends UWindowListBoxItem;

var string		WeaponClassName;
var string		WeaponName;
var name		PriorityName;
var bool		bFound;
var Mesh		WeaponMesh;
var Texture		WeaponSkin;
var float		WeaponScale;
var int			CurrentPriority;

function bool ShowThisItem()
{
	return bFound/* && (Left(WeaponClassName, 8) ~= "UnrealI." || Left(WeaponClassName, 12) ~= "UnrealShare.")*/; // Allow all to be shown.
}

function bool Compare(UWindowList T, UWindowList B)
{
	return UMenuWeaponPriorityList(T).CurrentPriority < UMenuWeaponPriorityList(B).CurrentPriority;
}

defaultproperties
{
}
