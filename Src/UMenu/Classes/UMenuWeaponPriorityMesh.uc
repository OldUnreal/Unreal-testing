class UMenuWeaponPriorityMesh expands UMenuDialogClientWindow;

var MeshActor MeshActor;
var Rotator R;
var Mesh LastUsedMesh;
var Texture LastUsedSkin;

var UWindowButton RotateButton;
var float RotatePauseTime,MouseDragX,MouseDragY;
var bool bWasClicked;

function Created()
{
	Super.Created();
	if ( MeshActor==None )
	{
		MeshActor = GetEntryLevel().Spawn(class'MeshActor');
		MeshActor.Mesh = LastUsedMesh;
		MeshActor.Skin = LastUsedSkin;
		MeshActor.DrawScale=0.07;
		MeshActor.AmbientGlow=255;
		MeshActor.ScaleGlow=3;
	}
	
	RotateButton = UWindowButton(CreateControl(class'UWindowButton', 0, 0, WinWidth, WinHeight));
	RotateButton.bIgnoreLDoubleclick = True;
}
function Resized()
{
	Super.Resized();
	RotateButton.SetSize(WinWidth, WinHeight);
}
function Paint(Canvas C, float X, float Y)
{
	local float OldFov;
	local PlayerPawn P;

	C.Style = ERenderStyle.STY_Modulated;
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	C.Style = ERenderStyle.STY_Normal;

	if (MeshActor != None && MeshActor.Mesh != None)
	{
		MeshActor.bUnlit = false;
		class'UMenuPlayerMeshClient'.Static.InitPreviewLight(C);
		
		P = GetPlayerOwner();
		OldFov = P.FOVAngle;
		P.FOVAngle = 30;
		DrawClippedActor( C, WinWidth/2, WinHeight/2, MeshActor, False, R, vect(0, 0, 0), true );
		C.SetCustomLighting();
		C.ClearCustomLightSources();
		P.FOVAngle = OldFov;
	}
}

final function RotateMesh( float Y, float P )
{
	R = R & Construct<Rotator>(Yaw=-Y,Pitch=P,Roll=0);
}
final function NormalizeRoll( out int V, float Delta )
{
	V = (V & 65535);
	if( V )
	{
		if( V>32767 )
			V-=65535;
		V*=(1.f-(Delta*4.f));
		if( V<100 && V>-100 )
			V = 0;
	}
}

function Tick(float Delta)
{
	if( bWasClicked!=RotateButton.bMouseDown )
	{
		bWasClicked = RotateButton.bMouseDown;
		MouseDragX = Root.MouseX;
		MouseDragY = Root.MouseY;
	}
	if( RotateButton.bMouseDown )
	{
		RotateMesh((Root.MouseX-MouseDragX) * (64000.f / WinWidth), (Root.MouseY-MouseDragY) * (64000.f / WinWidth));
		MouseDragX = Root.MouseX;
		MouseDragY = Root.MouseY;
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
	{
		R.Yaw += (Delta * 16384);
		NormalizeRoll(R.Pitch,Delta);
		NormalizeRoll(R.Roll,Delta);
	}
}


function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	if (MeshActor != None)
	{
		LastUsedMesh = MeshActor.Mesh;
		LastUsedSkin = MeshActor.Skin;
		MeshActor.Destroy();
		MeshActor = None;
	}
}
function WindowShown()
{
	Super.WindowShown();
	if ( MeshActor==None )
	{
		MeshActor = GetEntryLevel().Spawn(class'MeshActor');
		MeshActor.Mesh = LastUsedMesh;
		MeshActor.Skin = LastUsedSkin;
		MeshActor.DrawScale=0.07;
		MeshActor.AmbientGlow=255;
		MeshActor.ScaleGlow=3;
	}
}

defaultproperties
{
}
