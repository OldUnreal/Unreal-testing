
#include "PhysXPhysics.h"

#define PRE_INIT_SHAPE \
	FINISH_PHYSX_THREAD; \
	physx::PxRigidActor* rbA = GetRigidActor(Props.RbObject); \
	if(!rbA) return NULL; \
	physx::PxShape* ResultShape = NULL; \
	physx::PxMaterial* AllocMat = NULL; \
	physx::PxMaterial* UseMat = NULL; \
	if (Props.bUseDefault) \
		UseMat = UPhysXPhysics::DefaultMaterial; \
	else AllocMat = UseMat = UPhysXPhysics::physXScene->createMaterial(Props.Friction, Props.Friction, Props.Restitution);

#define CREATE_SHAPE \
	ResultShape = UPhysXPhysics::physXScene->createShape(Shape, *UseMat, true, (physx::PxShapeFlag::eSCENE_QUERY_SHAPE | physx::PxShapeFlag::eSIMULATION_SHAPE)); check(ResultShape!=NULL); \
	if(Props.Coords) \
		ResultShape->setLocalPose(UECoordsToPX(*Props.Coords)); \
	ResultShape->setSimulationFilterData(physx::PxFilterData(0, 0, 0, (Props.bContactReport ? ESHAPEFLAGS_ContactCallback : 0) | (Props.bModifyContact ? ESHAPEFLAGS_ContactModify : 0))); \
	rbA->attachShape(*ResultShape); \
	ResultShape->release();

#define POST_CREATE_SHAPE(ShClass) \
	if(AllocMat) \
		AllocMat->release(); \
	if(ResultShape) return new ShClass(Props, ResultShape, AllocMat); \
	return NULL;

#define POST_CREATE_SHAPE_SHORT \
	if(AllocMat) \
		AllocMat->release();

struct FBoxShape : public FPhysXShape
{
	DECLARE_PXSHAPE(FBoxShape);
};
PX_ShapeObject* UPhysXPhysics::CreateBoxShape(const FShapeProperties& Props, const FVector& Extent)
{
	guard(UPhysXPhysics::CreateBoxShape);
	PRE_INIT_SHAPE;
	physx::PxBoxGeometry Shape(UEVectorToPX(Extent * 0.5));
	CREATE_SHAPE;
	POST_CREATE_SHAPE(FBoxShape);
	unguard;
}

struct FSphereShape : public FPhysXShape
{
	DECLARE_PXSHAPE(FSphereShape);
};
PX_ShapeObject* UPhysXPhysics::CreateSphereShape(const FShapeProperties& Props, FLOAT Radii)
{
	guard(UPhysXPhysics::CreateSphereShape);
	PRE_INIT_SHAPE;
	physx::PxSphereGeometry Shape(Radii * UEScaleToPX);
	CREATE_SHAPE;
	POST_CREATE_SHAPE(FSphereShape);
	unguard;
}

struct FCapsuleShape : public FPhysXShape
{
	DECLARE_PXSHAPE(FCapsuleShape);
};
PX_ShapeObject* UPhysXPhysics::CreateCapsuleShape(const FShapeProperties& Props, FLOAT Height, FLOAT Radii)
{
	guard(UPhysXPhysics::CreateCapsuleShape);
	PRE_INIT_SHAPE;
	physx::PxCapsuleGeometry Shape(Radii * UEScaleToPX, Max(Height * UEScaleToPX, UEScaleToPX * 0.1f));
	CREATE_SHAPE;
	POST_CREATE_SHAPE(FCapsuleShape);
	unguard;
}

struct FMeshDebugInfo
{
private:
	FVector* VertList, * DrawList;
	INT* IndexList;
	INT NumLines, NumVerts;

public:
	FMeshDebugInfo(struct FMeshShape* Shape);
	~FMeshDebugInfo();

	void DrawDebug(const FCoords& Coords, const FPlane& ShapeColor);

	inline UBOOL ValidShape() const
	{
		return (NumLines > 0);
	}
};
struct FMeshShape : public FPhysXShape
{
	FMeshDebugInfo* DebugShape;

	FMeshShape(const FShapeProperties& Parms, physx::PxShape* Sh, physx::PxMaterial* LM)
		: FPhysXShape(Parms, Sh, LM)
		, DebugShape(nullptr)
	{}
	
