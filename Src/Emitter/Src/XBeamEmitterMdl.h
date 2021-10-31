
class EMITTER_API UBeamMesh : public UStaticMesh
{
	DECLARE_CLASS(UBeamMesh,UStaticMesh,CLASS_Transient,Emitter)

	AXParticleEmitter* RenOwner;
	BYTE OldSegmentsCount;
	FLOAT OldUV[4];

	// UObject interface.
	UBeamMesh()
		: UStaticMesh(),OldSegmentsCount(255)
	{
		bCurvyMesh = 0;
		Textures.Empty();
		Textures.AddItem(FindObjectChecked<UTexture>(ANY_PACKAGE,TEXT("Engine.DefaultTexture")));
		Textures.AddZeroed(2);
		TextureLOD.Empty();
		TextureLOD.Add(1);
		SMGroups.Empty();
		for( BYTE i=0; i<3; ++i )
		{
			FStaticMeshTexGroup& G = SMGroups(SMGroups.Add());
			G.RealPolyFlags = PF_TwoSided;
			G.Texture = i;
		}
	}

	UTexture* GetTexture( INT Count, AActor* Owner )
	{
		if( Count )
			return (Owner->MultiSkins[Count-1] ? Owner->MultiSkins[Count-1] : Textures(0));
		return (Owner->Texture ? Owner->Texture : Textures(0));
	}
	void SetSegments( BYTE Count, FLOAT TexCrds[4], UTexture* Start, UTexture* End );
	FBox GetRenderBoundingBox( const AActor* Owner, UBOOL Exact );
	void GetFrame( FVector* Verts, INT Size, FCoords Coords, AActor* Owner, INT* LODFactor=NULL );
	void Serialize( FArchive& Ar )
	{
		UObject::Serialize(Ar); // Serialize nothing from StaticMesh
	}
};
IMPLEMENT_CLASS(UBeamMesh);

void UBeamMesh::SetSegments( BYTE Count, FLOAT TexCrds[4], UTexture* Start, UTexture* End )
{
	Count = Min<INT>(Count,200);
	if( OldSegmentsCount==Count && OldUV==TexCrds )
		return;
	appMemcpy(OldUV,TexCrds,sizeof(OldUV));
	OldSegmentsCount = Count;
	FrameVerts = Count*2+4;

	INT FaceCount = (Count ? (((Count-1)*2)+4) : 2);
	SMTris.Empty();
	SMTris.Add(FaceCount);
	Connects.Empty();
	Connects.Add(FrameVerts);
	for( INT j=0; j<FrameVerts; ++j )
	{
		Connects(j).TriangleListOffset = 0;
		Connects(j).NumVertTriangles = 1;
	}
	VertLinks.Empty();
	VertLinks.AddItem(0);
	SBYTE AddCount = 1;
	if( Start )
		AddCount--;
	if( End )
		AddCount--;
	FLOAT uDiv = TexCrds[0]/FLOAT(Count+AddCount);
	FLOAT UStart = TexCrds[2];
	FLOAT U = UStart+uDiv;

	for( INT i=0; i<FaceCount; ++i )
	{
		FStaticMeshTri& Tri = SMTris(i);
		Tri.GroupIndex = 0;
		if( Start && i<2 )
			Tri.GroupIndex = 1;
		else if( End && i>=(FaceCount-2) )
			Tri.GroupIndex = 2;
		if( !(i & 1) )
		{
			Tri.iVertex[0] = i;
			Tri.iVertex[1] = i+1;
			Tri.iVertex[2] = i+2;
			if( Tri.GroupIndex )
			{
				Tri.Tex[0].U = 0;
				Tri.Tex[0].V = 1;
				Tri.Tex[1].U = 0;
				Tri.Tex[1].V = 0;
				Tri.Tex[2].U = 1;
				Tri.Tex[2].V = 1;
			}
			else
			{
				Tri.Tex[0].U = UStart;
				Tri.Tex[0].V = TexCrds[1];
				Tri.Tex[1].U = UStart;
				Tri.Tex[1].V = TexCrds[3];
				Tri.Tex[2].U = U;
				Tri.Tex[2].V = TexCrds[1];
			}
		}
		else
		{
			Tri.iVertex[0] = i;
			Tri.iVertex[1] = i+2;
			Tri.iVertex[2] = i+1;
			if( Tri.GroupIndex )
			{
				Tri.Tex[0].U = 0;
				Tri.Tex[0].V = 0;
				Tri.Tex[1].U = 1;
				Tri.Tex[1].V = 0;
				Tri.Tex[2].U = 1;
				Tri.Tex[2].V = 1;
			}
			else
			{
				Tri.Tex[0].U = UStart;
				Tri.Tex[0].V = TexCrds[3];
				Tri.Tex[1].U = U;
				Tri.Tex[1].V = TexCrds[3];
				Tri.Tex[2].U = U;
				Tri.Tex[2].V = TexCrds[1];
				UStart = U;
				U+=uDiv;
			}
		}
	}
}
FBox UBeamMesh::GetRenderBoundingBox( const AActor* Owner, UBOOL Exact )
{
	return *(FBox*)&Owner->RotationRate; // Just use unused memory data for bounding box.
}
void UBeamMesh::GetFrame( FVector* Verts, INT Size, FCoords Coords, AActor* Owner, INT* LODFactor)
{
	RenOwner->GetBeamFrame(Verts,Size,Coords,Owner,FrameVerts);
}
static UBeamMesh* GetBeamingModel( AXParticleEmitter* RenderOwner )
{
	UBeamMesh* NewBeam = FindObject<UBeamMesh>(RenderOwner,UBeamMesh::StaticClass()->GetName(),1);
	if( !NewBeam )
		NewBeam = new(RenderOwner,UBeamMesh::StaticClass()->GetFName())UBeamMesh();
	NewBeam->RenOwner = RenderOwner;
	return NewBeam;
}
