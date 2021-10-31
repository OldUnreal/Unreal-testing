class VolumeTimer extends Info
	NoUserCreate;

var Volume V;

function PostBeginPlay()
{
	V = Volume(Owner);
}
function Timer()
{
	V.TimerPop(self);
}

defaultproperties
{
	bStatic=false
	RemoteRole=ROLE_None
	bHidden=true
	bMovable=false
}