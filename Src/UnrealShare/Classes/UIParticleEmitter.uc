//================================================================
// class: ParticleEmitter
// file: ParticleEmitter.uc
// author: Raven
// www: http://turniej.unreal.pl/rp
//================================================================
class UIParticleEmitter extends UIParticleSystem;
//================================================================
// CONSTS
//================================================================
const MAX_TEMPLATES = 16;                                             // maximum number of templates
//================================================================
// TEMAPLATES
//================================================================
var(ParticleTemplate) SGlobal Particle_Global;                        // global settings (optional)
var(ParticleTemplate) SMain Particle_Main[16];                        // main options
var(ParticleTemplate) SAnimation Particle_Animation[16];              // animation options
var(ParticleTemplate) SAdvanced Particle_Advanced[16];                // advanced options
var(ParticleTemplate) SDisplay Particle_Display[16];                  // display options
var(ParticleTemplate) SSize Particle_Size[16];                        // size options
var(ParticleTemplate) SDecal Particle_Decal[16];                      // decal options
var(ParticleTemplate) SSound Particle_Sound[16];                      // sound options
var(ParticleTemplate) SLight Particle_Light[16];                      // light options
var(ParticleTemplate) SLightColor Particle_LightColor[16];            // light color options
var(ParticleTemplate) SLighting Particle_Lighting[16];                // lighting options
var(ParticleTemplate) SFading Particle_Fading[16];                    // fading options
var(ParticleTemplate) SDamage Particle_Damage[16];                    // damage options
var(ParticleTemplate) SPPhysics Particle_Physics[16];                 // physics options
var(ParticleTemplate) SCollision Particle_Collision[16];              // collision options
var(ParticleTemplate) SBounce Particle_Bounce[16];                    // bounce options
var(ParticleTemplate) SBuoyance Particle_Buoyance[16];                // buoyance options
var(ParticleTemplate) SVelocity Particle_InvertVelocity[16];          // velocity inversion
var(ParticleTemplate) SSpawnPlace Particle_EffectArea[16];            // override default effectarea
var(ParticleTemplate) SMesh Particle_Mesh[16];                        // used if bUseMesh in Particle_Display is true
var(ParticleTemplate) SDest Particle_Destination[16];                 // optional destination added at Xeppitz request :)
var(ParticleTemplate) SRot Particle_RandomRotation[16];               // randomizes rotation (tnx Q for idea)
var(ParticleTemplate) SAdvSpwn AdvancedSpawning[16];                  // advanced spawning effects
var(ParticleTemplate) SSpawnEffect Particle_SpawnEffect[16];          // particles can spawn effect on start
var(ParticleTemplate) SMisc Particle_Misc[16];                        // misc variables
var(ParticleTemplate) int NumTemplates;                               // number of templates
//================================================================
// MAIN
//================================================================
var(ParticleEmitter) enum Select
{
	SELECT_Linear,                                                    // cyclically iterate through the ParticleTemplate
	SELECT_Random                                                     // randomly pick a particle from the ParticleTemplate
} SelectionMethod;
var(ParticleEmitter) enum Burst
{
	BURST_Linear,                                                     // in each burst only one template will be used
	BURST_Random                                                      // in each burst many templates will be used
} BurstMethod;
var(ParticleEmitter) bool bPerformanceMode;                           // Performance mode (it'll set new intervall if player is outside radius/can't see generator)
var(ParticleEmitter) float NewIntervall;                              // new intervall
var(ParticleEmitter) float NewIntensity;                              // new intensity
var(ParticleEmitter) float Intervall;                                 // time betweet each bursts
var(ParticleEmitter) float Intensity;                                 // number of particles in each burst
var(ParticleEmitter) vector EffectArea;                               // area where particle will be spawn
var(ParticleEmitter) bool bOn;                                        // is particle active on startup (is_active)
var(ParticleEmitter) bool OneShot;                                    // one shot :) (one_shot)
var(ParticleEmitter) bool LineOfSightCheck;                           // if true will only spawn particles if player can see this actor
var(ParticleEmitter) float GeneratorLife;                             // generator life span ( 0 = not used)
var(ParticleEmitter) nowarn float VisibilityRadius;                   // particle visibility radius (visibility_radius)
var(ParticleEmitter) int ParticlesLimit;                              // 0 = no limit
var(ParticleEmitter) float ParticleProjForward;                       //
var(ParticleEmitter_Die) float BeforeDieSleep;                        // We have to gieve it time to fade particles
var(ParticleEmitter_Die) bool WaitForParticles;                       // waits till all particles dies befre destroy
var(ParticleEmitter_Die) float WaitPause;                             // pause till emitter will re-check for existing particles it created
//================================================================
// OTHER
//================================================================
var int ChosenTemplate;                                               // current template
var UIBasicParticle DPM;                                              // particle class
var float my_time;                                                    // time that pass till last particle tick
var float trIntervall;                                                // actual intervall (used when bPerformanceMode is true)
var float trIntensity;                                                // actual intensity (used when bPerformanceMode is true)
var int ParteNum;                                                     // number of particles (if ParticlesLimit > 0)
var bool flag;                                                        // can particles be spawned
var rotator WindRotator;                                              // custom wind direction (used by WindTrigger)
var bool SetWindRotator;                                              // can custom wind direction be used (used by WindTrigger)
var float RotatModif;                                                 // rotation modifier (used by WindTrigger)
var float RotatModifVar;                                              // rotator modifier variance (used by WindTrigger)
var float BCKSpray, BCKSprayVariance;
var rotator RndRot, RndRot2;