	void DrawDebug(const FPlane& ShapeColor);

	~FMeshShape() noexcept(false);

	TArray<physx::PxShape*> ConvexShapes;
};
PX_ShapeObject* UPhysXPhysics::CreateMeshShape(const FShapeProperties& Props, PX_MeshShape* Mesh, const FVector& Scale)
{
	guard(UPhysXPhysics::CreateMeshShape);
	PRE_INIT_SHAPE;
	FPhysXMesh* P = reinterpret_cast<FPhysXMesh*>(Mesh);
	FMeshShape* MeshResult = NULL;
	switch (P->GetType())
	{
	case PX_MeshShape::RBSHAPE_Tris:
		{
			physx::PxTriangleMeshGeometry Shape(P->GetTriangle(), UENormalToPX(Scale));
			CREATE_SHAPE;
			MeshResult = new FMeshShape(Props, ResultShape, AllocMat);
			break;
		}
	case PX_MeshShape::RBSHAPE_Convex:
		{
			physx::PxConvexMeshGeometry Shape(P->GetConvex(), UENormalToPX(Scale));
			if (Scale.X < 0.f || Scale.Y < 0.f || Scale.Z < 0.f)
				GWarn->Logf(TEXT("Create inverted convex mesh (%f,%f,%f)"), Scale.X, Scale.Y, Scale.Z);
			CREATE_SHAPE;
			MeshResult = new FMeshShape(Props, ResultShape, AllocMat);
			break;
		}
	case PX_MeshShape::RBSHAPE_MultiConvex:
		{
			for (INT i = 0; i < P->ConvexList.Num(); ++i)
			{
				physx::PxConvexMeshGeometry Shape(P->ConvexList(i), UENormalToPX(Scale));
				CREATE_SHAPE;
				if (MeshResult)
				{
					ResultShape->userData = MeshResult;
					MeshResult->ConvexShapes.AddItem(ResultShape);
				}
				else
				{
					MeshResult = new FMeshShape(Props, ResultShape, AllocMat);
					if (P->ConvexList.Num() > 1)
						MeshResult->ConvexShapes.Empty(P->ConvexList.Num() - 1); // Slack
				}
			}
			break;
		}
	default:
		GWarn->Logf(NAME_PhysX, TEXT("CreateMeshShape with invalid mesh type!"));
	}
	POST_CREATE_SHAPE_SHORT;
	return MeshResult;
	unguard;
}

FPhysXShape::FPhysXShape(const FShapeProperties& Parms, physx::PxShape* Sh, physx::PxMaterial* LM)
	: PX_ShapeObject(Parms.bContactReport, Parms.Friction, Parms.Restitution, Parms.RbObject), Shape(Sh), LocalMateria(LM), UserData(NULL), bUseContactVelocity(FALSE)
{
	Sh->userData = this;
	if (Owner->GetType() == PX_PhysicsObject::ERBObjectType::RBTYPE_RigidBody)
		UserData = reinterpret_cast<FPhysXUserDataBase*>(GetRigidActor(Owner)->userData);
}
FPhysXShape::~FPhysXShape() noexcept(false)
{
	guard(FPhysXShape::~FPhysXShape);
	if (Owner)
	{
		FINISH_PHYSX_THREAD;
		GetRigidActor(Owner)->detachShape(*Shape);
	}
	unguard;
}
FMeshShape::~FMeshShape() noexcept(false)
{
	guard(FMeshShape::~FMeshShape);
	delete DebugShape;
	if (Owner && ConvexShapes.Num())
	{
		FINISH_PHYSX_THREAD;
		physx::PxRigidActor* rb = GetRigidActor(Owner);
		for (INT i = 0; i < ConvexShapes.Num(); ++i)
			rb->detachShape(*ConvexShapes(i));
	}
	unguard;
}

