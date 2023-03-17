#pragma once

class EMITTER_API UBeamMesh : public UStaticMesh
{
	DECLARE_CLASS(UBeamMesh,UStaticMesh,CLASS_Transient,Emitter)

	AXBeamEmitter* RenOwner;
	BYTE OldSegmentsCount;
	FLOAT OldUV[4];
	TArray<FLOAT> SegmentScales;

	// UObject interface.
	UBeamMesh();
	UTexture* GetTexture( INT Count, AActor* Owner );
	void SetSegments( BYTE Count, FLOAT TexCrds[4], UTexture* Start, UTexture* End );
	FBox GetRenderBoundingBox( const AActor* Owner, UBOOL Exact );
	void GetFrame( FVector* Verts, INT Size, FCoords Coords, AActor* Owner, INT* LODFactor=NULL );
	void Serialize( FArchive& Ar );
};
