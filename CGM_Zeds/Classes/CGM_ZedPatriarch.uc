class CGM_ZedPatriarch extends KFPawn_ZedPatriarch
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