class GameSetups extends Object
    config(WM_SpawnManager);

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
    var int Number;
    var int MaxWave;
    var int InitialDosh;
    var int TraderTime;
    var bool bStartWithTrader;
    var float ZedHealthScale;
    var float XpScale;
    var float DoshScale;
    var float ExtraSpawnPerWave;
    var float ExtraSpawnPerPlayer;
    var int MaxAlive;
    var int Interval;
};

var public config Array<EntryInt> MaxWave;
var public config Array<EntryInt> InitialDosh;
var public config Array<EntryInt> TraderTime;
var public config Array<EntryBool> bStartWithTrader;
var public config Array<EntryFloat> ZedHealthScale;
var public config Array<EntryFloat> XpScale;
var public config Array<EntryFloat> DoshScale;
var public config Array<EntryFloat> ExtraSpawnPerWave;
var public config Array<EntryFloat> ExtraSpawnPerPlayer;
var public config Array<EntryInt> MaxAlive;
var public config Array<EntryInt> Interval;

public static function GameSetup GetCurrentSetup(int setupNum)
{
    local GameSetup setup;
    local EntryInt intEntry;
    local EntryFloat floatEntry;
    local EntryBool boolEntry;

    foreach default.MaxWave(intEntry)
    {
        if (intEntry.Setup == setupNum)
        {
            setup.MaxWave = intEntry.Value;
            break;
        }
    }

    foreach default.InitialDosh(intEntry)
    {
        if (intEntry.Setup == setupNum)
        {
            setup.InitialDosh = intEntry.Value;
            break;
        }
    }

    foreach default.TraderTime(intEntry)
    {
        if (intEntry.Setup == setupNum)
        {
            setup.TraderTime = intEntry.Value;
            break;
        }
    }

    foreach default.bStartWithTrader(boolEntry)
    {
        if (boolEntry.Setup == setupNum)
        {
            setup.bStartWithTrader = boolEntry.Value;
            break;
        }
    }

    foreach default.ZedHealthScale(floatEntry)
    {
        if (floatEntry.Setup == setupNum)
        {
            setup.ZedHealthScale = floatEntry.Value;
            break;
        }
    }

    foreach default.XpScale(floatEntry)
    {
        if (floatEntry.Setup == setupNum)
        {
            setup.XpScale = floatEntry.Value;
            break;
        }
    }

    foreach default.DoshScale(floatEntry)
    {
        if (floatEntry.Setup == setupNum)
        {
            setup.DoshScale = floatEntry.Value;
            break;
        }
    }

    foreach default.ExtraSpawnPerWave(floatEntry)
    {
        if (floatEntry.Setup == setupNum)
        {
            setup.ExtraSpawnPerWave = floatEntry.Value;
            break;
        }
    }

    foreach default.ExtraSpawnPerPlayer(floatEntry)
    {
        if (floatEntry.Setup == setupNum)
        {
            setup.ExtraSpawnPerPlayer = floatEntry.Value;
            break;
        }
    }

    foreach default.MaxAlive(intEntry)
    {
        if (intEntry.Setup == setupNum)
        {
            setup.MaxAlive = intEntry.Value;
            break;
        }
    }

    foreach default.Interval(intEntry)
    {
        if (intEntry.Setup == setupNum)
        {
            setup.Interval = intEntry.Value;
            break;
        }
    }

    return setup;
}