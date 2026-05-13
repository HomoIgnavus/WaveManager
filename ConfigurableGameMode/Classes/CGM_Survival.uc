class CGM_Survival extends KFGameInfo_Survival;

var config int CustomNumWaves;
var config int CustomWaveMax;
var config int TotalZedsBase;
var config bool bIsFirstTrader;

var private int InitialTraderTime;
var private int MaxZedsRecord;

const GameSetupObj = class'GameSetups';
var GameSetup CurrentGameSetup;

event InitGame( string Options, out string ErrorMessage )
{
	local int SetupIndex;
	SetupIndex = self.GetIntOption(Options, "Setup", 0);

    `log("CGM_Survival.InitGame()");
	CurrentGameSetup = GameSetupObj.static.GenSetup(SetupIndex);
	MaxZedsRecord = 0;
	bIsFirstTrader = true;

	// Append XP scaling options BEFORE calling Super.InitGame so mutators can see them
	Options = Options @ "?XpScale=" @ CurrentGameSetup.XpScale @ "?ExtraXpPerWave=" @ CurrentGameSetup.ExtraXpPerWave;
	`log("CGM_Survival.InitGame() - Appended Options:" @ Options);
	
	GameDifficulty = 3;
 	Super.InitGame( Options, ErrorMessage );
}

function AddServerExtMut()
{

}

event PreBeginPlay()
{
	super(KFGameInfo).PreBeginPlay();

	InitSpawnManager();
	UpdateGameSettings();
}

event PostBeginPlay()
{
	super(KFGameInfo).PostBeginPlay();

	bIsCastleVolterMap = Caps(WorldInfo.GetMapName(true)) == "KF-CASTLEVOLTER";

	TimeBetweenWaves = CurrentGameSetup.InitialTraderTime > 0 ? CurrentGameSetup.InitialTraderTime : InitialTraderTime;

	bGunGamePlayerOnLastGun = false;

	UpdateBonfires();
}

function SetupNextTrader()
{
    super.SetupNextTrader();
    
    TimeBetweenWaves = GetTraderTime();
    `log("CGM_Survival.SetupNextTrader() - TimeBetweenWaves set to: " @ TimeBetweenWaves);
}

function float GetTraderTime()
{
	if (bIsFirstTrader && CurrentGameSetup.bStartWithTrader) 
	{	
		bIsFirstTrader = false;
		return CurrentGameSetup.InitialTraderTime > 0 ? CurrentGameSetup.InitialTraderTime : InitialTraderTime;
	}

	return CurrentGameSetup.TraderTime;
}

function StartMatch()
{
	local KFPlayerController KFPC;

	WaveNum = 0;
	super.StartMatch();

	if( class'KFGameEngine'.static.CheckNoAutoStart() || class'KFGameEngine'.static.IsEditor() )
	{
		GotoState('DebugSuspendWave');
	}
	else
	{
		if (CurrentGameSetup.bStartWithTrader)
		{
			`log("CGM_Survival.StartMatch() - bStartWithTrader = true");
			GotoState('TraderOpen', 'Begin');
			WaveNum = 0;
		}
		else
		{
			`log("CGM_Survival.StartMatch() - bStartWithTrader = false");
			GotoState('PlayingWave');
		}
	}

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        KFPC.ClientMatchStarted();
    }
}

function SetupNextWave(int WaveBuffer)
{
	SpawnManager.SetupNextWave(WaveNum-1, WaveBuffer);
	`log("WaveNum=" @ WaveNum);
	`log("GetStateName() == 'PlayingWave'=" @ (GetStateName() == 'PlayingWave'));
	`log("MyKFGRI.bTraderIsOpen=" @ MyKFGRI.bTraderIsOpen);
	`log("MyKFGRI.AIRemaining=" @ MyKFGRI.AIRemaining);
	`log("MyKFGRI.WaveTotalAICount=" @ MyKFGRI.WaveTotalAICount);
}

/** Set up the spawning */
function InitSpawnManager()
{
    `log("CGM_Survival.InitSpawnManager()");
	SpawnManager = new(self) class'CGM_SpawnManager';
	SpawnManager.Initialize();
	MyKFGRI.WaveMax = CurrentGameSetup.MaxWave;
	WaveMax = CurrentGameSetup.MaxWave;
}

event Timer()
{
	super.Timer();

	if( SpawnManager != none )
	{
		SpawnManager.Update();
		if (MaxZedsRecord < AIAliveCount)
		{
			MaxZedsRecord = AIAliveCount;
			`log("MaxZedsRecord=" @ MaxZedsRecord);
		}
	}

	if( GameConductor != none )
	{
		GameConductor.TimerUpdate();
	}
}

