//=============================================================================
// EFXZoneInfo.
//=============================================================================
class EFXZoneInfo extends ZoneInfo;

var(ZoneAudio) enum EReverbPreset
{
	RP_Generic,
	RP_PaddedCell,
	RP_Room,
	RP_BathRoom,
	RP_LivingRoom,
	RP_StoneRoom,
	RP_Auditorium,
	RP_ConcertHall,
	RP_Cave,
	RP_Arena,
	RP_Hangar,
	RP_CarpettedHallway,
	RP_Hallway,
	RP_StoneCorridor,
	RP_Alley,
	RP_Forest,
	RP_City,
	RP_Mountains,
	RP_Quarry,
	RP_Plain,
	RP_ParkingLot,
	RP_SewerPipe,
	RP_Underwater,
	RP_Drugged,
	RP_Dizzy,
	RP_Psychotic,
	RP_CastleSmallRoom,
	RP_CastleShortPassage,
	RP_CastleMediumRoom,
	RP_CastleLongPassage,
	RP_CastleLargeRoom,
	RP_CastleHall,
	RP_CastleCupboard,
	RP_CastleCourtyard,
	RP_CastleAlcove,
	RP_FactoryAlcove,
	RP_FactoryShortPassage,
	RP_FactoryMediumRoom,
	RP_FactoryLongPassage,
	RP_FactoryLargeRoom,
	RP_FactoryHall,
	RP_FactoryCupboard,
	RP_FactoryCourtyard,
	RP_FactorySmallRoom,
	RP_IcePalaceAlcove,
	RP_IcePalaceShortPassage,
	RP_IcePalaceMediumRoom,
	RP_IcePalaceLongPassage,
	RP_IcePalaceLargeRoom,
	RP_IcePalaceHall,
	RP_IcePalaceCupboard,
	RP_IcePalaceCourtyard,
	RP_IcePalaceSmallroom,
	RP_SpaceStationAlcove,
	RP_SpaceStationMediumroom,
	RP_SpaceStationShortPassage,
	RP_SpaceStationLongPassage,
	RP_SpaceStationLargeRoom,
	RP_SpaceStationHall,
	RP_SpaceStationCupboard,
	RP_SpaceStationSmallroom,
	RP_WoodenAlcove,
	RP_WoodenShortPassage,
	RP_WoodenMediumRoom,
	RP_WoodenLongPassage,
	RP_WoodenLargeRoom,
	RP_WoodenHall,
	RP_WoodenCupboard,
	RP_WoodenSmallroom,
	RP_WoodenCourtyard,
	RP_SportEmptystadium,
	RP_SportSquashcourt,
	RP_SportSmallswimmingpool,
	RP_SportLargeswimmingpool,
	RP_SportGymnasium,
	RP_SportFullstadium,
	RP_SportStadiumtannoy,
	RP_PrefabWorkshop,
	RP_PrefabSchoolroom,
	RP_PrefabPractiseroom,
	RP_PrefabOuthouse,
	RP_PrefabCaravan,
	RP_DomeTomb,
	RP_PipeSmall,
	RP_DomeSaintPauls,
	RP_PipeLongThin,
	RP_PipeLarge,
	RP_PipeResonant,
	RP_OutdoorsBackyard,
	RP_OutdoorsRollingPlains,
	RP_OutdoorsDeepCanyon,
	RP_OutdoorsCreek,
	RP_OutdoorsValley,
	RP_MoodHeaven,
	RP_MoodHell,
	RP_MoodMemory,
	RP_DrivingCommentator,
	RP_DrivingPitGarage,
	RP_DrivingInCarRacer,
	RP_DrivingInCarSports,
	RP_DrivingInCarLuxury,
	RP_DrivingFullGrandStand,
	RP_DrivingEmptyGrandStand,
	RP_DrivingTunnel,
	RP_CityStreets,
	RP_CitySubway,
	RP_CityMuseum,
	RP_CityLibrary,
	RP_CityUnderpass,
	RP_CityAbandoned,
	RP_DustyRoom,
	RP_Chapel,
	RP_SmallWaterRoom,
	RP_UnderSlime,
	RP_None,
} ReverbPreset;

