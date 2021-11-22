class UMenuMutatorInclude expands UMenuMutatorListBox;

function bool ExternalDragOver(UWindowDialogControl ExternalControl, float X, float Y)
{
	if (ExternalControl.OwnerWindow != OwnerWindow || UMenuMutatorExclude(ExternalControl) == None)
		return False;

	return Super.ExternalDragOver(ExternalControl, X, Y);
}

function ReceiveDoubleClickItem(UWindowListBox L, UWindowListBoxItem I)
{
	Super.ReceiveDoubleClickItem(L, I);
	MakeSelectedVisible();
}

defaultproperties
{
	bCanDrag=True
	bCanDragExternal=True
	bAcceptExternalDragDrop=True
}
