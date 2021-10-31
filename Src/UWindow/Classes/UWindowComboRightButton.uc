class UWindowComboRightButton extends UWindowButton;

function BeforePaint(Canvas C, float X, float Y)
{
	LookAndFeel.Combo_SetupRightButton(Self);
}

function LMouseDown(float X, float Y)
{
	local int i, ItemsCount;

	Super.LMouseDown(X, Y);

	if (bDisabled)
		return;
	ItemsCount = UWindowComboControl(OwnerWindow).ItemsCount();
	if (ItemsCount == 0)
		return;
	i = UWindowComboControl(OwnerWindow).GetSelectedIndex() + 1;
	if (i >= ItemsCount)
		i = 0;
	UWindowComboControl(OwnerWindow).SetSelectedIndex(i);
}

defaultproperties
{
	bNoKeyboard=True
}
