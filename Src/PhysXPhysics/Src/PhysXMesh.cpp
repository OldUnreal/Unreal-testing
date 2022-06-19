
#include "PhysXPhysics.h"

inline void AppendPoint(TArray<physx::PxVec3>& List, const FVector& P)
{
	physx::PxVec3 NewPoint = UEVectorToPX(P);
	for (INT i = 0; i < List.Num(); ++i)
		if ((List(i) - NewPoint).magnitudeSquared() < (UEScaleToPX * 0.1f))
			return;
	List.AddItem(NewPoint);
}

PX_MeshShape* UPhysXPhysics::CreateConvexMesh(FVector* Ptr, INT NumPts, UBOOL bMayMirror)
{
	guard(UPhysXPhysics::CreateConvexMesh);
	FINISH_PHYSX_THREAD;
	TArray<physx::PxVec3> Pts(NumPts);
	for (INT i = 0; i < NumPts; i++)
		Pts(i) = UEVectorToPX(Ptr[i]);

	physx::PxConvexMeshDesc MeshDesc;
	MeshDesc.points.stride = sizeof(physx::PxVec3);
	MeshDesc.points.count = NumPts;
	MeshDesc.points.data = &Pts(0);
	MeshDesc.flags = physx::PxConvexFlag::eCOMPUTE_CONVEX;

	physx::PxCooking* Cooker = UPhysXPhysics::GetCooker();
	UEMemoryStreamer buf;
	if (!Cooker || !Cooker->cookConvexMesh(MeshDesc, buf))
	{
		GLog->Logf(NAME_PhysX, TEXT("Unable to cook a convex mesh."));
		return NULL;
	}
	physx::PxConvexMesh* Result = UPhysXPhysics::physXScene->createConvexMesh(buf);

	if (!Result)
		return NULL;

	FPhysXMesh* CM = new FPhysXMesh(Result);
	if (bMayMirror)
	{
		for (INT i = 0; i < NumPts; i++)
			Pts(i).x = -Pts(i).x;

		buf.Reset();
		if (!Cooker->cookConvexMesh(MeshDesc, buf))
			GLog->Logf(NAME_PhysX, TEXT("Unable to cook a mirrored convex mesh."));
		else
		{
			Result = UPhysXPhysics::physXScene->createConvexMesh(buf);
			if(Result)
				CM->MirroredMesh = new FPhysXMesh(Result);
		}
	}
	return CM;
	unguard;
}
PX_MeshShape* UPhysXPhysics::CreateMultiConvexMesh(FConvexModel* ConvexMesh, UBOOL bMayMirror)
{
	guard(UPhysXPhysics::CreateMultiConvexMesh);
	FINISH_PHYSX_THREAD;
	TArray<physx::PxConvexMesh*> ConvexList;
	TArray<physx::PxVec3> Pts;
	INT i, j;

	physx::PxConvexMeshDesc MeshDesc;
	MeshDesc.points.stride = sizeof(physx::PxVec3);
	MeshDesc.flags = physx::PxConvexFlag::eCOMPUTE_CONVEX;
	physx::PxCooking* Cooker = UPhysXPhysics::GetCooker();
	INT NumFailed = 0;

	for (FConvexModel* C = ConvexMesh; C; C = C->Next)
	{
		Pts.Empty();
		for (i = 0; i < C->Faces.Num(); i++)
		{
			const FConvexFace& F = C->Faces(i);
			for (j = 0; j < F.Verts.Num(); ++j)
				AppendPoint(Pts, F.Verts(j));
		}
		if (Pts.Num() < 4)
			continue;

		MeshDesc.points.count = Pts.Num();
		MeshDesc.points.data = &Pts(0);

		UEMemoryStreamer buf;
		if (!Cooker || !Cooker->cookConvexMesh(MeshDesc, buf))
		{
			++NumFailed;
#if DO_GUARD_SLOW
			GLog->Logf(NAME_PhysX, TEXT("Unable to cook a convex mesh part."));
#endif
		}
		else
		{
			physx::PxConvexMesh* Result = UPhysXPhysics::physXScene->createConvexMesh(buf);
			if (Result)
				ConvexList.AddItem(Result);
		}
	}
#if DO_GUARD_SLOW
	if (NumFailed)
		GWarn->Logf(NAME_PhysX, TEXT("Built convex mesh (%i/%i convex parts failed)."), NumFailed, (NumFailed + ConvexList.Num()));
#endif

	if (ConvexList.Num())
		return new FPhysXMesh(ConvexList);
	return NULL;
	unguard;
}
PX_MeshShape* UPhysXPhysics::CreateTrisMesh(FVector* Ptr, INT NumPts, DWORD* Tris, INT NumTris, UBOOL bMayMirror)
{
	guard(UPhysXPhysics::CreateTrisMesh);
	FINISH_PHYSX_THREAD;
	TArray<physx::PxVec3> Pts(NumPts);
	for (INT i = 0; i < NumPts; i++)
		Pts(i) = UEVectorToPX(Ptr[i]);

	physx::PxTriangleMeshDesc MeshDesc;
	MeshDesc.flags = (physx::PxMeshFlag::Enum) NULL; // physx::PxMeshFlag::e16_BIT_INDICES;

	MeshDesc.points.stride = sizeof(physx::PxVec3);
	MeshDesc.points.count = Pts.Num();
	MeshDesc.points.data = Pts.GetData();

	MeshDesc.triangles.stride = sizeof(DWORD) * 3;
	MeshDesc.triangles.count = NumTris;
	MeshDesc.triangles.data = Tris;

	physx::PxTriangleMesh* Result;
	guard(CookTriangleMesh);
	physx::PxCooking* Cooker = UPhysXPhysics::GetCooker();
	UEMemoryStreamer buf;

	if (!Cooker || !Cooker->cookTriangleMesh(MeshDesc, buf))
	{
		GLog->Logf(NAME_PhysX, TEXT("Unable to cook a triangle mesh."));
		return NULL;
	}
	Result = UPhysXPhysics::physXScene->createTriangleMesh(buf);
	unguard;

	if (!Result)
		return NULL;
	return new FPhysXMesh(Result);
	unguard;
}

FPhysXMesh::FPhysXMesh(physx::PxConvexMesh* CMesh)
	: PX_MeshShape(RBSHAPE_Convex), Mesh(CMesh), MirroredMesh(NULL)
{
}
FPhysXMesh::FPhysXMesh(physx::PxTriangleMesh* TMesh)
	: PX_MeshShape(RBSHAPE_Tris), Mesh(TMesh), MirroredMesh(NULL)
{
}
FPhysXMesh::FPhysXMesh(TArray<physx::PxConvexMesh*>& ConvexArray)
	: PX_MeshShape(RBSHAPE_MultiConvex), Mesh(NULL), MirroredMesh(NULL)
{
	ConvexArray.ExchangeArray(&ConvexList);
	ConvexList.Shrink();
}

FPhysXMesh::~FPhysXMesh()
{
	guard(FPhysXMesh::~FPhysXMesh);
	if (MirroredMesh)
		delete MirroredMesh;

	FINISH_PHYSX_THREAD;
	if (Mesh)
		Mesh->release();
	for (INT i = 0; i < ConvexList.Num(); ++i)
		ConvexList(i)->release();
	unguard;
}
