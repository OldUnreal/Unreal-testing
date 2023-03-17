class UMenuPlayerMeshClient extends UMenuDialogClientWindow;

var UWindowSmallButton FaceButton;
var localized string FaceText, BodyText;

var UWindowButton RotateButton;

var MeshActor MeshActor;

var rotator CenterRotator, ViewRotator;

var bool bFace, bTween, bIsHuman, bWasClicked;

var name IdleAnimName;

var Mesh LastDisplayMesh;
var float LastDisplayScale, RotatePauseTime, MouseDragX;
var Texture LastDisplaySkin;

function WindowShown()
{
	Super.WindowShown();
	if (MeshActor == none || MeshActor.bDeleteMe)
	{
		MeshActor = GetEntryLevel().Spawn(class'MeshActor', GetEntryLevel());
		MeshActor.NotifyClient = Self;
		SetSkin(LastDisplaySkin);
		SetMesh(LastDisplayMesh,1);
	}
	if (LastDisplayScale > 0)
		MeshActor.DrawScale = LastDisplayScale;
}

function Created()
{
	Super.Created();

	if ( MeshActor==None )
	{
		MeshActor = GetEntryLevel().Spawn(class'MeshActor', GetEntryLevel());
		MeshActor.Mesh = GetPlayerOwner().Mesh;
		MeshActor.Skin = GetPlayerOwner().Skin;
		MeshActor.NotifyClient = Self;
	}
	RotateButton = UWindowButton(CreateControl(class'UWindowButton', 0, 0, WinWidth, WinHeight));
	RotateButton.bIgnoreLDoubleclick = True;
	ViewRotator = rot(0, 32768, 0);

	FaceButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, WinHeight - 16, 48, 16));
	FaceButton.Text = FaceText;
	FaceButton.bAlwaysOnTop = True;
	FaceButton.bIgnoreLDoubleclick = True;
}

function Resized()
{
	Super.Resized();

	RotateButton.SetSize(WinWidth, WinHeight);
	FaceButton.WinTop = WinHeight - 16;
}

function BeforePaint(Canvas C, float X, float Y)
{
	FaceButton.AutoWidth(C);
}

static final function InitPreviewLight( Canvas C )
{
	local Actor A;
	
	C.SetCustomLighting(true, vect(0.05f, 0.05f, 0.05f));
	A = C.AddCustomLightSource(vect(0, 0, 0), rot(60501, -57723, 0), true);
	A.LightEffect = LE_Sunlight;
	A.LightBrightness = 255;
	A = C.AddCustomLightSource(vect(0, 0, 0), rot(4989, -24447, 0), true);
	A.LightEffect = LE_Sunlight;
	A.LightBrightness = 127;
	A.LightSaturation = 64;
	A.LightHue = 127;
}

function Paint(Canvas C, float X, float Y)
{
	local float OldFov;
	local PlayerPawn P;

	C.Style = ERenderStyle.STY_Modulated;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	C.Style = ERenderStyle.STY_Normal;

	if (MeshActor != None)
	{
		MeshActor.bUnlit = false;
		InitPreviewLight(C);
		
		P = GetPlayerOwner();
		OldFov = P.FOVAngle;
		P.FOVAngle = 30;
		DrawClippedActor( C, WinWidth/2, WinHeight/2, MeshActor, False, ViewRotator, bFace ? (bIsHuman ? vect(-7, 0, -1.5) : vect(-4, 0, -1.5)) : (bIsHuman ? vect(0, 0, 0) : vect(5, 0, 0)), true );
		C.SetCustomLighting();
		C.ClearCustomLightSources();
		P.FOVAngle = OldFov;
	}
}

