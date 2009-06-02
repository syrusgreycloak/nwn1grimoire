//*:**************************************************************************
//*:*  GR_IN_BEHOLDER.NSS
//*:**************************************************************************
//*:* Beholder AI and Attack Include (x2_inc_beholder) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller Created On: August, 2003
//*:**************************************************************************
//*:* Updated On: January 28, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
//#include "x0_i0_position" - INCLUDED THROUGH GR_IN_SPELLS->GR_IN_LIB

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
//*:* #include "GR_IN_SPELLHOOK"
#include "GR_IN_ARRLIST"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************
const int BEHOLDER_RAY_CHARM_MON = 1;
const int BEHOLDER_RAY_CHARM_PER = 2;
const int BEHOLDER_RAY_DISINTEGRATE = 3;
const int BEHOLDER_RAY_FEAR = 4;
const int BEHOLDER_RAY_FINGER_DEATH = 5;
const int BEHOLDER_RAY_FLESH_TO_STONE = 6;
const int BEHOLDER_RAY_INFLICT_MOD_WOUNDS = 7;
const int BEHOLDER_RAY_SLEEP = 8;
const int BEHOLDER_RAY_SLOW = 9;
const int BEHOLDER_RAY_TK = 10;
const int BEHOLDER_RAY_ANTIMAGIC_EYE = 11;

const string ARR_NAME = "GR_BEH";
const string THREAT_OBJECT = "OBJECT";
const string THREAT_ZONE = "ZONE";
const string THREAT_RATING = "RATING";
const string THREAT_SAVE = "SAVE";

/*const int BEHOLDER_RAY_DEATH = 1;
const int BEHOLDER_RAY_TK = 2;
const int BEHOLDER_RAY_PETRI= 3;
const int BEHOLDER_RAY_CHARM = 4;
const int BEHOLDER_RAY_SLOW = 5;
const int BEHOLDER_RAY_WOUND = 6;
const int BEHOLDER_RAY_FEAR = 7;
/* Beholder rays are DC 17
Charm Monster
Charm Person
Disintegrate
Fear
Finger of Death
Flesh to Stone
Inflict Moderate Wounds
Sleep
Slow
Telekinesis
*/

struct beholder_target_struct {
    //*:* instead of keeping the target list and threat ratings in the struct
    //*:* we will make a threat rating list array stored in locals on the 'holder.
    int     iNumTargets;            // total number of possible targets in the area
    int     iZone1Targets;          // number of targets in zone 1 (current front of beholder)
    int     iZone2Targets;          // number of targets in zone 2 (left of beholder)
    int     iZone3Targets;          // number of targets in zone 3 (right of beholder)
    int     iZone4Targets;          // number of targets in zone 4 (behind beholder)
    object  oCasterTarget;
    int     iCasterTargetZone;
    int     iCasterThreatRating;
    int     iCasterTargetLevels;
    object  oFighterTarget;
    int     iFighterTargetZone;
    int     iFighterThreatRating;
    int     iFighterTargetLevels;
    object  oRogueTarget;
    int     iRogueTargetZone;
    int     iRogueThreatRating;
    int     iRogueTargetLevels;
};

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
struct beholder_target_struct NewBeholderTargetStruct();

int   GetAntiMagicRayMakesSense(object oTarget);
void  OpenAntiMagicEye(object oTarget);
void  CloseAntiMagicEye(object oTarget);
int BehGetTargetThreatRating(object oTarget, struct class_info csClassInfo);
int   BehDetermineHasEffect(int nRay, object oCreature);
void  BehDoFireBeam(int nRay, object oTarget);

struct beholder_target_struct GetRayTargets(object oTarget);

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
struct beholder_target_struct NewBeholderTargetStruct() {

    struct beholder_target_struct bts;

    bts.iNumTargets = 0;
    bts.iZone1Targets = 0;
    bts.iZone2Targets = 0;
    bts.iZone3Targets = 0;
    bts.iZone4Targets = 0;
    bts.oCasterTarget = OBJECT_INVALID;
    bts.iCasterTargetZone = 0;
    bts.iCasterThreatRating = 0;
    bts.iCasterTargetLevels = 0;
    bts.oFighterTarget = OBJECT_INVALID;
    bts.iFighterTargetZone = 0;
    bts.iFighterThreatRating = 0;
    bts.iFighterTargetLevels = 0;
    bts.oRogueTarget = OBJECT_INVALID;
    bts.iRogueTargetZone = 0;
    bts.iRogueThreatRating = 0;
    bts.iRogueTargetLevels = 0;

