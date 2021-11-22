//=============================================================================
// OBSOLETE!
//=============================================================================
class ScriptPostRenderRI expands RenderIterator;

var transient const name ScriptRenderFunct; // Event to call on
var transient const Object CallingObject; // Object to call event on (None = Self)
var transient const bool bOnlyCallWhenVisible;

function ScriptPostRender( Canvas Canvas );

defaultproperties
{
}