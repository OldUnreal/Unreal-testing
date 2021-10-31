//=============================================================================
// BubbleTrail.
// $Author: Deb $
// $Date: 4/23/99 12:13p $
// $Revision: 1 $
//=============================================================================
class BubbleTrail expands Effects;

var float OriginalScale;

simulated function PostBeginPlay()
{
	DrawScale += FRand() * 0.2;
	OriginalScale = DrawScale;
	Velocity = Vect( 0, 0, 1 ) * 80;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	if ( !NewZone.bWaterZone )
		Destroy();
}

simulated function Tick (float DeltaTime)
{
	if ( FRand() < 0.5  && DrawScale < OriginalScale - 0.25 )
		DrawScale += 0.1;
	else if ( DrawScale > OriginalScale + 0.25 )
		DrawScale -= 0.1;
}

defaultproperties
{
     Physics=PHYS_Projectile
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=5.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=Texture'UnrealShare.S_bubble1'
     DrawScale=0.050000
     Buoyancy=3.750000
}
