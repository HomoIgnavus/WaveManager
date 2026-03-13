class RandomWaves extends WM_Waves;

var public config Array<RandomSpawnGroup> Group;
var public config Array<SpawnEntry> Spawn;

delegate int SortSpawnGroups(RandomSpawnGroup A, RandomSpawnGroup B)
{
	return A.Number > B.Number ? -1 : 0;
}

public static function Init(GameSetup setup)
{
    Setup = setup;
    GroupSpawns();
    default.WaveCount = default.Spawn.Length;
}

private static function GroupSpawns()
{
    local SpawnWave currentGroup;
    local SpawnEntry spawnEntry;
    local Array<SpawnWave> localSpawnWaves;
    local int count;
    default.Spawn.Sort(SortSpawnEntry);
    default.Group.Sort(SortSpawnGroups);
    currentGroup.Spawns.Length = 0;
    currentGroup.Number = -1;

    foreach default.Spawn(spawnEntry)
    {
        if (spawnEntry.Wave != currentGroup.Number)
        {
            if (currentGroup.Spawns.Length > 0)
            {
                for (count = 0; count < default.Group[currentGroup.Number].Frequency; count++)
                {
                    localSpawnWaves.AddItem(currentGroup);
                }
            }
            currentGroup.Spawns.Length = 0;
            currentGroup.Number++;
        }
        currentGroup.Spawns.AddItem(class<KFPawn_Monster>(DynamicLoadObject(spawnEntry.ZedClass, class'Class')));
    }

    if (currentGroup.Spawns.Length > 0)
    {
        for (count = 0; count < default.Group[currentGroup.Number].Frequency; count++)
        {
            localSpawnWaves.AddItem(currentGroup);
        }
    }
    default.SpawnWaves = localSpawnWaves;
}

public static function Array< class<KFPawn_Monster> > GetSpawnList(int waveNum, int playerNum)
{
    local Array< class<KFPawn_Monster> > spawnList;
    local int randomGroupIndex;

    randomGroupIndex = Round(FRand() * default.Group.Length);
    spawnList = default.SpawnWaves[randomGroupIndex].Spawns;

    return spawnList;
}