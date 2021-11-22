//==================================================================
// class: UIProjectorDecal
// file: UIProjectorDecal.uc
// author: Raven
// game: For 227 Unreal 1 patch
// description: decal used in projector
//==================================================================
class UIProjectorDecal extends ExtendedDecal;

simulated function AttachToSurface() {}
//==============================================================================
// called when decal is spawned
//==============================================================================
simulated function BeginUpdate(UIProjector ProjectorOwner, vector HitNorm)
{
	if (ProjectorOwner == none) return;

	if ( Level.NetMode != NM_DedicatedServer ) DetachDecal();
	Texture=ProjectorOwner.ProjectorTexture;
	DrawScale=ProjectorOwner.ProjectorScale;
	if (ProjectorOwner.bRandomScale)
		DrawScale=RandRange(ProjectorOwner.RandomScaleMin,ProjectorOwner.RandomScaleMax);
	MultiDecalLevel=ProjectorOwner.ProjectableSurfaces;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (AttachDecal(100.00, HitNorm) == None)
		{
			if (ProjectorOwner.bLogWarnings)log("Decal: "$self$", projected by: "$ProjectorOwner$", can not be attached!", 'UIProjector');
		}
	}
}
simulated function rotator CalculateRotation(UIProjector ProjectorOwner, rotator OldR, rotator NewR)
{
	if (ProjectorOwner.bUpdateYaw)
	{
		if (ProjectorOwner.bReplaceOldRotation) OldR.Yaw=NewR.Yaw;
		else OldR.Yaw+=NewR.Yaw;
	}
	if (ProjectorOwner.bUpdateRoll)
	{
		if (ProjectorOwner.bReplaceOldRotation) OldR.Roll=NewR.Roll;
		else OldR.Roll+=NewR.Roll;
	}
	if (ProjectorOwner.bUpdatePitch)
	{
		if (ProjectorOwner.bReplaceOldRotation) OldR.Pitch=NewR.Pitch;
		else OldR.Pitch+=NewR.Pitch;
	}
	return OldR;
}
//==============================================================================
// updates decal
//==============================================================================
simulated function DecalUpdate(UIProjector ProjectorOwner)
{
	local vector HitNormal, HitLocation, TDir, StartDir, EndDir;
	local Actor S;
	local rotator TRot, ModRot;
	local float TempDS;
	local actor TempActor;

	if (ProjectorOwner == none || Level.NetMode == NM_DedicatedServer) return;
	if ( Level.NetMode != NM_DedicatedServer ) DetachDecal();
	if (ProjectorOwner.bTraceActor) StartDir=ProjectorOwner.TracedActor.Location;
	else StartDir=ProjectorOwner.Location;
	if (ProjectorOwner.bNoRotation)
	{
		EndDir=StartDir - (vect(0,0,1)*ProjectorOwner.ProjectionDistance);
	}
	else
	{
		if (!ProjectorOwner.bTraceActor)
		{
			EndDir=vector(ProjectorOwner.Rotation)*ProjectorOwner.ProjectionDistance>>ProjectorOwner.Rotation;
		}
		else
		{
			if (ProjectorOwner.TracedActor != none)
				EndDir=vector(ProjectorOwner.TracedActor.Rotation)*ProjectorOwner.ProjectionDistance>>ProjectorOwner.TracedActor.Rotation;
		}
	}
	S=Trace(HitLocation, HitNormal, EndDir, StartDir, false);
	SetLocation(HitLocation+ProjectorOwner.ProjectionOffset);
	if (ProjectorOwner.bTraceActor)
	{
		if (ProjectorOwner.bApplyHitNormal) TRot=rotator(HitNormal);
		if (ProjectorOwner.TraceRotation)
		{
			ModRot = CalculateRotation(ProjectorOwner, TRot, ProjectorOwner.TracedActor.Rotation);
			TRot = ModRot;
		}
		TRot+=ProjectorOwner.ProjectorRotationModifier;
		TDir=vector(TRot);
	}
	else
	{
		if (ProjectorOwner.bApplyHitNormal) TRot=rotator(HitNormal);
		if (ProjectorOwner.TraceRotation)
		{
			ModRot = CalculateRotation(ProjectorOwner, TRot, ProjectorOwner.Rotation);
			TRot = ModRot;
		}
		TRot+=ProjectorOwner.ProjectorRotationModifier;
		TDir=vector(TRot);
	}
	SetRotation(TRot);
	ScaleGlow=1.0;
	if (ProjectorOwner.ProjectorScaleModifier > 0 && ProjectorOwner.GetSizeType() > 0 && ProjectorOwner.bDistanceSizing)
	{
		if (S != none)
		{
			if (!ProjectorOwner.bTraceActor)
				TempActor=ProjectorOwner;
			else
			{
				if (ProjectorOwner.TracedActor != none)
					TempActor=ProjectorOwner.TracedActor;
				else
					TempActor=ProjectorOwner;
			}
			if (ProjectorOwner.GetSizeType() == 1)
			{
				TempDS=(ProjectorOwner.ProjectorScale+(abs(VSize(TempActor.Location-HitLocation))*ProjectorOwner.ProjectorScaleModifier));
				if (TempDS >= ProjectorOwner.MaxSize) DrawScale=ProjectorOwner.MaxSize;
				else DrawScale=TempDS;
			}
			else
			{
				TempDS=(ProjectorOwner.ProjectorScale-(abs(VSize(TempActor.Location-HitLocation))*ProjectorOwner.ProjectorScaleModifier));
				if (TempDS <= ProjectorOwner.MinSize) DrawScale=ProjectorOwner.MinSize;
				else DrawScale=TempDS;
			}
		}
	}
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (AttachDecal(100, TDir) == None)
		{
			if (ProjectorOwner.bLogWarnings) log("Decal: "$self$", projected by: "$ProjectorOwner$", can not be attached!", 'UIProjector');
		}
	}
}

defaultproperties
{
	bHighDetail=true
	MultiDecalLevel=8
	Style=STY_Modulated
	//Texture=Texture'Scorch1'
	DrawScale=1.000000
	bStatic=false
	bStasis=false
	bFixedRotationDir=true
}