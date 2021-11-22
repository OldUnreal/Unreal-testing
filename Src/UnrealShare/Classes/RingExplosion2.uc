//=============================================================================
// RingExplosion2.
//=============================================================================
class RingExplosion2 extends RingExplosion;

#exec OBJ LOAD FILE=Textures\fireeffect51.utx PACKAGE=UnrealShare.Effect51
#exec AUDIO IMPORT FILE="Sounds\Tazer\ASMDEx3.wav" NAME="SpecialExpl" GROUP="General"

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explosion', 0.2 );
		if (level.bHighDetailMode) SpawnEffects();
		PlaySound(ExploSound,,20.0,,1000,0.6);
		if( Level.NetMode!=NM_Client )
			PostNetBeginPlay();
	}
}

simulated function PostNetBeginPlay()
{
	local vector X,Y,Z,HitLocation,HitNormal;

	GetAxes(Rotation,X,Y,Z);

	if( Class'GameInfo'.Default.bProjectorDecals )
	{
		if( Trace(HitLocation,HitNormal,Location-Z*100,Location,false)!=None
			|| Trace(HitLocation,HitNormal,Location+Z*100,Location,false)!=None ) // Floor or ceiling
			Spawn(Class'BigEnergyImpact',,,HitLocation+HitNormal*20.f,rotator(HitNormal));
		if( Trace(HitLocation,HitNormal,Location-Y*100,Location,false)!=None ) // Left
			Spawn(Class'BigEnergyImpact',,,HitLocation+HitNormal*20.f,rotator(HitNormal));
		if( Trace(HitLocation,HitNormal,Location+Y*100,Location,false)!=None ) // Right
			Spawn(Class'BigEnergyImpact',,,HitLocation+HitNormal*20.f,rotator(HitNormal));
		return;
	}
	if ( !FastTrace(Location-Z*100,Location) )
		Spawn(Class'BigEnergyImpact',,,,rotation+rotang(90,0,0));//floor
	if ( !FastTrace(Location-Z*100,Location) )
		Spawn(Class'BigEnergyImpact',,,,rotation+rotang(270,0,0));//ceiling
	if ( !FastTrace(Location-X*100,Location) )
		Spawn(Class'BigEnergyImpact',,,,rotation);//back
	if ( !FastTrace(Location-Y*100,Location) )
		Spawn(Class'BigEnergyImpact',,,,rotation+rotang(0,90,0));//left
	if ( !FastTrace(Location+X*100,Location) )
		Spawn(Class'BigEnergyImpact',,,,rotation+rotang(0,180,0));//front
	if ( !FastTrace(Location+Y*100,Location) )
		Spawn(Class'BigEnergyImpact',,,,rotation+rotang(0,270,0));//right
}

simulated function SpawnEffects()
{
	local Actor a;

	a = Spawn(class'PurpleLight');
	a.RemoteRole = ROLE_None;
	a = Spawn(class'EnergyBurst');
	a.DrawScale = 3.5;
	a.RemoteRole = ROLE_None;
	a = Spawn(class'ParticleBurst');
	a.RemoteRole = ROLE_None;
}

defaultproperties
{
	DecalClass=None
	ExploSound=Sound'SpecialExpl'
	Skin=FireTexture'UnrealShare.Effect51.MyTex3'
	DrawScale=1.000000
	LightRadius=8
}