    return bts;
}


/*:***********************************************
object GetTargetObject(int iPosition, object oCaster=OBJECT_SELF) {

    return GetLocalObject(oCaster, "GR_L_THREAT_LIST_"+IntToString(iPosition));
}

//*:***********************************************
int GetTargetThreatRating(int iPosition, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_L_THREAT_RATING_"+IntToString(iPosition));
}

//*:***********************************************
int GetTargetZone(int iPosition, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_L_THREAT_ZONE_"+IntToString(iPosition));
}

//*:***********************************************
int GetTargetBestSave(int iPosition, object oCaster=OBJECT_SELF) {

    return GetLocalInt(oCaster, "GR_L_THREAT_SAVE_"+IntToString(iPosition));
}

//*:***********************************************
void SetTargetObject(int iPosition, object oTarget, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_L_THREAT_LIST_"+IntToString(iPosition), oTarget);
}

//*:***********************************************
void SetTargetThreatRating(int iPosition, int iThreatRating, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_L_THREAT_RATING_"+IntToString(iPosition), iThreatRating);
}

//*:***********************************************
void SetTargetZone(int iPosition, int iZone, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_L_THREAT_ZONE_"+IntToString(iPosition), iZone);
}

//*:***********************************************
void SetTargetBestSave(int iPosition, int iSave, object oCaster=OBJECT_SELF) {

    SetLocalInt(oCaster, "GR_L_THREAT_SAVE_"+IntToString(iPosition), iSave);
}
*/
//*:***********************************************
int GetAntiMagicRayMakesSense(object oTarget) {

    if(!GetIsObjectValid(oTarget)) return FALSE;

    int bMakesSense = TRUE;
    int iEffType;
    int i;
    struct class_info cisClassInfo = GRGetClassInfo(oTarget);

    if(cisClassInfo.iCastingLevels>4) {
        return TRUE;
    }

    effect eTest = GetFirstEffect(oTarget);

    while(GetIsEffectValid(eTest) && bMakesSense == TRUE ) {
        iEffType = GetEffectType(eTest);
        if(iEffType == EFFECT_TYPE_STUNNED || iEffType == EFFECT_TYPE_PARALYZE  ||
            iEffType == EFFECT_TYPE_SLEEP || iEffType == EFFECT_TYPE_PETRIFY  ||
            iEffType == EFFECT_TYPE_CHARMED  || iEffType == EFFECT_TYPE_CONFUSED ||
            iEffType == EFFECT_TYPE_FRIGHTENED || iEffType == EFFECT_TYPE_SLOW )
        {
            bMakesSense = FALSE;
        }

        eTest = GetNextEffect(oTarget);
    }

    if(GetHasSpellEffect(727, oTarget) || GRGetMagicBlocked(oTarget)) { // already antimagic/magic-dead area
        bMakesSense = FALSE;
    }

    return bMakesSense;
}

//*:***********************************************
/*void OpenAntiMagicEye(object oTarget) {

    if(GetAntiMagicRayMakesSense(oTarget)) {
        ActionCastSpellAtObject(727 , GetSpellTargetObject(),METAMAGIC_ANY,TRUE,0, PROJECTILE_PATH_TYPE_DEFAULT,TRUE);
    }
}*/

//*:***********************************************
// being a badass beholder, we close our antimagic eye only to attack with our eye rays
// and then reopen it...
//*:***********************************************
/*void CloseAntiMagicEye(object oTarget) {

    RemoveSpellEffects(727, OBJECT_SELF, oTarget);
}*/

