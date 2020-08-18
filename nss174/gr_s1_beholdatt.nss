//*:**************************************************************************
//*:*  GR_S1_BEHOLDATT.NSS
//*:**************************************************************************
//*:* Beholder Attack Spell Logic (x2_s1_beholdatt) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-08-28
//*:**************************************************************************
//*:* This spellscript is the core of the beholder's attack logic.
//*:**************************************************************************
//*:* Updated On: January 28, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"
//#include "GR_IN_SPELLHOOK" - do not need this at this point
#include "GR_IN_BEHOLDER" // INCLUDES GR_IN_SPELLS

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void SetZoneChecked(int iZone, int bValue = TRUE, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "BEH_ZONE_CHECKED"+IntToString(iZone), bValue);
}

//*:**********************************************
int GetZoneChecked(int iZone, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "BEH_ZONE_CHECKED"+IntToString(iZone));
}

//*:**********************************************
int GetZoneRays(int iZone, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "BEH_ZONE_RAYS"+IntToString(iZone));
}

//*:**********************************************
void IncZoneRays(int iZone, object oCaster=OBJECT_SELF) {

    int iNumRays = GetZoneRays(iZone);
    SetLocalInt(oCaster, "BEH_ZONE_RAYS"+IntToString(iZone), iNumRays++);
}

//*:**********************************************
void InitZoneRays(object oCaster=OBJECT_SELF) {

    int i;
    for(i=1; i<=4; i++) {
        SetLocalInt(oCaster, "BEH_ZONE_RAYS"+IntToString(i), 0);
    }
}

//*:**********************************************
void SetCharmAttempted(object oTarget) {

    SetLocalInt(oTarget, "GR_L_BEH_CHARMATTEMPTED", TRUE);
    DelayCommand(RoundsToSeconds(2), SetLocalInt(oTarget, "GR_L_BEH_CHARMATTEMPTED", FALSE));
}

//*:**********************************************
int GetCharmAttempted(object oTarget) {

    return GetLocalInt(oTarget, "GR_L_BEH_CHARMATTEMPTED");
}

//*:**********************************************
void SetTargetedByRay(object oTarget, object oCaster=OBJECT_SELF) {

    int bTargeted = GetLocalInt(oTarget, "GR_L_BEH_TARGETED_"+ObjectToString(oCaster));

    SetLocalInt(oTarget, "GR_L_BEH_TARGETED_"+ObjectToString(oCaster), bTargeted++);
    DelayCommand(GRGetDuration(1)-0.2f, DeleteLocalInt(oTarget, "GR_L_BEH_TARGETED_"+ObjectToString(oCaster)));
}

