class WM_Waves extends Object
    dependson(WM_SpawnManager)
    config(WM_SpawnManager);

struct SpawnEntry
{
    var int Setup;
    var int Wave;
    var string ZedClass;
    var int Count;
    var int Priority;
};

struct RandomSpawnGroup
{
    var int Setup;
    var int Number;
    var int Frequency;
};

struct SpawnWave
{
    var int Number;
    var Array< class<KFPawn_Monster> > Spawns;
};

var GameSetup Setup;
var config Array<SpawnWave> SpawnWaves;
var config int WaveCount;

delegate int SortSpawnEntry(SpawnEntry A, SpawnEntry B)
{
	return (A.Wave > B.Wave && A.Priority < B.Priority) ? -1 : 0;
}

public static function Init(GameSetup setup){}

public static function Array< class<KFPawn_Monster> > GetSpawnList(int waveNum, int playerNum){}

public static function int GetWaveCount(){}