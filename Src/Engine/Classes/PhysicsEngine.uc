//=============================================================================
// PhysicsEngine: The base class for a physics engine that should simulate rigidbodies.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
Class PhysicsEngine extends Subsystem
	native
	transient
	abstract;

// Scenes that should be ticked next tick.
var pointer<PX_SceneBase*> TickScenes;
var pointer<PX_MeshShape*> DefCylinder;

cpptext
{
	static UPhysicsEngine* GPhysicsEngine;

	UPhysicsEngine();
	
	virtual void InitEngine() {}
	virtual void ExitEngine() {}
	
	void Destroy();
	
	static void CreateDefaultCylinder(PX_PhysicsObject* Object, FLOAT Radius, FLOAT Height, class AZoneInfo* Zone);
	
	virtual UBOOL Exec(const TCHAR* Cmd, FOutputDevice& Out = *GLog);
	
	// Tick order is: PhysicsEngine.PreTick -> All tickable scenes.PreTickStep -> PhysicsEngine.Tick -> all other actors tick.
	virtual void PreTick();
	
	// Initialize level
	virtual PX_SceneBase* CreateScene( ULevel* Level );
	
	// Physics mesh creation.
	virtual PX_MeshShape* CreateConvexMesh(FVector* Ptr, INT NumPts, UBOOL bMayMirror) { return NULL; }
	virtual PX_MeshShape* CreateMultiConvexMesh(struct FConvexModel* ConvexMesh, UBOOL bMayMirror) { return NULL; }
	virtual PX_MeshShape* CreateTrisMesh(FVector* Ptr, INT NumPts, DWORD* Tris, INT NumTris, UBOOL bMayMirror) { return NULL; }
	
	// Shape creation.
	virtual void CreateBoxShape(const FShapeProperties& Props, const FVector& Extent) {}
	virtual void CreateSphereShape(const FShapeProperties& Props, FLOAT Radii) {}
	virtual void CreateCapsuleShape(const FShapeProperties& Props, FLOAT Height, FLOAT Radii) {}
	virtual void CreateMeshShape(const FShapeProperties& Props, PX_MeshShape* Mesh, const FVector& Scale=FVector(1,1,1)) {}
	
	// Joints.
	virtual UBOOL CreateJointFixed( const FJointBaseProps& Props ) { return FALSE; }
	virtual UBOOL CreateJointHinge( const FJointHingeProps& Props ) { return FALSE; }
	virtual UBOOL CreateJointSocket( const FJointSocketProps& Props ) { return FALSE; }
	virtual UBOOL CreateConstriant( const FJointConstProps& Props ) { return FALSE; }
}