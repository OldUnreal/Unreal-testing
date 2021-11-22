class UWindowConsoleTextAreaControl extends UWindowHTMLTextArea;

struct LinkPrefixInfo
{
	var string Prefix;
	var bool bIsHostPrefix;
	var int Pos;
};

function int FindHostPrefix(string Str, string Prefix, int Start)
{
	local int Result, DotPos, SpacePos;
	local int StrLen, PrefixLen;

	StrLen = Len(Str);
	PrefixLen = Len(Prefix);
	
	while (Start < StrLen)
	{
		if (Start == 0 && StartsWith(Str, Prefix))
			Result = 0;
		else
		{
			Result = InStr(Str, " " $ Prefix, Max(0, Start - 1));
			if (Result < 0)
				return -1;
			++Result;
		}
		DotPos = InStr(Str, ".", Result + PrefixLen);
		if (DotPos > Result + PrefixLen)
		{
			SpacePos = InStr(Str, " ", Result + PrefixLen);
			if (SpacePos < 0 && DotPos + 1 < StrLen || DotPos + 1 < SpacePos)
				return Result;
		}
		Start += PrefixLen;
	}
	return -1;
}

function UWindowDynamicTextRow AddText(string NewLine, optional color TxtCol )
{
	local int i, n;
	local int Pos, LeftmostLinkIndex, StrPos;
	local UWindowHTMLTextRow L;
	local HTMLStyle CurrentStyle;
	local string LowNewLine;
	local array<LinkPrefixInfo> LinkPrefixes;

	CurrentStyle.BulletLevel = 0;
	CurrentStyle.LinkDestination = "";
	if (TxtCol.R==0 && TxtCol.G==0 && TxtCol.B==0)
		CurrentStyle.TextColor = TextColor;
	else
		CurrentStyle.TextColor = TxtCol;

	// Replace <>
	NewLine = ReplaceStr(NewLine, "<", "&lt;");
	NewLine = ReplaceStr(NewLine, ">", "&gt;");

	// Add links

	LowNewLine = Locs(NewLine);

	n = 0;
	LeftmostLinkIndex = 0;
	LinkPrefixes[n++].Prefix = "mailto:";
	LinkPrefixes[n++].Prefix = "http://";
	LinkPrefixes[n++].Prefix = "https://";
	LinkPrefixes[n++].Prefix = "ftp://";
	LinkPrefixes[n].bIsHostPrefix = true;
	LinkPrefixes[n++].Prefix = "www.";
	LinkPrefixes[n].bIsHostPrefix = true;
	LinkPrefixes[n++].Prefix = "ftp.";
	LinkPrefixes[n++].Prefix = "unreal://";

	for (i = 0; i < n; ++i)
		LinkPrefixes[i].Pos = -1;

	StrPos = 0;
	while (true)
	{
		LeftmostLinkIndex = 0;
		i = 0;
		while (i < n)
		{
			if (LinkPrefixes[i].Pos < StrPos)
			{
				if (LinkPrefixes[i].bIsHostPrefix)
					Pos = FindHostPrefix(LowNewLine, LinkPrefixes[i].Prefix, StrPos);
				else
					Pos = InStr(LowNewLine, LinkPrefixes[i].Prefix, StrPos);

				if (Pos >= 0)
					LinkPrefixes[i].Pos = Pos;
				else
				{
					Array_Remove(LinkPrefixes, i);
					--n;
					continue;
				}
			}
			if (LinkPrefixes[i].Pos < LinkPrefixes[LeftmostLinkIndex].Pos)
				LeftmostLinkIndex = i;
			++i;
		}
		if (n == 0)
			break;

		if (LinkPrefixes[LeftmostLinkIndex].Pos > StrPos)
		{
			L = UWindowHTMLTextRow(Super(UWindowDynamicTextArea).AddText(
				Mid(NewLine, StrPos, LinkPrefixes[LeftmostLinkIndex].Pos - StrPos)));
			L.StartStyle = CurrentStyle;
			L.StartStyle.bNoBR = true;
		}
		i = InStr(NewLine, " ", LinkPrefixes[LeftmostLinkIndex].Pos);
		if (i >= 0)
			L = UWindowHTMLTextRow(Super(UWindowDynamicTextArea).AddText(
				Mid(NewLine, LinkPrefixes[LeftmostLinkIndex].Pos, i - LinkPrefixes[LeftmostLinkIndex].Pos)));
		else
			L = UWindowHTMLTextRow(Super(UWindowDynamicTextArea).AddText(
				Mid(NewLine, LinkPrefixes[LeftmostLinkIndex].Pos)));
		L.StartStyle = CurrentStyle;
		L.StartStyle.LinkDestination = L.Text;
		L.StartStyle.bLink = true;
		L.StartStyle.bNoBR = true;
		if (i < 0)
			return L;

		StrPos = i + 1;
	}

	// End line.
	if (Len(NewLine) > StrPos)
	{
		L = UWindowHTMLTextRow(Super(UWindowDynamicTextArea).AddText(Mid(NewLine, StrPos)));
		L.StartStyle = CurrentStyle;
	}
	return L;
}

defaultproperties
{
				LinkColor=(R=127,G=127)
				ALinkColor=(G=127,B=127)
				MaxLines=500
				bTopCentric=False
}