function Tick(float Delta)
{
	if( bWasClicked!=RotateButton.bMouseDown )
	{
		bWasClicked = RotateButton.bMouseDown;
		MouseDragX = Root.MouseX;
	}
	if( RotateButton.bMouseDown )
	{
		ViewRotator.Yaw-=((Root.MouseX-MouseDragX) * (64000.f / WinWidth));
		MouseDragX = Root.MouseX;
		ViewRotator.Yaw = ViewRotator.Yaw & 65535;
		RotatePauseTime = 3.f;
	}
	if (RotatePauseTime>0.f)
	{
		RotatePauseTime-=Delta;
		if( RotatePauseTime<1.f )
			Delta*=(1.f-RotatePauseTime);
		else Delta = 0.f;
	}
	if( Delta>0.f )
		ViewRotator.Yaw = (ViewRotator.Yaw + Delta * 4000) & 65535;
}

function ClearSkins()
{
	local int i;

	MeshActor.Skin = None;
	for (i=0; i<4; i++)
		MeshActor.MultiSkins[i] = None;
}

function SetSkin(texture NewSkin)
{
	ClearSkins();
	MeshActor.Skin = NewSkin;
}

function SetMesh(mesh NewMesh, float DScaling )
{
	MeshActor.bMeshEnviroMap = False;
	MeshActor.DrawScale = MeshActor.Default.DrawScale*DScaling*0.7;
	MeshActor.Mesh = NewMesh;
	if ( MeshActor.Mesh!=None )
	{
		if ( SkeletalMesh(NewMesh)!=None )
			MeshActor.LinkSkelAnim(None);
		if ( MeshActor.HasAnim('Breath1') )
			IdleAnimName = 'Breath1';
		else if ( MeshActor.HasAnim('Breath') )
			IdleAnimName = 'Breath';
		else
		{
			MeshActor.AnimRate = 0;
			return;
		}
		MeshActor.PlayAnim(IdleAnimName, 0.5,0.f);
	}
}

function SetNoAnimMesh(mesh NewMesh)
{
	MeshActor.bMeshEnviroMap = False;
	MeshActor.DrawScale = MeshActor.Default.DrawScale;
	MeshActor.Mesh = NewMesh;
	if ( SkeletalMesh(NewMesh)!=None )
		MeshActor.LinkSkelAnim(None);
	MeshActor.AnimRate = 0;
}

function SetMeshString(string NewMesh)
{
	SetMesh(mesh(DynamicLoadObject(NewMesh, Class'Mesh')),1);
}

function SetNoAnimMeshString(string NewMesh)
{
	SetNoAnimMesh(mesh(DynamicLoadObject(NewMesh, Class'Mesh')));
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if (MeshActor != None)
	{
		LastDisplayMesh = MeshActor.Mesh;
		LastDisplayScale = MeshActor.DrawScale;
		LastDisplaySkin = MeshActor.Skin;
		MeshActor.NotifyClient = None;
		MeshActor.Destroy();
		MeshActor = None;
	}
}

function Notify(UWindowDialogControl C, byte E)
{
	switch (E)
	{
	case DE_Click:
		switch (C)
		{
		case FaceButton:
			FacePressed();
			break;
		}
		break;
	}
}

function FacePressed()
{
	bFace = !bFace;
	if (bFace)
		FaceButton.Text = BodyText;
	else
		FaceButton.Text = FaceText;
}

function LeftPressed()
{
	ViewRotator.Yaw += 128;
}

function RightPressed()
{
	ViewRotator.Yaw -= 128;
}
function AnimEnd(MeshActor MyMesh)
{
	if ( MyMesh.AnimSequence==IdleAnimName && FRand()<0.3 )
	{
		if ( MyMesh.HasAnim('Taunt1') && FRand()<0.33 )
			MyMesh.PlayAnim('Taunt1', 0.8,0.1);
		else if ( MyMesh.HasAnim('Victory1') && FRand()<0.33 )
			MyMesh.PlayAnim('Victory1', 0.8,0.1);
		else if ( MyMesh.HasAnim('Wave') )
			MyMesh.PlayAnim('Wave', 0.7,0.1);
		else MyMesh.PlayAnim(IdleAnimName, 0.4);
	}
	else MyMesh.PlayAnim(IdleAnimName, 0.4);
}

defaultproperties
{
	FaceText="Face"
	BodyText="Body"
}
