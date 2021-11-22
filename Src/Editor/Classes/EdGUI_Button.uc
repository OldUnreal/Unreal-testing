// This component sends signal to frame: SG_LeftClick
Class EdGUI_Button extends EdGUI_Component
	native;

cpptext
{
	UEdGUI_Button() {}
	void Init();
	void Close(UBOOL bRemoved = 0);
	void SetCaption(const TCHAR* NewCaption);
}

var() const string Caption;
