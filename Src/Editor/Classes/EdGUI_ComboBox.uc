// This component sends signal to frame: SG_ValueChange
Class EdGUI_ComboBox extends EdGUI_Component
	native;

cpptext
{
	UEdGUI_ComboBox() {}
	void Init();
	void Close(UBOOL bRemoved = 0);
	void SetCaption(const TCHAR* NewCaption);
}

var const int SelectedLine;

var() const string SelectedText;
var() const array<string> Lines;
var() const bool bSortList; // Sort all lines alphabetically.

// Line operators.
native final function int AddLine( string Line );
native final function RemoveLine( int Index );
native final function SelectLine( int Index );
native final function EmptyCombo();
