class WM_SpawnManager extends KFAISpawnManager
    dependson(GameSetups)
    config(WM_SpawnManager);

var KFGameInfo KFGI;

var int SpawnedCount;
var int MaxAlive;

const GameSetupObj = class'GameSetups';
const RegularWaves = class'WM_Waves';
const RandomWaves = class'WM_Waves';
const IntervalWaves = class'WM_Waves';

var int Interval;
var GameSetup setup;

// the spawn list for the current wave
var array< class<KFPawn_Monster> > CurrentSpawnList;
var int CurrentSpawnIndex;

function Initialize()
{
    local int SetupIndex;
    local string options;
    super.Initialize();

    KFGI = KFGameInfo(WorldInfo.Game);
    options = Repl(WorldInfo.GetLocalURL(), WorldInfo.GetMapName(true), "");
    `log("WM_SpawnManager.Initialize() Options:" @ options);

    SetupIndex = KFGI.GetIntOption(options, "Setup", 0);
    `log("WM_SpawnManager.Initialize() SetupIndex:" @ SetupIndex);
    setup = GameSetupObj.static.GetCurrentSetup(SetupIndex);
    MaxAlive = setup.MaxAlive;
    Interval = setup.Interval;
}

function SetupNextWave(byte NextWaveIndex, int TimeToNextWaveBuffer = 0)
{
    // Call parent implementation first
    super.SetupNextWave(NextWaveIndex, TimeToNextWaveBuffer);
    
    SpawnedCount = 0; // Reset spawned count for the new wave
    GetSpawnList(NextWaveIndex);
    
    `log("WM_SpawnManager.SetupNextWave() - WaveTotalAI =" @ WaveTotalAI);
}

/** Get the spawn list for the current wave based on the game setup and wave number */
function GetSpawnList(int NextWaveIndex)
{
    `log("WM_SpawnManager.GetSpawnList()");
    
    // decide what type of wave it will be
    if (NextWaveIndex < RegularWaves.static.GetWaveCount())
    {
        CurrentSpawnList = RegularWaves.static.GetSpawnList(NextWaveIndex, MyKFGRI.GetNumPlayers());
    }
    else if (NextWaveIndex % Interval == 0)
    {
        CurrentSpawnList = IntervalWaves.static.GetSpawnList(NextWaveIndex - RegularWaves.static.GetWaveCount() - RandomWaves.static.GetWaveCount(), MyKFGRI.GetNumPlayers());
    }
    else
    {
        CurrentSpawnList = RandomWaves.static.GetSpawnList(NextWaveIndex - RegularWaves.static.GetWaveCount(), MyKFGRI.GetNumPlayers());
    }
}

function bool ShouldSpawn()
{
    if (MyKFGRI.CurrentAIAliveCount < MaxAlive)
    {
        return true; // Continue spawning until we reach the total AI for the wave
    }
    return false;
}

function Update()
{
    local array< class<KFPawn_Monster> > spawnList;
    local int currentAlive;
    local int cycleSpawnedCount;

	if( IsWaveActive() )
	{
   		TotalWavesActiveTime += 1.0;
		TimeUntilNextSpawn -= 1.f;
        currentAlive = MyKFGRI.CurrentAIAliveCount;
        cycleSpawnedCount = 0;

        while ( cycleSpawnedCount + currentAlive < MaxAlive && CurrentSpawnIndex < CurrentSpawnList.Length )
        {
        	spawnList.AddItem(CurrentSpawnList[CurrentSpawnIndex]);
            CurrentSpawnIndex++;
            cycleSpawnedCount++;
        }

        SpawnedCount += SpawnSquad( spawnList );
        TimeUntilNextSpawn = CalcNextGroupSpawnTime();
        UpdateAIRemaining();
	}
}

/** Find best spawn location and spawn a squad there */
function int SpawnSquad( out array< class<KFPawn_Monster> > AIToSpawn, optional bool bSkipHumanZedSpawning=false )
{
	local KFSpawnVolume KFSV;
	local int SpawnerAmount, VolumeAmount, FinalAmount, i;
    local bool bCanSpawnPlayerBoss;

`if(`notdefined(ShippingPC))
	local KFGameReplicationInfo KFGRI;
	local vector VolumeLocation;
