class WM_Survival extends KFGameInfo_Survival;

var config int CustomNumWaves;
var config int CustomWaveMax;
var config int TotalZedsBase;

const GameSetupObj = class'GameSetups';
var GameSetup CurrentGameSetup;

event InitGame( string Options, out string ErrorMessage )
{
 	Super.InitGame( Options, ErrorMessage );
    `log("WM_Survival.InitGame()");
	CurrentGameSetup = GameSetupObj.static.GetCurrentSetup(0); // Load the first setup by default, you can change this to load different setups based on your needs
}

event PreBeginPlay()
{
	super.PreBeginPlay();

	InitSpawnManager();
	// UpdateGameSettings();
}

/** Set up the spawning */
function InitSpawnManager()
{
    `log("WM_Survival.InitSpawnManager()");
	SpawnManager = new(self) class'WM_SpawnManager';
	SpawnManager.Initialize();
	MyKFGRI.WaveMax = 255;
	WaveMax = 255;
}

event Timer()
{
	super.Timer();

	if( SpawnManager != none )
	{
		SpawnManager.Update();
	}

	if( GameConductor != none )
	{
		GameConductor.TimerUpdate();
	}
}

/** Do something when there are no AIs left */
function CheckWaveEnd( optional bool bForceWaveEnd = false )
{

    if( !MyKFGRI.bMatchHasBegun )
    {
		`log("KFGameInfo - CheckWaveEnd - Cannot check if wave has ended since match has not begun. ");
    	return;
    }

    `log("KFGameInfo.CheckWaveEnd() AIAliveCount:" @ AIAliveCount, SpawnManager.bLogAISpawning);

    if( GetLivingPlayerCount() <= 0 )
	{
//		`log("KFGameInfo.CheckWaveEnd() - Call Wave Ended - WEC_TeamWipedOut");
		WaveEnded(WEC_TeamWipedOut);
	}
	else if( (AIAliveCount <= 0 && IsWaveActive() && SpawnManager.IsFinishedSpawning()) || bForceWaveEnd )
	{
		//`log("KFGameInfo.CheckWaveEnd() - Call Wave Ended - WEC_WaveWon");
		WaveEnded(WEC_WaveWon);
	}
}