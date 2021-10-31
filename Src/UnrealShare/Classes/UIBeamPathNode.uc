//=======================================================
// class       : UIBeamPathNode
// file        : UIBeamPathNode.uc
// author      : Raven
// game        : Unreal 1 Patch v 227
// description : Can change beam's target and/or split
//               beam in two
//=======================================================
class UIBeamPathNode extends UIBeam;

var() actor NextNode;          // next node (target)
var() bool bSplitBeam;         // splits beam into two different beams
var() actor ChildBeamTarget;   // same as NextNode but works only for ChildBeam (if bSplitBeam is true)
var bool bCreatedRoot;

/*replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority ) bCreatedRoot;
}*/

simulated function Touch(actor Other)
{
	if (UIBaseBeam(Other) != none)
	{
		UIBaseBeam(Other).CurrentTarget=NextNode;
		if (UIBaseBeam(Other).bIsChild) UIBaseBeam(Other).CurrentTarget=ChildBeamTarget;
		if (bSplitBeam && !bCreatedRoot)
		{
			UIBaseBeam(Other).SecondBeamTarget=ChildBeamTarget;
			UIBaseBeam(Other).bCreateRoot=true;
			bCreatedRoot=true;
		}
	}
}

defaultproperties
{
	bHidden=true
	bCollideActors=true
	Texture=Texture'UnrealShare.Icons.ParticlePath'
	bNoDelete=true
}