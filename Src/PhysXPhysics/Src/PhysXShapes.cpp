
#include "PhysXPhysics.h"

#define PRE_INIT_SHAPE \
	FINISH_PHYSX_THREAD; \
	physx::PxRigidActor* rbA = GetRigidActor(Props.RbObject); \
	if(!rbA) return; \
	physx::PxMaterial* AllocMat = NULL; \
	physx::PxMaterial* UseMat = NULL; \
	if (Props.bUseDefault) \
		UseMat = UPhysXPhysics::DefaultMaterial; \
	else AllocMat = UseMat = UPhysXPhysics::physXScene->createMaterial(Props.Friction, Props.Friction, Props.Restitution);

#define CREATE_SHAPE \
	physx::PxShape* Sh = UPhysXPhysics::physXScene->createShape(Shape, *UseMat, true, (physx::PxShapeFlag::eSCENE_QUERY_SHAPE | physx::PxShapeFlag::eSIMULATION_SHAPE)); check(Sh!=NULL); \
	if(Props.Coords) \
		Sh->setLocalPose(UECoordsToPX(*Props.Coords)); \
	rbA->attachShape(*Sh); \
	Sh->release();

#define POST_CREATE_SHAPE if(AllocMat) AllocMat->release();

void UPhysXPhysics::CreateBoxShape(const FShapeProperties& Props, const FVector& Extent)
{
	guard(UPhysXPhysics::CreateBoxShape);
	PRE_INIT_SHAPE;
	physx::PxBoxGeometry Shape(UEVectorToPX(Extent * 0.5));
	CREATE_SHAPE;
	POST_CREATE_SHAPE;
	unguard;
}
void UPhysXPhysics::CreateSphereShape(const FShapeProperties& Props, FLOAT Radii)
{
	guard(UPhysXPhysics::CreateSphereShape);
	PRE_INIT_SHAPE;
	physx::PxSphereGeometry Shape(Radii * UEScaleToPX);
	CREATE_SHAPE;
	POST_CREATE_SHAPE;
	unguard;
}
void UPhysXPhysics::CreateCapsuleShape(const FShapeProperties& Props, FLOAT Height, FLOAT Radii)
{
	guard(UPhysXPhysics::CreateCapsuleShape);
	PRE_INIT_SHAPE;
	physx::PxCapsuleGeometry Shape(Radii * UEScaleToPX, Max((Height * 2) * UEScaleToPX, UEScaleToPX * 0.1f));
	CREATE_SHAPE;
	POST_CREATE_SHAPE;
	unguard;
}
void UPhysXPhysics::CreateMeshShape(const FShapeProperties& Props, PX_MeshShape* Mesh, const FVector& Scale)
{
	guard(UPhysXPhysics::CreateMeshShape);
	PRE_INIT_SHAPE;
	FPhysXMesh* P = reinterpret_cast<FPhysXMesh*>(Mesh);
	switch (P->GetType())
	{
	case PX_MeshShape::RBSHAPE_Tris:
		{
			physx::PxTriangleMeshGeometry Shape(P->GetTriangle(), UENormalToPX(Scale));
			CREATE_SHAPE;
			break;
		}
	case PX_MeshShape::RBSHAPE_Convex:
		{
			physx::PxConvexMeshGeometry Shape(P->GetConvex(), UENormalToPX(Scale));
			if (Scale.X < 0.f || Scale.Y < 0.f || Scale.Z < 0.f)
				GWarn->Logf(TEXT("Create inverted convex mesh (%f,%f,%f)"), Scale.X, Scale.Y, Scale.Z);
			CREATE_SHAPE;
			break;
		}
	case PX_MeshShape::RBSHAPE_MultiConvex:
		{
			for (INT i = 0; i < P->ConvexList.Num(); ++i)
			{
				physx::PxConvexMeshGeometry Shape(P->ConvexList(i), UENormalToPX(Scale));
				CREATE_SHAPE;
			}
			break;
		}
	default:
		GWarn->Logf(NAME_PhysX, TEXT("CreateMeshShape with invalid mesh type!"));
	}
	POST_CREATE_SHAPE;
	unguard;
}
