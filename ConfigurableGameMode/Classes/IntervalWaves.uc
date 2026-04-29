class IntervalWaves extends RandomWaves
    config(ConfigurableGameMode);

// var public config bool bDynamicSpawnCount;
// var public config Array<RandomSpawnGroup> Wave;
// var public config Array<SpawnEntryCfg> Spawn;

public function bool HasWaves()
{
    return self.SpawnWaves.Length > 0;
}
