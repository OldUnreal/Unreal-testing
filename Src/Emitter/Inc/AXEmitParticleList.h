
	AXEmitParticleList() {}
	virtual UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType ) { return 1; }
	UBOOL IsBlockedBy( const AActor* Other ) const { return 0; }
	UBOOL IsBasedOn( const AActor *Other ) const { return 0; }
	FLOAT LifeFraction() { return 1; }
	virtual void performPhysics(FLOAT DeltaSeconds) {}
	virtual void eventPreBeginPlay() {}
	virtual void eventBeginPlay() {}
	virtual void eventSetInitialState() {}
	virtual void eventPostBeginPlay() {}
	virtual void eventTick(FLOAT DeltaTime) {}
	void Destroy();
	FVector GetCameraPos();
	void InitializeEmitters();
/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
