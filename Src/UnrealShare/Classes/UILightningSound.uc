//=============================================================================
// plays lightning sound
// put this actor where you want to hear thunder
// intended to be used with UILightningEffect
//=============================================================================
// by Raven
class UILightningSound extends UIWeather_Lightning;

#exec TEXTURE IMPORT NAME=LightningS FILE="Textures\Icons\LightningS.bmp" GROUP=Icons LODSET=2

var() sound LightningSound; //lightning sound
var() byte LightningVolume; //lightning volume
var() bool LightningbNoOverride; //lightning Nooverride
var() byte LightningRadius; //lightning radius
var() bool bPlayRandomSound; //lightning will play 'LightningSound' or random sound from array 'LightningSounds[16]'
var() sound LightningSounds[16]; //lightning sounds (random play)
var() int numSounds;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		PlayThunder;
}

function PlayThunder()
{
	local int i;
	if (bPlayRandomSound)
	{
		i = Rand(numSounds);
		PlaySound(LightningSounds[i], SLOT_None, float(LightningVolume)/15, LightningbNoOverride, float(LightningRadius)*25);
	}
	else if (!bPlayRandomSound)
	{
		PlaySound(LightningSound, SLOT_None, float(LightningVolume)/15, LightningbNoOverride, float(LightningRadius)*25);
	}
}

defaultproperties
{
	Texture=Texture'UnrealShare.Icons.LightningS'
	LightningSound=Sound'UnrealShare.Thunder'
	LightningVolume=255
	LightningbNoOverride=false
	LightningRadius=255
}