var(ZoneAudio) float AirAbsorptionGainHF;
var(ZoneAudio) float DecayHFRatio;
var(ZoneAudio) float DecayLFRatio;
var(ZoneAudio) float DecayTime;
var(ZoneAudio) float Density;
var(ZoneAudio) float Diffusion;
var(ZoneAudio) float EchoDepth;
var(ZoneAudio) float EchoTime;
var(ZoneAudio) nowarn float Gain;
var(ZoneAudio) float GainHF;
var(ZoneAudio) float GainLF;
var(ZoneAudio) float HFReference;
var(ZoneAudio) float LFReference;
var(ZoneAudio) float LateReverbDelay;
var(ZoneAudio) float LateReverbGain;
var(ZoneAudio) float RoomRolloffFactor;
var(ZoneAudio) bool bDecayHFLimit;
var(ZoneAudio) bool bUserDefined; // Set to true to use options above.

struct EFXEffects
{
	var int   Version;
	var EReverbPreset	ReverbPreset;
	var float AirAbsorptionGainHF;
	var float DecayHFRatio;
	var float DecayLFRatio;
	var float DecayTime;
	var float Density;
	var float Diffusion;
	var float EchoDepth;
	var float EchoTime;
	var float Gain;
	var float GainHF;
	var float GainLF;
	var float HFReference;
	var float LFReference;
	var float LateReverbDelay;
	var float LateReverbGain;
	var float RoomRolloffFactor;
	var bool  bUserDefined;
	var bool  bDecayHFLimit;
	var int   Reserved[32];
};

// ----------------------------------------------------------------------------
// QueryEffects - UnrealScript-C++ glue magic.
//
// AlAudio now just calls QueryEffects() on the ViewActor Zone's ZoneInfo.
// So you just need to have a  QueryEffects() event in your ZoneInfo to support
// EFX. All what matters is this event, and the correct ordering and size
// of EReverbPreset/EFXEffects, all properties of this class are just arbitrary
// conveniance setttings for mappers, they are just used by QueryEffects().
// EFXEffects.Version should be also set to 1, and is intended if the interface
// of EFXEffects changes (not likely to happen). Info.Version is set by ALAudio
// to the maximum EFXEffects interface version supported.
// ----------------------------------------------------------------------------

simulated event QueryEffects( out EFXEffects Effects, Actor ViewActor )
{
	//Log( "EFXEffects interface version is" @ Effects.Version )
	
	Effects.Version             = 1;
	Effects.ReverbPreset        = ReverbPreset;
	Effects.AirAbsorptionGainHF = AirAbsorptionGainHF;
	Effects.DecayHFRatio        = DecayHFRatio;
	Effects.DecayLFRatio        = DecayLFRatio;
	Effects.DecayTime           = DecayTime;
	Effects.Density             = Density;
	Effects.Diffusion           = Diffusion;
	Effects.EchoDepth           = EchoDepth;
	Effects.EchoTime            = EchoTime;
	Effects.Gain                = Gain;
	Effects.GainHF              = GainHF;
	Effects.GainLF              = GainLF;
	Effects.HFReference         = HFReference;
	Effects.LFReference         = LFReference;
	Effects.LateReverbDelay     = LateReverbDelay;
	Effects.LateReverbGain      = LateReverbGain;
	Effects.RoomRolloffFactor   = RoomRolloffFactor;
	Effects.bUserDefined        = bUserDefined;
	Effects.bDecayHFLimit       = bDecayHFLimit;
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

defaultproperties
{
	AirAbsorptionGainHF=0.994
	DecayHFRatio=0.83
	DecayLFRatio=1.0
	DecayTime=1.49
	Density=1.0
	Diffusion=1.0
	EchoDepth=0.0
	EchoTime=0.25
	Gain=0.32
	GainHF=0.89
	GainLF=0.0
	HFReference=5000.0
	LFReference=150.0
	LateReverbDelay=0.011
	LateReverbGain=1.26
	RoomRolloffFactor=0.0;
	bDecayHFLimit=True;
	bUserDefined=False
	ReverbPreset=RP_None
}
