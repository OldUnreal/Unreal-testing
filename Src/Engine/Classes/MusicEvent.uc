//=============================================================================
// MusicEvent
// Can be used to change map music.
//=============================================================================
class MusicEvent extends Triggers;

// Variables.
var() music				Song; // Song to change to.
var() byte				SongSection; // Song section to change to (255 = silence).
var() byte				CdTrack; // Unused.
var() EMusicTransition	Transition; // Transition style.
var() bool				bSilence; // Change to silence.
var() bool				bOnceOnly; // Can only be triggered once only.
var() bool				bAffectAllPlayers; // All players or triggerer only should be affected.
var() bool				bChangeAllLevels; // Should change song on all sublevels too?

// When gameplay starts.
function BeginPlay()
{
	if ( Song==None )
	{
		Song = Level.Song;
	}
	if ( bSilence )
	{
		SongSection = 255;
		CdTrack     = 255;
	}
}

// When triggered.
function Trigger( actor Other, pawn EventInstigator )
{
	local PlayerPawn P;
	local LevelInfo L;

	if ( bAffectAllPlayers )
	{
		// Fix for online games:
		if( bChangeAllLevels && Level.ParentLevel!=None )
		{
			for( L=Level.ParentLevel; L!=None; L=L.ChildLevel )
			{
				L.Song = Song;
				L.SongSection = SongSection;
			}
		}
		else
		{
			Level.Song = Song;
			Level.SongSection = SongSection;
		}

		foreach AllActors(class'PlayerPawn',P,,,bChangeAllLevels)
			P.ClientSetMusic( Song, SongSection, CdTrack, Transition );
	}
	else
	{
		// Only affect the one player.
		P = PlayerPawn(EventInstigator);
		if ( P==None || (!bChangeAllLevels && P.Level!=Level) )
			return;

		// Go to music.
		P.ClientSetMusic( Song, SongSection, CdTrack, Transition );
	}

	// Turn off if once-only.
	if ( bOnceOnly )
	{
		SetCollision(false,false,false);
		Disable( 'Trigger' );
	}
}

// Reset the MusicEvent
function Reset()
{
	if ( bOnceOnly )
		Enable('Trigger');
}

defaultproperties
{
	CdTrack=255
	Transition=MTRAN_Fade
	bAffectAllPlayers=True
}