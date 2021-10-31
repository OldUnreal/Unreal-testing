//=============================================================================
// APathNodeIterator.h
//=============================================================================

	APathNodeIterator(){}
	virtual bool	IsPathValid( FVector           Start, FVector           End, bool FullCheck = false );
	virtual bool	IsPathValid( ANavigationPoint* Start, FVector           End, bool FullCheck = false );
	virtual bool	IsPathValid( FVector           Start, ANavigationPoint* End, bool FullCheck = false );
	virtual bool	IsPathValid( FReachSpec* ReachSpec );
	virtual bool	IsPathHeightValid( FVector Start, FVector End );
	virtual int		CalcNodeCost( FReachSpec* ReachSpec );
	virtual void	BuildPath( FVector Start, FVector End );
	void			BuildPathCache( ANavigationPoint* End );

	ANavigationPoint* breathPathTo( ANavigationPoint* Start, APawn* Scout );
	ANavigationPoint* GetFirst();
	ANavigationPoint* GetPrevious();
	ANavigationPoint* GetCurrent();
	ANavigationPoint* GetNext();
	ANavigationPoint* GetLast();
	ANavigationPoint* GetLastVisible();

// end of APathNodeIterator.h