//*:***********************************************
// stacking protection
//*:***********************************************
int BehDetermineHasEffect(int iRayType, object oCreature) {

    if(GetIsDead(oCreature)) return TRUE;  // if they're dead, does it really matter?

    switch(iRayType) {
        case BEHOLDER_RAY_ANTIMAGIC_EYE:
            if(GetHasSpellEffect(727, oCreature)) return TRUE;
        case BEHOLDER_RAY_CHARM_MON:
        case BEHOLDER_RAY_CHARM_PER:
            if(GetHasEffect(EFFECT_TYPE_CHARMED, oCreature)) {
                if(!GetIsPC(GetMaster(oCreature))) return TRUE;
            }
            break;
        //case BEHOLDER_RAY_DISINTEGRATE:  no effect to check
        case BEHOLDER_RAY_FEAR:
            if(GetHasEffect(EFFECT_TYPE_FRIGHTENED, oCreature)) return TRUE;
        /*case BEHOLDER_RAY_FINGER_DEATH:
            if(GetIsDead(oCreature)) return TRUE;*/
        case BEHOLDER_RAY_FLESH_TO_STONE:
            if(GetHasEffect(EFFECT_TYPE_PETRIFY, oCreature)) return TRUE;
        //case BEHOLDER_RAY_INFLICT_MOD_WOUNDS: no effect to check
        case BEHOLDER_RAY_SLEEP:
            if(GetHasEffect(EFFECT_TYPE_SLEEP, oCreature)) return TRUE;
        case BEHOLDER_RAY_SLOW:
            if(GetHasEffect(EFFECT_TYPE_SLOW, oCreature)) return TRUE;
        case BEHOLDER_RAY_TK:
            if(GetHasSpellEffect(777, oCreature)) return TRUE;
    }

    return FALSE;
}

//*:***********************************************
int BehGetTargetThreatRating(object oTarget, struct class_info csClassInfo) {

    if(oTarget==OBJECT_INVALID || GetIsDead(oTarget)) {
        return 0;
    }

    int i, iClassType;

    int iThreatValue = 20;


    //*:* Character level comparison
    iThreatValue += (GetHitDice(oTarget)-GetHitDice(OBJECT_SELF)/2);

    if(GetHitDice(oTarget)>20) iThreatValue += GetHitDice(oTarget)-20;

    //*:* Melee Distance
    if(GetDistanceBetween(oTarget, OBJECT_SELF)<5.0f) {
        iThreatValue += 3;
        if(csClassInfo.bBarbarian || csClassInfo.bFighter || csClassInfo.bRogue || csClassInfo.bConstruct || csClassInfo.bDragon ||
            csClassInfo.bGiant || csClassInfo.bAssassin) {
            iThreatValue += 6;
        } else if(csClassInfo.bCleric || csClassInfo.bRanger || csClassInfo.bPaladin || csClassInfo.bDruid || csClassInfo.bWeaponmaster ||
            csClassInfo.bDragonDisciple || csClassInfo.bOutsider || csClassInfo.bElemental) {
            iThreatValue += 3;
        } else if(csClassInfo.bOoze || csClassInfo.bUndead || csClassInfo.bShapechanger || csClassInfo.bMagicBeast || csClassInfo.bShifter) {
            iThreatValue += 2;
        }
    } else {
    //*:* Ranged Distance
        if(csClassInfo.bArcaneArcher || csClassInfo.bSorcerer || csClassInfo.bWizard || csClassInfo.bRanger || csClassInfo.bGiant ||
            csClassInfo.bDragon) {
            iThreatValue += 9;
        } else if(csClassInfo.bCleric || csClassInfo.bDruid || csClassInfo.bBlackguard || csClassInfo.bDragonDisciple || csClassInfo.bShifter) {
            iThreatValue += 4;
        }
    }
    //*:* If the target is attacking another creature, let's worry about it less than those actually attacking us
    if(GetAttackTarget(oTarget)!=OBJECT_SELF && GetAttackTarget(oTarget)!=OBJECT_INVALID) iThreatValue -= 4;

    //*:* can't really hurt plot targets
    if(GetPlotFlag(oTarget)) iThreatValue -= 6;

    /*  not sure why we're reducing threat of associates with a master
        should based on other criteria like class, distance, etc.*/
    //if(GetMaster(oTarget)!=OBJECT_INVALID) iThreatValue -= 4;

    //*:* If stoned, may not be permanent due to game difficulty level, so still may be a threat, but we'll worry about them later
    if(GetHasEffect(EFFECT_TYPE_PETRIFY, oTarget)) iThreatValue -= 10;

    //*:* easy targets that are close and may become dangerous should be dealt with swiftly to decrease numbers
    if((GetHasEffect(EFFECT_TYPE_FRIGHTENED, oTarget) || GetHasEffect(EFFECT_TYPE_PARALYZE, oTarget) || GetHasEffect(EFFECT_TYPE_SLEEP, oTarget)) &&
        GetDistanceBetween(oTarget, OBJECT_SELF)<10.0f) iThreatValue += 15;

    //*:* confused creatures are dangerous not only to us, but also to their allies.  let's keep them around a bit
    if(GetHasEffect(EFFECT_TYPE_CONFUSED, oTarget)) iThreatValue -= 2;

    //*:* we want to keep the creatures we charmed as long as possible
    if(GRGetHasEffectTypeFromCaster(EFFECT_TYPE_CHARMED, oTarget, OBJECT_SELF)) iThreatValue -= 20;

    //*:* regenerating creatures will take longer to kill, try to kill them quickly or get them to help us
    if(GetHasEffect(EFFECT_TYPE_REGENERATE, oTarget)) iThreatValue += 10;

    //*:* creatures that have polymorphed get extra abilities.
    if(GetHasEffect(EFFECT_TYPE_POLYMORPH, oTarget)) iThreatValue += 3;

    //*:* slowed creatures not as dangerous
    if(GetHasEffect(EFFECT_TYPE_SLOW, oTarget)) iThreatValue -= 2;

    //*:* stunned and dazed creatures are easier targets
    if(GetHasEffect(EFFECT_TYPE_STUNNED, oTarget) || GetHasEffect(EFFECT_TYPE_DAZED)) iThreatValue += 2;

    //*:* hasted creatures get more attacks. we need to deal with them quickly
    if(GetHasEffect(EFFECT_TYPE_HASTE, oTarget) || GetHasSpellEffect(SPELL_HASTE, oTarget) || GetHasFeatEffect(FEAT_EPIC_BLINDING_SPEED, oTarget)) {
        iThreatValue += 5;
    }

    //*:* blind creatures not as much of a threat
    if(GetHasEffect(EFFECT_TYPE_BLINDNESS, oTarget)) iThreatValue -= 2;

    //*:* concealed creatures harder to hit.  maybe try to deal with others first
    if(GetHasEffect(EFFECT_TYPE_CONCEALMENT, oTarget)) iThreatValue -= 2;

    //*:* knocked down creatures not a danger this time around
    if(GetHasSpellEffect(777, oTarget)) iThreatValue -= 5;

    return iThreatValue;

}

