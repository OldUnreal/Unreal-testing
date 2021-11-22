//=============================================================================
// KillPoint.
//=============================================================================
class KillPoint expands Info;

var() Name MatchedTag;
var() bool bDestroyWhenDone;

function Trigger( actor Other, Pawn EventInstigator )
{
	local Actor Target;

	foreach allactors( class'Actor', Target, MatchedTag )
	{
		if( !Target.IsA( 'MarineBox' ) && Target.Tag == MatchedTag && !Target.IsA( 'Info' ) )
			Target.Destroy();
	}
	Destroy();
}
	

defaultproperties
{
     bDestroyWhenDone=True
     bCollideActors=True
}
