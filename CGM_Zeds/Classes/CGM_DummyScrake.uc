// a scrake with no AI controller, and refills health every second. Used for testing player damage

class CGM_DummyScrake extends KFPawn_ZedScrake;

var protected float MaxHealth;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    
    `log("CGM_DummyScrake: health=" @ Health);
    if (Role == ROLE_Authority)
    {
        SetTimer(3.0f, false, 'Timer_SetHealth');
    }
}

function Timer_SetHealth()
{
    HealthMax = Health;
    Health = MaxHealth;
    SetTimer(1.0f, true, 'Timer_RegenerateHealth');
}

function Timer_RegenerateHealth()
{
    if (IsAliveAndWell())
    {
        Health = MaxHealth;
        HealthMax = MaxHealth;
        
        // Also restore head health
        HitZones[HZI_HEAD].GoreHealth = MaxHealth;
        HitZones[HZI_HEAD].MaxGoreHealth = MaxHealth;
        
        // `log("CGM_DummyScrake: health=" @ Health);
    }
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
    ClearTimer('Timer_RegenerateHealth');
    return super.Died(Killer, DamageType, HitLocation);
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
    local KFAIController KFAIC;
    
    super.PossessedBy(C, bVehicleTransition);
    
    // KFAIC = KFAIController(C);
    // if (KFAIC != none)
    // {
    //     KFAIC.StopMovement();
    // }
}

defaultproperties
{
    MaxHealth=999999999
    GroundSpeed=0
    SprintSpeed=0
    HiddenGroundSpeed=0
    RotationRate=(Pitch=0,Yaw=0,Roll=0)
    bCanRage=false
    
    // Set head health (GoreHealth) to match body health
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=999999999, DmgScale=1.1, SkinID=1)
}