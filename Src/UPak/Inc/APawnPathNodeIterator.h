//=============================================================================
// APawnPathNodeIterator.h
//=============================================================================

	APawnPathNodeIterator(){}
	virtual bool	IsPathValid( FVector           Start, FVector           End, bool FullCheck = false );
	virtual bool	IsPathValid( ANavigationPoint* Start, FVector           End, bool FullCheck = false );
	virtual bool	IsPathValid( FVector           Start, ANavigationPoint* End, bool FullCheck = false );
	virtual bool	IsPathValid( FReachSpec* ReachSpec );
	virtual bool	IsPathHeightValid( FVector Start, FVector End );
	virtual void	BuildPath( FVector Start, FVector End );

	void SetPawn( APawn* Pawn );

// end of APawnPathNodeIterator.h

