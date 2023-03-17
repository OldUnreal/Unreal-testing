
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXMeshEmitter);

void AXMeshEmitter::ModifyParticle(xParticle* A)
{
	A->Mesh = ParticleMesh;
	A->LODBias = LODBias;
	A->Fatness = ParticleFatness.GetValue();
	A->Skin = A->Texture;
	A->bParticles = bRenderParticles;
	A->bRandomFrame = bParticlesRandFrame;
	FVector V = InitialRot.GetValue() * 65536.f;
	A->Rotation = FRotator(appFloor(V.X), appFloor(V.Y), appFloor(V.Z));
	A->PRot = (GMath.UnitCoords / A->Rotation);
	A->RotSp = RotationsPerSec.GetValue() * 65536.f;
	A->bDoRot = !A->RotSp.IsZero();
	A->AmbientGlow = AmbientGlow;
	A->DrawType = DT_Mesh;
	A->bMeshEnviroMap = bMeshEnviromentMapping;
	A->bTextureAnimOnce = (SpriteAnimationType != SAN_LoopAnim);

	if( bAnimateParticles && ParticleMesh )
	{
		if( RandAnims.Num() )
		{
			INT Num = RandAnims.Num();
			FAnimationType& AT = RandAnims(GetRandomVal(Num));
			A->AnimSequence = AT.AnimSeq;
			A->AnimFrame = AT.Frame;
			A->AnimRate = AT.Rate;
			A->bAnimLoop = AT.bAnimLoop;
		}
		else
		{
			A->AnimSequence = ParticleAnim;
			A->AnimFrame = PartAnimFrameStart;
			A->AnimRate = PartAnimRate;
			A->bAnimLoop = bPartAnimLoop;
		}
		if( A->AnimSequence!=NAME_None && !A->bAnimLoop && A->AnimRate>0 )
		{
			const FMeshAnimSeq* Seq = (ParticleMesh->GetClass()==USkeletalMesh::StaticClass() ? 
				(((USkeletalMesh*)ParticleMesh)->DefaultAnimation ?
				((USkeletalMesh*)ParticleMesh)->DefaultAnimation->GetAnimSeq(A->AnimSequence) : NULL) :
				ParticleMesh->GetAnimSeq( A->AnimSequence ));
			if( Seq )
				A->AnimLast = 1.f - (1.f / Seq->NumFrames);
		}
	}
}
FRotator AXMeshEmitter::GetParticleRot(xParticle* A, const FLOAT Dlt, FVector& Mvd, UEmitterRendering* Render)
{
	if (bUsePhysXRotation && A->RbPhysicsData)
		return A->Rotation;

	if (bAnimateParticles)
	{
		if (AnimateByActor)
		{
			A->AnimFrame = AnimateByActor->AnimFrame;
			A->AnimSequence = AnimateByActor->AnimSequence;
			A->SkelAnim = AnimateByActor->SkelAnim;
			A->bAnimLoop = AnimateByActor->bAnimLoop;
		}
		else if (A->bAnimLoop)
		{
			A->AnimFrame += A->AnimRate * Dlt;
			if (A->AnimFrame >= 1)
				A->AnimFrame -= 1.f;
		}
		else if (A->AnimFrame < A->AnimLast)
			A->AnimFrame = Min(A->AnimFrame + A->AnimRate * Dlt, A->AnimLast);
	}
	if (A->bDoRot && A->bMovable)
		A->PRot /= FRotator(appFloor(A->RotSp.X * Dlt), appFloor(A->RotSp.Y * Dlt), appFloor(A->RotSp.Z * Dlt));
	FCoords CR = A->PRot;
	if (bRelativeToMoveDir)
		CR /= (Mvd - A->OldLocation).Rotation();
	if (ParticleRotation == MEP_FacingCamera)
		CR /= (UEmitterRendering::CamPos.Origin - Mvd).Rotation();
	else if (ParticleRotation == MEP_YawingToCamera)
	{
		if (CR.ZAxis.Z == 1.f)
			CR /= FRotator(0, (UEmitterRendering::CamPos.Origin - Mvd).Rotation().Yaw, 0);
		else
		{
			FVector AimP = (UEmitterRendering::CamPos.Origin - A->Pos).TransformVectorBy(GetFacingCoords(CR.ZAxis));
			CR /= TransformForRot(AimP.Rotation().Yaw, CR.ZAxis);
		}
	}
	return CR.OrthoRotation();
}
