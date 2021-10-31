//=============================================================================
// WeaponPowerUp.
//=============================================================================
class WeaponPowerUp extends Pickup;

#exec OBJ LOAD FILE=Detail.utx

#exec MESH IMPORT MESH=WeaponPowerUpMesh ANIVFILE=Models\dpower_a.3d DATAFILE=Models\dpower_d.3d MLOD=0
#exec MESH ORIGIN MESH=WeaponPowerUpMesh X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=WeaponPowerUpMesh SEQ=All STARTFRAME=0  NUMFRAMES=20
#exec MESH SEQUENCE MESH=WeaponPowerUpMesh SEQ=AnimEnergy STARTFRAME=0  NUMFRAMES=20
#exec TEXTURE IMPORT NAME=aPower1 FILE=Models\dpower.pcx GROUP="Skins" DETAIL=Metal
#exec OBJ LOAD FILE=Textures\fireeffect22.utx PACKAGE=UnrealShare.Effect22
#exec MESHMAP SCALE MESHMAP=WeaponPowerUpMesh X=0.05 Y=0.05 Z=0.10
#exec MESHMAP SETTEXTURE MESHMAP=WeaponPowerUpMesh NUM=1 TEXTURE=aPower1 TLOD=5
#exec MESHMAP SETTEXTURE MESHMAP=WeaponPowerUpMesh NUM=0 TEXTURE=UnrealShare.Effect22.FireEffect22

#exec AUDIO IMPORT FILE="Sounds\Dispersion\number1.wav" NAME="number1" GROUP="Dispersion"
#exec AUDIO IMPORT FILE="Sounds\Dispersion\number2.wav" NAME="number2" GROUP="Dispersion"
#exec AUDIO IMPORT FILE="Sounds\Dispersion\number3.wav" NAME="number3" GROUP="Dispersion"
#exec AUDIO IMPORT FILE="Sounds\Dispersion\number4.wav" NAME="number4" GROUP="Dispersion"

var Sound PowerUpSounds[4];

event float BotDesireability( pawn Bot )
{
	local DispersionPistol D;

	foreach Bot.AllInventory(class'DispersionPistol',D)
	{
		if( D.PowerLevel<4 )
			return Super.BotDesireability(Bot);
	}
	return -1;
}

auto state Pickup
{
	function BeginState()
	{
		BecomePickup();
		LoopAnim('AnimEnergy',0.4);
	}

	function Touch( actor Other )
	{
		local DispersionPistol D;

		if ( Pawn(Other)!=None && Pawn(Other).bIsPlayer)
		{
			foreach Pawn(Other).AllInventory(class'DispersionPistol',D)
			{
				if( D.PowerLevel<4 )
				{
					ActivateSound = PowerUpSounds[D.PowerLevel];
					D.HandlePickupQuery(self);
					return;
				}
			}
			Level.Game.PickupQuery(Pawn(Other), Self); // if we got here, everything else is fully upgraded or we dont have a dispersion pistol somehow.
		}
	}

}

defaultproperties
{
	PowerUpSounds(0)=Sound'UnrealShare.Dispersion.number1'
	PowerUpSounds(1)=Sound'UnrealShare.Dispersion.number2'
	PowerUpSounds(2)=Sound'UnrealShare.Dispersion.number3'
	PowerUpSounds(3)=Sound'UnrealShare.Dispersion.number4'
	PickupMessage="You got the Dispersion Pistol Powerup"
	PickupViewMesh=Mesh'UnrealShare.WeaponPowerUpMesh'
	AnimSequence="AnimEnergy"
	Mesh=Mesh'UnrealShare.WeaponPowerUpMesh'
	bMeshCurvy=False
	CollisionRadius=12.000000
	RespawnTime=+30.00000
}
