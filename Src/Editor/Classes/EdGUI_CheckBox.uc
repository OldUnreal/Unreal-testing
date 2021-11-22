// This component sends signal to frame: SG_ValueChange
Class EdGUI_CheckBox extends EdGUI_Component
	native;

cpptext
{
	UEdGUI_CheckBox() {}
	void Init();
	void Close(UBOOL bRemoved = 0);
	void SetCaption(const TCHAR* NewCaption);
}

var() const string Caption;
var() const bool bChecked,
				bLeftStyle; // If true, Caption text is drawn to the left side of the checkbox.

native final function SetChecked( bool bCheck );

defaultproperties
{
	bLeftStyle=true
}