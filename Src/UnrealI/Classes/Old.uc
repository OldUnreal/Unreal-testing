//=============================================================================
// Old - dummy class to re-import some textures and sounds into UnrealI
// to satisfy some dependencies for old maps,
// because they were moved during the split into UnrealI/UnrealShare.
// NEVER use in mods or maps!
//=============================================================================
class Old extends Decoration
	transient;

// Books
#exec MESH IMPORT MESH=BookM ANIVFILE=..\UnrealShare\Models\Book_a.3d DATAFILE=Models\Book_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BookM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=BookM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BookM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JBook1 FILE=..\UnrealShare\Models\Book1.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=JBook2 FILE=..\UnrealShare\Models\Book2.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=JBook3 FILE=..\UnrealShare\Models\Book3.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=JBook4 FILE=..\UnrealShare\Models\Book4.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=BookM X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=BookM NUM=0 TEXTURE=JBook1 TLOD=10
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\General\Chunkhit2.wav" NAME="Chunkhit2" GROUP="General"

// Barrel
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\General\bPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\General\EndPush.wav" NAME="Endpush" GROUP="General"
#exec MESH IMPORT MESH=BarrelM ANIVFILE=..\UnrealShare\Models\Barrel_a.3d DATAFILE=Models\Barrel_d.3d ZEROTEX=1
#exec MESH LODPARAMS MESH=BarrelM STRENGTH=0.5
#exec MESH ORIGIN MESH=BarrelM X=320 Y=160 Z=95 YAW=64
#exec MESH SEQUENCE MESH=BarrelM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BarrelM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JBarrel1 FILE=..\UnrealShare\Models\Barrel.pcx GROUP=Skins FLAGS=2
#exec MESHMAP SCALE MESHMAP=BarrelM X=0.15 Y=0.15 Z=0.3
#exec MESHMAP SETTEXTURE MESHMAP=BarrelM NUM=0 TEXTURE=JBarrel1 TLOD=10

// Steelbox
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\General\bPush1.wav" NAME="ObjectPush" GROUP="General"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\General\EndPush.wav" NAME="Endpush" GROUP="General"
#exec MESH IMPORT MESH=SteelBoxM ANIVFILE=Models\Box_a.3d DATAFILE=Models\Box_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SteelBoxM X=0 Y=0 Z=0 YAW=64
#exec MESH SEQUENCE MESH=SteelBoxM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=SteelBoxM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JSteelBox1 FILE=..\UnrealShare\Models\steelBox.pcx GROUP=Skins
#exec MESHMAP SCALE MESHMAP=SteelBoxM X=0.08 Y=0.08 Z=0.16
#exec MESHMAP SETTEXTURE MESHMAP=SteelBoxM NUM=1 TEXTURE=JSteelBox1

// Pawn stuff
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Generic\land1.wav" NAME="Land1" GROUP="Generic"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\Generic\lsplash.wav" NAME="LSplash" GROUP="Generic"

defaultproperties
{
}
