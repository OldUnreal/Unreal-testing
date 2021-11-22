//=============================================================================
// UBrowserBufferedTcpLink
//=============================================================================
class UBrowserBufferedTcpLink extends TcpLink;

var byte 			InputBuffer[1024];
var byte 			OutputBuffer[1024];

var int 			InputBufferHead;
var int 			InputBufferTail;

var int 			OutputBufferHead;
var int 			OutputBufferTail;

var string			OutputQueue;
var int 			OutputQueueLen;

var string			InputQueue;
var int 			InputQueueLen;

var bool			bEOF;

var string			CRLF;
var string			CR;
var string			LF;

var bool			bWaiting;
var float			WaitTimeoutTime;
var string			WaitingFor;
var int				WaitForCountChars;		// if we're waiting for X bytes
var string			WaitResult;
var int				WaitMatchData;

function ResetBuffer()
{
	OutputQueueLen = 0;
	InputQueueLen = 0;
	InputBufferHead = 0;
	InputBufferTail = 0;
	OutputBufferHead = 0;
	OutputBufferTail = 0;
	bWaiting = false;
	CRLF = Chr(10)$Chr(13);
	CR = Chr(13);
	LF = Chr(10);
	bEOF = False;
	LinkMode = MODE_Line;
	ReceiveMode = RMODE_Manual;
}


function WaitFor(string What, float TimeOut, int MatchData)
{
	bWaiting = True;
	WaitingFor = What;
	WaitForCountChars = 0;
	WaitTimeoutTime = Level.TimeSeconds + TimeOut;
	WaitMatchData = MatchData;
	WaitResult = "";
}

function WaitForCount(int Count, float TimeOut, int MatchData)
{
	bWaiting = True;
	WaitingFor = "";
	WaitForCountChars = Count;
	WaitTimeoutTime = Level.TimeSeconds + TimeOut;
	WaitMatchData = MatchData;
	WaitResult = "";
}

function GotMatch(int MatchData)
{
	// called when a match happens
}

function GotMatchTimeout(int MatchData)
{
	// when a match times out
}


function string ParseDelimited(string Text, string Delimiter, int Count, optional bool bToEndOfLine)
{
	local string Result;
	local int Found, i;
	local string s;

	Result = "";
	Found = 1;

	for (i=0; i<Len(Text); i++)
	{
		s = Mid(Text, i, 1);
		if (InStr(Delimiter, s) != -1)
		{
			if (Found == Count)
			{
				if (bToEndOfLine)
					return Result$Mid(Text, i);
				else
					return Result;
			}

			Found++;
		}
		else
		{
			if (Found >= Count)
				Result = Result $ s;
		}
	}

	return Result;
}

function bool SendEOF()
{
	local int NewTail;

	NewTail = OutputBufferTail;
	NewTail = (NewTail + 1) % 1024;
	if (NewTail == OutputBufferHead)
	{
		Log(Name$" - Output buffer overrun",'UBrowser');
		return False;
	}
	OutputBuffer[OutputBufferTail] = 0;
	OutputBufferTail = NewTail;

	return True;
}

// Read an individual character, returns 0 if no characters waiting
function int ReadChar()
{
	local int c;
	if (InputBufferHead == InputBufferTail) return 0;

	c = InputBuffer[InputBufferHead];
	InputBufferHead = (InputBufferHead + 1) % 1024;

	return c;
}


// Take a look at the next waiting character, return 0 if no characters waiting
function int PeekChar()
{
	if (InputBufferHead == InputBufferTail) return 0;
	return InputBuffer[InputBufferHead];
}

