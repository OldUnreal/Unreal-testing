//===================================================
// Parent class for all TCO plants
//===================================================
// This simple code plays sound, when player
// is in plant collision radius
//===================================================
// code by Raven
class UIFlora extends Decoration;


#exec AUDIO IMPORT FILE="Sounds\Shrub\shrub1_01.wav" NAME="shrub1" GROUP="shrub"
#exec AUDIO IMPORT FILE="Sounds\Shrub\shrub1_02.wav" NAME="shrub2" GROUP="shrub"
#exec AUDIO IMPORT FILE="Sounds\Shrub\shrub1_03.wav" NAME="shrub3" GROUP="shrub"

var() sound SSound1; //Sound 1
var() sound SSound2; //Sound 2
var() sound SSound3; //Sound 3
var() bool bBushSound;
var() float SSoundVolume;
var PlayerPawn RP;

//replication
//{
// Variables the server should send to the client.
//	reliable if( Role==ROLE_Authority )
//		SSound1, SSound2, SSound3, bBushSound;
//}

simulated function Touch( actor Other )
{
	local float rnd;

	if (!bBushSound)
		return;
	rnd = FRand();

	if ( rnd < 0.34 )
		PlaySound(SSound1,SLOT_None,SSoundVolume);
	else if (rnd < 0.67 )
		PlaySound(SSound2,SLOT_None,SSoundVolume);
	else
		PlaySound(SSound3,SLOT_None,SSoundVolume);
}

simulated function Landed( vector HitNormal )
{
	SetPhysics(PHYS_None);
}

defaultproperties
{
	DrawType=DT_Mesh
	bCollideWhenPlacing=false
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=False
	bBlockPlayers=False
	SSound1=Sound'Unrealshare.shrub.shrub1'
	SSound2=Sound'Unrealshare.shrub.shrub2'
	SSound3=Sound'Unrealshare.shrub.shrub3'
	bStatic=false
	SSoundVolume=64
}