function BossDied(Controller Killer, optional bool bCheckWaveEnded = true)
{
	`log("CGM_Survival.BossDied() Killer: " @ Killer);
	return;
}

/** Do something when there are no AIs left */
function CheckWaveEnd( optional bool bForceWaveEnd = false )
{

    if( !MyKFGRI.bMatchHasBegun )
    {
		`log("KFGameInfo - CheckWaveEnd - Cannot check if wave has ended since match has not begun. ");
    	return;
    }

    `log("KFGameInfo.CheckWaveEnd() AIAliveCount:" @ AIAliveCount, SpawnManager.bLogAISpawning);

    if( GetLivingPlayerCount() <= 0 )
	{
//		`log("KFGameInfo.CheckWaveEnd() - Call Wave Ended - WEC_TeamWipedOut");
		WaveEnded(WEC_TeamWipedOut);
	}
	else if( (AIAliveCount <= 0 && IsWaveActive() && SpawnManager.IsFinishedSpawning()) || bForceWaveEnd )
	{
		//`log("KFGameInfo.CheckWaveEnd() - Call Wave Ended - WEC_WaveWon");
		WaveEnded(WEC_WaveWon);
	}
}

function RestartPlayer(Controller NewPlayer)
{
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;
	local bool bWasWaitingForClientPerkData;

	KFPC = KFPlayerController(NewPlayer);
	KFPRI = KFPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo);

	if( KFPC != None && KFPRI != None )
	{
		if( IsPlayerReady( KFPRI ) )
		{
			bWasWaitingForClientPerkData = KFPC.bWaitingForClientPerkData;

			/** If we have rejoined the match more than once, delay our respawn by some amount of time */
			if( MyKFGRI.bMatchHasBegun && KFPRI.NumTimesReconnected > 1 && `TimeSince(KFPRI.LastQuitTime) < ReconnectRespawnTime )
			{
				KFPC.StartSpectate();
				KFPC.SetTimer(ReconnectRespawnTime - `TimeSince(KFPRI.LastQuitTime), false, nameof(KFPC.SpawnReconnectedPlayer));
			}
			//If a wave is active, we spectate until the end of the wave
			else if( IsWaveActive() && !bWasWaitingForClientPerkData )
			{
				KFPC.StartSpectate();
			}
			else
			{
				Super.RestartPlayer(NewPlayer);

				// Already gone through one RestartPlayer() cycle, don't process again
				if( bWasWaitingForClientPerkData )
				{
					return;
				}

				if( KFPRI.Deaths == 0 )
				{
					if( WaveNum < 1 )
					{
						KFPRI.Score = CurrentGameSetup.InitialDosh;
					}
					else
					{
						KFPRI.Score = GetAdjustedDeathPenalty( KFPRI, true );
					}
					`log("SCORING: Player" @ KFPRI.PlayerName @ "received" @ KFPRI.Score @ "starting cash", bLogScoring);
				}
			}
		}
	}
}

// Difficulty scaling
function SetMonsterDefaults( KFPawn_Monster P )
{
	local float HealthMod;
	local float HeadHealthMod;
	local float TotalSpeedMod, StartingSpeedMod;
	local float DamageMod;
	local int LivingPlayerCount;
	local int i;
	local float CgmScale;

	if (CurrentGameSetup.bUseStockScaling)
    {
		`log("CGM_Survival.SetMonsterDefaults() - Using stock difficulty scaling");
		LivingPlayerCount = GetLivingPlayerCount();

		DamageMod = 1.0;
		HealthMod = 1.0;
		HeadHealthMod = 1.0;

		// Scale health and damage by game conductor values for versus zeds
		if( P.bVersusZed )
		{
			DifficultyInfo.GetVersusHealthModifier(P, LivingPlayerCount, HealthMod, HeadHealthMod);

			HealthMod *= GameConductor.CurrentVersusZedHealthMod;
			HeadHealthMod *= GameConductor.CurrentVersusZedHealthMod;

			// scale damage
			P.DifficultyDamageMod = DamageMod * GameConductor.CurrentVersusZedDamageMod;

			StartingSpeedMod = 1.f;
			TotalSpeedMod = 1.f;
		}
		else
		{
			DifficultyInfo.GetAIHealthModifier(P, GameDifficulty, LivingPlayerCount, HealthMod, HeadHealthMod);
			DamageMod = DifficultyInfo.GetAIDamageModifier(P, GameDifficulty,bOnePlayerAtStart);

			// scale damage
			P.DifficultyDamageMod = DamageMod;

			StartingSpeedMod = DifficultyInfo.GetAISpeedMod(P, GameDifficulty);
			TotalSpeedMod = GameConductor.CurrentAIMovementSpeedMod * StartingSpeedMod;
		}

		//`log("Start P.GroundSpeed = "$P.GroundSpeed$" GroundSpeedMod = "$GroundSpeedMod$" percent of default = "$(P.default.GroundSpeed * GroundSpeedMod)/P.default.GroundSpeed$" RandomSpeedMod= "$RandomSpeedMod);

		// scale movement speed
		P.GroundSpeed = P.default.GroundSpeed * TotalSpeedMod;
		P.SprintSpeed = P.default.SprintSpeed * TotalSpeedMod;

		// Store the difficulty adjusted ground speed to restore if we change it elsewhere
		P.NormalGroundSpeed = P.GroundSpeed;
		P.NormalSprintSpeed = P.SprintSpeed;
		P.InitialGroundSpeedModifier = StartingSpeedMod;

		//`log(P$" GroundSpeed = "$P.GroundSpeed$" P.NormalGroundSpeed = "$P.NormalGroundSpeed);

		// Scale health by difficulty
		P.Health = P.default.Health * HealthMod;
		if( P.default.HealthMax == 0 )
		{
			P.HealthMax = P.default.Health * HealthMod;
		}
		else
		{
			P.HealthMax = P.default.HealthMax * HealthMod;
		}

		P.ApplySpecialZoneHealthMod(HeadHealthMod);
		P.GameResistancePct = DifficultyInfo.GetDamageResistanceModifier(LivingPlayerCount);

		// look for special monster properties that have been enabled by the kismet node
		for (i = 0; i < ArrayCount(SpawnedMonsterProperties); i++)
		{
			// this property is currently enabled
			if (SpawnedMonsterProperties[i] != 0)
			{
				// do the action associated with that property
				switch (EMonsterProperties(i))
				{
				case EMonsterProperties_Enraged:
					P.SetEnraged(true);
					break;
				case EMonsterProperties_Sprinting:
					P.bSprintOverride=true;
					break;
				}
			}
		}

		if (OutbreakEvent != none)
		{
			OutbreakEvent.AdjustMonsterDefaults(P);
		}
	}
	else
	{
		`log("CGM_Survival.SetMonsterDefaults() - Using custom difficulty scaling");
		`log("CGM_Survival.SetMonsterDefaults() Before - P.Health: " @ P.Health @ " P.GroundSpeed: " @ P.GroundSpeed @ " P.SprintSpeed: " @ P.SprintSpeed @ " P.DifficultyDamageMod: " @ P.DifficultyDamageMod);
		// Apply current Setup values

		CgmScale = FMin(CurrentGameSetup.ZedHealthScale + CurrentGameSetup.ExtraHealthPerWave * WaveNum, CurrentGameSetup.MaxHealthScale) * (1 + CurrentGameSetup.ExtraHealthPerPlayer * (LivingPlayerCount - 1));
		P.Health *= CgmScale;
		
		CgmScale = FMin(CurrentGameSetup.ZedResistanceScale + CurrentGameSetup.ExtraResistancePerWave * WaveNum, CurrentGameSetup.MaxResistanceScale);
		P.GameResistancePct *= CgmScale;

		CgmScale = FMin(CurrentGameSetup.ZedSpeedScale + CurrentGameSetup.ExtraSpeedPerWave * WaveNum, CurrentGameSetup.MaxSpeedScale);
		P.GroundSpeed *= CgmScale;
		P.SprintSpeed *= CgmScale;

		CgmScale = FMin(CurrentGameSetup.ZedDamageScale + CurrentGameSetup.ExtraDamagePerWave * WaveNum, CurrentGameSetup.MaxDamageScale);
		P.DifficultyDamageMod *= CgmScale;
		// P.Health *= 10;
		// P.GroundSpeed *= 10;
		// P.SprintSpeed *= 10;
		// P.DifficultyDamageMod *= 10;

		`log("CGM_Survival.SetMonsterDefaults() After - P.Health: " @ P.Health @ " P.GroundSpeed: " @ P.GroundSpeed @ " P.SprintSpeed: " @ P.SprintSpeed @ " P.DifficultyDamageMod: " @ P.DifficultyDamageMod);

		// // debug logging
		// `log("==== SetMonsterDefaults for pawn: " @P @"====",bLogAIDefaults);
		// `log("HealthMod: " @HealthMod @ "Original Health: " @P.default.Health @" Final Health = " @P.Health, bLogAIDefaults);
		// `log("HeadHealthMod: " @HeadHealthMod @ "Original Head Health: " @P.default.HitZones[HZI_HEAD].GoreHealth @" Final Head Health = " @P.HitZones[HZI_HEAD].GoreHealth, bLogAIDefaults);
		// `log("GroundSpeedMod: " @TotalSpeedMod @" Final Ground Speed = " @P.GroundSpeed, bLogAIDefaults);
		// //`log("HiddenSpeedMod: " @HiddenSpeedMod @" Final Hidden Speed = " @P.HiddenGroundSpeed, bLogAIDefaults);
		// `log("SprintSpeedMod: " @TotalSpeedMod @" Final Sprint Speed = " @P.SprintSpeed, bLogAIDefaults);
		// `log("DamageMod: " @DamageMod @" Final Melee Damage = " @P.MeleeAttackHelper.BaseDamage * DamageMod, bLogAIDefaults);
		// //`log("bCanSprint: " @P.bCanSprint @ " from SprintChance: " @SprintChance, bLogAIDefaults);
	}
}

// Handle chat commands
event Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
	super.Broadcast(Sender, Msg, Type);

	if ( Type == 'Say' )
	{
	
	}
}

defaultproperties
{
	InitialTraderTime = 60
}