//=============================================================================
// spaceship.
//=============================================================================
class spaceship expands Decoration;

#exec MESH IMPORT MESH=spaceship ANIVFILE=MODELS\SPACESHIP\spaceship_a.3d DATAFILE=MODELS\SPACESHIP\spaceship_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=spaceship X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=spaceship SEQ=All       STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=spaceship SEQ=SPACESHIP STARTFRAME=0 NUMFRAMES=1

#exec TEXTURE IMPORT NAME=Jspaceship1 FILE=MODELS\SPACESHIP\space01.pcx GROUP=Skins FLAGS=2 // Material #1
#exec TEXTURE IMPORT NAME=Jspaceship2 FILE=MODELS\SPACESHIP\space04.pcx GROUP=Skins // Material #2
#exec TEXTURE IMPORT NAME=Jspaceship3 FILE=MODELS\SPACESHIP\space06.pcx GROUP=Skins // Material #3
#exec TEXTURE IMPORT NAME=Jspaceship4 FILE=MODELS\SPACESHIP\space05.pcx GROUP=Skins // Material #4
#exec TEXTURE IMPORT NAME=Jspaceship5 FILE=MODELS\SPACESHIP\space02.pcx GROUP=Skins // Material #5
#exec TEXTURE IMPORT NAME=Jspaceship6 FILE=MODELS\SPACESHIP\space03.pcx GROUP=Skins // Material #6
#exec TEXTURE IMPORT NAME=Jspaceship7 FILE=MODELS\SPACESHIP\space07.pcx GROUP=Skins // Material #7

#exec MESHMAP NEW   MESHMAP=spaceship MESH=spaceship
#exec MESHMAP SCALE MESHMAP=spaceship X=4.5 Y=4.5 Z=9

#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=1 TEXTURE=Jspaceship1
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=2 TEXTURE=Jspaceship2
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=3 TEXTURE=Jspaceship3
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=4 TEXTURE=Jspaceship4
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=5 TEXTURE=Jspaceship5
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=6 TEXTURE=Jspaceship6
#exec MESHMAP SETTEXTURE MESHMAP=spaceship NUM=7 TEXTURE=Jspaceship7

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LodMesh'SpaceShip'
     CollisionRadius=600.000000
     CollisionHeight=140.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