FCoords FPhysXShape::GetLocalPose()
{
	guard(FPhysXShape::GetLocalPose);
	FINISH_PHYSX_THREAD;
	return PXCoordsToUE(Shape->getLocalPose());
	unguard;
}
void FPhysXShape::SetContactNotify(UBOOL bEnable)
{
	guard(FPhysXShape::SetContactNotify);
	FINISH_PHYSX_THREAD;
	physx::PxFilterData FF = Shape->getSimulationFilterData();
	if (bEnable)
		FF.word3 |= ESHAPEFLAGS_ContactCallback;
	else FF.word3 &= ~ESHAPEFLAGS_ContactCallback;
	Shape->setSimulationFilterData(FF);
	unguard;
}
void FPhysXShape::SetFriction(FLOAT NewStatic, FLOAT NewDynmaic, FLOAT NewRestitution)
{
	guard(FPhysXShape::SetFriction);
	if (LocalMateria)
	{
		FINISH_PHYSX_THREAD;
		StaticFriction = NewStatic;
		DynamicFriction = NewDynmaic;
		Restitution = NewRestitution;
		LocalMateria->setStaticFriction(NewStatic);
		LocalMateria->setDynamicFriction(NewDynmaic);
		LocalMateria->setRestitution(NewRestitution);
		physx::PxModifiableContact C;
	}
	unguard;
}
void FPhysXShape::SetLocalPose(const FCoords& NewCoords)
{
	guard(FPhysXShape::SetLocalPose);
	FINISH_PHYSX_THREAD;
	Shape->setLocalPose(UECoordsToPX(NewCoords));
	unguard;
}
void FPhysXShape::SetContactVelocity(const FVector& NewCVelocity)
{
	guard(FPhysXShape::SetContactVelocity);
	FINISH_PHYSX_THREAD;
	if (NewCVelocity.IsZero())
	{
		ContactVelocity = FVector(0.f, 0.f, 0.f);
		CurContactVelocity = physx::PxVec3(physx::PxZERO::PxZero);
		bUseContactVelocity = FALSE;
	}
	else
	{
		/*FCoords C = PXCoordsToUE(GetRigidActor(Owner)->getGlobalPose());
		C = PXCoordsToUE(Shape->getLocalPose()) * C.Transpose();
		new FDebugLineData(C.Origin, C.Origin + NewCVelocity, FPlane(1, 0, 0, 1));*/

		ContactVelocity = NewCVelocity;
		CurContactVelocity = UEVectorToPX(NewCVelocity);
		bUseContactVelocity = TRUE;

		// This flag should been set in advance, but just in case...
		physx::PxFilterData FF = Shape->getSimulationFilterData();
		FF.word3 |= ESHAPEFLAGS_ContactModify;
		Shape->setSimulationFilterData(FF);
	}
	unguard;
}

// NOTE: This callback is done during simulation thread, so mus treat this information carefully!
UBOOL FPhysXShape::OnContact(const physx::PxVec3& Location, const physx::PxVec3& Normal)
{
	guardSlow(FPhysXShape::OnContact);
	if (UserData)
	{
		bPendingContact = TRUE;
		PendingLocation = Location;
		PendingNormal = Normal;
		UserData->bShapeQuery = TRUE;
	}
	return !bContactNotifyActor;
	unguardSlow;
}