//*:**********************************************
int GetTargetedByRay(object oTarget, int iRayNumber, int iNumTargets, object oCaster=OBJECT_SELF) {

    int bTargeted = GetLocalInt(oTarget, "GR_L_BEH_TARGETED_"+ObjectToString(oCaster));

    if(iRayNumber<iNumTargets) {
        bTargeted = FALSE;
    }

    return bTargeted;
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    object  oTarget         = GetSpellTargetObject();

    int     iAppearanceType = GetAppearanceType(oCaster);
    int     bBeholderMage   = (GRGetHasClass(CLASS_TYPE_SORCERER) || GRGetHasClass(CLASS_TYPE_WIZARD));
    int     iAntimagicZone  = 0;
    int     i, j;

    //*:* Ray Target objects
    object  oAntimagicRayTarget     = OBJECT_INVALID;
    object  oCharmMonsterTarget     = OBJECT_INVALID;
    object  oCharmPersonTarget      = OBJECT_INVALID;
    object  oDisintegrateTarget     = OBJECT_INVALID;
    object  oFearTarget             = OBJECT_INVALID;
    object  oFingerDeathTarget      = OBJECT_INVALID;
    object  oFleshToStoneTarget     = OBJECT_INVALID;
    object  oInflictModWoundsTarget = OBJECT_INVALID;
    object  oSleepTarget            = OBJECT_INVALID;
    object  oSlowTarget             = OBJECT_INVALID;
    object  oTKTarget               = OBJECT_INVALID;

    object  oPossibleTarget         = OBJECT_INVALID;
    int     iPossibleTargetZone     = 0;

    //*:* keep us from dropping out of combat
    SignalEvent(oTarget, EventSpellCastAt(oCaster, GetSpellId()));

    //*:* Zone Tracking
    for(i=1; i<=4; i++) {
        SetZoneChecked(i, FALSE);
    }
    InitZoneRays();

    //*:**********************************************
    //*:* Determine targets
    //*:**********************************************
    struct beholder_target_struct btsTargets = GetRayTargets(oTarget);

    //*:**********************************************
    //*:* Determine which targets get which rays
    //*:**********************************************
    //*:* Antimagic Eye
    if(!bBeholderMage) {
        if(GetAntiMagicRayMakesSense(btsTargets.oCasterTarget)) {
            TurnToFaceObject(btsTargets.oCasterTarget);
            oAntimagicRayTarget = btsTargets.oCasterTarget;
            iAntimagicZone = btsTargets.iCasterTargetZone;
        } else {
            SetZoneChecked(btsTargets.iCasterTargetZone);
            //*:* see if another zone makes sense
            for(i=1; i<=4 && oAntimagicRayTarget==OBJECT_INVALID; i++) {
                if(!GetZoneChecked(i)) {
                    // need to determine a target in the zone
                    for(j=1; j<=btsTargets.iNumTargets && oAntimagicRayTarget==OBJECT_INVALID; j++ ) {
                        if(i==GRIntGetValueAt(ARR_NAME, THREAT_ZONE, j)) {
                            oAntimagicRayTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, j);
                            if(GetAntiMagicRayMakesSense(oAntimagicRayTarget)) {
                                TurnToFaceObject(oAntimagicRayTarget);
                                iAntimagicZone = i;
                            } else {
                                oAntimagicRayTarget = OBJECT_INVALID;
                            }
                        }
                    }
                }
                SetZoneChecked(i);
            }
        }
    }


    if(btsTargets.iNumTargets>1) {
        //*:**********************************************
        //*:* Charm Monster
        //*:**********************************************
        if(!GetCharmAttempted(btsTargets.oFighterTarget) &&  btsTargets.iFighterTargetZone!=iAntimagicZone &&
            !BehDetermineHasEffect(BEHOLDER_RAY_CHARM_MON, btsTargets.oFighterTarget)) {

            oCharmMonsterTarget = btsTargets.oFighterTarget;
            IncZoneRays(btsTargets.iFighterTargetZone);
            SetTargetedByRay(oCharmMonsterTarget);
        } else {
            oPossibleTarget = OBJECT_INVALID;
            iPossibleTargetZone = 0;
            for(i=1; i<=btsTargets.iNumTargets && oCharmMonsterTarget==OBJECT_INVALID; i++) {
                if(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone) { // cannot be in zone getting antimagic ray
                    // here we store the best target not in the antimagic zone in case we don't find one who's best save isn't Will
                    if(oPossibleTarget==OBJECT_INVALID) {
                        oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                        iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                        if(BehDetermineHasEffect(BEHOLDER_RAY_CHARM_MON, oPossibleTarget)) oPossibleTarget = OBJECT_INVALID;
                    }
                    if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_WILL) {
                        oCharmMonsterTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                        if(BehDetermineHasEffect(BEHOLDER_RAY_CHARM_MON, oCharmMonsterTarget)) {
                            oCharmMonsterTarget = OBJECT_INVALID;
                        } else {
                            IncZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i));
                            SetTargetedByRay(oCharmMonsterTarget);
                        }
                    }
                }
            }
            if(oCharmMonsterTarget==OBJECT_INVALID) {
                oCharmMonsterTarget = oPossibleTarget;
                if(GetIsObjectValid(oCharmMonsterTarget)) {
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oCharmMonsterTarget);
                }
            }
        }

        //*:**********************************************
        //*:* Charm Person
        //*:**********************************************
        if(btsTargets.oRogueTarget!=oCharmMonsterTarget && !GetCharmAttempted(btsTargets.oRogueTarget) &&
            btsTargets.iRogueTargetZone!=iAntimagicZone && !BehDetermineHasEffect(BEHOLDER_RAY_CHARM_PER, btsTargets.oRogueTarget)) {

            oCharmPersonTarget = btsTargets.oRogueTarget;
            IncZoneRays(btsTargets.iRogueTargetZone);
            SetTargetedByRay(oCharmPersonTarget);
        } else {
            oPossibleTarget = OBJECT_INVALID;
            iPossibleTargetZone = 0;
            for(i=1; i<=btsTargets.iNumTargets && oCharmPersonTarget==OBJECT_INVALID; i++) {
                if(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone) { // cannot be in zone getting antimagic ray
                    if(GRGetIsHumanoid(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i))) {  // charm person targets must be humanoid
                        // here we store the best target not in the antimagic zone in case we don't find one who's best save isn't Will
                        if(oPossibleTarget==OBJECT_INVALID) {
                            oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                            iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                            if(BehDetermineHasEffect(BEHOLDER_RAY_CHARM_PER, oPossibleTarget)) oPossibleTarget = OBJECT_INVALID;
                        }
                        // we'll let oPossibleTarget possibly = oCharmMonsterTarget just in case we can't find another good
                        // charm target
                        if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_WILL &&
                            GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i)!=oCharmMonsterTarget) {

                            oCharmPersonTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                            if(BehDetermineHasEffect(BEHOLDER_RAY_CHARM_PER, oCharmPersonTarget)) {
                                oCharmPersonTarget = OBJECT_INVALID;
                            } else {
                                IncZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i));
                                SetTargetedByRay(oCharmPersonTarget);
                            }
                        }
                    }
                }
            }
            if(oCharmPersonTarget==OBJECT_INVALID) {
                oCharmPersonTarget = oPossibleTarget;
                if(GetIsObjectValid(oCharmPersonTarget)) {
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oCharmPersonTarget);
                }
            }
        }

        //*:**********************************************
        //*:* Finger of Death
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        //*:* Try to kill top ranking target with weaker fort save
        //*:* Try not to double up on charm targets
        //*:* Cannot cast into antimagic area
        for(i=1; i<=btsTargets.iNumTargets && oFingerDeathTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 3, btsTargets.iNumTargets) &&
                GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i, OBJECT_SELF)!=iAntimagicZone) {

                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_FORT) {
                    oFingerDeathTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oFingerDeathTarget);
                }
            }
        }
        if(oFingerDeathTarget==OBJECT_INVALID) {
            oFingerDeathTarget = oPossibleTarget;
            if(oFingerDeathTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oFingerDeathTarget);
            }
        }

        //*:**********************************************
        //*:* Disintegrate
        //*:**********************************************
        //*:* From here on we must check if firing more
        //*:* than 3 rays into same zone
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        for(i=1; i<=btsTargets.iNumTargets && oDisintegrateTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 4, btsTargets.iNumTargets) &&
                GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone && GetZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i))<3) {
                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_FORT) {
                    oDisintegrateTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oDisintegrateTarget);
                }
            }
        }
        if(oDisintegrateTarget==OBJECT_INVALID) {
            oDisintegrateTarget = oPossibleTarget;
            if(oDisintegrateTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oDisintegrateTarget);
            }
        }

        //*:**********************************************
        //*:* Flesh To Stone
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        for(i=1; i<=btsTargets.iNumTargets && oFleshToStoneTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 5, btsTargets.iNumTargets) &&
                GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone && GetZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i))<3 &&
                !BehDetermineHasEffect(BEHOLDER_RAY_FLESH_TO_STONE, GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i))) {
                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_FORT) {
                    oFleshToStoneTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oFleshToStoneTarget);
                }
            }
        }
        if(oFleshToStoneTarget==OBJECT_INVALID) {
            oFleshToStoneTarget = oPossibleTarget;
            if(oFleshToStoneTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oFleshToStoneTarget);
            }
        }

        //*:**********************************************
        //*:* Telekinesis
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        for(i=1; i<=btsTargets.iNumTargets && oTKTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 6, btsTargets.iNumTargets) &&
                GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone && GetZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i))<3 &&
                !BehDetermineHasEffect(BEHOLDER_RAY_TK, GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i))) {
                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)==SAVING_THROW_WILL) {
                    oTKTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oTKTarget);
                }
            }
        }
        if(oTKTarget==OBJECT_INVALID) {
            oTKTarget = oPossibleTarget;
            if(oTKTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oTKTarget);
            }
        }

        //*:**********************************************
        //*:* Inflict Moderate Wounds
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        for(i=1; i<=btsTargets.iNumTargets && oInflictModWoundsTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 7, btsTargets.iNumTargets) &&
                GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone && GetZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i))<3) {
                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_FORT) {
                    oInflictModWoundsTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oInflictModWoundsTarget);
                }
            }
        }
        if(oInflictModWoundsTarget==OBJECT_INVALID) {
            oInflictModWoundsTarget = oPossibleTarget;
            if(oInflictModWoundsTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oInflictModWoundsTarget);
            }
        }

        //*:**********************************************
        //*:* Fear
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        for(i=1; i<=btsTargets.iNumTargets && oFearTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 8, btsTargets.iNumTargets) &&
                GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone && GetZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i))<3 &&
                !BehDetermineHasEffect(BEHOLDER_RAY_FEAR, GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i))) {
                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_WILL) {
                    oFearTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oFearTarget);
                }
            }
        }
        if(oFearTarget==OBJECT_INVALID) {
            oFearTarget = oPossibleTarget;
            if(oFearTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oFearTarget);
            }
        }

        //*:**********************************************
        //*:* Slow
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        for(i=1; i<=btsTargets.iNumTargets && oSlowTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 9, btsTargets.iNumTargets) && GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone && GetZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i))<3 &&
                !BehDetermineHasEffect(BEHOLDER_RAY_SLOW, GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i))) {
                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_WILL) {
                    oSlowTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oSlowTarget);
                }
            }
        }
        if(oSlowTarget==OBJECT_INVALID) {
            oSlowTarget = oPossibleTarget;
            if(oSlowTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oSlowTarget);
            }
        }

        //*:**********************************************
        //*:* Sleep
        //*:**********************************************
        oPossibleTarget = OBJECT_INVALID;
        iPossibleTargetZone = 0;
        for(i=1; i<=btsTargets.iNumTargets && oSleepTarget==OBJECT_INVALID; i++) {
            if(!GetTargetedByRay(GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i), 10, btsTargets.iNumTargets) && GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i)!=iAntimagicZone && GetZoneRays(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i))<3 &&
                !BehDetermineHasEffect(BEHOLDER_RAY_SLEEP, GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i))) {
                oPossibleTarget = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i);
                iPossibleTargetZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i);
                if(GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i)!=SAVING_THROW_WILL) {
                    oSleepTarget = oPossibleTarget;
                    IncZoneRays(iPossibleTargetZone);
                    SetTargetedByRay(oSleepTarget);
                }
            }
        }
        if(oSleepTarget==OBJECT_INVALID) {
            oSleepTarget = oPossibleTarget;
            if(oSleepTarget!=OBJECT_INVALID) {
                IncZoneRays(iPossibleTargetZone);
                SetTargetedByRay(oSleepTarget);
            }
        }
    }

    //*:**********************************************
    //*:* Fire Beams
    //*:**********************************************
    if(GetIsObjectValid(oAntimagicRayTarget)) BehDoFireBeam(BEHOLDER_RAY_ANTIMAGIC_EYE, oAntimagicRayTarget);
    if(GetIsObjectValid(oCharmMonsterTarget)) BehDoFireBeam(BEHOLDER_RAY_CHARM_MON, oCharmMonsterTarget);
    if(GetIsObjectValid(oCharmPersonTarget)) BehDoFireBeam(BEHOLDER_RAY_CHARM_PER, oCharmPersonTarget);
    if(GetIsObjectValid(oFingerDeathTarget)) BehDoFireBeam(BEHOLDER_RAY_FINGER_DEATH, oFingerDeathTarget);
    if(GetIsObjectValid(oDisintegrateTarget)) BehDoFireBeam(BEHOLDER_RAY_DISINTEGRATE, oDisintegrateTarget);
    if(GetIsObjectValid(oFleshToStoneTarget)) BehDoFireBeam(BEHOLDER_RAY_FLESH_TO_STONE, oFleshToStoneTarget);
    if(GetIsObjectValid(oTKTarget)) BehDoFireBeam(BEHOLDER_RAY_TK, oTKTarget);
    if(GetIsObjectValid(oInflictModWoundsTarget)) BehDoFireBeam(BEHOLDER_RAY_INFLICT_MOD_WOUNDS, oInflictModWoundsTarget);
    if(GetIsObjectValid(oFearTarget)) BehDoFireBeam(BEHOLDER_RAY_FEAR, oFearTarget);
    if(GetIsObjectValid(oSlowTarget)) BehDoFireBeam(BEHOLDER_RAY_SLOW, oSlowTarget);
    if(GetIsObjectValid(oSleepTarget)) BehDoFireBeam(BEHOLDER_RAY_SLEEP, oSleepTarget);

}
//*:**************************************************************************
//*:**************************************************************************