//================================================================
// USED BY WIND ACTOR
//================================================================
simulated function SetWind(rotator WindRot, bool SetWindRot, float RotMod, float RotModVar)
{
	SetWindRotator=SetWindRot;
	WindRotator=WindRot;
	RotatModif=RotMod;
	RotatModifVar=RotModVar;
	if (RotatModif == 0) RotatModif=1;
}
//================================================================
// PREBEGINPLAY STUFF
//================================================================
simulated function PreBeginPlay()
{
	if (Intervall == 0 || Intensity == 0 || NumTemplates == 0)
	{
		log("Warning: map author is a moron!", 'ParticleEmitter');
		Destroy();
	}
	flag=true;
	SetTimer(0.3,true);
	if (GeneratorLife > 0.0) LifeSpan=GeneratorLife;
}
//================================================================
// BEGINPLAY STUFF
//================================================================
simulated function BeginPlay()
{
	if (ParticlesLimit > 0) ParteNum=ParticlesLimit;
	if (!bPerformanceMode)
	{
		trIntervall=Intervall;
		trIntensity=Intensity;
	}
	Super.BeginPlay();
}
//================================================================
// CHOOSE TEMPLATES
//================================================================
simulated function int PickTemplate()
{
	if (NumTemplates <= 0) return 0;
	if (SelectionMethod == SELECT_Random) return Rand(NumTemplates);
	if (SelectionMethod == SELECT_Linear)
	{
		if (ChosenTemplate == NumTemplates-1) ChosenTemplate=0;
		else ChosenTemplate++;
		return ChosenTemplate;
	}
	return 0;
}
//================================================================
// Advanced Spawning Functions
//================================================================
// SPHERE
//================================================================
// calculate random point on sphere surface
simulated function vector CalcSurface(float radius)
{
	local float phi,z,theta;
	local vector Orig;

	phi = FRand() * (2*pi);
	z = FRand() * 2.0 - 1.0;
	theta = Sqrt(1.0 - z * z);

	Orig.X+=radius * theta * Cos(phi);
	Orig.Y+=radius * theta * Sin(phi);
	Orig.Z+=radius * z;

	return Orig;
}
// main sphere function
simulated function vector CalculateSphere(int TPL)
{
	local float r, radius;
	local vector Orig;
	Orig=location + AdvancedSpawning[TPL].SpawnOffset;
	radius=AdvancedSpawning[TPL].SphereRadius;

	if (AdvancedSpawning[TPL].bSpawnOnSurface)
	{
		Orig+=CalcSurface(Radius);
	}
	else
	{
		r = FRand()*AdvancedSpawning[TPL].SphereRadius;
		r = Sqrt(r * r);
		r = Sqrt(r * r);
		Orig+=CalcSurface(r);
	}
	return Orig;
}
//================================================================
// BOX
//================================================================
// random point on box surface
//================================================================
simulated function vector CalculateBoxSurface(vector MinVal, vector MaxVal)
{
	local float leftRightArea, topBottomArea, frontBackArea, u, v, side;
	local vector dimensions, ext, Fin;

	ext.X=abs(MaxVal.X)+abs(MinVal.X);
	ext.Y=abs(MaxVal.X)+abs(MinVal.X);
	ext.Z=abs(MaxVal.X)+abs(MinVal.X);

	dimensions = ext;

	leftRightArea = dimensions.Z * dimensions.Y;
	topBottomArea = dimensions.X * dimensions.Z;
	frontBackArea = dimensions.X * dimensions.Y;

	side = FRand() * (leftRightArea * 2) * (topBottomArea * 2) * (frontBackArea * 2);

	u = FRand() * 2 - 1;
	v = FRand() * 2 - 1;

	side -= leftRightArea;
	if (side < 0.0)
	{
		Fin.X=(-1) * ext.X;
		Fin.Y=v * ext.Y;
		Fin.Z=u * ext.Z;
	}

	side -= leftRightArea;
	if (side < 0.0)
	{
		Fin.X=ext.X;
		Fin.Y=v * ext.Y;
		Fin.Z=u * ext.Z;
	}

	side -= topBottomArea;
	if (side < 0.0)
	{
		Fin.X=u * ext.X;
		Fin.Y=ext.Y;
		Fin.Z=v * ext.Z;
	}

	side -= topBottomArea;
	if (side < 0.0)
	{
		Fin.X=u * ext.X;
		Fin.Y=(-1) * ext.Y;
		Fin.Z=v * ext.Z;
	}

	side -= frontBackArea;
	if (side < 0.0)
	{
		Fin.X=u * ext.X;
		Fin.Y=v * ext.Y;
		Fin.Z=(-1) * ext.Z;
	}
	else
	{
		Fin.X=u * ext.X;
		Fin.Y=v * ext.Y;
		Fin.Z=ext.Z;
	}

	return Fin;
}
// Main box function
simulated function vector CalculateBox(vector Orig, vector MinVal, vector MaxVal, int TPL)
{
	if (!AdvancedSpawning[TPL].bSpawnOnSurface)
	{
		Orig.X+=RandRange(MinVal.X,MaxVal.X);
		Orig.Y+=RandRange(MinVal.Y,MaxVal.Y);
		Orig.Z+=RandRange(MinVal.Z,MaxVal.Z);
	}
	else
	{
		Orig+=CalculateBoxSurface(MinVal,MaxVal);
	}
	return Orig;
}
//================================================================
// CYLINDER
//================================================================
// calculate random point on cylinder surface
simulated function vector CalculateOnCylSurf(int TPL)
{
	local float Radius, Length, capArea, sideArea, capAndSideArea, phi, section, randomRadius, randomZ;
	local vector Orig;

	Orig=AdvancedSpawning[TPL].SpawnOffset;

	Length=AdvancedSpawning[TPL].CylinderHeight;
	Radius=AdvancedSpawning[TPL].CylinderRadius;

	capArea = pi * (radius * radius);
	sideArea = 2 * Pi * radius * length;
	capAndSideArea = capArea + sideArea;

	phi = FRand() * (2*pi);

	section = FRand() * (capArea * 2.0 + sideArea);

	if (section < capArea)
	{
		randomZ = length / 2.0;
		randomRadius = Sqrt(FRand()) * radius;
	}
	else if (section < capAndSideArea)
	{
		randomZ = (FRand() - 0.5) * length;
		randomRadius = radius;
	}
	else
	{
		randomZ = -length / 2.0;
		randomRadius = Sqrt(FRand()) * radius;
	}

	Orig.X+=randomRadius * Cos(phi);
	Orig.Y+=randomRadius * Sin(phi);
	Orig.Z+=randomZ;

	return Orig;
}
// calculate random point within cylinder
simulated function vector CalculateWithinCylinder(int TPL)
{
	local float phi, r;
	local vector Orig;

	Orig=AdvancedSpawning[TPL].SpawnOffset;

	phi = FRand() * Pi * 2.0;
	r = Sqrt(FRand()) * (AdvancedSpawning[TPL].CylinderRadius);

	Orig.X+=r * Cos(phi);
	Orig.Y+=r * Sin(phi);
	Orig.Z+=(FRand() * 2.0 - 1.0)*(AdvancedSpawning[TPL].CylinderHeight);

	return Orig;
}
// calculates disc surface
simulated function vector CalculateDiscSurface(int TPL)
{
	local float phi;
	local vector Orig;

	Orig=AdvancedSpawning[TPL].SpawnOffset;

	phi = FRand() * (2*pi);

	Orig.X+=AdvancedSpawning[TPL].CylinderRadius * Cos(phi);
	Orig.Y+=AdvancedSpawning[TPL].CylinderRadius * Sin(phi);

	return Orig;
}
// main cylinder function
simulated function vector CalculateCylinder(int TPL)
{
	if (AdvancedSpawning[TPL].bSpawnOnSurface)
	{
		if (AdvancedSpawning[TPL].CylinderHeight != 0) return CalculateOnCylSurf(TPL);
		else return CalculateDiscSurface(TPL);
	}
	else
	{
		return CalculateWithinCylinder(TPL);
	}
}

