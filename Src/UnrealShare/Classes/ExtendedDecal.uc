class ExtendedDecal extends Decal;
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Used to resize decal. We can do it without
  this function, but it makes everything much
  easier.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
function bool ResizeDecal(float Scale, float TraceDistance, optional vector DecalDir)
{
	if (Scale < 0) return false;
	DetachDecal();
	DrawScale=Scale;
	if (AttachDecal(TraceDistance, DecalDir) != none) return true;
	else return false;
}