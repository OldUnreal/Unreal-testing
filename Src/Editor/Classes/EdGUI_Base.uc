// Interface for creating custom editor menus.
Class EdGUI_Base extends Object
	native
	abstract;

cpptext
{
	UEdGUI_Base() {}
	virtual void Init();
	virtual void Close(UBOOL bRemoved=0);
	virtual void DoClose() {}
	virtual void SetCaption(const TCHAR* NewCaption);
}

var pointer WndPtr;

var const EdGUI_WindowFrame Parent;
var const EdGUI_Base NextComponent;

var bool bNeedsTick; // Should receive Tick event.

// Create and add an UI component.
native final function EdGUI_Base AddComponent( class<EdGUI_Base> Class, int X, int Y, int XS, int YS );

// Remove an UI component (or close menu).
native final function Close();

static native final function GetMouse( out int X, out int Y, optional EdGUI_Base RelativeComponent );

// Change component caption if has any.
native final function SetCaption( string NewCaption );

// Component was initialized.
event OnInit();

// Window was closed.
event OnClosed();

// Called when this component was removed.
event OnRemoved();

// Called if bNeedsTick is True.
event OnTick();
