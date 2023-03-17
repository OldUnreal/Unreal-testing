// Trigger catcher
Class Phys_MoverTrigger extends Info
	NoUserCreate;

var Phys_Mover Mover;

function Trigger( Actor Other, Pawn EventInstigator )
{
	Mover.OnTrigger(Tag);
}

defaultproperties
{
	RemoteRole=ROLE_None
}