//*:***********************************************
int BehDetermineTargetZoneLocation(object oTarget, object oMe = OBJECT_SELF) {

    int iZone = 0;

    float fAngle = GetNormalizedDirection(GetAngleBetweenLocations(GetLocation(oTarget), GetLocation(oMe)));

    if(fAngle>45.0 && fAngle<=135.0) {
        iZone = 1;
    } else if(fAngle>135.0 && fAngle<=225.0) {
        iZone = 2;
    } else if(fAngle>315.0 || fAngle<=45.0) {
        iZone = 3;
    } else if(fAngle>225.0 && fAngle<=315.0) {
        iZone = 4;
    }

    return iZone;
}

//*:***********************************************
struct beholder_target_struct GetRayTargets(object oTargetCreature) {

    struct beholder_target_struct   btsTargets      = NewBeholderTargetStruct();
    struct class_info               cisClassInfo;
    float   fRange                  = FeetToMeters(150.0);  // range of eye rays
    location lTarget                = GetLocation(OBJECT_SELF);
    object  oTarget                 = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    int     iThreatRating;
    int     iZoneLocation;
    int     i, j;

    GRCreateArrayList(ARR_NAME, THREAT_ZONE, VALUE_TYPE_INT, OBJECT_SELF, THREAT_RATING, VALUE_TYPE_INT, THREAT_SAVE, VALUE_TYPE_INT);
    GRAddArrayDimension(ARR_NAME, THREAT_OBJECT, VALUE_TYPE_OBJECT, OBJECT_SELF);

