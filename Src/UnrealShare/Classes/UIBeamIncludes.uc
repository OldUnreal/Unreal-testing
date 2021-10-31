class UIBeamIncludes extends UIBeam;

function vector RandomizeGiven(vector Orginal, float Modifier1, optional float Modifier2)
{
	if (Modifier2 == 0) Modifier2=1;
	return ((Orginal.X+(Modifier1*(Modifier2-FRand())))*vect(1,0,0))+((Orginal.Y+(Modifier1*(Modifier2-FRand())))*vect(0,1,0))+((Orginal.Z+(Modifier1*(Modifier2-FRand())))*vect(0,0,1));
}

function vector ModifyPath(actor Target, vector CurLoc, float BeamTargetSpray)
{
	local vector SDR;

	SDR = Normal(Target.Location - Location);
	SDR = Normal(SDR * BeamTargetSpray*FRand());
	return SDR;
//       return Normal(Target.Location-CurLoc)+(vect(1,1,1)*(BeamTargetSpray*FRand()));
}

function vector ReturnOrientation(UIBeamEmitter BeamEmitter)
{
	local vector X,Y,Z;

	GetAxes(BeamEmitter.Rotation,X,Y,Z);

	switch (BeamEmitter.MeshOrientation)
	{
	case EMeshOrientation.OR_XAxis:
		return X;
		break;
	case EMeshOrientation.OR_YAxis:
		return Y;
		break;
	case EMeshOrientation.OR_ZAxis:
		return Z;
		break;
	}
}

function CompareSettings(UIBeamEmitter MyEmitter)
{

	if (MyEmitter == none) return;
	if (Mesh != MyEmitter.BeamMesh) Mesh=MyEmitter.BeamMesh;
	if (DrawScale != MyEmitter.BeamDrawScale) DrawScale=MyEmitter.BeamDrawScale;
	if (Texture != MyEmitter.BeamSkin) Texture=MyEmitter.BeamSkin;
	if (Skin != MyEmitter.BeamSkin) Skin=MyEmitter.BeamSkin;
	if (Style != MyEmitter.BeamStyle) Style=MyEmitter.BeamStyle;
	if (MyEmitter.bCastLight)
	{
		if (LightType != MyEmitter.BeamLightType ) LightType=MyEmitter.BeamLightType;
		if (LightEffect != MyEmitter.BeamLightEffect) LightEffect=MyEmitter.BeamLightEffect;
		if (LightBrightness != MyEmitter.BeamLightBrightness) LightBrightness=MyEmitter.BeamLightBrightness;
		if (LightHue != MyEmitter.BeamLightHue) LightHue=MyEmitter.BeamLightHue;
		if (LightSaturation != MyEmitter.BeamLightSaturation) LightSaturation=MyEmitter.BeamLightSaturation;
		if (LightRadius != MyEmitter.BeamLightRadius) LightRadius=MyEmitter.BeamLightRadius;
		if (LightPeriod != MyEmitter.BeamLightPeriod) LightPeriod=MyEmitter.BeamLightPeriod;
		if (LightPhase != MyEmitter.BeamLightPhase) LightPhase=MyEmitter.BeamLightPhase;
		if (LightCone != MyEmitter.BeamLightCone) LightCone=MyEmitter.BeamLightCone;
		if (VolumeBrightness != MyEmitter.BeamVolumeBrightness) VolumeBrightness=MyEmitter.BeamVolumeBrightness;
		if (VolumeRadius != MyEmitter.BeamVolumeRadius) VolumeRadius=MyEmitter.BeamVolumeRadius;
		if (VolumeFog != MyEmitter.BeamVolumeFog) VolumeFog=MyEmitter.BeamVolumeFog;
	}
}


function ForceSettings(UIBeamEmitter MyCEmitter)
{

	if (MyCEmitter == none) return;
	Mesh=MyCEmitter.BeamMesh;
	DrawScale=MyCEmitter.BeamDrawScale;
	Texture=MyCEmitter.BeamSkin;
	Skin=MyCEmitter.BeamSkin;
	Style=MyCEmitter.BeamStyle;
	if (MyCEmitter.bCastLight)
	{
		LightType=MyCEmitter.BeamLightType;
		LightEffect=MyCEmitter.BeamLightEffect;
		LightBrightness=MyCEmitter.BeamLightBrightness;
		LightHue=MyCEmitter.BeamLightHue;
		LightSaturation=MyCEmitter.BeamLightSaturation;
		LightRadius=MyCEmitter.BeamLightRadius;
		LightPeriod=MyCEmitter.BeamLightPeriod;
		LightPhase=MyCEmitter.BeamLightPhase;
		LightCone=MyCEmitter.BeamLightCone;
		VolumeBrightness=MyCEmitter.BeamVolumeBrightness;
		VolumeRadius=MyCEmitter.BeamVolumeRadius;
		VolumeFog=MyCEmitter.BeamVolumeFog;
	}
}
