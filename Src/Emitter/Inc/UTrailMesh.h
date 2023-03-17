#pragma once

class EMITTER_API UTrailMesh : public UMesh
{
	DECLARE_CLASS(UTrailMesh, UMesh, CLASS_Transient | CLASS_NoUserCreate, Emitter)

	UTrailMesh()
		: UMesh()
	{}
	FBox GetRenderBoundingBox( const AActor* Owner, UBOOL Exact )
	{
		return reinterpret_cast<const AXTrailParticle*>(Owner)->Bounds;
	}
	void Serialize(FArchive& Ar)
	{
		guard(AXTrailParticle::Serialize);
		FName N = GetFName();
		Ar << N;
		unguard;
	}
};