static void DrawBoxGeom(const FCoords& C, const FVector& Extent, const FPlane& ShapeColor)
{
	FDebugLineData::DrawTransformedBox(-Extent, Extent, C.Transpose(), ShapeColor);
}
static void DrawCapsuleGeom(const FCoords& C, FLOAT Height, FLOAT Radius, const FPlane& ShapeColor)
{
	if (Height < 0.1f)
	{
		FDebugLineData::DrawSphere(C.Origin, Radius, 8, ShapeColor);
		return;
	}
	constexpr INT DetailSides = 8;
	constexpr INT SinMulti = (65536 / (DetailSides * 2));
	FVector Points[DetailSides * 4];
	INT i;

	constexpr INT SideA = 0;
	constexpr INT SideB = DetailSides;
	constexpr INT SideC = (DetailSides * 2);
	constexpr INT SideD = (DetailSides * 3);
	constexpr INT SideAE = SideA + DetailSides - 1;
	constexpr INT SideBE = SideB + DetailSides - 1;
	constexpr INT SideCE = SideC + DetailSides - 1;
	constexpr INT SideDE = SideD + DetailSides - 1;

	// Set edges
	Points[SideA] = FVector(Height, Radius, 0.f);
	Points[SideAE] = FVector(Height, -Radius, 0.f);
	Points[SideB] = FVector(Height, 0.f, Radius);
	Points[SideBE] = FVector(Height, 0.f, -Radius);
	Points[SideC] = FVector(-Height, -Radius, 0.f);
	Points[SideCE] = FVector(-Height, Radius, 0.f);
	Points[SideD] = FVector(-Height, 0.f, -Radius);
	Points[SideDE] = FVector(-Height, 0.f, Radius);

	// Calc rounded edges
	for (i = 1; i < (DetailSides - 1); ++i)
	{
		const FLOAT SinValue = GMath.SinTab(i * SinMulti) * Radius;
		const FLOAT CosValue = GMath.CosTab(i * SinMulti) * Radius;
		Points[i + SideA] = FVector(Height + SinValue, CosValue, 0.f);
		Points[i + SideB] = FVector(Height + SinValue, 0.f, CosValue);
		Points[i + SideC] = FVector(-Height - SinValue, -CosValue, 0.f);
		Points[i + SideD] = FVector(-Height - SinValue, 0.f, -CosValue);
	}

	FCoords NC = C.Transpose();
	for (i = 0; i < DetailSides * 4; ++i)
		Points[i] = Points[i].TransformPointBy(NC);

	constexpr INT TotalPoints = (((DetailSides - 1) * 4) + 4);
	FDebugLineData::FLinePair* RendPoints = new FDebugLineData::FLinePair[TotalPoints];

	constexpr INT RSideA = 0;
	constexpr INT RSideB = (DetailSides - 1);
	constexpr INT RSideC = (DetailSides - 1) * 2;
	constexpr INT RSideD = (DetailSides - 1) * 3;
	constexpr INT Edges = (DetailSides - 1) * 4;

	for (i = 0; i < (DetailSides - 1); ++i)
	{
		RendPoints[i + RSideA].Set(Points[i + SideA], Points[i + SideA + 1]);
		RendPoints[i + RSideB].Set(Points[i + SideB], Points[i + SideB + 1]);
		RendPoints[i + RSideC].Set(Points[i + SideC], Points[i + SideC + 1]);
		RendPoints[i + RSideD].Set(Points[i + SideD], Points[i + SideD + 1]);
	}

	RendPoints[Edges].Set(Points[SideA],Points[SideCE]);
	RendPoints[Edges + 1].Set(Points[SideB], Points[SideDE]);
	RendPoints[Edges + 2].Set(Points[SideAE], Points[SideC]);
	RendPoints[Edges + 3].Set(Points[SideBE], Points[SideD]);

	FDebugLineData::DrawLineList(RendPoints, TotalPoints, ShapeColor);
}

#define RPE_DRAW_SHAPE \
	FINISH_PHYSX_THREAD; \
	FCoords C = PXCoordsToUE(GetRigidActor(Owner)->getGlobalPose()); \
	FDebugLineData::DrawLine(FDebugLineData::FLinePair(C.Origin, C.Origin + C.XAxis * 4.f), FPlane(0, 1, 0, 1)); \
	FDebugLineData::DrawLine(FDebugLineData::FLinePair(C.Origin, C.Origin + C.YAxis * 4.f), FPlane(1, 0, 0, 1)); \
	FDebugLineData::DrawLine(FDebugLineData::FLinePair(C.Origin, C.Origin + C.ZAxis * 4.f), FPlane(0, 0, 1, 1)); \
	C = C.Transpose(); \
	FCoords LC = PXCoordsToUE(Shape->getLocalPose()) * C; \
	physx::PxGeometryHolder Geom = Shape->getGeometry()

void FBoxShape::DrawDebug(const FPlane& ShapeColor)
{
	guard(FBoxShape::DrawDebug);
	RPE_DRAW_SHAPE;

	DrawBoxGeom(LC, PXVectorToUE(Geom.box().halfExtents), ShapeColor);
	unguard;
}
void FSphereShape::DrawDebug(const FPlane& ShapeColor)
{
	guard(FSphereShape::DrawDebug);
	RPE_DRAW_SHAPE;

	FDebugLineData::DrawSphere(LC.Origin, Geom.sphere().radius * PXScaleToUE, 8, ShapeColor);
	unguard;
}
void FCapsuleShape::DrawDebug(const FPlane& ShapeColor)
{
	guard(FCapsuleShape::DrawDebug);
	RPE_DRAW_SHAPE;

	DrawCapsuleGeom(LC, Geom.capsule().halfHeight * PXScaleToUE, Geom.capsule().radius * PXScaleToUE, ShapeColor);
	unguard;
}