function bool ReadBufferedLine(out string Text)
{
	local int NewHead;

	Text = "";

	NewHead = InputBufferHead;
	while (NewHead != InputBufferTail)
	{
		if (InputBuffer[NewHead] == 13)
		{
			// it's an Enter
			NewHead = (NewHead + 1) % 1024;
			if (NewHead != InputBufferTail)
			{
				if (InputBuffer[NewHead] == 10)
				{
					// Eat a linefeed
					NewHead = (NewHead + 1) % 1024;
				}
			}
			InputBufferHead = NewHead;
			return True;
		}

		Text = Text $ Chr(InputBuffer[NewHead]);
		NewHead = (NewHead + 1) % 1024;
	}

	return False;

}

function bool SendBufferedData(string Text)
{
	local int intLength;
	local int i;
	local int NewTail;

	//Log("Sending: "$Text$".");

	intLength = Len(Text);

	for (i=0; i<intLength; i++)
	{
		NewTail = OutputBufferTail;
		NewTail = (NewTail + 1) % 1024;
		if (NewTail == OutputBufferHead)
		{
			Log(Name$" - Output buffer overrun",'UBrowser');
			return False;
		}
		OutputBuffer[OutputBufferTail] = Asc(Mid(Text, i, 1));
		OutputBufferTail = NewTail;
	}

	return True;
}

// DoQueueIO is intended to be called from Tick();
function DoBufferQueueIO()
{
	local int i;
	local int NewTail;
	local int NewHead;
	local int BytesSent;
	local byte ch;

	while (bWaiting)
	{
		if (Level.TimeSeconds > WaitTimeoutTime)
		{
			bWaiting = False;
			GotMatchTimeout(WaitMatchData);
		}
		ch = ReadChar();
		while (ch != 0 && bWaiting)
		{
			WaitResult = WaitResult $ Chr(ch);

			if (WaitForCountChars > 0)
			{
				if (Len(WaitResult) == WaitForCountChars)
				{
					// Match
					bWaiting = False;
					GotMatch(WaitMatchData);
					break;
				}
			}
			else
			{
				if (InStr(WaitResult, WaitingFor) != -1 || (WaitingFor == CR && InStr(WaitResult, LF) != -1) )
				{
					// Match
					bWaiting = False;
					GotMatch(WaitMatchData);
					break;
				}
			}
			ch = ReadChar();
		}
		if (ch == 0)
			break;
	}

	if (IsConnected())
	{
		// Output data
		OutputQueueLen = 0;
		OutputQueue = "";
		NewHead = OutputBufferHead;
		while ((OutputQueueLen < 255) && (NewHead != OutputBufferTail))
		{
			// put some more stuff in the output queue
			if (OutputBuffer[NewHead] != 0)
			{
				OutputQueue = OutputQueue $ Chr(OutputBuffer[NewHead]);
				OutputQueueLen++;
			}
			else
			{
				bEOF = True;
			}

			NewHead = (NewHead + 1) % 1024;
		}

		if (OutputQueueLen > 0)
		{
			BytesSent = SendText(OutputQueue $ "");
			OutputBufferHead = NewHead; //(OutputBufferHead + BytesSent) % 1024;
			//Log("Sent "$BytesSent$" bytes >>"$OutputQueue$"<<");
		}
	}

	// Now process any received data
	while ((IsDataPending() && IsConnected()) || InputQueueLen>0)
	{
		// if there's no data waiting since the last buffer-full
		if (InputQueueLen == 0)
		{
			if (ReadText(InputQueue) > 0)
			{
				InputQueueLen=Len(InputQueue);
				//Log("ReadText: "$InputQueue);
			}
		}

		if (InputQueueLen > 0)
		{
			for (i=0; i<Len(InputQueue); i++)
			{
				NewTail = InputBufferTail;
				NewTail = (NewTail + 1) % 1024;
				if (NewTail == InputBufferHead)
				{
					InputQueueLen = InputQueueLen - i;
					InputQueue = Mid(InputQueue, i, InputQueueLen);
					return;
				}

				InputBuffer[InputBufferTail] = Asc(Mid(InputQueue, i, 1));
				InputBufferTail = NewTail;
			}

			InputQueueLen = 0;
		}
		else
		{
			break;
		}
	}
}

defaultproperties
{
}