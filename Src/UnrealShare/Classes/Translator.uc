//=============================================================================
// Translator.
//=============================================================================
class Translator extends Pickup;

#exec AUDIO IMPORT FILE="Sounds\Pickups\HEALTH1.wav" NAME="HEALTH1" GROUP="Pickups"

#exec Texture Import File=Textures\HD_Icons\I_HD_Translator.bmp Name=I_HD_Translator Group="HD" Mips=Off
#exec TEXTURE IMPORT NAME=I_Tran FILE=Textures\HUD\i_TRAN.pcx GROUP="Icons" MIPS=OFF HD=I_HD_Translator

#exec MESH IMPORT MESH=TranslatorMesh ANIVFILE=Models\tran_a.3d DATAFILE=Models\tran_d.3d X=0 Y=0 Z=0 MLOD=1

// 28 Vertices, 52 Triangles
#exec MESH LODPARAMS MESH=TranslatorMesh STRENGTH=0.1 MINVERTS=28 MORPH=0.0 ZDISP=4000.0
#exec MESH ORIGIN MESH=TranslatorMesh X=5 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=TranslatorMesh SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JTranslator1HD FILE=Models\tran.pcx GROUP="HD"
#exec TEXTURE IMPORT NAME=JTranslator1 FILE=Models\tran_old.pcx GROUP="Skins" HD=JTranslator1HD
#exec MESHMAP SCALE MESHMAP=TranslatorMesh X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=TranslatorMesh NUM=1 TEXTURE=JTranslator1 TLOD=10

#exec TEXTURE IMPORT NAME=TranslatorHUDHD FILE="Textures\HUD\HDTranslator.dds" GROUP="HD" FLAGS=131074 MIPS=0
#exec TEXTURE IMPORT NAME=TranslatorHUD3 FILE=models\TRANHUD3.pcx GROUP="Icons" FLAGS=2 MIPS=OFF HD=TranslatorHUDHD

var globalconfig float TranslatorScale;
var string FontNames[4];
var font LoadedFonts[4];
var() texture HiResHUD,LowResHUD;

var() localized string NewMessage;
var localized string Hint,HintString;
var bool bNewMessage, bNotNewMessage, bShowHint, bCurrentlyActivated;

replication
{
	// Things the server should send to the client.
	reliable if ( Role==ROLE_Authority && bNetOwner )
		NewMessage, bNewMessage, bNotNewMessage, bCurrentlyActivated;
}

function TravelPreAccept()
{
	if ( Pawn(Owner).FindInventoryType(class) == None )
		Super.TravelPreAccept();
	else Destroy();
}

state Activated
{
	function BeginState()
	{
		bActive = true;
		bCurrentlyActivated = true;
	}

	function EndState()
	{
		bActive = false;
		bCurrentlyActivated = false;
	}
}

state Deactivated
{
Begin:
	bShowHint = False;
	bNewMessage = False;
	bNotNewMessage = False;
}

function ActivateTranslator(bool bHint)
{
	if (bHint && Hint=="")
	{
		bHint=False;
		Return;
	}
	bShowHint = bHint;
	Activate();
}

function AssignMessage( TranslatorEvent E, bool bFirstMessage )
{
	Hint = E.Hint;
	bShowHint = False;
	if( Len(E.Message) )
	{
		NewMessage = E.Message;
		
		if( bFirstMessage )
		{
			bNewMessage = true;
			Pawn(Owner).ClientMessage(E.M_NewMessage);
		}
		else
		{
			bNotNewMessage = true;
			Pawn(Owner).ClientMessage(E.M_TransMessage);
		}
	}
	else
	{
		bNewMessage = true;
		Pawn(Owner).ClientMessage(E.M_HintMessage);
	}
}

function UntouchMessage( TranslatorEvent E )
{
	bNewMessage = False;
	bNotNewMessage = False;
	if( IsInState('Activated') ) GoToState('Deactivated');
}

// 227g: Moved Translator draw code from HUD to here.
simulated function DrawTranslator( Canvas Canvas )
{
	local float TempX,TempY;
	local string CurrentMessage;
	local byte i;

	Canvas.bCenter = false;
	TempX = Canvas.ClipX;
	TempY = Canvas.ClipY;
	if ( bShowHint && Len(Hint)!=0 )
		CurrentMessage = HintString@Hint;
	else CurrentMessage = NewMessage;
	Canvas.Style = ERenderStyle.STY_Masked;

	if( TranslatorScale<=1.f )
	{
		Canvas.SetPos(Canvas.ClipX/2-128, Canvas.ClipY/2-68);
		Canvas.DrawIcon(LowResHUD, 1.0);
		Canvas.SetOrigin(Canvas.ClipX/2-110,Canvas.ClipY/2-52);
		Canvas.SetClip(225,110);
		Canvas.SetPos(0,0);
		Canvas.Font = Canvas.MedFont;
	}
	else
	{
		Canvas.SetPos(Canvas.ClipX/2-128*TranslatorScale, Canvas.ClipY/2-68*TranslatorScale);
		Canvas.DrawTile( HiResHUD, TranslatorScale*256.f, TranslatorScale*256.f, 0, 0, HiResHUD.USize, HiResHUD.VSize );
		if( TranslatorScale<1.3f )
			Canvas.Font = Canvas.MedFont;
		else
		{
			if( TranslatorScale<=1.7f )
				i = 0;
			else if( TranslatorScale<=2.35f )
				i = 1;
			else if( TranslatorScale<=4.25f )
				i = 2;
			else i = 3;
			if( LoadedFonts[i]==None )
			{
				LoadedFonts[i] = Font(DynamicLoadObject(FontNames[i],Class'Font'));
				if( LoadedFonts[i]==None )
					LoadedFonts[i] = Canvas.MedFont;
			}
			Canvas.Font = LoadedFonts[i];
			Canvas.DrawColor = MakeColor(0,255,0);
		}
		Canvas.SetOrigin(Canvas.ClipX/2-100*TranslatorScale,Canvas.ClipY/2-52*TranslatorScale);
		Canvas.SetClip(205*TranslatorScale,110*TranslatorScale);
		Canvas.SetPos(0,0);
	}
	Canvas.Style = 1;
	Canvas.DrawText(CurrentMessage, False);
	Canvas.ClipX = TempX;
	Canvas.ClipY = TempY;
	Canvas.Font = Canvas.MedFont;
	Canvas.DrawColor = MakeColor(255,255,255);
}

defaultproperties
{
	NewMessage="Universal Translator"
	bActivatable=True
	bDisplayableInv=True
	PickupMessage="Press F2 to activate the Translator"
	PickupViewMesh=LodMesh'TranslatorMesh'
	PickupSound=Sound'GenPickSnd'
	Icon=Texture'I_Tran'
	Mesh=LodMesh'TranslatorMesh'
	CollisionHeight=5.000000

	HintString="Hint:"
	TranslatorScale=1
	FontNames(0)="UWindowFonts.Tahoma14"
	FontNames(1)="UWindowFonts.Tahoma16"
	FontNames(2)="UWindowFonts.Tahoma20"
	FontNames(3)="UWindowFonts.Tahoma30"
	HiResHUD=texture'TranslatorHUDHD'
	LowResHUD=texture'TranslatorHUD3'
}
