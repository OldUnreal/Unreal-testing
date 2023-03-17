Class TerrainInfoRender extends RenderIterator
	native;

cpptext
{
	UTerrainInfoRender();
	AActor* GetActors();
	AActor* GetStaticActors();
}

defaultproperties
{
	bIsTerrain=true
}