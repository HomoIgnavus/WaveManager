class RegularWaves extends WM_Waves;

var public config Array<SpawnEntry> Spawn;

public static function Init(GameSetup setup)
{
    Setup = setup;
    default.WaveCount = 10;
}

public static function Array< class<KFPawn_Monster> > GetSpawnList(int waveNum, int playerNum)
{
    local Array<SpawnEntry> SortedSpawns;
    local SpawnEntry spawnEntry;
    local Array< class<KFPawn_Monster> > SpawnList;
    local int count;
    local int numToSpawn;

    // take the spawns for the current wave and setup
    foreach default.Spawn(spawnEntry)
    {
        if (spawnEntry.Setup != default.Setup.Number || spawnEntry.Wave != waveNum)
        {
            continue; // Skip spawns that don't match the current setup or wave
        }

        SortedSpawns.AddItem(spawnEntry);
    }
    SortedSpawns.Sort(SortSpawnEntry); // Sort the spawns by wave and priority

    foreach SortedSpawns(spawnEntry)
    {
        `log("RegularWaves: Wave=" @ spawnEntry.Wave @ ", Class=" @ spawnEntry.ZedClass @ ", Count=" @ spawnEntry.Count @ ", Priority=" @ spawnEntry.Priority);
        numToSpawn = Round(spawnEntry.Count * (1 + default.Setup.ExtraSpawnPerWave * (waveNum - 1)) * (1 + default.Setup.ExtraSpawnPerPlayer * playerNum)); // Calculate the number of monsters to spawn based on the count and the extra spawn multipliers
        for (count = 0; count < numToSpawn; count++)
        {
            SpawnList.AddItem(class<KFPawn_Monster>(DynamicLoadObject(spawnEntry.ZedClass, class'Class'))); // Add the monster class to the spawn list based on the count
        }
    }

    return SpawnList;
}

public static function int GetWaveCount()
{
    return default.WaveCount;
}