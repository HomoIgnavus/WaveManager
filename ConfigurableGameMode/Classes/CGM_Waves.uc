class CGM_Waves extends Object
    dependson(CGM_Structs)
    config(ConfigurableGameMode);



var public config Array<SpawnEntryCfg> Spawn;
var config GameSetup CurrentSetup;
var Array<SpawnWave> SpawnWaves;

delegate int SortSpawnEntry(SpawnEntryCfg A, SpawnEntryCfg B)
{
	return (A.Wave > B.Wave && A.Priority < B.Priority) ? -1 : 0;
}

public function Init(GameSetup SetupParam)
{
    CurrentSetup = SetupParam;
}

/**
 * CheckEntries
 */
public function CheckEntries()
{
    local SpawnEntryCfg Entry;
    foreach Spawn(Entry)
    {
        // defaults to CurrentSetup values if not specified in the entry
        if (Entry.ExtraPerPlayer == 0)
        {
            Entry.ExtraPerPlayer = CurrentSetup.ExtraSpawnPerPlayer;
        }

        if (Entry.ExtraPerWave == 0)
        {
            Entry.ExtraPerWave = CurrentSetup.ExtraSpawnPerWave;
        }
    }
}

public function Array<SpawnInfo> GetSpawnList(int WaveIdx, int WaveNum, int PlayerNum, out int WaveType)
{
    local Array<SpawnEntryCfg> SpawnEntries;
    local SpawnEntryCfg SpawnEntry;
    local Array<SpawnInfo> SpawnList;
    local SpawnInfo Info;
    local int Count;
    local int WaveTotal;
    local int NumToSpawn;
    local float WaveNumScale;
    local float PlayerNumScale;
    local float CurrentScale;
    local float ScaledCount;
    local int SpawnCount;
    local int RandomSpawnIdx;

    // take the spawns for the current wave and setup
    `log("CGM_Waves.GetSpawnList() - Getting spawns for Wave:" @ WaveNum @ " PlayerNum:" @ PlayerNum);
    WaveNumScale = 1.0 + CurrentSetup.ExtraSpawnPerWave * WaveNum;
    PlayerNumScale = 1.0 + CurrentSetup.ExtraSpawnPerPlayer * (PlayerNum - 1);
    CurrentScale = WaveNumScale * PlayerNumScale;
    `log("CGM_Waves.GetSpawnList() - WaveNumScale:" @ WaveNumScale @ " PlayerNumScale:" @ PlayerNumScale @ " CurrentScale:" @ CurrentScale);

    foreach SpawnWaves[WaveIdx].Spawns(SpawnEntry)
    {
        Info.ZedClass = class<KFPawn_Monster>(DynamicLoadObject(SpawnEntry.ZedClass, class'Class'));
        if (Info.ZedClass == None)
        {
            continue;
        }

        WaveTotal += SpawnEntry.Count;
        ScaledCount = SpawnEntry.Count * CurrentScale;
        NumToSpawn = Round(ScaledCount);
        SpawnCount += NumToSpawn;
        // `log("CGM_Waves.GetSpawnList() - SpawnEntry.Count=" @ SpawnEntry.Count @ " NumToSpawn=" @ NumToSpawn);
        Info.Count = NumToSpawn;
        Info.Delay = SpawnEntry.Delay;
        Info.MaxAliveToSpawn = SpawnEntry.MaxAliveToSpawn;

        Info.SquadSize = SpawnEntry.SquadSize;
        if (Info.SquadSize <= 0)
        {
            Info.SquadSize = 5;
        }

        Info.ExtraPerWave = SpawnEntry.ExtraPerWave;
        Info.ExtraPerPlayer = SpawnEntry.ExtraPerPlayer;
        
        SpawnList.AddItem(Info);
    }

    WaveTotal *= CurrentScale;
    // `log("CGM_Waves.GetSpawnList() - WaveTotal=" @ WaveTotal @ ", CurrentScale=" @ CurrentScale);
    while (WaveTotal > SpawnCount)
    {
        RandomSpawnIdx = Rand(SpawnList.Length);
        SpawnList[RandomSpawnIdx].Count++;
        SpawnCount++;
    }

    // `log("CGM_Waves.GetSpawnList() - Wave:" @ WaveNum @ " PlayerNum:" @ PlayerNum @ " SpawnList.Length:" @ SpawnList.Length);
    WaveType = 0;
    return SpawnList;
}