    while(GetIsObjectValid(oTarget)) {
        //*:* Determine if is a target
        if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF, NO_CASTER) ||
            (GetIsFriend(oTarget) && GRGetHasEffectTypeFromCaster(EFFECT_TYPE_CHARMED, oTarget, OBJECT_SELF))) {
            //*:* Get class info, threat rating, & zone location

            cisClassInfo = GRGetClassInfo(oTarget);
            iThreatRating = BehGetTargetThreatRating(oTarget, cisClassInfo);
            if(GetIsPC(oTarget) || GetIsPC(GetMaster(oTarget))) {
                if(GetFactionEqual(oTarget, oTargetCreature)) iThreatRating += 2; // bump threat if in faction of initially passed target
            }
            iZoneLocation = BehDetermineTargetZoneLocation(oTarget);
            if((cisClassInfo.bRogue || cisClassInfo.bAssassin) && iZoneLocation!=1) iThreatRating += 2;  // bump threat of flanking rogues

            GRObjectAdd(ARR_NAME, THREAT_OBJECT, oTarget, OBJECT_SELF);
            GRIntAdd(ARR_NAME, THREAT_RATING, iThreatRating, OBJECT_SELF);
            GRIntAdd(ARR_NAME, THREAT_ZONE, iZoneLocation, OBJECT_SELF);
            GRIntAdd(ARR_NAME, THREAT_SAVE, cisClassInfo.iBestSaveType, OBJECT_SELF);

            //*:* update particular target type info
            if(cisClassInfo.iCastingLevels>btsTargets.iCasterTargetLevels) {
                if(abs(iThreatRating-btsTargets.iCasterThreatRating)<5 || iThreatRating>btsTargets.iCasterThreatRating) {
                    btsTargets.oCasterTarget = oTarget;
                    btsTargets.iCasterTargetZone = iZoneLocation;
                    btsTargets.iCasterThreatRating = iThreatRating;
                    btsTargets.iCasterTargetLevels = cisClassInfo.iCastingLevels;
                }
            }
            if(cisClassInfo.iFightingLevels>=btsTargets.iFighterTargetLevels && !cisClassInfo.bRogue && !cisClassInfo.bAssassin) {
                if(abs(iThreatRating-btsTargets.iFighterThreatRating)<=5 || iThreatRating>btsTargets.iFighterThreatRating) {
                    btsTargets.oFighterTarget = oTarget;
                    btsTargets.iFighterTargetZone = iZoneLocation;
                    btsTargets.iFighterThreatRating = iThreatRating;
                    btsTargets.iFighterTargetLevels = cisClassInfo.iFightingLevels;
                }
            }
            if(cisClassInfo.iFightingLevels>btsTargets.iRogueTargetLevels && (cisClassInfo.bRogue || cisClassInfo.bAssassin)) {
                if(abs(iThreatRating-btsTargets.iRogueThreatRating)<5 || iThreatRating>btsTargets.iRogueThreatRating) {
                    btsTargets.oRogueTarget = oTarget;
                    btsTargets.oRogueTarget = oTarget;
                    btsTargets.iRogueTargetZone = iZoneLocation;
                    btsTargets.iRogueThreatRating = iThreatRating;
                    btsTargets.iRogueTargetLevels = cisClassInfo.iFightingLevels;
                }
            }
            //*:* just in case we missed a caster that somehow didn't make the list
            //*:* we need to know this for antimagic eye use
            if(cisClassInfo.iCastingLevels>0 && btsTargets.oCasterTarget==OBJECT_INVALID) {
                btsTargets.oCasterTarget = oTarget;
                btsTargets.iCasterTargetZone = iZoneLocation;
                btsTargets.iCasterThreatRating = iThreatRating;
                btsTargets.iCasterTargetLevels = cisClassInfo.iCastingLevels;
            }
        } // end if is a target
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    } // end while(GetIsObjectValid)

    if(btsTargets.iNumTargets==0) {  // if we didn't get a target (ie all targets farther than 150ft away)
        GRDeleteArrayList(ARR_NAME, OBJECT_SELF);
        GRCreateArrayList(ARR_NAME, THREAT_ZONE, VALUE_TYPE_INT, OBJECT_SELF, THREAT_RATING, VALUE_TYPE_INT, THREAT_SAVE, VALUE_TYPE_INT);
        GRAddArrayDimension(ARR_NAME, THREAT_OBJECT, VALUE_TYPE_OBJECT, OBJECT_SELF);

        oTarget = oTargetCreature;
        //*:* Get class info, threat rating, & zone location
        cisClassInfo = GRGetClassInfo(oTarget);
        iThreatRating = BehGetTargetThreatRating(oTarget, cisClassInfo);
        if(GetIsPC(oTarget) || GetIsPC(GetMaster(oTarget))) {
            if(GetFactionEqual(oTarget, oTargetCreature)) iThreatRating += 2; // bump threat if in faction of initially passed target
        }
        iZoneLocation = BehDetermineTargetZoneLocation(oTarget);
        if((cisClassInfo.bRogue || cisClassInfo.bAssassin) && iZoneLocation!=1) iThreatRating += 2;  // bump threat of flanking rogues

        btsTargets.iNumTargets = 1;
        /*GRObjectAdd(ARR_NAME, THREAT_OBJECT, oTarget, OBJECT_SELF);
        GRIntAdd(ARR_NAME, THREAT_RATING, iThreatRating, OBJECT_SELF);
        GRIntAdd(ARR_NAME, THREAT_ZONE, iZoneLocation, OBJECT_SELF);
        GRIntAdd(ARR_NAME, THREAT_SAVE, cisClassInfo.iBestSaveType, OBJECT_SELF);*/

        if(cisClassInfo.iCastingLevels>0) {
            btsTargets.oCasterTarget = oTarget;
            btsTargets.iCasterTargetZone = iZoneLocation;
            btsTargets.iCasterThreatRating = iThreatRating;
            btsTargets.iCasterTargetLevels = cisClassInfo.iCastingLevels;
        }
        if(cisClassInfo.iFightingLevels>0) {
            btsTargets.oFighterTarget = oTarget;
            btsTargets.iFighterTargetZone = iZoneLocation;
            btsTargets.iFighterThreatRating = iThreatRating;
            btsTargets.iFighterTargetLevels = cisClassInfo.iFightingLevels;
            if(cisClassInfo.bRogue || cisClassInfo.bAssassin) {
                btsTargets.oRogueTarget = oTarget;
                btsTargets.iRogueTargetZone = iZoneLocation;
                btsTargets.iRogueThreatRating = iThreatRating;
                btsTargets.iRogueTargetLevels = cisClassInfo.iFightingLevels * 3 / 4;
            }
        }
    } else if(btsTargets.iNumTargets>1) {
        //*:* sort the array
        int i, j;
        int iThreatRating, iZone, iSave;
        object oThreat;

        for(i=2; i<=GRGetDimSize(ARR_NAME, THREAT_RATING, OBJECT_SELF); i++) {
            oThreat = GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, i, OBJECT_SELF);
            iThreatRating = GRIntGetValueAt(ARR_NAME, THREAT_RATING, i, OBJECT_SELF);
            iZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i, OBJECT_SELF);
            iSave = GRIntGetValueAt(ARR_NAME, THREAT_SAVE, i, OBJECT_SELF);
            j = i-1;
            // sort by zone first, then threat rating
            while(j>0 && (GRIntGetValueAt(ARR_NAME, THREAT_ZONE, j, OBJECT_SELF)>iZone ||
                (GRIntGetValueAt(ARR_NAME, THREAT_ZONE, j, OBJECT_SELF)==iZone && GRIntGetValueAt(ARR_NAME, THREAT_RATING, j, OBJECT_SELF)>iThreatRating))) {

                GRObjectSetValueAt(ARR_NAME, THREAT_OBJECT, j+1, GRObjectGetValueAt(ARR_NAME, THREAT_OBJECT, j, OBJECT_SELF), OBJECT_SELF);
                GRIntSetValueAt(ARR_NAME, THREAT_ZONE, j+1, GRIntGetValueAt(ARR_NAME, THREAT_ZONE, j, OBJECT_SELF), OBJECT_SELF);
                GRIntSetValueAt(ARR_NAME, THREAT_RATING, j+1, GRIntGetValueAt(ARR_NAME, THREAT_RATING, j, OBJECT_SELF), OBJECT_SELF);
                GRIntSetValueAt(ARR_NAME, THREAT_SAVE, j+1, GRIntGetValueAt(ARR_NAME, THREAT_SAVE, j, OBJECT_SELF), OBJECT_SELF);
            }
            GRObjectSetValueAt(ARR_NAME, THREAT_OBJECT, j+1, oThreat, OBJECT_SELF);
            GRIntSetValueAt(ARR_NAME, THREAT_ZONE, j+1, iZone, OBJECT_SELF);
            GRIntSetValueAt(ARR_NAME, THREAT_RATING, j+1, iThreatRating, OBJECT_SELF);
            GRIntSetValueAt(ARR_NAME, THREAT_SAVE, j+1, iSave, OBJECT_SELF);
        }

        //*:* trim up the list - 3 targets per zone
        iZone = 1;
        int iNumInZone = 0;
        int iArraySize = GRGetDimSize(ARR_NAME, THREAT_OBJECT, OBJECT_SELF);
        for(i=1; i<=iArraySize; i++) {
            if(GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i, OBJECT_SELF)==iZone) {
                if(iNumInZone<=3) {
                    iNumInZone++;
                } else {
                    GRDeletePosition(ARR_NAME, i, OBJECT_SELF);
                    iArraySize = GRGetDimSize(ARR_NAME, THREAT_OBJECT, OBJECT_SELF);
                    i--; // back up i so that when we increment, we get the new value in the "deleted" spot
                }
            } else {
                iZone = GRIntGetValueAt(ARR_NAME, THREAT_ZONE, i, OBJECT_SELF);
                iNumInZone = 1;
            }
            switch(iZone) {
                case 1:
                    btsTargets.iZone1Targets = iNumInZone;
                    break;
                case 2:
                    btsTargets.iZone2Targets = iNumInZone;
                    break;
                case 3:
                    btsTargets.iZone3Targets = iNumInZone;
                    break;
                case 4:
                    btsTargets.iZone4Targets = iNumInZone;
                    break;
            }
        }
    }

    return btsTargets;
}

