class RegularWaves extends CGM_Waves
    config(ConfigurableGameMode);

// var public config Array<SpawnEntry> Spawn;

public function Init(GameSetup SetupParam)
{
    super.Init(SetupParam);
    `log("RegularWaves.Init() - Setup parameter:" @ SetupParam.Number);
    `log("RegularWaves.Init() - Setup property:" @ CurrentSetup.Number);
    SortWaves();
}

public function SortWaves()
{
    local Array<SpawnEntryCfg> SortedSpawns;
    local SpawnEntryCfg SpawnEntry;
    local SpawnWave Wave;
    Wave.Spawns.Length = 0;
    Wave.Number = -1;

    `log("RegularWaves.SortWaves(): Setup = " @ CurrentSetup.Number);
    foreach default.Spawn(SpawnEntry)
    {
        if (SpawnEntry.Setup != CurrentSetup.Number)
        {
            continue; // Skip spawns that don't match the current setup or wave
        }
        SortedSpawns.AddItem(SpawnEntry);
    }
    SortedSpawns.Sort(SortSpawnEntry);
    `log("Loaded " @ SortedSpawns.Length @ " spawns.");

    foreach SortedSpawns(SpawnEntry)
    {
        if (Wave.Number != SpawnEntry.Wave)
        {
            if (Wave.Spawns.Length > 0)
            {
                SpawnWaves.AddItem(Wave);
            }
            Wave.Spawns.Length = 0;
            Wave.Number = SpawnEntry.Wave;
        }

        Wave.Spawns.AddItem(SpawnEntry);
    }
    if (Wave.Spawns.Length > 0)
    {
        SpawnWaves.AddItem(Wave);
    }
    `log("RegularWaves.SortWaves() - Total Waves:" @ SpawnWaves.Length);
}

// public function Array<SpawnInfo> GetSpawnList(int WaveNum, int PlayerNum, out int WaveType)
// {
//     local Array<SpawnEntryCfg> SpawnEntries;
//     local SpawnEntryCfg SpawnEntry;
//     local Array<SpawnInfo> SpawnList;
//     local SpawnInfo Info;
//     local int Count;
//     local int NumToSpawn;

//     // take the spawns for the current wave and setup
//     `log("RegularWaves.GetSpawnList() - Getting spawns for Wave:" @ WaveNum @ " PlayerNum:" @ PlayerNum);
//     foreach SpawnWaves[WaveNum].Spawns(SpawnEntry)
//     {
//         NumToSpawn = Round(SpawnEntry.Count * (1 + CurrentSetup.ExtraSpawnPerWave * WaveNum) * (1 + CurrentSetup.ExtraSpawnPerPlayer * (PlayerNum - 1)));
//         for (Count = 0; Count < NumToSpawn; Count++)
//         {
//             Info.ZedClass = class<KFPawn_Monster>(DynamicLoadObject(SpawnEntry.ZedClass, class'Class'));
//             Info.Count = SpawnEntry.Count * (1 + SpawnEntry.ExtraPerWave * WaveNum) * (1 + SpawnEntry.ExtraPerPlayer * (PlayerNum - 1));
//             Info.Delay = SpawnEntry.Delay;
//             Info.MaxAliveToSpawn = SpawnEntry.MaxAliveToSpawn;

//             Info.SquadSize = SpawnEntry.SquadSize;
//             if (Info.SquadSize <= 0)
//             {
//                 Info.SquadSize = 5;
//             }

//             Info.ExtraPerWave = SpawnEntry.ExtraPerWave;
//             Info.ExtraPerPlayer = SpawnEntry.ExtraPerPlayer;
//             SpawnList.AddItem(Info);
//         }
//     }
//     `log("RegularWaves.GetSpawnList() - Wave:" @ WaveNum @ " PlayerNum:" @ PlayerNum @ " SpawnCount:" @ SpawnList.Length);
//     WaveType = 0;
//     return SpawnList;
// }

public function int GetWaveCount()
{
    `log("RegularWaves.GetWaveCount() WaveCount = " @ SpawnWaves.Length);
    return SpawnWaves.Length;
}