`endif

    // Since this is called from multiple locations, early out if we're not in a wave
    if( !IsWaveActive() )
    {
        return 0;
    }

	// first check scripted spawners
	if( ActiveSpawner != None && ActiveSpawner.CanSpawnHere(DesiredSquadType) )
	{
		SpawnerAmount = ActiveSpawner.SpawnSquad(AIToSpawn);

		`log("KFAISpawnManager.SpawnAI() Using Spawner AIs spawned:" @ SpawnerAmount @ "in Spawner:" @ ActiveSpawner, bLogAISpawning);
	}
	// otherwise use default spawn volume selection
	if( AIToSpawn.Length > 0 )
	{
		KFSV = GetBestSpawnVolume(AIToSpawn);

		if( KFSV != None )
		{
`if(`notdefined(ShippingPC))
			VolumeLocation=KFSV.Location;
`endif

            KFSV.VolumeChosenCount++;

            if( bLogAISpawning )
            {
    			LogMonsterList(AIToSpawn, "SpawnSquad Pre Spawning");
            }

            bCanSpawnPlayerBoss = (bIsVersusGame && MyKFGRI.WaveNum == MyKFGRI.WaveMax) ? CanSpawnPlayerBoss() : false;

            if( !bIsVersusGame || MyKFGRI.WaveNum < MyKFGRI.WaveMax || !bCanSpawnPlayerBoss )
            {
    			VolumeAmount = KFSV.SpawnWave(AIToSpawn, true);
                LastAISpawnVolume = KFSV;
            }

            if( bIsVersusGame && !bSkipHumanZedSpawning && MyKFGRI.WaveNum == MyKFGRI.WaveMax )
            {
                AIToSpawn.Length = 0;
            }

		    `log("KFAISpawnManager.SpawnAI() AIs spawned:" @ VolumeAmount @ "in Volume:" @ KFSV, bLogAISpawning);

            if( bLogAISpawning )
            {
                LogMonsterList(AIToSpawn, "SpawnSquad Post Spawning");
            }

`if(`notdefined(ShippingPC))
        	// Let the GRI know that a spawn volume was just used
        	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
        	if( KFGRI != none && KFGRI.bTrackingMapEnabled )
        	{
        		KFGRI.AddRecentSpawnVolume(KFSV.Location);
        	}
`endif
		}

		if( VolumeAmount == 0 )
		{
		  // `warn(self@GetFuncName()$" No spawn volume with a positive rating, no AI will spawn!!!");
		}
	}

	FinalAmount = VolumeAmount + SpawnerAmount;
	NumAIFinishedSpawning += VolumeAmount; // volume zeds get spawned right away, so add this here

   	RefreshMonsterAliveCount();

	if( AIToSpawn.Length > 0 )
	{
        //`warn(self@GetFuncName()$" Didn't spawn the whole list of AI!!!");

`if(`notdefined(ShippingPC))
    	// Let the GRI know that a spawn volume failed to spawn some AI
    	if( !IsZero(VolumeLocation) )
    	{
        	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
        	if( KFGRI != none && KFGRI.bTrackingMapEnabled )
        	{
        		KFGRI.AddFailedSpawn(VolumeLocation);
        	}
    	}
`endif

        if( bLogAISpawning )
        {
            LogMonsterList(AIToSpawn, "SpawnSquad Incomplete Spawn Remaining");
            LogMonsterList(LeftoverSpawnSquad, "Failed Spawn Before Adding To Leftovers");
        }
    	// Add any failed spawns back into the LeftoverSpawnSquad to rapidly spawn somewhere else
        for ( i = 0; i < AIToSpawn.Length; i++ )
    	{
            LeftoverSpawnSquad[LeftoverSpawnSquad.Length] = AIToSpawn[i];
    	}

        if( bLogAISpawning )
        {
    	   LogMonsterList(LeftoverSpawnSquad, "Failed Spawn After Adding To Leftovers");
    	}
	}

    return FinalAmount;
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