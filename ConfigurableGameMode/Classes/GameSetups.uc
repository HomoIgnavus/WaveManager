class GameSetups extends Object
    dependson(CGM_Structs)
    config(ConfigurableGameMode);

var public config Array<EntryInt> DisplayMode;
var public config Array<EntryInt> MaxWave;
var public config Array<EntryInt> InitialDosh;
var public config Array<EntryInt> TraderTime;
var public config Array<EntryBool> bStartWithTrader;
var public config Array<EntryInt> InitialTraderTime;
var public config Array<EntryFloat> XpScale;
var public config Array<EntryFloat> ExtraXpPerWave;
var public config Array<EntryFloat> DoshScale;
var public config Array<EntryFloat> ExtraSpawnPerWave;
var public config Array<EntryFloat> ExtraSpawnPerPlayer;
var public config Array<EntryInt> MaxAlive;
var public config Array<EntryInt> Interval;
var public config Array<EntryFloat> ZedHealthScale;
var public config Array<EntryFloat> ExtraHealthPerWave;
var public config Array<EntryFloat> ExtraHealthPerPlayer;
var public config Array<EntryFloat> MaxHealthScale;
var public config Array<EntryFloat> ZedResistanceScale;
var public config Array<EntryFloat> ExtraResistancePerWave;
var public config Array<EntryFloat> MaxResistanceScale;
var public config Array<EntryFloat> ZedDamageScale;
var public config Array<EntryFloat> ExtraDamagePerWave;
var public config Array<EntryFloat> MaxDamageScale;
var public config Array<EntryFloat> ZedSpeedScale;
var public config Array<EntryFloat> ExtraSpeedPerWave;
var public config Array<EntryFloat> MaxSpeedScale;
var public config Array<EntryBool> bUseStockScaling;
var public config Array<EntryBool> bEnableBossWaves;
var config GameSetup CurrentSetup;

public static function GameSetup GetSetup()
{
    return default.CurrentSetup;
}

public static function GameSetup GenSetup(int SetupNum)
{
    local int SetupIndex;
    local string options;
    local GameSetup Setup;
    local EntryInt IntEntry;
    local EntryFloat FloatEntry;
    local EntryBool BoolEntry;

    Setup.Number = SetupNum;

    foreach default.DisplayMode(IntEntry)
    {
        if (IntEntry.Setup == SetupNum)
        {
            Setup.DisplayMode = IntEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() DisplayMode:" @ Setup.DisplayMode);

    foreach default.MaxWave(IntEntry)
    {
        if (IntEntry.Setup == SetupNum)
        {
            Setup.MaxWave = IntEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() MaxWave:" @ Setup.MaxWave);

    foreach default.InitialDosh(IntEntry)
    {
        if (IntEntry.Setup == SetupNum)
        {
            Setup.InitialDosh = IntEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() InitialDosh:" @ Setup.InitialDosh);

    foreach default.TraderTime(IntEntry)
    {
        if (IntEntry.Setup == SetupNum)
        {
            Setup.TraderTime = IntEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() TraderTime:" @ Setup.TraderTime);

    foreach default.bStartWithTrader(BoolEntry)
    {
        if (BoolEntry.Setup == SetupNum)
        {
            Setup.bStartWithTrader = BoolEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() bStartWithTrader:" @ Setup.bStartWithTrader);

    foreach default.InitialTraderTime(IntEntry)
    {
        if (IntEntry.Setup == SetupNum)
        {
            Setup.InitialTraderTime = IntEntry.Value;
            break;
        }
    }   
    `log("GameSetups.GenSetup() InitialTraderTime:" @ Setup.InitialTraderTime);

    foreach default.XpScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.XpScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() XpScale:" @ Setup.XpScale);

    foreach default.ExtraXpPerWave(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraXpPerWave = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraXpPerWave:" @ Setup.ExtraXpPerWave);

    foreach default.DoshScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.DoshScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() DoshScale:" @ Setup.DoshScale);

    foreach default.ExtraSpawnPerWave(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraSpawnPerWave = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraSpawnPerWave:" @ Setup.ExtraSpawnPerWave);

    foreach default.ExtraSpawnPerPlayer(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraSpawnPerPlayer = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraSpawnPerPlayer:" @ Setup.ExtraSpawnPerPlayer);

    foreach default.MaxAlive(IntEntry)
    {
        if (IntEntry.Setup == SetupNum)
        {
            Setup.MaxAlive = IntEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() MaxAlive:" @ Setup.MaxAlive);

    foreach default.Interval(IntEntry)
    {
        if (IntEntry.Setup == SetupNum)
        {
            Setup.Interval = IntEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() Interval:" @ Setup.Interval);

    foreach default.ZedHealthScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ZedHealthScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ZedHealthScale:" @ Setup.ZedHealthScale);

    foreach default.ExtraHealthPerWave(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraHealthPerWave = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraHealthPerWave:" @ Setup.ExtraHealthPerWave);

    foreach default.ExtraHealthPerPlayer(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraHealthPerPlayer = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraHealthPerPlayer:" @ Setup.ExtraHealthPerPlayer);

    foreach default.MaxHealthScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.MaxHealthScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() MaxHealthScale:" @ Setup.MaxHealthScale);

    foreach default.ZedResistanceScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ZedResistanceScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ZedResistanceScale:" @ Setup.ZedResistanceScale);

    foreach default.ExtraResistancePerWave(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraResistancePerWave = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraResistancePerWave:" @ Setup.ExtraResistancePerWave);

    foreach default.MaxResistanceScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.MaxResistanceScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() MaxResistanceScale:" @ Setup.MaxResistanceScale);

    foreach default.ZedDamageScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ZedDamageScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ZedDamageScale:" @ Setup.ZedDamageScale);

    foreach default.ExtraDamagePerWave(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraDamagePerWave = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraDamagePerWave:" @ Setup.ExtraDamagePerWave);

    foreach default.MaxDamageScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.MaxDamageScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() MaxDamageScale:" @ Setup.MaxDamageScale);

    foreach default.ZedSpeedScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ZedSpeedScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ZedSpeedScale:" @ Setup.ZedSpeedScale);

    foreach default.ExtraSpeedPerWave(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.ExtraSpeedPerWave = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() ExtraSpeedPerWave:" @ Setup.ExtraSpeedPerWave);

    foreach default.MaxSpeedScale(FloatEntry)
    {
        if (FloatEntry.Setup == SetupNum)
        {
            Setup.MaxSpeedScale = FloatEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() MaxSpeedScale:" @ Setup.MaxSpeedScale);

    foreach default.bUseStockScaling(BoolEntry)
    {
        if (BoolEntry.Setup == SetupNum)
        {
            Setup.bUseStockScaling = BoolEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() bUseStockScaling:" @ Setup.bUseStockScaling);

    foreach default.bEnableBossWaves(BoolEntry)
    {
        if (BoolEntry.Setup == SetupNum)
        {
            Setup.bEnableBossWaves = BoolEntry.Value;
            break;
        }
    }
    `log("GameSetups.GenSetup() bEnableBossWaves:" @ Setup.bEnableBossWaves);

    default.CurrentSetup = Setup;
    return Setup;
}