struct FVertexPoolCollector
{
	TArray<FVector> Verts;
	TArray<INT> Indices;

private:
	inline INT GetPoint(const FVector& V) const
	{
		for (INT i = 0; i < Verts.Num(); ++i)
			if (V.DistSquared(Verts(i)) < 1.f)
				return i;
		return INDEX_NONE;
	}
public:
	inline void AddLine(const FVector& A, const FVector& B)
	{
		if (A.DistSquared(B) < 1.f) // overlaps with self.
			return;
		INT pA, pB;
		pA = GetPoint(A);
		pB = GetPoint(B);
		if (pA == pB && pA != INDEX_NONE) // overlaps with another line...
			return;
		if (pA == INDEX_NONE)
			pA = Verts.AddItem(A);
		if (pB == INDEX_NONE)
			pB = Verts.AddItem(B);
		Indices.AddItem(pA);
		Indices.AddItem(pB);
	}
};

static void GetConvexMesh(const FVector& Scale, physx::PxConvexMesh* Mesh, FVertexPoolCollector& Pool)
{
	guardSlow(GetConvexMesh);
	FScopedMemMark Scope(GMem);
	INT i, j;
	const INT NumVerts = Mesh->getNbVertices();
	const INT NumPolies = Mesh->getNbPolygons();
	const physx::PxVec3* Verts = Mesh->getVertices();
	FVector* TVerts = New<FVector>(GMem, NumVerts);
	for (i = 0; i < NumVerts; ++i)
		TVerts[i] = (PXVectorToUE(Verts[i]) * Scale);

	const physx::PxU8* IndexBuffer = Mesh->getIndexBuffer();

	physx::PxHullPolygon Hull;
	for (i = 0; i < NumPolies; ++i)
	{
		Mesh->getPolygonData(i, Hull);
		const physx::PxU8* Ref = &IndexBuffer[Hull.mIndexBase];
		for (j = 1; j < Hull.mNbVerts; ++j)
			Pool.AddLine(TVerts[Ref[j - 1]], TVerts[Ref[j]]);
		Pool.AddLine(TVerts[Ref[0]], TVerts[Ref[Hull.mNbVerts - 1]]);
	}
	unguardSlow;
}
static void GetTrisMesh(const FVector& Scale, physx::PxTriangleMesh* Mesh, FVertexPoolCollector& Pool)
{
	guardSlow(GetTrisMesh);
	FScopedMemMark Scope(GMem);
	INT i;
	const INT NumVerts = Mesh->getNbVertices();
	const physx::PxVec3* Verts = Mesh->getVertices();
	FVector* TVerts = New<FVector>(GMem, NumVerts);
	for (i = 0; i < NumVerts; ++i)
		TVerts[i] = (PXVectorToUE(Verts[i]) * Scale);

	const INT NumPolies = Mesh->getNbTriangles();
	const physx::PxU32* TriMap = Mesh->getTrianglesRemap();

	if (Mesh->getTriangleMeshFlags() & physx::PxTriangleMeshFlag::e16_BIT_INDICES)
	{
		const _WORD* Tris = reinterpret_cast<const _WORD*>(Mesh->getTriangles());
		for (i = 0; i < NumPolies; ++i, Tris += 3)
		{
			if (TriMap)
			{
				Pool.AddLine(TVerts[TriMap[Tris[0]]], TVerts[TriMap[Tris[1]]]);
				Pool.AddLine(TVerts[TriMap[Tris[1]]], TVerts[TriMap[Tris[2]]]);
				Pool.AddLine(TVerts[TriMap[Tris[2]]], TVerts[TriMap[Tris[0]]]);
			}
			else
			{
				Pool.AddLine(TVerts[Tris[0]], TVerts[Tris[1]]);
				Pool.AddLine(TVerts[Tris[1]], TVerts[Tris[2]]);
				Pool.AddLine(TVerts[Tris[2]], TVerts[Tris[0]]);
			}
		}
	}
	else
	{
		const DWORD* Tris = reinterpret_cast<const DWORD*>(Mesh->getTriangles());
		for (i = 0; i < NumPolies; ++i, Tris += 3)
		{
			if (TriMap)
			{
				Pool.AddLine(TVerts[TriMap[Tris[0]]], TVerts[TriMap[Tris[1]]]);
				Pool.AddLine(TVerts[TriMap[Tris[1]]], TVerts[TriMap[Tris[2]]]);
				Pool.AddLine(TVerts[TriMap[Tris[2]]], TVerts[TriMap[Tris[0]]]);
			}
			else
			{
				Pool.AddLine(TVerts[Tris[0]], TVerts[Tris[1]]);
				Pool.AddLine(TVerts[Tris[1]], TVerts[Tris[2]]);
				Pool.AddLine(TVerts[Tris[2]], TVerts[Tris[0]]);
			}
		}
	}
	unguardSlow;
}

