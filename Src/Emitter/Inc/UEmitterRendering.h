	UEmitterRendering();
	
	static FCoords CamPos;
	void ChangeParticleCount( int NewNum );
	bool HasAliveParticles();
	void HideAllParticles();
	AActor* GetActors();
	AActor* GetActorsInner(UBOOL bDrawSelf = FALSE);
	void Destroy();
	void SpawnDelayedPart( const FVector& Pos );
