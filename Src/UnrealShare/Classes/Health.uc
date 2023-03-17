//=============================================================================
// Health.
//=============================================================================
class Health extends PickUp;

#exec OBJ LOAD FILE=Detail.utx

#exec AUDIO IMPORT FILE="Sounds\Pickups\HEALTH2.wav"  NAME="Health2"     GROUP="Pickups"

#exec MESH IMPORT MESH=HealthM ANIVFILE=Models\aniv38.3d DATAFILE=Models\data38.3d LODSTYLE=8
#exec MESH LODPARAMS MESH=HealthM STRENGTH=0.3
#exec MESH ORIGIN MESH=HealthM X=-0.8 Y=0 Z=1.5 YAW=0 PITCH=-64 ROLL=64
#exec MESH SEQUENCE MESH=HealthM SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec TEXTURE IMPORT NAME=Jhealth1HD FILE=Models\health.pcx GROUP="HD" FLAGS=2 DETAIL=metalf3
#exec TEXTURE IMPORT NAME=Jhealth1 FILE=Models\health_old.pcx GROUP="Skins" FLAGS=2 HD="Jhealth1HD"
#exec MESHMAP NEW   MESHMAP=HealthM MESH=HealthM
#exec MESHMAP SCALE MESHMAP=HealthM X=0.126 Y=0.126 Z=0.254
#exec MESHMAP SETTEXTURE MESHMAP=HealthM NUM=0 TEXTURE=Jhealth1 TLOD=5


var() int HealingAmount;
var() bool bSuperHeal;

event float BotDesireability(Pawn Bot)
{
	local float desire;
	local int HealMax;

	HealMax = Bot.Default.Health;
	if (bSuperHeal) HealMax = HealMax * 2.0;
	desire = Min(HealingAmount, HealMax - Bot.Health);

	if ( (Bot.Weapon != None) && (Bot.Weapon.AIRating > 0.5) )
		desire *= 1.7;
	if ( Bot.Health < 40 )
		return ( FMin(0.03 * desire, 2.2) );
	else
		return ( FMin(0.015 * desire, 2.0) );
}

function PlayPickupMessage(Pawn Other)
{
	Other.ClientMessage(PickupMessage$HealingAmount, 'Pickup');
}

auto state Pickup
{
	function Touch( actor Other )
	{
		local int HealMax;
		local Pawn P;

		if ( ValidTouch(Other) )
		{
			P = Pawn(Other);
			HealMax = P.default.health;
			if (bSuperHeal) HealMax = HealMax * 2.0;
			if (P.Health < HealMax)
			{
				if (Level.Game.LocalLog != None)
					Level.Game.LocalLog.LogPickup(Self, P);
				if (Level.Game.WorldLog != None)
					Level.Game.WorldLog.LogPickup(Self, P);
				P.Health += HealingAmount;
				if ( level.game.bAllHealthStopsBleeding || level.game.bBandagesStopBleeding && self.isa('Bandages') )
					if (p.bIsBleeding)
					{
						if (p.BleedingActor != none)
							p.bIsBleeding=false;
					}
				if (P.Health > HealMax) P.Health = HealMax;
				PlayPickupMessage(P);
				PlaySound (PickupSound,,2.5);
				if ( Level.Game.Difficulty > 1 )
					Other.MakeNoise(0.1 * Level.Game.Difficulty);
				SetRespawn();
			}
		}
	}
}

defaultproperties
{
	HealingAmount=20
	PickupMessage="You picked up a Health Pack +"
	RespawnTime=20.000000
	PickupViewMesh=LodMesh'UnrealShare.HealthM'
	MaxDesireability=0.500000
	PickupSound=Sound'UnrealShare.Pickups.Health2'
	Icon=Texture'UnrealShare.Icons.I_Health'
	RemoteRole=ROLE_DumbProxy
	Mesh=LodMesh'UnrealShare.HealthM'
	AmbientGlow=64
	CollisionRadius=22.000000
	CollisionHeight=8.000000
	Mass=10.000000
}