FMeshDebugInfo::FMeshDebugInfo(struct FMeshShape* Shape)
{
	guard(FMeshDebugInfo::FMeshDebugInfo);
	FVertexPoolCollector Collector;
	const INT MaxIndex = Shape->ConvexShapes.Num();

	for (INT i = INDEX_NONE; i < MaxIndex; ++i)
	{
		physx::PxShape* S = (i == INDEX_NONE) ? Shape->Shape : Shape->ConvexShapes(i);
		physx::PxGeometryType::Enum Type = S->getGeometryType();
		physx::PxGeometryHolder Geom = S->getGeometry();
		
		if (Type == physx::PxGeometryType::eCONVEXMESH)
			GetConvexMesh(PXNormalToUE(Geom.convexMesh().scale.scale), Geom.convexMesh().convexMesh, Collector);
		else if (Type == physx::PxGeometryType::eTRIANGLEMESH)
			GetTrisMesh(PXNormalToUE(Geom.triangleMesh().scale.scale), Geom.triangleMesh().triangleMesh, Collector);
	}

	if (!Collector.Indices.Num()) // Invalid shape.
	{
		VertList = nullptr;
		DrawList = nullptr;
		IndexList = nullptr;
		NumVerts = NumLines = 0;
		return;
	}

	VertList = new FVector[Collector.Verts.Num()];
	DrawList = new FVector[Collector.Verts.Num()];
	IndexList = new INT[Collector.Indices.Num()];

	appMemcpy(VertList, &Collector.Verts(0), sizeof(FVector) * Collector.Verts.Num());
	appMemcpy(IndexList, &Collector.Indices(0), sizeof(INT) * Collector.Indices.Num());

	NumVerts = Collector.Verts.Num();
	NumLines = Collector.Indices.Num() >> 1;
	unguard;
}
FMeshDebugInfo::~FMeshDebugInfo()
{
	delete[] VertList;
	delete[] DrawList;
	delete[] IndexList;
}

void FMeshDebugInfo::DrawDebug(const FCoords& Coords, const FPlane& ShapeColor)
{
	guardSlow(FMeshDebugInfo::DrawDebug);
	INT i;
	for (i = 0; i < NumVerts; ++i)
		DrawList[i] = VertList[i].TransformPointBy(Coords);

	FDebugLineData::FLinePair* Lines = new FDebugLineData::FLinePair[NumLines];
	for (INT* iVert = IndexList, i = 0; i < NumLines; ++i, iVert += 2)
		Lines[i].Set(DrawList[iVert[0]], DrawList[iVert[1]]);
	FDebugLineData::DrawLineList(Lines, NumLines, ShapeColor);
	unguardSlow;
}

void FMeshShape::DrawDebug(const FPlane& ShapeColor)
{
	guard(FMeshShape::DrawDebug);
	RPE_DRAW_SHAPE;

	if (!DebugShape)
		DebugShape = new FMeshDebugInfo(this);
	if (DebugShape->ValidShape())
		DebugShape->DrawDebug(LC.Transpose(), ShapeColor);
	unguard;
}

void FPhysXActorBase::DrawRbShapes(const PX_PhysicsObject& Object, const FPlane& ShapeColor)
{
	guard(FPhysXActorBase::DrawRbShapes);
	for (FPhysXShape* S = reinterpret_cast<FPhysXShape*>(Object.GetShapes()); S; S = reinterpret_cast<FPhysXShape*>(S->GetNext()))
		S->DrawDebug(ShapeColor);
	unguard;
}
