//=============================================================================
// SCUBAGear.
//=============================================================================
class SCUBAGear extends Pickup;

#exec OBJ LOAD FILE=Detail.utx

#exec AUDIO IMPORT FILE="Sounds\Pickups\scubada1.wav" NAME="Scubada1" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\scubal1.wav" NAME="Scubal1" GROUP="Pickups"
#exec AUDIO IMPORT FILE="Sounds\Pickups\scubal2.wav" NAME="Scubal2" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Scuba.bmp Name=I_HD_Scuba Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Scuba FILE=Textures\Hud\i_scuba.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Scuba

#exec MESH IMPORT MESH=Scuba ANIVFILE=Models\Scuba_a.3d DATAFILE=Models\Scuba_d.3d X=0 Y=0 Z=0 LODSTYLE=8 MLOD=1

// 71 Vertices, 131 Triangles
#exec MESH LODPARAMS MESH=Scuba STRENGTH=0.5 MINVERTS=36 MORPH=0.3 ZDISP=1200.0
#exec MESH ORIGIN MESH=Scuba X=0 Y=-400 Z=-100 YAW=64
#exec MESH SEQUENCE MESH=Scuba SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=ASC1 FILE=Models\scuba.pcx GROUP="Skins" DETAIL=Metal
#exec MESHMAP SCALE MESHMAP=Scuba X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=Scuba NUM=1 TEXTURE=ASC1 TLOD=10

var vector X,Y,Z;
var Actor EffectsActor;

event TravelPreAccept()
{
	if (!Pawn(Owner).HeadRegion.Zone.bWaterZone)
		bActive = false;
	Super.TravelPreAccept();
}

function inventory PrioritizeArmor( int Damage, name DamageType, vector HitLocation )
{
	if (DamageType == 'Breathe')
	{
		if (Pawn(Owner)!=None && IsInState('activated')
				&& !Pawn(Owner).FootRegion.Zone.bPainZone) Pawn(Owner).PainTime=12;
		GotoState('Deactivated');
	}
	else if (DamageType == 'Drowned' && Damage==0)
		GoToState('Activated');
	if (DamageType == 'Drowned')
	{
		NextArmor = None;
		Return Self;
	}
	return Super.PrioritizeArmor(Damage, DamageType, HitLocation);
}

function UsedUp()
{
	local Pawn OwnerPawn;

	OwnerPawn = Pawn(Owner);
	if (OwnerPawn != none && 0 < OwnerPawn.PainTime && OwnerPawn.PainTime < 15 &&
		!OwnerPawn.FootRegion.Zone.bPainZone && OwnerPawn.HeadRegion.Zone.bWaterZone)
	{
		OwnerPawn.PainTime = 15;
	}
	DisableInventoryEffects();
	Super.UsedUp();
}

function bool UseSpecialEffectsActor()
{
	return Class == class'SCUBAGear';
}

function EnableInventoryEffects()
{
	local Triggers SoundActor;

	if (!UseSpecialEffectsActor())
		EffectsActor = Owner;
	else if (EffectsActor == none || EffectsActor.bDeleteMe)
	{
		// trying to find a sound source of other scuba gear
		foreach Owner.ChildActors(class'Triggers', SoundActor)
			if (SoundActor.Tag == 'SCUBAGear_EffectsActor')
			{
				EffectsActor = SoundActor; // EffectsActor is shared between different scuba gears
				SetScubaAmbientSound();
				return;
			}

		EffectsActor = Spawn(class'Triggers', Owner, 'SCUBAGear_EffectsActor', Owner.Location);
		if (EffectsActor != none)
		{
			EffectsActor.SetCollision(false);
			EffectsActor.SetPhysics(PHYS_Trailer);
			EffectsActor.RemoteRole = ROLE_SimulatedProxy;
			EffectsActor.SoundRadius = Owner.default.SoundRadius;
			EffectsActor.SoundVolume = Owner.default.SoundVolume;
		}
		else
			EffectsActor = Owner;
	}

	SetScubaAmbientSound();
}

