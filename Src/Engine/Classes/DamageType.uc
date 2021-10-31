//=============================================================================
// DamageType, the base class of all damagetypes.
// this and its subclasses are never spawned, just used as information holders
//=============================================================================
class DamageType extends Actor
			abstract;

// Description of a type of damage.
var() nowarn localized string Name;         // Description of damage.
var() localized string     AltName;      // Alternative description.
var() float                ViewFlash;    // View flash to play.
var() vector               ViewFog;      // View fog to play.
var() class<effects>       DamageEffect; // Special effect.

static function string DeathMessage()
{
	if ( FRand() < 0.5 )
		return Default.Name;
	else
		return Default.AltName;
}

defaultproperties
{
	name="killed"
	altname="killed"
}
