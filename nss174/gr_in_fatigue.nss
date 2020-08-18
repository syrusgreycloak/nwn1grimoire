//*:**************************************************************************
//*:*  GR_IN_FATIGUE.NSS
//*:**************************************************************************
//*:*
//*:* Functions applying to fatigue and exhaustion effects
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: January 6, 2009
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
//#include "GR_IC_NAMES" -- included through GR_IN_EFFECTS -> GR_IN_LIB
#include "GR_IN_EFFECTS"

//*:**************************************************************************
//*:* Constant Declarations
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void GRSetTargetFatigued(object oTarget, int iSpellID=-1);
void GRSetTargetExhausted(object oTarget, int iSpellID=-1);
int  GRGetTargetFatigued(object oTarget);
int  GRGetTargetExhausted(object oTarget);
int  GRGetFatigueEffectSpellId(object oTarget);
int  GRGetExhaustionEffectSpellId(object oTarget);
void GRRemoveFatigueEffects(object oTarget, int iSpellID=-1);
void GRRemoveExhaustionEffects(object oTarget);
void GRApplyFatigueToObject(object oTarget, int iSpellID=-1);
void GRApplyExhaustionToObject(object oTarget, int iSpellID=-1);

//*:**************************************************************************
//*:* Function Implementations
//*:**************************************************************************
void GRSetTargetFatigued(object oTarget, int iSpellID=-1) {

    if(iSpellID==0) iSpellID=9999;  // Acid Fog doesn't fatigue, but just in case
                                    // we don't want it to read as false

    SetLocalInt(oTarget, IS_FATIGUED, iSpellID);

}

void GRSetTargetExhausted(object oTarget, int iSpellID=-1) {

    if(iSpellID==0) iSpellID=9999;

    SetLocalInt(oTarget, IS_EXHAUSTED, iSpellID);

}

int GRGetTargetFatigued(object oTarget) {

    if(GetLocalInt(oTarget, IS_FATIGUED)>0) return TRUE;

    return FALSE;
}

int GRGetTargetExhausted(object oTarget) {

    if(GetLocalInt(oTarget, IS_EXHAUSTED)>0) return TRUE;

    return FALSE;
}

int GRGetFatigueEffectSpellId(object oTarget) {

    int iSpellID = GetLocalInt(oTarget, IS_FATIGUED);
    if(iSpellID==0) iSpellID = -1;
    else if(iSpellID==9999) iSpellID = 0;

    return iSpellID;
}

int GRGetExhaustionEffectSpellId(object oTarget) {

    int iSpellID = GetLocalInt(oTarget, IS_EXHAUSTED);
    if(iSpellID==0) iSpellID = -1;
    else if(iSpellID==9999) iSpellID = 0;

    return iSpellID;
}

void GRRemoveFatigueEffects(object oTarget, int iSpellID=-1) {

    int iFatigueSpellID = GetLocalInt(oTarget, IS_FATIGUED);

    if(iSpellID==-1) {
        iSpellID = iFatigueSpellID;
    } else if(iSpellID!=iFatigueSpellID) {
        iSpellID = 0;
    }

    if(iSpellID>0) {
        if(iSpellID==9999) iSpellID=0;
        GRRemoveEffectTypeBySpellId(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, iSpellID, oTarget);
        DeleteLocalInt(oTarget, IS_FATIGUED);
    }
}

void GRRemoveExhaustionEffects(object oTarget) {

    int iSpellID = GetLocalInt(oTarget, IS_EXHAUSTED);

    if(iSpellID>0) {
        if(iSpellID==9999) iSpellID=0;
        GRRemoveEffectTypeBySpellId(EFFECT_TYPE_MOVEMENT_SPEED_DECREASE, iSpellID, oTarget);
        DeleteLocalInt(oTarget, IS_EXHAUSTED);
    }
}

void GRApplyFatigueToObject(object oTarget, int iSpellID=-1) {

    int bNoFatigue = !GRGetTargetFatigued(oTarget);

    if(bNoFatigue || GRGetFatigueEffectSpellId(oTarget)==SPELL_TOUCH_OF_FATIGUE) {
        // Touch of Fatigue is a temporary spell.  If target receives another fatigue effect
        // while having Touch of Fatigue, do no reapply fatigue effect, just change spell id
        // so that the removal call for Touch of Fatigue will fail
        if(bNoFatigue) GRApplyEffectToObject(DURATION_TYPE_PERMANENT, GREffectFatigue(), oTarget);
        GRSetTargetFatigued(oTarget, iSpellID);
    } else {
        GRApplyExhaustionToObject(oTarget, iSpellID);
    }
}

void GRApplyExhaustionToObject(object oTarget, int iSpellID=-1) {

    if(!GRGetTargetExhausted(oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, GREffectExhausted(), oTarget);
        GRSetTargetExhausted(oTarget, iSpellID);
    }
}