//================================================================
// SPAWNS PARTICLE USING CURRENT TEMPLATE
//================================================================
simulated function SpawnParticle(int TPL)
{
	local float init_life;
	local vector NewLocal, NewVel;                                                  // current spawn location
	local Actor U1RSpawnEffect;

	if (Level.NetMode == NM_DedicatedServer) return; //clientside emitter :)

	if (ParticlesLimit > 0) ParteNum-=1;

	if (AdvancedSpawning[TPL].SpawnType == ST_Sphere)
	{
		NewLocal=CalculateSphere(TPL);
	}
	else if (AdvancedSpawning[TPL].SpawnType == ST_Box)
	{
		NewLocal=CalculateBox(AdvancedSpawning[TPL].SpawnOffset, AdvancedSpawning[TPL].BoxMinArea, AdvancedSpawning[TPL].BoxMaxArea, TPL);
	}
	else if (AdvancedSpawning[TPL].SpawnType == ST_Cylindrical)
	{
		NewLocal=CalculateCylinder(TPL);
	}
	else
	{
		if (!Particle_EffectArea[TPL].bUseOwnEffectArea)
		{
			NewLocal.x = Jiiter(EffectArea.x)+AdvancedSpawning[TPL].SpawnOffset.X;
			Newlocal.y = Jiiter(EffectArea.y)+AdvancedSpawning[TPL].SpawnOffset.Y;
			Newlocal.z = Jiiter(EffectArea.z)+AdvancedSpawning[TPL].SpawnOffset.Z;
		}
		else
		{
			NewLocal.x = Jiiter(Particle_EffectArea[TPL].OwnEffectArea.x)+AdvancedSpawning[TPL].SpawnOffset.X;
			Newlocal.y = Jiiter(Particle_EffectArea[TPL].OwnEffectArea.y)+AdvancedSpawning[TPL].SpawnOffset.Y;
			Newlocal.z = Jiiter(Particle_EffectArea[TPL].OwnEffectArea.z)+AdvancedSpawning[TPL].SpawnOffset.Z;
		}
	}
	if (AdvancedSpawning[TPL].bAlignSpawnSurface) Newlocal=RotateVector(Rotation-AdvancedSpawning[TPL].AlignModifier,Newlocal);
	Newlocal+=Location;
	if (Particle_Advanced[TPL].bUseParticleClass)
		DPM = Spawn(Particle_Advanced[TPL].ParticleClass,self,,Newlocal);
	else
		DPM = Spawn(class'UIBasicParticle',self,,Newlocal);
	if (Particle_SpawnEffect[TPL].bUseSpawnEffect)
	{
		U1RSpawnEffect = Spawn(Particle_SpawnEffect[TPL].SpawnedEffect,DPM,,Newlocal);
		if (Particle_SpawnEffect[TPL].SpawnStyle == SS_BindToParticle && U1RSpawnEffect != none)
		{
			U1RSpawnEffect.SetBase(DPM);
			U1RSpawnEffect.SetPhysics(PHYS_Trailer);
			DPM.U1RSpawnEffect=U1RSpawnEffect;
		}
	}
	DPM.CallParent=self;
	DPM.CurTPL=TPL;
	DPM.SpawnTime=Level.TimeSeconds;
	DPM.bUnlit=Particle_Display[TPL].bUnlitParticle;
	DPM.SpriteProjForward=ParticleProjForward;
	if (!Particle_Main[TPL].bForceGlobalSettings)
	{
		init_life=Particle_Main[TPL].ParticleLifeTime + Jiiter(Particle_Main[TPL].ParticleLifeTimeVariance);
	}
	else
	{
		init_life=Particle_Global.ParticleLifeTime + Jiiter(Particle_Global.ParticleLifeTimeVariance);
	}
	DPM.StartLifeSpan=init_life;
	DPM.LifeSpan=init_life;
	DPM.DrawScale = Particle_Size[TPL].ParticleDrawScale + Jiiter(Particle_Size[TPL].ParticleDrawScaleVariance);
	if (DPM.DrawScale <= 0) DPM.DrawScale=1;
	DPM.bShadowCast=Particle_Display[TPL].bParticleCastShadow;
	DPM.Style=Particle_Display[TPL].ParticleStyle;
	if (Particle_Display[TPL].bUseMesh)
	{
		DPM.Mesh=Particle_Display[TPL].PraticleMesh;
		DPM.DrawType=DT_Mesh;
		DPM.bMeshEnviroMap=Particle_Display[TPL].bParticleMeshEnviroMap;
		if (Particle_Mesh[TPL].bAnimatedMesh)
		{
			if (DPM.HasAnim(Particle_Mesh[TPL].AnimationName))
			{
				if (Particle_Mesh[TPL].AnimationType == AN_PlayOnce) DPM.PlayAnim(Particle_Mesh[TPL].AnimationName, Particle_Mesh[TPL].AnimationRate, Particle_Mesh[TPL].TweenRate);
				else  DPM.LoopAnim(Particle_Mesh[TPL].AnimationName, Particle_Mesh[TPL].AnimationRate, Particle_Mesh[TPL].TweenRate);
			}
		}
		if (Particle_Physics[TPL].ParticlePhysics == PHYS_Rotating && Particle_Mesh[TPL].FaceObject == FACE_None) DPM.RotationRate=Particle_Mesh[TPL].MeshRotationRate;
	}
	if (Particle_Collision[TPL].ParticlesUseCollision)
	{
		DPM.SetCollision(Particle_Collision[TPL].CollideWithActors,Particle_Collision[TPL].BlockActors,Particle_Collision[TPL].BlockPlayers);
		DPM.SetCollisionSize(Particle_Collision[TPL].ParticleCollisonRadius, Particle_Collision[TPL].ParticleCollisonHeight);
		DPM.bCollideWorld=Particle_Collision[TPL].ParticleCollideWorld;
	}
	else
	{
		DPM.SetCollision(false,false,false);
		DPM.SetCollisionSize(0, 0);
		DPM.bCollideWorld=false;
	}
	DPM.SetPhysics(Particle_Physics[TPL].ParticlePhysics);
	DPM.Buoyancy=Particle_Buoyance[TPL].ParticleBuoyancy;
	DPM.Mass=Particle_Buoyance[TPL].ParticleMass;
	if (Particle_Fading[TPL].CanFadeIn)
	{
		DPM.NowFading=true;
		DPM.ScaleGlow=Particle_Fading[TPL].InitailScaleGlow;
	}
	if (Particle_Sound[TPL].FlyingSound != none)
		DPM.AmbientSound = Particle_Sound[TPL].FlyingSound;
	DPM.bBounce=Particle_Bounce[TPL].CanBounce;
	if (Particle_Light[TPL].CastLight)
	{
		DPM.LightType=Particle_Lighting[TPL].ParticleLightType;
		DPM.LightEffect=Particle_Lighting[TPL].ParticleLightEffect;
		DPM.LightBrightness=Particle_LightColor[TPL].ParticleLightBrightness;
		DPM.LightHue=Particle_LightColor[TPL].ParticleLightHue;
		DPM.LightSaturation=Particle_LightColor[TPL].ParticleLightSaturation;
		DPM.LightRadius=Particle_Lighting[TPL].ParticleLightRadius;
		DPM.LightPeriod=Particle_Lighting[TPL].ParticleLightPeriod;
		DPM.LightPhase=Particle_Lighting[TPL].ParticleLightPhase;
		DPM.LightCone=Particle_Lighting[TPL].ParticleLightCone;
		DPM.VolumeBrightness=Particle_Lighting[TPL].ParticleVolumeBrightness;
		DPM.VolumeRadius=Particle_Lighting[TPL].ParticleVolumeRadius;
		DPM.VolumeFog=Particle_Lighting[TPL].ParticleVolumeFog;
	}
	DPM.AccelerationType=Particle_Physics[TPL].AccelerationType;
	DPM.SetTimer(0.2, true);
	if (Particle_Main[TPL].bUseParticleRotation)
		DPM.SetRotation(Particle_Main[TPL].ParticleRotation);
	if (!Particle_RandomRotation[TPL].bRandomizeRotation)
	{
		if (!Particle_Main[TPL].bForceGlobalSettings)
		{
			NewVel=(Particle_Main[TPL].ParticleSpeed + Jiiter(Particle_Main[TPL].SpeedVariance))*vector(Rotation);
		}
		else
		{
			NewVel=(Particle_Global.ParticleSpeed + Jiiter(Particle_Global.SpeedVariance))*vector(Rotation);
		}
		if (!Particle_Main[TPL].bForceGlobalSettings)
		{
			if (Particle_Main[TPL].bDefineSpeedAsVector)
			{
				NewVel.x=Particle_Main[TPL].BaseSpeed.x + Jiiter(Particle_Main[TPL].SpeedVariance);
				NewVel.y=Particle_Main[TPL].BaseSpeed.y + Jiiter(Particle_Main[TPL].SpeedVariance);
				NewVel.z=Particle_Main[TPL].BaseSpeed.z + Jiiter(Particle_Main[TPL].SpeedVariance);
			}
		}
		else
		{
			if (Particle_Global.bDefineSpeedAsVector)
			{
				NewVel.x=Particle_Global.BaseSpeed.x + Jiiter(Particle_Global.SpeedVariance);
				NewVel.y=Particle_Global.BaseSpeed.y + Jiiter(Particle_Global.SpeedVariance);
				NewVel.z=Particle_Global.BaseSpeed.z + Jiiter(Particle_Global.SpeedVariance);
			}
		}
	}
	else
	{
		RndRot=Rotation;
		if (!Particle_RandomRotation[TPL].bForceRndRot)
		{
			if (Particle_RandomRotation[TPL].bRandPitch) RndRot.Pitch=RandRange(Particle_RandomRotation[TPL].MinRotation.Pitch, Particle_RandomRotation[TPL].MaxRotation.Pitch);
			if (Particle_RandomRotation[TPL].bRandYaw) RndRot.Yaw=RandRange(Particle_RandomRotation[TPL].MinRotation.Yaw, Particle_RandomRotation[TPL].MaxRotation.Yaw);
			if (Particle_RandomRotation[TPL].bRandRoll) RndRot.Roll=RandRange(Particle_RandomRotation[TPL].MinRotation.Roll, Particle_RandomRotation[TPL].MaxRotation.Roll);
		}
		else
		{
			RndRot2=RotRand();
			if (Particle_RandomRotation[TPL].bRandPitch) RndRot.Pitch=RndRot2.Pitch;
			if (Particle_RandomRotation[TPL].bRandYaw) RndRot.Yaw=RndRot2.Yaw;
			if (Particle_RandomRotation[TPL].bRandRoll) RndRot.Roll=RndRot2.Roll;
		}
//           if(Particle_RandomRotation[TPL].bAlignRotator) RndRot=class'U1Quaternions'.static.AddRotator(RndRot,Rotation);
		if (Particle_RandomRotation[TPL].bAlignRotator) RndRot=RndRot+Rotation;
		NewVel=(Particle_Main[TPL].ParticleSpeed + Jiiter(Particle_Main[TPL].SpeedVariance))*vector(RndRot);
	}
	if (Particle_InvertVelocity[TPL].bUseInvertVelocity && !Particle_InvertVelocity[TPL].bLoop)
	{
		if (ReturnInvX(TPL)) NewVel.X*=-1;
		if (ReturnInvY(TPL)) NewVel.Y*=-1;
		if (ReturnInvZ(TPL)) NewVel.Z*=-1;
	}
	if (SetWindRotator)
	{
		NewVel=(RotatModif + Jiiter(RotatModifVar))*vector(WindRotator);
	}
	if (!Particle_Main[TPL].bForceGlobalSettings)
	{
		if (Particle_Main[TPL].SprayFactor > 0.0)
		{
			NewVel.x=NewVel.x*(Particle_Main[TPL].SprayFactor + Jiiter(Particle_Main[TPL].SprayFactorVariance));
			NewVel.y=NewVel.y*(Particle_Main[TPL].SprayFactor + Jiiter(Particle_Main[TPL].SprayFactorVariance));
			NewVel.z=NewVel.z*(Particle_Main[TPL].SprayFactor + Jiiter(Particle_Main[TPL].SprayFactorVariance));
		}
	}
	else
	{
		if (Particle_Main[TPL].SprayFactor > 0.0)
		{
			NewVel.x=NewVel.x*(Particle_Global.SprayFactor + Jiiter(Particle_Global.SprayFactorVariance));
			NewVel.y=NewVel.y*(Particle_Global.SprayFactor + Jiiter(Particle_Global.SprayFactorVariance));
			NewVel.z=NewVel.z*(Particle_Global.SprayFactor + Jiiter(Particle_Global.SprayFactorVariance));
		}
	}
	DPM.Velocity=NewVel;
	DPM.Texture=Particle_Display[TPL].ParticleTexture;	// Sprite texture if DrawType=DT_Sprite.
	if (Particle_Display[TPL].bUseRandomTexture)
	{
		if (!Particle_Animation[TPL].DefineAnimationStorage)
		{
			if (Particle_Animation[TPL].NumOfTextures > 0)
			{
				DPM.Texture=Particle_Animation[TPL].AnimTextures[Rand(Particle_Animation[TPL].NumOfTextures)];
			}
		}
		else
		{
			if (Particle_Animation[TPL].ParticleAnimationStorage != none)
			{
				if (Particle_Animation[TPL].ParticleAnimationStorage.default.NumOfTextures > 0)
				{
					DPM.Texture=Particle_Animation[TPL].ParticleAnimationStorage.default.ParticleAnimation[Rand(Particle_Animation[TPL].ParticleAnimationStorage.default.NumOfTextures)];
				}
			}
		}
	}
	if (Particle_Misc[TPL].bUseDistanceCulling)
	{
		DPM.VisibilityHeight=Particle_Misc[TPL].PartVisibilityHeight;
		DPM.VisibilityRadius=Particle_Misc[TPL].PartVisibilityRadius;
	}
	if (ReturnDestinationType(TPL) != DEST_None) DPM.Destn=ReturnTarget(TPL);
}
//================================================================
// PERFORMANCE
//================================================================
simulated function Timer()
{
	local PlayerPawn pp;
	flag=false;
	if (Level.NetMode != NM_DedicatedServer)
	{
		foreach RadiusActors(class'PlayerPawn',pp,VisibilityRadius)
		{
			if (Viewport(pp.Player) != None) flag=true; //we found local player in visibility radius
		}
	}
}
//================================================================
// SPAWN AND OTHER FUNCTION CAN TAKE PLACE ONLY AT CLIENT SIDE
//================================================================
simulated function InStateStuff()
{
	local int i, tpl;

	if (Level.NetMode == NM_DedicatedServer) return; //clientside emitter :)
	if (LineOfSightCheck)
		if (!PlayerCanSeeMe()) return;
	if (bPerformanceMode)
	{
		if (!flag)
		{
			trIntervall=NewIntervall;
			trIntensity=NewIntensity;
		}
		else if (flag)
		{
			trIntervall=Intervall;
			trIntensity=Intensity;
		}
	}
	if (flag || bPerformanceMode)
	{
		if (BurstMethod == BURST_Linear) tpl=PickTemplate();
		for (i = 0; i < RandFloat(trIntensity); i++)
		{
			if (BurstMethod == BURST_Linear) SpawnParticle(TPL);
			if (BurstMethod == BURST_Random) SpawnParticle(PickTemplate());
		}
	}
	if (ParticlesLimit > 0)
	{
		if (ParteNum <=0)// GoToState('BeforeDie'); //Destroy();
		{
			if (!bNoDelete) GoToState('BeforeDie'); //Destroy();
			else GoToState('NoParticles');
		}
	}
	if (OneShot)// GoToState('BeforeDie'); //Destroy();
	{
		if (!bNoDelete) GoToState('BeforeDie'); //Destroy();
		else GoToState('NoParticles');
	}
}
//================================================================
// SYSTEM TICK
//================================================================
//simulated function Tick(float DeltaTime){}
/*--------------------------------------------------------------------------------------------------------
  !!! STATES !!!
--------------------------------------------------------------------------------------------------------*/
auto simulated state() NormalParticle
{
	simulated function BeginState()
	{
		Disable('Tick');
	}
Begin:
	if (Level.NetMode == NM_DedicatedServer) GoToState('NoParticles'); //we need to go to NoParticleState if
AfterBegin:
	if (!bOn) GoTo('NearEnd');
	InStateStuff();
NearEnd:
	sleep(trIntervall);
	GoTo('AfterBegin');
}
//=============================================================================
// Toggle when triggered. Implemented in subclass.
//=============================================================================
simulated state() TriggerToggle {}
//=============================================================================
// tunrs off when triggered. Implemented in subclass.
//=============================================================================
simulated state() TriggerTurnsOff {}
//=============================================================================
// turns on when triggered. Implemented in subclass.
//=============================================================================
simulated state() TriggerTurnsOn {}
//=============================================================================
// Start when triggered, Stop when get untriggered. Implemented in subclass.
//=============================================================================
simulated state() TriggerControl {}
//=============================================================================
// Blast triggered. Implemented in subclass.
//=============================================================================
simulated state() TriggeredBlast {}
//=============================================================================
// State where particles will not be spawned.
//=============================================================================
simulated state NoParticles
{
Begin:
	bOn=false;
	Disable('Tick');
}
auto simulated state Startup
{
Begin:
	if (Level.NetMode != NM_DedicatedServer)
	{
		GotoState('NormalParticle');
	}
}

