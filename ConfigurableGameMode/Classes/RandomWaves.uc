class RandomWaves extends CGM_Waves
    config(ConfigurableGameMode);

var public config Array<RandomSpawnGroup> Wave;
// var public config Array<SpawnEntryCfg> Spawn;
var private Array<int> WavePool;

delegate int SortSpawnGroups(RandomSpawnGroup A, RandomSpawnGroup B)
{
	return A.Number > B.Number ? -1 : 0;
}

public function Init(GameSetup SetupParam)
{
    super.Init(SetupParam);
    GroupSpawns();
}

private function GroupSpawns()
{
    local SpawnWave CurrentGroup;
    local int GroupIdx;
    local SpawnEntryCfg SpawnBuffer;
    local Array<SpawnWave> LocalSpawnWaves;
    local Array<SpawnEntryCfg> SortedSpawns;
    local Array<RandomSpawnGroup> SortedSpawnGroups;
    local RandomSpawnGroup Groupbuffer;
    local int countI;
    local int countJ;
    local int frequency;

    foreach default.Wave(Groupbuffer)
    {
        if (Groupbuffer.Setup == CurrentSetup.Number)
        {
            SortedSpawnGroups.AddItem(Groupbuffer);
        }
    }

    if (SortedSpawnGroups.Length == 0)
    {
        `log("RandomWaves.GroupSpawns() - No wave entries defined for setup " @ CurrentSetup.Number);
        SpawnWaves.Length = 0; // Ensure SpawnWaves is empty if no entries are found
        return;
    }

    for (countI = 0; countI < SortedSpawnGroups.Length; countI++)
    {
        Frequency = SortedSpawnGroups[countI].Frequency;
        for (countJ = 0; countJ < Frequency; countJ++)
        {
            WavePool.AddItem(countI);
            `log("RandomWaves.GroupSpawns() Adding wave index " @ countI);
        }
    }

    foreach default.Spawn(SpawnBuffer)
    {
        if (SpawnBuffer.Setup == CurrentSetup.Number)
        {
            SortedSpawns.AddItem(SpawnBuffer);
        }
    }

    SortedSpawns.Sort(SortSpawnEntry);
    SortedSpawnGroups.Sort(SortSpawnGroups);
    
    CurrentGroup.Spawns.Length = 0;
    CurrentGroup.Number = -1;
    GroupIdx = -1;

    foreach SortedSpawns(SpawnBuffer)
    {
        if (SpawnBuffer.Wave != CurrentGroup.Number)
        {
            if (CurrentGroup.Spawns.Length > 0)
            {
                for (countI = 0; countI < SortedSpawnGroups[GroupIdx].Frequency; countI++)
                {
                    LocalSpawnWaves.AddItem(CurrentGroup);
                }
            }
            CurrentGroup.Spawns.Length = 0;
            CurrentGroup.Number = SpawnBuffer.Wave;
            GroupIdx++;
        }
        CurrentGroup.Spawns.AddItem(SpawnBuffer);
    }

    if (CurrentGroup.Spawns.Length > 0)
    {
        for (countI = 0; countI < SortedSpawnGroups[GroupIdx].Frequency; countI++)
        {
            LocalSpawnWaves.AddItem(CurrentGroup);
        }
    }

    SpawnWaves = LocalSpawnWaves;

    `log("RandomWaves.GroupSpawns() Total waves: " @ SpawnWaves.Length);
}

public function bool HasWaves()
{
    return SpawnWaves.Length > 0;
}

public function Array<SpawnInfo> GetSpawnList(int WaveIdx,int waveNum, int playerNum, out int WaveType)
{
    // local Array< class<KFPawn_Monster> > SpawnList;
    local SpawnEntryCfg SpEntry;
    local Array< SpawnInfo > SpawnList;
    local SpawnWave selectedWave;
    local int RandomWaveIndex;
    local int SpawnCount;
    local int AddedCount;

    if (!HasWaves())
    {
        `log("RandomWaves.GetSpawnList() - No waves defined in config.");
        return SpawnList; // Return empty list if no waves are defined
    }
    
    RandomWaveIndex = Rand(WavePool.Length);
    // selectedWave = SpawnWaves[WavePool[RandomWaveIndex]];
    `log("RandomWaves.GetSpawnList() poolIdx=" @ RandomWaveIndex @ " WaveIndex=" @ WavePool[RandomWaveIndex]);
    // foreach selectedWave.Spawns(SpEntry)
    // {
    //     SpawnCount = SpEntry.Count * (1 + SpEntry.ExtraPerPlayer * (playerNum - 1)) * (1 + SpEntry.ExtraPerWave * waveNum);

    //     for (AddedCount = 0; AddedCount < SpawnCount; AddedCount++)
    //     {
    //         SpawnList.AddItem(class<KFPawn_Monster>(DynamicLoadObject(SpEntry.ZedClass, class'Class')));
    //     }
    // }

    WaveType = 0;
    return super.GetSpawnList(WavePool[RandomWaveIndex], waveNum, playerNum, WaveType);
}