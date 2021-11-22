//=============================================================================
// TeleportEffectB.
//=============================================================================
class TeleportEffectB expands TeleportEffect;

var vector StartOwnerPos;

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer && Pawn(Owner)!=None )
	{
		StartOwnerPos = Owner.Location;
		SetTeamColor(Pawn(Owner).GetTeamNum());
	}
}
simulated function PostNetReceive()
{
	if ( Pawn(Owner)!=None )
	{
		StartOwnerPos = Owner.Location;
		bNetNotify = false;
		SetTeamColor(Pawn(Owner).GetTeamNum());
	}
}
simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		ScaleGlow = (Lifespan/Default.Lifespan);
		AmbientGlow = ScaleGlow * 255;
		if ( Owner!=None )
			Velocity+=Normal(StartOwnerPos-Location)*DeltaTime*150;
		Fatness = Min(Fatness+35*DeltaTime,255);
	}
}

defaultproperties
{
	bAnimByOwner=true
	LifeSpan=1
	Physics=PHYS_Projectile
}
