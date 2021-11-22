class UIFan2_Vortex extends UIProjectorSample;

#exec TEXTURE IMPORT NAME=Fan2_Shadow FILE="Textures\Fan2.pcx" GROUP=Skins UClampMode=UCLAMP VClampMode=VCLAMP

defaultproperties
{
	ProjectorTexture=Texture'Fan2_Shadow'
	bNoRotation=True
	TraceRotation=True
	bUpdateYaw=True
	bReplaceOldRotation=True
	bDynamicLight=True
	Physics=PHYS_Rotating
	bFixedRotationDir=True
	RotationRate=(Yaw=9000)
	DesiredRotation=(Yaw=1)
	ProjectorRefreshTime=0.02
}