//=============================================================================
// Searches for existing particles spawned by this Emitter.
//=============================================================================
simulated function bool PartAlive()
{
	local UIBasicParticle BP, CK;

	foreach AllActors(class'UIBasicParticle', BP)
	{
		if (BP.Owner == self || BP.CallParent == self)
		{
			CK=BP;
			break;
		}
	}
	if (CK != none) return true;
	else return false;
}
//=============================================================================
// All needed actions before destroying emitter takes place here.
//=============================================================================
simulated state BeforeDie
{
Begin:
	bOn=false;
	Disable('Tick');
PostBegin:
	if (WaitForParticles)
	{
		if (PartAlive())
		{
			Sleep(WaitPause);
			GoTo('PostBegin');
		}
	}
PreDie:
	Sleep(BeforeDieSleep);
	Destroy();
}
//=============================================================================
// If anyone wants to destroy emitter, he can use this function.
//=============================================================================
simulated function EmitterDestroy()
{
	GoToState('BeforeDie');
}
//=============================================================================
// Not used !!
//=============================================================================
simulated function StopParticles() {}
//=============================================================================
// Not used !! :P
//=============================================================================
simulated function Destroyed()
{
	StopParticles();
}
/*--------------------------------------------------------------------------------------------------------
                                     !!! PARTICLE SUPPORT !!!
  Since i cannot read structures from particle class (which sux BTW :P), i had to write functions which
  will read and return 'em.
--------------------------------------------------------------------------------------------------------*/
//MAIN
final simulated function float ReturnSlowDown(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 1;
	return Particle_Main[CurTPL].ParticleSlowingDownFactor;
}
final simulated function bool ReturnMoveSmooth(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return true;
	return Particle_Main[CurTPL].bMoveSmooth;
}
//ANIMATION
final simulated function texture ReturnAnimTex(int CurTPL, int TexNum)
{
	if (CurTPL > MAX_TEMPLATES-1 || TexNum > 59) return none;
	return Particle_Animation[CurTPL].AnimTextures[TexNum];
}
final simulated function int ReturnTexNum(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Animation[CurTPL].NumOfTextures;
}
final simulated function texture ReturnStAnimTex(int CurTPL, int TexNum)
{
	if (CurTPL > MAX_TEMPLATES-1 || TexNum > 59) return none;
	if (Particle_Animation[CurTPL].ParticleAnimationStorage == none) return none;
	return Particle_Animation[CurTPL].ParticleAnimationStorage.Default.ParticleAnimation[TexNum];
}
final simulated function bool ReturnSt(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Animation[CurTPL].DefineAnimationStorage;
}
final simulated function int ReturnStTexNum(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	if (Particle_Animation[CurTPL].ParticleAnimationStorage == none) return 0;
	return Particle_Animation[CurTPL].ParticleAnimationStorage.Default.NumOfTextures;
}
//SIZE
final simulated function float ReturnGrow(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return abs(Particle_Size[CurTPL].ParticleGrowth);
}
final simulated function float ReturnGrowth(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	if (Particle_Size[CurTPL].SizeType == ST_Grow) return abs(Particle_Size[CurTPL].ParticleGrowth);
	else if (Particle_Size[CurTPL].SizeType == ST_Shrink) return (-1*abs(Particle_Size[CurTPL].ParticleShrink));
	else return 0;
}
//final simulated function bool ReturnCycleSize(int CurTPL){ if(CurTPL > MAX_TEMPLATES-1) return false; return Particle_Size[CurTPL].bCycleSize; }
final simulated function ESizeType ReturnCycleSize(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return ST_Normal;
	return Particle_Size[CurTPL].SizeType;
}
final simulated function ESizing ReturnSizing(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return SIZING_Infinity;
	return Particle_Size[CurTPL].Sizing;
}
final simulated function float ReturnShrink(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return (-1*abs(Particle_Size[CurTPL].ParticleShrink));
}
final simulated function float ReturnMinSize(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0.0001;
	return Particle_Size[CurTPL].MinSize;
}
final simulated function float ReturnMaxSize(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 1;
	return Particle_Size[CurTPL].MaxSize;
}
//DISPLAY
final simulated function bool ReturnSpriteAnim(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Display[CurTPL].bUseSpriteAnimation;
}
//DECAL
final simulated function class<decal> ReturnDecalClass(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Decal[CurTPL].ParticleDecal;
}
final simulated function texture ReturnDecalTex(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Decal[CurTPL].ParticleDecalTexture;
}
final simulated function int ReturnDecalSize(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 1;
	return Particle_Decal[CurTPL].ParticleDecalSize;
}
final simulated function bool ReturnParticleSpawnDecal(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Decal[CurTPL].ParticleSpawnDecal;
}
final simulated function bool ReturnbLimitDecals(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Decal[CurTPL].bLimitDecals;
}
//SOUND
final simulated function sound ReturnBornSound(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Sound[CurTPL].BornSound;
}
final simulated function sound ReturnDyingSound(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Sound[CurTPL].DyingSound;
}
final simulated function sound ReturnLandingSound(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Sound[CurTPL].LandingSound;
}
final simulated function sound ReturnHittingSound(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Sound[CurTPL].HittingSound;
}
final simulated function sound ReturnTouchingSound(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Sound[CurTPL].TouchingSound;
}
final simulated function ESoundSlot ReturnParticleSoundSlot(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return ESoundSlot.SLOT_None;
	return Particle_Sound[CurTPL].ParticleSoundSlot;
}
final simulated function bool ReturnParticleSoundbNoOverride(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Sound[CurTPL].ParticleSoundbNoOverride;
}
final simulated function float ReturnParticleSoundVolume(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 64;
	return Particle_Sound[CurTPL].ParticleSoundVolume;
}
final simulated function float ReturnParticleSoundRadius(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 64;
	return Particle_Sound[CurTPL].ParticleSoundRadius;
}
final simulated function float ReturnParticleSoundPitch(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 64;
	return Particle_Sound[CurTPL].ParticleSoundPitch;
}
//FADING
final simulated function bool ReturnCanFadeIn(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Fading[CurTPL].CanFadeIn;
}
final simulated function float ReturnFadeInFactor(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Fading[CurTPL].FadeInScaleFactor;
}
final simulated function float ReturnFadeIn(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Fading[CurTPL].FadeInTime;
}
final simulated function bool ReturnCanFadeOut(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Fading[CurTPL].CanFadeOut;
}
final simulated function float ReturnFadeOutFactor(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Fading[CurTPL].FadeOutScaleFactor;
}
final simulated function float ReturnFadeOut(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Fading[CurTPL].FadeOutTime;
}
//DAMAGE
final simulated function bool ReturnParticleGivesDamage(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Damage[CurTPL].ParticleGivesDamage;
}
final simulated function bool ReturnPlayerTakeDamage(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Damage[CurTPL].PlayerTakeDamage;
}
final simulated function bool ReturnScriptedPawnTakeDamage(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Damage[CurTPL].ScriptedPawnTakeDamage;
}
final simulated function bool ReturnFlockPawnTakeDamage(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Damage[CurTPL].FlockPawnTakeDamage;
}
final simulated function bool ReturnOtherActorTakeDamage(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Damage[CurTPL].OtherActorTakeDamage;
}
final simulated function name ReturnParticleDamageType(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 'Burned';
	return Particle_Damage[CurTPL].ParticleDamageType;
}
final simulated function int ReturnParticleDamage(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Damage[CurTPL].ParticleDamage;
}
final simulated function int ReturnMomentumTransfer(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Damage[CurTPL].MomentumTransfer;
}
//PHYSICS
final simulated function vector ReturnAccel(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return vect(0,0,0);
	return Particle_Physics[CurTPL].AccelerateFactor;
}
final simulated function bool ReturnCanAccel(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Physics[CurTPL].bCanAccelerate;
}
final simulated function vector ReturnTerminalAccel(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return vect(0,0,0);
	return Particle_Physics[CurTPL].TerminalVelocity;
}
//COLLISION
final simulated function bool ReturnDestroyWhenTouch(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return true;
	return Particle_Collision[CurTPL].DestroyWhenTouch;
}
final simulated function bool ReturnDestroyWhenColideWorld(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return true;
	return Particle_Collision[CurTPL].DestroyWhenColideWorld;
}
final simulated function bool ReturnDestroyWhenLand(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return true;
	return Particle_Collision[CurTPL].DestroyWhenLand;
}
final simulated function bool ReturnDestroyWhenTouchWater(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return true;
	return Particle_Collision[CurTPL].DestroyWhenTouchWater;
}
final simulated function bool ReturnStopWhenTouchWall(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].StopWhenTouchWall;
}
final simulated function bool ReturnStopWhenTouchPawn(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].StopWhenTouchPawn;
}
final simulated function bool ReturnStickToWall(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].StickToWall;
}
final simulated function bool ReturnStickToPawn(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].StickToPawn;
}
final simulated function bool ReturnbSpawnLandEffect(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].bSpawnLandEffect;
}
final simulated function bool ReturnbOverrideWaterEntrySound(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].bOverrideWaterEntrySound;
}
final simulated function bool ReturnbOverrideWaterEntryEffect(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].bOverrideWaterEntryEffect;
}
final simulated function bool ReturnbSpawnEffectOnDestroy(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Collision[CurTPL].bSpawnEffectOnDestroy;
}
final simulated function sound ReturnWaterEntrySound(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Collision[CurTPL].WaterEntrySound;
}
final simulated function class<actor> ReturnLandEffect(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Collision[CurTPL].LandEffect;
}
final simulated function class<actor> ReturnWaterEntryActor(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Collision[CurTPL].WaterEntryActor;
}
final simulated function class<actor> ReturnDestroyEffect(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Collision[CurTPL].DestroyEffect;
}
//BOUNCE
final simulated function bool ReturnCanBounce(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Bounce[CurTPL].CanBounce;
}
final simulated function bool ReturnEndlessBounce(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Bounce[CurTPL].EndlessBounce;
}
final simulated function float ReturnBounceRatio(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Bounce[CurTPL].BounceRatio;
}
final simulated function float ReturnBounceModifier(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Bounce[CurTPL].BounceModifier;
}
final simulated function int ReturnBounceNum(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 0;
	return Particle_Bounce[CurTPL].BounceNum;
}
//BOUYANCY
final simulated function bool ReturnCanBouyance(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Buoyance[CurTPL].CanBuoyance;
}
final simulated function bool ReturnSplashWhenHitWater(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Buoyance[CurTPL].SplashWhenHitWater;
}
final simulated function bool ReturnSoundWhenHitWater(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Buoyance[CurTPL].SoundWhenHitWater;
}
//INVERSE VELOCITY
final simulated function bool ReturnCanLoopInv(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_InvertVelocity[CurTPL].bLoop;
}
final simulated function bool ReturnCanInv(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_InvertVelocity[CurTPL].bUseInvertVelocity;
}
final simulated function bool ReturnInvX(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_InvertVelocity[CurTPL].InvertX;
}
final simulated function bool ReturnInvY(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_InvertVelocity[CurTPL].InvertY;
}
final simulated function bool ReturnInvZ(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_InvertVelocity[CurTPL].InvertZ;
}
final simulated function float ReturnInvDelay(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 1;
	return Particle_InvertVelocity[CurTPL].InvertDelay;
}
//MESH
//final simulated function bool ReturnVelNorm(int CurTPL){ if(CurTPL > MAX_TEMPLATES-1) return false; return Particle_Mesh[CurTPL].bRotVelocity; }
final simulated function actor ReturnLookTarget(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	return Particle_Mesh[CurTPL].LookTarget;
}
final simulated function EFType ReturnFaceObject(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return FACE_None;
	return Particle_Mesh[CurTPL].FaceObject;
}
//DESTINATION
final simulated function actor ReturnTarget(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return none;
	if (Particle_Destination[CurTPL].DestinationActor == DA_Chosen )
		return Particle_Destination[CurTPL].Destination;
	else
		return self;
}
final simulated function EDest ReturnDestinationType(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return DEST_None;
	return Particle_Destination[CurTPL].DestinationType;
}
final simulated function bool ReturnbForceFollow(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Destination[CurTPL].bForceFollow;
}
//Misc
final simulated function float ReturnParticlesBounce_Min(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 1;
	return Particle_Misc[CurTPL].ParticlesBounce_Min;
}
final simulated function float ReturnParticlesBounce_Max(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 1;
	return Particle_Misc[CurTPL].ParticlesBounce_Max;
}
final simulated function bool ReturnbTrailer(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Misc[CurTPL].ParticlesFixedTrailer;
}
final simulated function bool ReturnbJerkyness(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return false;
	return Particle_Misc[CurTPL].ParticlesUseJerkyness;
}
final simulated function float ReturnParticlesJerkyness(int CurTPL)
{
	if (CurTPL > MAX_TEMPLATES-1) return 1;
	return Particle_Misc[CurTPL].ParticlesJerkyness;
}

