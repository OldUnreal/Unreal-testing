//=============================================================================
// Ladders.
//=============================================================================
class Ladders expands Actor;

function Touch(Actor Other)
{

 	// Only players can climb

	if (!Other.IsA('CSPlayer'))
     return;

	CSPlayer(Other).GotoState('LadderClimbing');

}

function UnTouch(Actor Other)
{
 	// Only players can climb

	if (!Other.IsA('CSPlayer'))
      return;

    CSPlayer(Other).SetPhysics(PHYS_Walking);
	CSPlayer(Other).GotoState('PlayerWalking');
}

defaultproperties
{
     bHidden=True
     bCollideActors=True
}
