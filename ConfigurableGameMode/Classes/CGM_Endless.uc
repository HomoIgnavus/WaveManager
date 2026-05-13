class CGM_Endless extends CGM_Survival;

var private int TrueWaveCount;

function SetupNextWave(int WaveBuffer)
{
	SpawnManager.SetupNextWave(TrueWaveCount - 1, WaveBuffer);
}

public function StartWave()
{
	super.StartWave();
	WaveNum--;
	TrueWaveCount++;
}

defaultproperties
{
	TrueWaveCount = 0
}