// RainRestrictionVolume, prevent XWeatherEmitter from raining in a specific local area.
// Set bDirectional to True to make the volume directional.
// You can eighter matchup this actor with weather emitter by Tag, or leave empty for all weather emitters.
Class XRainRestrictionVolume extends Volume
	Native;

#EXEC TEXTURE IMPORT FILE="Textures\rainvolume.pcx" NAME="S_RainVolume" GROUP="Icons" MIPS=off FLAGS=2 TEXFLAGS=0

var() vector BoundsMin,BoundsMax;
var transient const BoundingBox RainBounds;
var transient const array<XWeatherEmitter> Emitters; // Weather emitters associated to this.
var transient bool bBoundsDirty; // Will update RainBounds next tick (typically should set to True if you change shape of this but don't move it).

simulated function BeginPlay()
{
	Role = ROLE_Authority; // Keep client authority.
}

defaultproperties
{
	BoundsMin=(X=-128,Y=-128,Z=-128)
	BoundsMax=(X=128,Y=128,Z=128)
	bCollideActors=false
	CollisionRadius=22
	CollisionHeight=22
	DrawType=DT_Sprite
	Texture=Texture'S_RainVolume'
	bNotifyPositionUpdate=true
}