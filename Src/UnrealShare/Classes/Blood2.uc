//=============================================================================
// Blood2.
//=============================================================================
class Blood2 extends Effects
	transient;

#exec MESH IMPORT MESH=blood2M ANIVFILE=Models\Blood2_a.3d DATAFILE=Models\Blood2_d.3d X=0 Y=0 Z=0 ZEROTEX=1
#exec MESH ORIGIN MESH=blood2M X=0 Y=0 Z=0 YAW=128
#exec MESH SEQUENCE MESH=blood2M SEQ=All       STARTFRAME=0   NUMFRAMES=45
#exec MESH SEQUENCE MESH=blood2M SEQ=Spray     STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=blood2M SEQ=Still     STARTFRAME=6   NUMFRAMES=1
#exec MESH SEQUENCE MESH=blood2M SEQ=GravSpray STARTFRAME=7   NUMFRAMES=5
#exec MESH SEQUENCE MESH=blood2M SEQ=Stream    STARTFRAME=12  NUMFRAMES=11
#exec MESH SEQUENCE MESH=blood2M SEQ=Trail     STARTFRAME=23  NUMFRAMES=11
#exec MESH SEQUENCE MESH=blood2M SEQ=Burst     STARTFRAME=34  NUMFRAMES=2
#exec MESH SEQUENCE MESH=blood2M SEQ=GravSpray2 STARTFRAME=36 NUMFRAMES=7

#exec TEXTURE IMPORT NAME=BloodSpot FILE=Models\bloods2.pcx GROUP=Skins FLAGS=2
#exec TEXTURE IMPORT NAME=BloodSGrn FILE=Models\bloodg2.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=blood2M X=0.055 Y=0.055 Z=0.11 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=blood2M NUM=0  TEXTURE=BloodSpot


var array<BloodSpray2> BloodSprays;
var Bleeding PawnBleedingActor;

simulated function GreenBlood()
{
	Texture = texture'BloodSGrn';
	GreenBleeding();
}

function PreBeginPlay()
{
	PawnBleeding();
	if ( Level.Game!=None && Level.Game.bVeryLowGore )
		GreenBlood();
}

function PawnBleeding()
{
	local vector Momentum;
	local int i;
	local Actor b;

	if (Instigator != none &&
		Instigator.LastDamageTime == Level.TimeSeconds &&
		!Instigator.bLastDamageSpawnedBlood)
	{
		Momentum = Instigator.LastDamageMomentum / FMax(Instigator.Mass, 1) * 3.0;
		if (Instigator == Instigator.LastDamageInstigator)
			Momentum *= 0.6; 
		if (Instigator.LastDamageType == 'SHREDDED')
			Momentum = vect(0,0,0);
		else if (Instigator.LastDamageType == 'SHOT')
			Momentum *= 2;


		if (Instigator.Pawn_BloodsprayClass == None)
			Instigator.Pawn_BloodsprayClass = class'BloodSpray2';

		for (i = Rand(4); i > 0; --i)
		{
			b = Spawn(Instigator.Pawn_BloodsprayClass, Instigator, '', Location, rotator(Instigator.Location - Instigator.LastDamageHitLocation));
			if (b != none)
				b.Velocity = Momentum + VRand() * 100;
			if (BloodSpray2(b) != none)
				BloodSprays[Array_Size(BloodSprays)] = BloodSpray2(b);
		}

		if (Level.Game.bBleedingEnabled && FRand() < 0.5) // Start bleeding.
		{
			if (Instigator.Pawn_BleedingClass == none)
				Instigator.Pawn_BleedingClass = class'Bleeding';

			b = Spawn(Instigator.Pawn_BleedingClass, Instigator, '', Location, rotator(Instigator.Location - Instigator.LastDamageHitLocation));

			if (b != none)
			{
				if (Instigator.BleedingActor != none)
					Instigator.BleedingActor.Destroy();
				Instigator.BleedingActor = b;
				Instigator.bIsBleeding = true;
				Instigator.BleedingActor.Instigator = Instigator.LastDamageInstigator;
			}
			PawnBleedingActor = Bleeding(Instigator.BleedingActor);
		}

		Instigator.bLastDamageSpawnedBlood = true;
	}
}

function GreenBleeding()
{
	local int i;

	for (i = 0; i < Array_Size(BloodSprays); ++i)
		if (BloodSprays[i] != none && !BloodSprays[i].bDeleteMe)
		{
			BloodSprays[i].Green();
			if (ScriptedPawn(Instigator) == none)
				BloodSprays[i].RemoteRole = ROLE_None; // impossible to transfer color change to clients
		}
	if (PawnBleedingActor != none && !PawnBleedingActor.bDeleteMe)
		PawnBleedingActor.Green();
}

simulated function AnimEnd()
{
	Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	DrawType=DT_Mesh
	Style=STY_Masked
	Texture=Texture'UnrealShare.BloodSpot'
	Mesh=Mesh'UnrealShare.Blood2M'
	DrawScale=0.250000
	AmbientGlow=56
	bUnlit=True
	bParticles=True
}
