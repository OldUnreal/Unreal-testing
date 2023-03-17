//=============================================================================
// Clip.
//=============================================================================
class Clip extends ShellBox;

#exec TEXTURE IMPORT NAME=Jclip1HD FILE=Models\clip.pcx GROUP="HD" FLAGS=2
#exec TEXTURE IMPORT NAME=Jclip1 FILE=Models\clip_old.pcx GROUP="Skins" FLAGS=2 HD=Jclip1HD

#exec TEXTURE IMPORT NAME=I_ClipAmmo FILE=Textures\Hud\i_clip.pcx GROUP="Icons"

#exec MESH IMPORT MESH=ClipM ANIVFILE=Models\aniv35.3d DATAFILE=Models\data35.3d LODSTYLE=8 MLOD=1
#exec MESH ORIGIN MESH=ClipM X=-0.75 Y=8 Z=5.5 YAW=0 PITCH=-64 ROLL=64
#exec MESH LODPARAMS MESH=ClipM STRENGTH=0.3
#exec MESH SEQUENCE MESH=ClipM SEQ=All   STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=ClipM MESH=ClipM
#exec MESHMAP SCALE MESHMAP=ClipM X=0.122 Y=0.1256 Z=0.223
#exec MESHMAP SETTEXTURE MESHMAP=ClipM NUM=2 TEXTURE=Jclip1 TLOD=10

defaultproperties
{
	AmmoAmount=20
	ParentAmmo=Class'UnrealShare.ShellBox'
	PickupMessage="You picked up a clip"
	PickupViewMesh=LodMesh'UnrealShare.ClipM'
	Icon=Texture'UnrealShare.Icons.I_ClipAmmo'
	Mesh=LodMesh'UnrealShare.ClipM'
	CollisionRadius=20.000000
	CollisionHeight=4.000000
}
