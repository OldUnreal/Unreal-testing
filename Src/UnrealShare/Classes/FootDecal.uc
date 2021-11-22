//========================================================
// class: FootDecal
// file: FootDecal.uc
// author: Raven, modified by Smirftsch for Unreal 227
// game: The Chosen One
// description: footprint support for unreal.
//========================================================
class FootDecal extends FootDecalBase;

#exec TEXTURE IMPORT NAME=Foot_DryR FILE=Textures\Footprints\footdryR.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetR FILE=Textures\Footprints\footwetR.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_DryL FILE=Textures\Footprints\footdryL.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetL FILE=Textures\Footprints\footwetL.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_DryRM FILE=Textures\Footprints\footdryRM.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetRM FILE=Textures\Footprints\footwetRM.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_DryLM FILE=Textures\Footprints\footdryLM.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetLM FILE=Textures\Footprints\footwetLM.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_DryRS FILE=Textures\Footprints\footdryRS.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetRS FILE=Textures\Footprints\footwetRS.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_DryLS FILE=Textures\Footprints\footdryLS.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetLS FILE=Textures\Footprints\footwetLS.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_DryRN FILE=Textures\Footprints\footdryRN.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetRN FILE=Textures\Footprints\footwetRN.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_DryLN FILE=Textures\Footprints\footdryLN.pcx GROUP=Skins
#exec TEXTURE IMPORT NAME=Foot_WetLN FILE=Textures\Footprints\footwetLN.pcx GROUP=Skins

var() Texture PrintTex[16];

//========================================================
// assign foot type + tex
//========================================================
simulated function AssignFootType( byte PrintIndex, Pawn DecalOwner )
{
	if( DecalOwner.Mesh!=None )
	{
		switch( DecalOwner.Mesh.Name )
		{
		case 'Male1':
		case 'Male2':
		case 'Male3':
			PrintIndex+=4;
			break;
		case 'sktrooper':
			PrintIndex+=8;
			break;
		case 'Nali1':
		case 'Nali2':
		case 'Nali3':
			PrintIndex+=12;
			break;
		}
	}
	Texture = PrintTex[PrintIndex];
	AttachDecal(100, vector(DecalOwner.Rotation));
}

defaultproperties
{
	PrintTex(0)=Texture'Foot_DryR'
	PrintTex(1)=Texture'Foot_WetR'
	PrintTex(2)=Texture'Foot_DryL'
	PrintTex(3)=Texture'Foot_WetL'
	PrintTex(4)=Texture'Foot_DryRM'
	PrintTex(5)=Texture'Foot_WetRM'
	PrintTex(6)=Texture'Foot_DryLM'
	PrintTex(7)=Texture'Foot_WetLM'
	PrintTex(8)=Texture'Foot_DryRS'
	PrintTex(9)=Texture'Foot_WetRS'
	PrintTex(10)=Texture'Foot_DryLS'
	PrintTex(11)=Texture'Foot_WetLS'
	PrintTex(12)=Texture'Foot_DryRN'
	PrintTex(13)=Texture'Foot_WetRN'
	PrintTex(14)=Texture'Foot_DryLN'
	PrintTex(15)=Texture'Foot_WetLN'
}
