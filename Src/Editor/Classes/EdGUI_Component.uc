Class EdGUI_Component extends EdGUI_Base
	native
	abstract;

cpptext
{
	UEdGUI_Component() {}
	void DoClose();
	virtual void SetDisabled( UBOOL bDisable );
}

var() int X,Y,XSize,YSize;
var() const bool bDisabled;

native final function SetDisabled( bool bDisable );

defaultproperties
{
	XSize=32
	YSize=20
}