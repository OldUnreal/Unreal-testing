//===============================================================================
// Triggers UILightningSound and UILightningEffect when their tag match event
//===============================================================================
// by Raven
class UILightningTrigger extends UIWeather_Lightning;

#exec TEXTURE IMPORT NAME=LightningT FILE="Textures\Icons\LightningT.bmp" GROUP=Icons LODSET=2

var() bool bSlave;
var bool bIsFlicker;
var bool IsStorm;
//var BFNPLightningSound A;
//var BFNPLightningEffect B;

replication
{
	// Variables the server should send to the client.
	reliable if ( Role==ROLE_Authority )
		bIsFlicker, IsStorm, Storm;
}

simulated function BeginPlay()
{
	if (!bSlave) Storm(true);
}

simulated function Storm(bool St)
{
	SetTimer(5+FRand()*10,False);
	bIsFlicker=false;
	IsStorm=St;
}

function Timer()
{
	local UILightningSound A;
	local UILightningEffect B;
	local UIThunder C;
	if (!IsStorm)
	{
		foreach AllActors( class 'UILightningEffect', B, Event )
		B.LightType=LT_None;
	}
	if (IsStorm)
	{
		foreach AllActors( class 'UILightningEffect', B, Event )
		{
			if (B.LightType == LT_Flicker)
				bIsFlicker=true;
			else
				bIsFlicker=false;
		}
		if (bIsFlicker)
		{
			foreach AllActors( class 'UILightningEffect', B, Event )
			B.OffThunder();
			SetTimer(9+FRand()*20,False);
		}
		else
		{
			foreach AllActors( class 'UILightningSound', A, Event )
			A.PlayThunder();
			foreach AllActors( class 'UILightningEffect', B, Event )
			B.PlayThunder();
			foreach AllActors( class 'UIThunder', C, Event )
			C.Trigger(self, self.Instigator);

			SetTimer(0.8+FRand()*0.5,False);
		}
	}
}

defaultproperties
{
	Texture=Texture'UnrealShare.Icons.LightningT'
	CollisionRadius=24.000000
	CollisionHeight=24.000000
}
