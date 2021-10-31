//=============================================================================
// PathNodeIterator.uc
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class PathNodeIterator expands Actor
	native
	transient;

var array<NavigationPoint> NodePath;
var int             NodeCount;
var int             NodeIndex;
var int             NodeCost;
var vector          NodeStart;

native final function BuildPath( vector Start, vector End );
static native final function CheckUPak();
native final function NavigationPoint GetFirst();
native final function NavigationPoint GetPrevious();
native final function NavigationPoint GetCurrent();
native final function NavigationPoint GetNext();
native final function NavigationPoint GetLast();
native final function NavigationPoint GetLastVisible();

// end of PathNodeIterator.uc

defaultproperties
{
	bHidden=True
	bMovable=False
	RemoteRole=ROLE_None
}