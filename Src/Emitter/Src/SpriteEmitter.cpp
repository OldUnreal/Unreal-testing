
#include "EmitterPrivate.h"

IMPLEMENT_CLASS(AXSpriteEmitter);

void AXSpriteEmitter::ModifyParticle(xParticle* A)
{
	A->Mesh = SheetModel;
	A->LODBias = 1.f;
	A->Fatness = 128;
	A->Skin = A->Texture;
	A->MultiSkins[0] = A->Texture;
	A->MultiSkins[1] = A->Texture;
	A->bParticles = 0;
	A->bRandomFrame = 0;
	FVector V = InitialRot.GetValue() * 65536.f;
	A->PRot = (GMath.UnitCoords / FRotator(appFloor(V.X),appFloor(V.Y),appFloor(V.Z)));
	A->RotSp = RotationsPerSec.GetValue() * 65536.f;
	A->bDoRot = (A->RotSp != FVector(0, 0, 0));
	A->bUnlit = bUnlit;
	A->AmbientGlow = AmbientGlow;
	A->AnimSequence = NAME_None;
	A->AnimFrame = 0;
	A->DrawType = DT_Mesh;
	A->bTextureAnimOnce = (SpriteAnimationType != SAN_LoopAnim);
}
FRotator AXSpriteEmitter::GetParticleRot(xParticle* A, const FLOAT Dlt, FVector& Mvd, UEmitterRendering* Render)
{
	if (A->bMovable && A->bDoRot)
	{
		FLOAT DMulti = (RotateByVelocityScale > 0.f ? (A->Velocity.Size() * 0.01f * RotateByVelocityScale * Dlt) : Dlt);
		A->PRot /= FRotator(appFloor(A->RotSp.X * DMulti), appFloor(A->RotSp.Y * DMulti), appFloor(A->RotSp.Z * DMulti));
	}
	FVector Vel(A->bMovable ? A->Velocity : (A->OldLocation - Mvd));
	FCoords CR;
	switch (ParticleRotation)
	{
	case SPR_DesiredRot:
		CR = FCoords(FVector(0, 0, 0), Render->Frame->Coords.ZAxis, Render->Frame->Coords.XAxis, -Render->Frame->Coords.YAxis);
		break;

	case SPR_RelFacingVelocity:
		CR.XAxis = Render->Frame->Coords.ZAxis;
		CR.ZAxis = Vel;
		CR.ZAxis.Normalize();
		CR.YAxis = (CR.ZAxis ^ CR.XAxis);
		CR.YAxis.Normalize();
		break;

	case SPR_AbsFacingVelocity:
		GetFaceCoords(A->Location, Render->Frame->Coords.Origin, Vel.SafeNormal(), CR);
		break;

	case SPR_RelFacingNormal:
		CR.XAxis = Render->Frame->Coords.ZAxis;
		CR.ZAxis = RotNormal;
		CR.ZAxis.Normalize();
		CR.YAxis = (CR.ZAxis ^ CR.XAxis);
		CR.YAxis.Normalize();
		break;

	default:
		GetFaceCoords(A->Location, Render->Frame->Coords.Origin, RotNormal.SafeNormal(), CR);
	}
	return (A->PRot / CR.OrthoRotation()).OrthoRotation();
}
