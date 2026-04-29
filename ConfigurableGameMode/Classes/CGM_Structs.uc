class CGM_Structs extends Object;

struct EntryInt
{
    var int Setup;
    var int Value;
};

struct EntryFloat
{
    var int Setup;
    var float Value;
};

struct EntryBool
{
    var int Setup;
    var bool Value;
};

struct GameSetup
{
    var int DisplayMode;
    var int Number;
    var int MaxWave;
    var int InitialDosh;
    var int TraderTime;
    var bool bStartWithTrader;
    var float XpScale;
    var float DoshScale;
    var float ExtraSpawnPerWave;
    var float ExtraSpawnPerPlayer;
    var int MaxAlive;
    var int Interval;
    var float ZedHealthScale;
    var float ExtraHealthPerWave;
    var float ExtraHealthPerPlayer;
    var float MaxHealthScale;
    var float ZedResistanceScale;
    var float ExtraResistancePerWave;
    var float MaxResistanceScale;
    var float ZedDamageScale;
    var float ExtraDamagePerWave;
    var float MaxDamageScale;
    var float ZedSpeedScale;
    var float ExtraSpeedPerWave;
    var float MaxSpeedScale;
    var bool bUseStockScaling;
    var bool bEnableBossWaves;
};

struct SpawnEntryCfg
{
    var int Setup;
    var int Wave;
    var string ZedClass;
    var int Count;
    var int Priority;
    var int Delay;
    var int MaxAliveToSpawn;
    var int SquadSize;
    var float ExtraPerWave;
    var float ExtraPerPlayer;
};

struct SpawnInfo
{
    var class<KFPawn_Monster> ZedClass;
    var int Count;
    var int Delay;
    var int MaxAliveToSpawn;
    var int SquadSize;
    var float ExtraPerWave;
    var float ExtraPerPlayer;
};

struct RandomSpawnGroup
{
    var int Setup;
    var int Number;
    var int Type;
    var int Frequency;
};

struct SpawnWave
{
    var int Number;
    var Array<SpawnEntryCfg> Spawns;
};