class CGM_ZedFleshpoundKing extends KFPawn_ZedFleshpoundKing
    dependson(CGM_Survival);

/** Play music for this boss (overridden for each boss) */
function PlayBossMusic()
{
    return;
}

static simulated event bool IsABoss()
{
	return False;
}