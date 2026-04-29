class CGM_ZedMatriarch extends KFPawn_ZedMatriarch
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