//=============================================================================
// NaliFruit.
//=============================================================================
class NaliFruit extends Health;

#exec TEXTURE IMPORT NAME=JNaliFruit1HD FILE=Models\Nalipl.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=JNaliFruit1 FILE=Models\Nalipl_old.pcx GROUP="Skins" FLAGS=2 HD=JNaliFruit1HD

#exec MESH IMPORT MESH=NaliFruitMesh ANIVFILE=Models\nalipl_a.3d DATAFILE=Models\nalipl_d.3d LODSTYLE=2
#exec MESH LODPARAMS MESH=NaliFruitMesh STRENGTH=0.1

#exec  MESH ORIGIN MESH=NaliFruitMesh X=0 Y=0 Z=70 YAW=0
#exec  MESH SEQUENCE MESH=NaliFruitMesh SEQ=All    STARTFRAME=0  NUMFRAMES=29
#exec  MESH SEQUENCE MESH=NaliFruitMesh SEQ=Still  STARTFRAME=0  NUMFRAMES=1
#exec  MESH SEQUENCE MESH=NaliFruitMesh SEQ=Root   STARTFRAME=1  NUMFRAMES=1
#exec  MESH SEQUENCE MESH=NaliFruitMesh SEQ=Grow  STARTFRAME=1  NUMFRAMES=26
#exec  MESH SEQUENCE MESH=NaliFruitMesh SEQ=Waver STARTFRAME=27  NUMFRAMES=2
#exec  MESHMAP SCALE MESHMAP=NaliFruitMesh X=0.15 Y=0.15 Z=0.3
#exec  MESHMAP SETTEXTURE MESHMAP=NaliFruitMesh NUM=1 TEXTURE=JNaliFruit1

var() bool bGrowWhenSeen;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bStasis = bGrowWhenSeen;
}

event float BotDesireability(Pawn Bot)
{
	if ( HealingAmount < 3 )
		return 0;

	return Super.BotDesireability(Bot);
}

auto state Pickup
{
	function Timer()
	{
		HealingAmount += 1;
		SetTimer(0.5,True);
	}

	function Touch( actor Other )
	{
		local int HealMax;

		if ( !ValidTouch(Other) || (HealingAmount<2) )
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
	PlayAnim('Root');
	FinishAnim();
	HealingAmount = 0;
	Sleep(FRand()*3);
	SetTimer(8.5,False);
	PlayAnim('Grow',0.036);
	FinishAnim();
	SetTimer(0.0,False);
	LoopAnim('Waver',0.1);
}

defaultproperties
{
	HealingAmount=0
	PickupMessage="You picked the Nali Healing Fruit +"
	RespawnTime=5.000000
	PickupViewMesh=Mesh'UnrealShare.NaliFruitMesh'
	Mesh=Mesh'UnrealShare.NaliFruitMesh'
	CollisionHeight=21.000000
}
