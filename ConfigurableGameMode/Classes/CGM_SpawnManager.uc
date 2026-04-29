class CGM_SpawnManager extends KFAISpawnManager
    dependson(CGM_Structs)
    config(ConfigurableGameMode);

var KFGameInfo KFGI;

var int SpawnedCount;
var int MaxAlive;
var int WavePlayerCount;

const GameSetupObj = class'GameSetups';
// const RegularWaves = class'RegularWaves';
// const RandomWaves = class'RandomWaves';
// const IntervalWaves = class'IntervalWaves';
var RegularWaves RegularWavesInstance;
var RandomWaves RandomWavesInstance;
var IntervalWaves IntervalWavesInstance;

var int Interval;
var GameSetup Setup;

// the spawn list for the current wave
var array<SpawnInfo> CurrentSpawnList;
var int CurrentSpawnIndex;

function Initialize()
{
    super.Initialize();

    Setup = GameSetupObj.static.GetSetup();
    `log("CGM_SpawnManager.Initialize() Loaded Setup:" @ Setup.Number);
    MaxAlive = Setup.MaxAlive;
    Interval = Setup.Interval;

    RegularWavesInstance = new class'RegularWaves';
    RandomWavesInstance = new class'RandomWaves';
    IntervalWavesInstance = new class'IntervalWaves';

    RegularWavesInstance.Init(Setup);
    RandomWavesInstance.Init(Setup);
    IntervalWavesInstance.Init(Setup);

    // InitSpawner();

    `log("CGM_SpawnManager.Initialize() MaxAlive:" @ MaxAlive @ " Interval:" @ Interval);
}

function SetupNextWave(byte NextWaveIndex, int TimeToNextWaveBuffer = 0)
{
    // Reset the total waves active time on first wave
    if( NextWaveIndex == 0 )
    {
        TotalWavesActiveTime = 0;
    }

    WaveStartTime = WorldInfo.TimeSeconds;
    TimeUntilNextSpawn = 5.f;
    LastAISpawnVolume = none;

    SpawnedCount = 0; // Reset spawned count for the new wave
    CurrentSpawnIndex = 0; // Reset spawn index for the new wave

    GetSpawnList(NextWaveIndex);
    WavePlayerCount = MyKFGRI.GetNumPlayers();
    SetTotalAi();
    
    `log("CGM_SpawnManager.SetupNextWave() - WaveTotalAI =" @ WaveTotalAI);
}

/** Get the spawn list for the current wave based on the game setup and wave number */
function GetSpawnList(int NextWaveIndex)
{
    local int PlayersCount;
    local int WaveType;

    PlayersCount = MyKFGRI.GetNumPlayers();   
    `log("CGM_SpawnManager.GetSpawnList(): NextWaveIndex = " @ NextWaveIndex @ " Interval = " @ Interval @ " PlayerCount = " @ PlayersCount);
    
    // decide what type of wave it will be
    if (NextWaveIndex < RegularWavesInstance.GetWaveCount())
    {
        `log("CGM_SpawnManager.GetSpawnList() - Regular Wave");
        CurrentSpawnList = RegularWavesInstance.GetSpawnList(NextWaveIndex, NextWaveIndex, PlayersCount, WaveType);
    }
    else if (IntervalWavesInstance.HasWaves() && (NextWaveIndex + 1) % Interval == 0)
    {
        `log("CGM_SpawnManager.GetSpawnList() - Interval Wave");
        CurrentSpawnList = IntervalWavesInstance.GetSpawnList(0, NextWaveIndex, PlayersCount, WaveType);
    }
    else
    {
        `log("CGM_SpawnManager.GetSpawnList() - Random Wave");
        CurrentSpawnList = RandomWavesInstance.GetSpawnList(0, NextWaveIndex, PlayersCount, WaveType);
    }
}

function SetTotalAi()
{
    local int Total;
    local SpawnInfo Info;
    Total = 0;
    foreach CurrentSpawnList(Info)
    {
        Total += Info.Count;
    }
    WaveTotalAI = Total;
    `log("CGM_SpawnManager.SetTotalAi() - Total AI for this wave: " @ WaveTotalAI);
}

function bool ShouldSpawn()
{
    if (AIAliveCount < MaxAlive && IsWaveActive())
    {
        return true; // Continue spawning until we reach the total AI for the wave
    }
    return false;
}

function Update()
{
    local array< class<KFPawn_Monster> > SquadToSpawn;
    local int localSpawnedCount;
    local int SquadCount;
    local int NumToSpawn;
    local SpawnInfo SpInfo;

    if (CurrentSpawnIndex >= CurrentSpawnList.Length)
    {
        return;
    }

	if( ShouldSpawn() )
	{
        SpInfo = CurrentSpawnList[CurrentSpawnIndex];
   		TotalWavesActiveTime += 1.0;
		// TimeUntilNextSpawn -= 1.f;
        SquadCount = 0;

        if (SpInfo.Delay > TotalWavesActiveTime)
        {
            return; // Not time to spawn this group yet
        }

        if (SpInfo.MaxAliveToSpawn > 0 && SpInfo.MaxAliveToSpawn < AIAliveCount)
        {
            return; // Too many AI alive to spawn this group
        }
        // else
        // {
        //     SpInfo.MaxAliveToSpawn = MaxAlive + 1; // clear it and start spawning
        // }

        for (SquadCount = 0; SquadCount < SpInfo.SquadSize && SquadCount < SpInfo.Count && SquadCount < MaxAlive - AIAliveCount; SquadCount++)
        {
        	SquadToSpawn.AddItem(SpInfo.ZedClass);
        }

        `log("CGM_SpawnManager.Update() - Spawning " @ SquadToSpawn.Length @ " " @ SpInfo.ZedClass.Name);
        GetDesiredSquadTypeForZedList(SquadToSpawn);
        localSpawnedCount = SpawnSquad( SquadToSpawn );
        SpawnedCount += localSpawnedCount;
        // `log("CGM_SpawnManager.Update() - SpawnedCount = " @ SpawnedCount);
        
        SpInfo.Count -= localSpawnedCount;
        if (SpInfo.Count <= 0)
        {
            CurrentSpawnIndex++;
        }
        else
        {
            CurrentSpawnList[CurrentSpawnIndex] = SpInfo; // update the count for the next spawn
        }

        TimeUntilNextSpawn = 0;
        UpdateAIRemaining();
	}
}

/** Any AI left for this wave */
function bool IsFinishedSpawning()
{
	if( SpawnedCount >= WaveTotalAI )
	{
		`log("KFAISpawnManager.IsFinishedSpawning()" @ string(SpawnedCount >= WaveTotalAI), bLogAISpawning);
		return true;
	}

	return false;
}