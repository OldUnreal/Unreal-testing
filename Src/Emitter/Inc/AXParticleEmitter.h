/*=============================================================================
	AXParticleEmitter.h.
=============================================================================*/
	AXParticleEmitter() {}
	virtual void InitializeEmitter(AXParticleEmitter* Parent);
	virtual void RelinkChildEmitters();
	virtual void UpdateEmitter(FLOAT DeltaTime, UEmitterRendering* Render, UBOOL bSkipChildren) {}
	void PostEditChange();
	virtual void ResetEmitter() {}
	virtual void KillEmitter();
	virtual UBOOL ShouldRenderEmitter(FSceneNode* Frame) { return TRUE; }
	virtual UBOOL ShouldUpdateEmitter(FSceneNode* Frame) { return TRUE; }
	virtual void ResetVars();
	virtual void DrawPartCoronas(FSceneNode* Frame, FLOAT Delta, AXParticleEmitter* Parent) {}
	void PostNetReceive();
	UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
	void PostScriptDestroyed();
	virtual void InitView() {}
	virtual class FParticlesDataBase* GetParticleInterface();
	static void SpawnChildPart( const FVector& Pos, TArray<class AXEmitter*>& PartIdx );
	void UpdateChildren(FLOAT Delta, UEmitterRendering* Render);
	AActor* GetRenderList(AActor* LastDrawn);
	UBOOL HasAliveParticles();
	virtual void DestroyCombiners();
	virtual FLOAT GetMaxLifeTime() const;
	virtual void RespawnEmitter();

	void Serialize(FArchive& Ar);
	void ScriptDestroyed();
	void Destroy();
	UBOOL ShouldExportProperty(UProperty* Property) const;
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