function SetScubaAmbientSound()
{
	if (EffectsActor == none || Pawn(Owner) == none)
		return;
	if (EffectsActor != Owner && (Owner.AmbientSound == ActivateSound || Owner.AmbientSound == RespawnSound))
		EffectsActor.AmbientSound = none;
	else if (Pawn(Owner).HeadRegion.Zone.bWaterZone)
		EffectsActor.AmbientSound = ActivateSound;
	else
		EffectsActor.AmbientSound = RespawnSound;
}

function DisableInventoryEffects()
{
	if (Owner != none && (!UseSpecialEffectsActor() || EffectsActor == Owner))
		Owner.AmbientSound = none;
	if (EffectsActor != none && EffectsActor != Owner)
		EffectsActor.Destroy();
	EffectsActor = none;
}

state Sleeping
{
	ignores Touch;

Begin:
	Sleep(ReSpawnTime);
	if (RespawnSound != sound'UnrealShare.Pickups.Scubal2')
		PlaySound(RespawnSound);
	Sleep(Level.Game.PlaySpawnEffect(self));
	GoToState('Pickup');
}

state Activated
{
	function EndState()
	{
		if (Owner != none)
			Owner.PlaySound(DeactivateSound);
		DisableInventoryEffects();
		bActive = false;
	}
	function Timer()
	{
		local float LocalTime;
		local Bubble1 b;
		local Pawn OwnerPawn;

		OwnerPawn = Pawn(Owner);
		if (OwnerPawn == none)
		{
			UsedUp();
			return;
		}
		Charge -= 1;
		if (Charge<-0)
		{
			UsedUp();
			return;
		}
		if (UseSpecialEffectsActor())
			EnableInventoryEffects();
		LocalTime += 0.1;
		LocalTime = LocalTime - int(LocalTime);
		if (OwnerPawn.HeadRegion.Zone.bWaterZone && !OwnerPawn.FootRegion.Zone.bPainZone)
		{
			if (0 < OwnerPawn.PainTime && OwnerPawn.PainTime < OwnerPawn.UnderWaterTime)
			{
				OwnerPawn.PainTime = FMin(OwnerPawn.PainTime + 0.1, OwnerPawn.UnderWaterTime);
				if (OwnerPawn.PainTime < 1)
				{
					Charge -= (1 - OwnerPawn.PainTime) * 10;
					OwnerPawn.PainTime = 1;
				}
			}

			if (FRand()<LocalTime)
			{
				GetAxes(OwnerPawn.ViewRotation,X,Y,Z);
				b = Spawn(class'Bubble1', Owner, '', OwnerPawn.Location
						  + 20.0 * X - (FRand()*6+5) * Y - (FRand()*6+5) * Z );
				if ( b != None )
					b.DrawScale = FRand()*0.1+0.05;
			}
			if (FRand()<LocalTime)
			{
				GetAxes(OwnerPawn.ViewRotation,X,Y,Z);
				b = Spawn(class'Bubble1', Owner, '', OwnerPawn.Location
						  + 20.0 * X + (FRand()*6+5) * Y - (FRand()*6+5) * Z );
				if ( b != None )
					b.DrawScale = FRand()*0.1+0.05;
			}
		}
	}
Begin:
	if (Owner == none)
		GotoState('');
	SetTimer(0.1, true);
	EnableInventoryEffects();
}

state DeActivated
{
Begin:

}

defaultproperties
{
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="You picked up the SCUBA gear"
	RespawnTime=20.000000
	PickupViewMesh=LodMesh'UnrealShare.Scuba'
	Charge=1200
	PickupSound=Sound'UnrealShare.Pickups.GenPickSnd'
	ActivateSound=Sound'UnrealShare.Pickups.Scubal1'
	DeActivateSound=Sound'UnrealShare.Pickups.Scubada1'
	RespawnSound=Sound'UnrealShare.Pickups.Scubal2'
	Icon=Texture'UnrealShare.Icons.I_Scuba'
	RemoteRole=ROLE_DumbProxy
	Mesh=LodMesh'UnrealShare.Scuba'
	SoundRadius=16
	CollisionRadius=18.000000
	CollisionHeight=15.000000
}
