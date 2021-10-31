// This component sends signal to frame: SG_ValueChange, SG_HitEnter (HitEnter callback will be ignored if multilined)
Class EdGUI_EditBox extends EdGUI_Component
	native;

cpptext
{
	UEdGUI_EditBox() {}
	void Init();
	void Close(UBOOL bRemoved = 0);
	void SetCaption(const TCHAR* NewCaption);
	void SetDisabled(UBOOL bDisable);
}

var() const string Text;
var() const bool bMultiLine;
