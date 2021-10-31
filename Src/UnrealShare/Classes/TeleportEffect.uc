//=============================================================================
// TeleportEffect.
//=============================================================================
class TeleportEffect expands Effects
	transient;

#exec AUDIO IMPORT FILE="Sounds\Translocator\resp2A.wav" NAME="Resp2A" GROUP="Translocator"

simulated function PostBeginPlay()
{
	PlayAnim('Burst', 0.6);
	PlaySound (EffectSound1);
	MakeNoise(1.0);
	if ( Level.NetMode != NM_DedicatedServer )
	{
		DrawScale = 1;
		if ( Pawn(Owner)!=None )
			SetTeamColor(Pawn(Owner).GetTeamNum());
	}
}
simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan);
		AmbientGlow = ScaleGlow * 255;
	}
}
simulated function PostNetReceive()
{
	if ( Pawn(Owner)!=None )
	{
		bNetNotify = false;
		SetTeamColor(Pawn(Owner).GetTeamNum());
	}
}
simulated function SetTeamColor( byte TeamNum )
{
	if ( TeamNum<4 )
		ActorGUnlitColor = Class'UnrealHUD'.Default.TeamColor[TeamNum];
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=true
	DrawType=DT_Mesh
	Mesh=Mesh'TeleEffect3'
	bParticles=true
	Texture=Texture'T_PStar'
	EffectSound1=Sound'Resp2A'
	Style=STY_Translucent
	LifeSpan=0.5
	DrawScale=0.5
	bNetNotify=true
	Physics=PHYS_Trailer
}
