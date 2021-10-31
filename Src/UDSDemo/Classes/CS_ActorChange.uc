//=============================================================================
// The Unreal Director's Suite                  Release version: Jan 7th, 1999
//=============================================================================
//
// [ CS_ActorChange ]
//
// This will cause an actor to change it's Attitude.
//=============================================================================

class CS_ActorChange expands CutSeq;

var() Const enum EChangeType
{
	CHG_State,
	CHG_Enemy,
	CHG_Attitude,
	CHG_Location,
	CHG_Rotation,
	CHG_Skin
	
} ChangeType;
	

var() name NewState;
var() name NewEnemy;
var() name NewPlayerAttitude;
var() vector NewLocation;
var() rotator NewRotation;
var() nowarn int Skin;

function Trigger(actor Other, pawn EventInstigator)
{
	local CSPawn P;
	
	CSTrackAction("CS_ActorChange");
   
	foreach AllActors(class'CSPawn',P,Event)
	{
		CSLog(""$P$" is going to state: "$NEwState);
		P.GotoState(NewState);
	}


}

defaultproperties
{
	Texture=CSACTION
}
