//=============================================================================
// Woodruff.
//=============================================================================
class Woodruff extends Health;


#exec MESH IMPORT MESH=Waldmeister ANIVFILE=Models\waldmeister_a.3d DATAFILE=Models\waldmeister_d.3d MLOD=0 LODSTYLE=8
#exec MESH ORIGIN MESH=Waldmeister X=0 Y=0 Z=10

#exec MESH SEQUENCE MESH=Waldmeister SEQ=All STARTFRAME=0 NUMFRAMES=61

#exec MESH SEQUENCE MESH=Waldmeister SEQ=Grow1 STARTFRAME=0 NUMFRAMES=16 Rate=5
#exec MESH SEQUENCE MESH=Waldmeister SEQ=Grow2 STARTFRAME=13 NUMFRAMES=15 Rate=5
#exec MESH SEQUENCE MESH=Waldmeister SEQ=Grow3 STARTFRAME=31 NUMFRAMES=15 Rate=5
#exec MESH SEQUENCE MESH=Waldmeister SEQ=Grow4 STARTFRAME=46 NUMFRAMES=15 Rate=5

#exec MESH SEQUENCE MESH=Waldmeister SEQ=Idle1 STARTFRAME=15 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Waldmeister SEQ=Idle2 STARTFRAME=30 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Waldmeister SEQ=Idle3 STARTFRAME=45 NUMFRAMES=1
#exec MESH SEQUENCE MESH=Waldmeister SEQ=Idle4 STARTFRAME=60 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=Waldmeister MESH=Waldmeister
#exec MESHMAP SCALE MESHMAP=Waldmeister X=0.2 Y=0.2 Z=0.2

#exec TEXTURE IMPORT NAME=JWoodruff FILE=Textures\WoodrufTex1.pcx GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=Waldmeister NUM=0 TEXTURE=JWoodruff

//WoodruffSchool
#exec MESH IMPORT MESH=WoodruffSchool ANIVFILE=Models\WoodruffSchool_a.3d DATAFILE=Models\WoodruffSchool_d.3d MLOD=0 LODSTYLE=8
#exec MESH ORIGIN MESH=WoodruffSchool X=0 Y=0 Z=10

#exec MESH SEQUENCE MESH=WoodruffSchool SEQ=All STARTFRAME=0 NUMFRAMES=1

#exec MESHMAP NEW   MESHMAP=WoodruffSchool  MESH=WoodruffSchool
#exec MESHMAP SCALE MESHMAP=WoodruffSchool  X=0.2 Y=0.2 Z=0.2

#exec MESHMAP SETTEXTURE MESHMAP=WoodruffSchool NUM=0 TEXTURE=JWoodruff

var int AnimationNumber;

event float BotDesireability(Pawn Bot)
{
	if ( HealingAmount < 3 )
		return 0;
	return Super.BotDesireability(Bot);
}

auto state Pickup
{
	function Touch( actor Other )
	{
		local int HealMax;

		if ( !ValidTouch(Other) || (HealingAmount==0) )
			Return;

		if (Level.Game.LocalLog != None)
			Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
		if (Level.Game.WorldLog != None)
			Level.Game.WorldLog.LogPickup(Self, Pawn(Other));

		HealMax = Pawn(Other).default.Health;
		if (Pawn(Other).Health < HealMax)
		{
			Pawn(Other).Health += HealingAmount;
			if (Pawn(Other).Health > HealMax) Pawn(Other).Health = HealMax;
			Pawn(Other).ClientMessage(PickupMessage$HealingAmount, 'Pickup');
			PlaySound (PickupSound);
			SetRespawn();
			if ( Level.Game.Difficulty > 1 )
				Other.MakeNoise(0.1 * Level.Game.Difficulty);
		}
	}
Begin:
	AnimationNumber = 1 + Rand(4);
	HealingAmount = 0;

	if (AnimationNumber == 1)
		PlayAnim('Grow1', 0.25, 0.f);
	else if (AnimationNumber == 2)
		PlayAnim('Grow2', 0.25, 0.f);
	else if (AnimationNumber == 3)
		PlayAnim('Grow3', 0.25, 0.f);
	else
		PlayAnim('Grow4', 0.25, 0.f);

	Sleep(0.5);
	HealingAmount += 1;
	Sleep(0.5);
	HealingAmount += 2;
	FinishAnim();
	HealingAmount = Default.HealingAmount;

	if (AnimationNumber == 1)
		PlayAnim('Idle1', 0.1);
	else if (AnimationNumber == 2)
		PlayAnim('Idle2', 0.1);
	else if (AnimationNumber == 3)
		PlayAnim('Idle3', 0.1);
	else
		PlayAnim('Idle4', 0.1);
}

State Sleeping
{
Begin:
	Sleep( ReSpawnTime );
	// Make no respawn effects.
	GoToState( 'Pickup' );
}

defaultproperties
{
	HealingAmount=5
	PickupMessage="You got some Master of the woods +"
	PickupViewMesh=Mesh'Waldmeister'
	Mesh=Mesh'Waldmeister'
	CollisionRadius=8
	CollisionHeight=7.5
	AnimSequence="Idle1"
	RespawnTime=10
	DrawScale=0.1
	PickupViewScale=0.1
	PrePivot=(Z=-3.5)
}
