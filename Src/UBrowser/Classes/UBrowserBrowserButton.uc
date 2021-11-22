class UBrowserBrowserButton extends UWindowButton;

var string LogoNames[30];
var Texture LogoImages[30];
var int LogoCount;
var string ClickURL;

var int CurrentFrame;
var float CurrentTime;

var bool bSpin;

function Created()
{
	local int i;

	bNoKeyboard = True;
	bStretched = True;
	if (ClickURL != "")
		Cursor = Root.HandCursor;

	Super.Created();

	for (i=0; i<LogoCount; i++)
		LogoImages[i] = Texture(DynamicLoadObject(LogoNames[CurrentFrame++], class'Texture', True));

	CurrentFrame = 0;
}

function Tick(float Delta)
{
	if (bSpin)
	{
		CurrentTime += Delta;
		if (CurrentTime > 0.03333)
		{
			UpTexture = LogoImages[CurrentFrame];
			OverTexture = UpTexture;
			DownTexture = UpTexture;

			CurrentFrame++;
			if (CurrentFrame >= LogoCount)
				CurrentFrame = 0;

			CurrentTime = 0;
		}
	}
	else
	{
		UpTexture = LogoImages[0];
		OverTexture = UpTexture;
		DownTexture = UpTexture;
	}
}

function Click(float X, float Y)
{
	if (ClickURL != "")
		GetPlayerOwner().ConsoleCommand("start "$ClickURL);
	Super.Click(X, Y);
}

defaultproperties
{
	LogoNames(0)="RotatingU.u_a00"
	LogoNames(1)="RotatingU.u_a01"
	LogoNames(2)="RotatingU.u_a02"
	LogoNames(3)="RotatingU.u_a03"
	LogoNames(4)="RotatingU.u_a04"
	LogoNames(5)="RotatingU.u_a05"
	LogoNames(6)="RotatingU.u_a06"
	LogoNames(7)="RotatingU.u_a07"
	LogoNames(8)="RotatingU.u_a08"
	LogoNames(9)="RotatingU.u_a09"
	LogoNames(10)="RotatingU.u_a10"
	LogoNames(11)="RotatingU.u_a11"
	LogoNames(12)="RotatingU.u_a12"
	LogoNames(13)="RotatingU.u_a13"
	LogoNames(14)="RotatingU.u_a14"
	LogoNames(15)="RotatingU.u_a15"
	LogoNames(16)="RotatingU.u_a16"
	LogoNames(17)="RotatingU.u_a17"
	LogoNames(18)="RotatingU.u_a18"
	LogoNames(19)="RotatingU.u_a19"
	LogoNames(20)="RotatingU.u_a20"
	LogoNames(21)="RotatingU.u_a21"
	LogoNames(22)="RotatingU.u_a22"
	LogoNames(23)="RotatingU.u_a23"
	LogoNames(24)="RotatingU.u_a24"
	LogoNames(25)="RotatingU.u_a25"
	LogoNames(26)="RotatingU.u_a26"
	LogoNames(27)="RotatingU.u_a27"
	LogoNames(28)="RotatingU.u_a28"
	LogoNames(29)="RotatingU.u_a29"
	LogoCount=30
	ClickURL="http://www.oldunreal.com"
}