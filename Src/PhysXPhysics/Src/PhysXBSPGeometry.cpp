
#include "PhysXPhysics.h"

// Loading API
uint32_t UEMemoryStreamer::read(void* dest, uint32_t count)
{
	ReadOffset += count;
	appMemcpy(dest, &Buffer(ReadOffset - count), count);
	return count;
}

// Saving API
uint32_t UEMemoryStreamer::write(const void* src, uint32_t count)
{
	INT Offset = Buffer.Add(count);
	appMemcpy(&Buffer(Offset), src, count);
	return count;
}

struct FBSPTriangle
{
	physx::PxU32 Verts[3];
	FBSPTriangle(INT A, INT B, INT C)
	{
		Verts[0] = A;
		Verts[1] = B;
		Verts[2] = C;
	}
	inline void MirrorSurf()
	{
		Exchange(Verts[0], Verts[2]);
	}
};

struct FBSPGatherer
{
	UModel* Model;
	FPhysXScene* Scene;
	TArray<FBSPTriangle> Tris;
	TArray<physx::PxMaterialTableIndex> Materials;
	AZoneInfo* DefaultZone;
	AZoneInfo* PrevZone;
	physx::PxMaterialTableIndex PrevIndex;
	UBOOL bBuildMaterials;

	FBSPGatherer(UModel* M, FPhysXScene* S, AZoneInfo* Z, UBOOL bBuildMat)
		: Model(M), Scene(S), DefaultZone(Z), PrevZone(NULL), bBuildMaterials(bBuildMat)
	{}
	void RecurseBSP(INT iNode)
	{
		while (iNode != INDEX_NONE)
		{
			const FBspNode& curNode = Model->Nodes(iNode);
			//if (!BTrack || !BTrack->SurfIsDynamic(M->Nodes(Index).iSurf))
			{
				INT iCoplanar = iNode;
				while (iCoplanar != INDEX_NONE)
				{
					const FBspNode& PlaneNode = Model->Nodes(iCoplanar);
					const FBspSurf& Surf = Model->Surfs(PlaneNode.iSurf);
					
					if ((PlaneNode.NumVertices > 0) && !(Surf.PolyFlags & PF_NotSolid))
					{
						if (bBuildMaterials)
						{
							AZoneInfo* Z = (PlaneNode.iZone[1] < FBspNode::MAX_ZONES) ? Model->Zones[PlaneNode.iZone[1]].ZoneActor : NULL;
							if (!Z)
								Z = DefaultZone;
							if (PrevZone != Z)
							{
								PrevZone = Z;
								PrevIndex = Scene->GetBSPMaterialFriction(Z->ZoneGroundFriction);
							}
						}
						FVert* GVerts = &Model->Verts(PlaneNode.iVertPool);

						for (INT i = 2; i < PlaneNode.NumVertices; i++)
						{
							if (bBuildMaterials)
								Materials.AddItem(PrevIndex);
							Tris.AddItem(FBSPTriangle(GVerts[0].pVertex, GVerts[i - 1].pVertex, GVerts[i].pVertex));
						}
					}
					iCoplanar = PlaneNode.iPlane;
				}
			}
			if (curNode.iBack != INDEX_NONE)
				RecurseBSP(curNode.iBack);
			iNode = curNode.iFront;
		}
	}
	inline void Mirror()
	{
		for (INT i = 0; i < Tris.Num(); i++)
			Tris(i).MirrorSurf();
	}
};

physx::PxTriangleMesh* FPhysXScene::CreateBSPModel(UModel* Model)
{
	guard(FPhysXScene::CreateBSPModel);

	// Build physical model
	FBSPGatherer BSP(Model, this, Level->GetLevelInfo(), TRUE);
	guard(GatherBSP);
	BSP.RecurseBSP(0);
	unguard;

	if (!BSP.Tris.Num())
		return nullptr; // Not enough surfs.

	//if (bMirror)
	//	BSP.Mirror();

	TArray<physx::PxVec3> Pts(Model->Points.Num());
	for (INT i = 0; i < Model->Points.Num(); i++)
		Pts(i) = UEVectorToPX(Model->Points(i));

	physx::PxTriangleMeshDesc BSPDesc;
	BSPDesc.materialIndices.data = &BSP.Materials(0);
	BSPDesc.materialIndices.stride = sizeof(physx::PxMaterialTableIndex);

	BSPDesc.points.stride = sizeof(physx::PxVec3);
	BSPDesc.points.count = Pts.Num();
	BSPDesc.points.data = Pts.GetData();

	BSPDesc.triangles.stride = sizeof(FBSPTriangle);
	BSPDesc.triangles.count = BSP.Tris.Num();
	BSPDesc.triangles.data = BSP.Tris.GetData();

	physx::PxTriangleMesh* Result;
	guard(CookTriangleMesh);
	physx::PxCooking* Cooker = UPhysXPhysics::GetCooker();
	UEMemoryStreamer buf;

	if (!Cooker || !Cooker->cookTriangleMesh(BSPDesc, buf))
	{
		GLog->Logf(NAME_PhysX, TEXT("Unable to cook a triangle mesh for %ls."), Model->GetFullName());
		return nullptr;
	}
	Result = UPhysXPhysics::physXScene->createTriangleMesh(buf);
	unguard;

	return Result;
	unguard;
}

physx::PxCooking* UPhysXPhysics::physxCooker = NULL;
physx::PxCooking* UPhysXPhysics::GetCooker()
{
	guard(UPhysXPhysics::GetCooker);
	if (bEngineRunning)
	{
		if (!physxCooker)
		{
			physx::PxCookingParams CKParms(physXScene->getTolerancesScale());
			CKParms.suppressTriangleMeshRemapTable = true;
			physxCooker = PxCreateCooking(PX_PHYSICS_VERSION, physXScene->getFoundation(), CKParms);
		}
		return physxCooker;
	}
	return NULL;
	unguard;
}

physx::PxMaterialTableIndex FPhysXScene::GetBSPMaterialFriction(FLOAT Friction)
{
	guard(FPhysXScene::GetBSPMaterialFriction);
	FLOAT RFrict = Clamp<FLOAT>(Friction * (0.5f / 4.f), 0.f, 2.f);
	DWORD FrictWord = appFloor(((DOUBLE)RFrict) * 1073741824.0);

	{
		physx::PxMaterialTableIndex* MI = ZoneMaterials.Find(FrictWord);
		if (MI)
			return *MI;
	}

	physx::PxMaterialTableIndex IX = Materials.AddItem(UPhysXPhysics::physXScene->createMaterial(RFrict, RFrict, 0.3f));
	ZoneMaterials.Set(FrictWord, IX);
	return IX;
	unguard;
}
