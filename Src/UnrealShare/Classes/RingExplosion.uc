//=============================================================================
// RingExplosion.
//=============================================================================
class RingExplosion extends Effects
	transient;

#exec MESH IMPORT MESH=Ringex ANIVFILE=Models\Ringex_a.3d DATAFILE=Models\Ringex_d.3d ZEROTEX=1 LODSTYLE=8
#exec MESH ORIGIN MESH=Ringex X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=Ringex SEQ=All       STARTFRAME=0   NUMFRAMES=6
#exec MESH SEQUENCE MESH=Ringex SEQ=Explosion STARTFRAME=0   NUMFRAMES=6
#exec OBJ LOAD FILE=Textures\fireeffect50.utx PACKAGE=UnrealShare.Effect50
#exec MESHMAP SCALE MESHMAP=Ringex X=0.4 Y=0.4 Z=0.8 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=Ringex NUM=0 TEXTURE=UnrealShare.Effect50.FireEffect50

#exec AUDIO IMPORT FILE="Sounds\General\Expl03.wav" NAME="Expl03" GROUP="General"

var() Sound ExploSound;
var bool bAddedDecal;
var() Class<Decal> DecalClass;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan);
		AmbientGlow = ScaleGlow * 255;
		if ( !bAddedDecal )
		{
			bAddedDecal = True;
			if ( DecalClass!=None )
				Spawn(DecalClass,,,,Rotation);
		}
	}
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explosion', 0.25 );
		SpawnEffects();
	}
	if ( Instigator != None )
		MakeNoise(0.5);
}

simulated function SpawnEffects()
{
	local actor a;

	a = Spawn(class'EffectLight');
	a.RemoteRole = ROLE_None;
	a = Spawn(class'ParticleBurst2');
	a.RemoteRole = ROLE_None;
}

defaultproperties
{
	DecalClass=Class'EnergyImpact'
	ExploSound=Sound'Expl03'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=0.800000
	DrawType=DT_Mesh
	Style=STY_Translucent
	Mesh=Mesh'UnrealShare.Ringex'
	DrawScale=0.700000
	ScaleGlow=1.100000
	bUnlit=true
}
