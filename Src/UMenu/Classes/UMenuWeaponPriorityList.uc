class UMenuWeaponPriorityList extends UWindowListBoxItem;

var string		WeaponClassName;
var string		WeaponName;
var name		PriorityName;
var bool		bFound;
var Mesh		WeaponMesh;
var Texture		WeaponSkin;


function bool ShowThisItem()
{
	return bFound/* && (Left(WeaponClassName, 8) ~= "UnrealI." || Left(WeaponClassName, 12) ~= "UnrealShare.")*/; // Allow all to be shown.
}

defaultproperties
{
}
