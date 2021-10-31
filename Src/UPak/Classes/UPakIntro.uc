//=============================================================================
// UPakIntro.
//=============================================================================
class UPakIntro expands Intro;

function PostBeginPlay()
{
	Class'PathNodeIterator'.Static.CheckUPak();
	Super.PostBeginPlay();
}

defaultproperties
{
     HUDType=Class'UPak.UPakIntroNullHud'
}
