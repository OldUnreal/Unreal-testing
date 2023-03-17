	AXRopeDeco() {}
	
	void PostBeginPlay();
	void PostLoad();
	void Spawned();
	void Serialize(FArchive& Ar);
	void PostScriptDestroyed();
	void RenderSelectInfo(FSceneNode* Frame);
	void NoteDuplicate(AActor* Src);
	void onPropertyChange(UProperty* Property, UProperty* OuterProperty);
	FVector GetEndOffset();
	void SoftwareCalcRope();
	void SyncRBRope();
	void InitRbPhysics();
	BYTE GetSplitOffset() const;