defaultproperties
{
	Texture=Texture'UnrealShare.Icons.ParticleEmitter'
	bStasis=True
	RemoteRole=ROLE_SimulatedProxy
	bHidden=true
	bNoDelete=true
	bDirectional=true
	NewIntervall=0.400000
	NewIntensity=1.000000
	Intervall=0.400000
	Intensity=1.000000
	bOn=True
	VisibilityRadius=14000.000000
	DrawScale=0.5
	InitialState=NormalParticle
	/*--------------------------------------------------------------------------------------------------------
	  !!! TEMPLATES !!!
	--------------------------------------------------------------------------------------------------------*/
	//MAIN
	Particle_Main(0)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(1)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(2)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(3)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(4)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(5)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(6)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(7)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(8)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(9)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(10)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(11)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(12)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(13)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(14)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	Particle_Main(15)=(ParticleLifeTime=2.000000,ParticleLifeTimeVariance=0.500000,ParticleSlowingDownFactor=1.000000)
	//DISPLAY
	Particle_Display(0)=(ParticleStyle=STY_Translucent)
	Particle_Display(1)=(ParticleStyle=STY_Translucent)
	Particle_Display(2)=(ParticleStyle=STY_Translucent)
	Particle_Display(3)=(ParticleStyle=STY_Translucent)
	Particle_Display(4)=(ParticleStyle=STY_Translucent)
	Particle_Display(5)=(ParticleStyle=STY_Translucent)
	Particle_Display(6)=(ParticleStyle=STY_Translucent)
	Particle_Display(7)=(ParticleStyle=STY_Translucent)
	Particle_Display(8)=(ParticleStyle=STY_Translucent)
	Particle_Display(9)=(ParticleStyle=STY_Translucent)
	Particle_Display(10)=(ParticleStyle=STY_Translucent)
	Particle_Display(11)=(ParticleStyle=STY_Translucent)
	Particle_Display(12)=(ParticleStyle=STY_Translucent)
	Particle_Display(13)=(ParticleStyle=STY_Translucent)
	Particle_Display(14)=(ParticleStyle=STY_Translucent)
	Particle_Display(15)=(ParticleStyle=STY_Translucent)
	//SIZE
	Particle_Size(0)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(1)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(2)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(3)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(4)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(5)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(6)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(7)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(8)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(9)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(10)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(11)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(12)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(13)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(14)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	Particle_Size(15)=(ParticleDrawScale=1.000000,ParticleDrawScaleVariance=2.000000,ParticleGrowth=0.00000,ParticleShrink=0.000000,MinSize=0.00001,MaxSize=1.000000,SizeType=ST_Normal)
	//FADING
	Particle_Fading(0)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(1)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(2)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(3)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(4)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(5)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(6)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(7)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(8)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(9)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(10)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(11)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(12)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(13)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(14)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	Particle_Fading(15)=(InitailScaleGlow=0.200000,FadeOutTime=0.500000,FadeOutScaleFactor=0.200000,FadeInTime=0.500000,FadeInScaleFactor=0.220000)
	//PHYSICS
	Particle_Physics(0)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(1)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(2)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(3)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(4)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(5)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(6)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(7)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(8)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(9)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(10)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(11)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(12)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(13)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(14)=(ParticlePhysics=PHYS_Flying)
	Particle_Physics(15)=(ParticlePhysics=PHYS_Flying)
	//COLLISION
	Particle_Collision(0)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(1)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(2)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(3)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(4)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(5)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(6)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(7)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(8)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(9)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(10)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(11)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(12)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(13)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(14)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	Particle_Collision(15)=(ParticleCollisonRadius=2.000000,ParticleCollisonHeight=2.000000)
	//BOUNCE
	Particle_Bounce(0)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(1)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(2)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(3)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(4)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(5)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(6)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(7)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(8)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(9)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(10)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(11)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(12)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(13)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(14)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	Particle_Bounce(15)=(BounceRatio=0.800000,BounceModifier=15.000000,BounceNum=5)
	//BUOYANCE
	Particle_Buoyance(0)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(1)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(2)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(3)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(4)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(5)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(6)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(7)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(8)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(9)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(10)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(11)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(12)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(13)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(14)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	Particle_Buoyance(15)=(ParticleBuoyancy=15.000000,ParticleMass=10.000000)
	//SOUND
	Particle_Sound(0)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(1)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(2)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(3)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(4)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(5)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(6)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(7)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(8)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(9)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(10)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(11)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(12)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(13)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(14)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	Particle_Sound(15)=(ParticleSoundVolume=64,ParticleSoundRadius=64,ParticleSoundPitch=64)
	//MESH ANIM
	Particle_Mesh(0)=(AnimationRate=1.0)
	Particle_Mesh(1)=(AnimationRate=1.0)
	Particle_Mesh(2)=(AnimationRate=1.0)
	Particle_Mesh(3)=(AnimationRate=1.0)
	Particle_Mesh(4)=(AnimationRate=1.0)
	Particle_Mesh(5)=(AnimationRate=1.0)
	Particle_Mesh(6)=(AnimationRate=1.0)
	Particle_Mesh(7)=(AnimationRate=1.0)
	Particle_Mesh(8)=(AnimationRate=1.0)
	Particle_Mesh(9)=(AnimationRate=1.0)
	Particle_Mesh(10)=(AnimationRate=1.0)
	Particle_Mesh(11)=(AnimationRate=1.0)
	Particle_Mesh(12)=(AnimationRate=1.0)
	Particle_Mesh(13)=(AnimationRate=1.0)
	Particle_Mesh(14)=(AnimationRate=1.0)
	Particle_Mesh(15)=(AnimationRate=1.0)
	//RANDOM ROTATION
	Particle_RandomRotation(0)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(1)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(2)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(3)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(4)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(5)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(6)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(7)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(8)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(9)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(10)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(11)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(12)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(13)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(14)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))
	Particle_RandomRotation(15)=(bRandPitch=True,bRandYaw=True,bRandRoll=True,MaxRotation=(Pitch=65536,Yaw=65536,Roll=65536))

	BeforeDieSleep=0.1
	WaitForParticles=true
	WaitPause=0.3
}