//*:***********************************************
void BehDoFireBeam(int iRayType, object oTarget) {

    // don't use a ray if the target already has that effect
    /*:* SG:  We do this in the attack script now when
        deciding which targets get which ray type
    */
    /*if(BehDetermineHasEffect(iRayType, oTarget)) {
        return;
    }*/

    int bHit   = TouchAttackRanged(oTarget, FALSE)>0;
    int iProjType;

    switch(iRayType) {
        case BEHOLDER_RAY_ANTIMAGIC_EYE:        // 11
            iProjType = 727;
            break;
        case BEHOLDER_RAY_CHARM_MON:            // 1
            iProjType = 779;
            break;
        case BEHOLDER_RAY_CHARM_PER:            // 2
            iProjType = 785;
            break;
        case BEHOLDER_RAY_DISINTEGRATE:         // 3
            iProjType = 786;
            break;
        case BEHOLDER_RAY_FEAR:                 // 4
            iProjType = 784;
            break;
        case BEHOLDER_RAY_FINGER_DEATH:         // 5
            iProjType = 776;
            break;
        case BEHOLDER_RAY_FLESH_TO_STONE:       // 6
            iProjType = 778;
            break;
        case BEHOLDER_RAY_INFLICT_MOD_WOUNDS:   // 7
            iProjType = 783;
            break;
        case BEHOLDER_RAY_SLEEP:                // 8
            iProjType = 787;
            break;
        case BEHOLDER_RAY_SLOW:                 // 9
            iProjType = 780;
            break;
        case BEHOLDER_RAY_TK:                   // 10
            iProjType = 777;
            break;
    }

    if(bHit) {
        ActionCastSpellAtObject(iProjType, oTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
    } else {
        location lFail = GetLocation(oTarget);
        vector vFail = GetPositionFromLocation(lFail);

        if(GetDistanceBetween(OBJECT_SELF,oTarget) > 6.0f) {

           vFail.x += IntToFloat(Random(3)) - 1.5;
           vFail.y += IntToFloat(Random(3)) - 1.5;
           vFail.z += IntToFloat(Random(2));
           lFail = Location(GetArea(oTarget),vFail,0.0f);

        }
        //----------------------------------------------------------------------
        // if we are fairly near, calculating a location could cause us to
        // spin, so we use the same location all the time
        //----------------------------------------------------------------------
        else {
              vFail.z += 0.8;
              vFail.y += 0.2;
              vFail.x -= 0.2;
        }

        ActionCastFakeSpellAtLocation(iProjType,lFail);
    }
}

//*:**************************************************************************
//*:**************************************************************************
