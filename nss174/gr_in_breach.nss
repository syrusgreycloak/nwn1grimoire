//*:**************************************************************************
//*:*  GR_IN_BREACH.NSS
//*:**************************************************************************
//*:*
//*:* Takes the bioware functions for doing a spell breach and makes the
//*:* process more random as to what spells get removed instead of the
//*:* straight list Bioware was using
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 28, 2005
//*:**************************************************************************
//*:* Updated On: February 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
//#include "GR_IC_NAMES" -- included through GR_IN_SPELLS -> GR_IN_EFFECTS -> GR_IN_LIB
#include "GR_IN_SPELLS"
#include "GR_IN_ARRLIST"

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************
const string ARR_BREACH = "GR_BREACH";
const string SPELL = "SPELL";

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
void    GRBuildSpellList(object oTarget);
int     GRDevourMagic(object oTarget, int iCasterLevel, effect eVis, effect eImpact);
void    GRDispelMagic(object oTarget, int iCasterLevel, effect eVis, effect eImpact, int bAll = TRUE, int bBreachSpells = FALSE);
void    GRDoSpellBreach(object oTarget, int iTotal, int iSR, int iSpellID);
int     GRGetSpellBreachProtection(object oTarget, int iSpellIndex);
int     GRRemoveProtections(int iSpellID, object oTarget);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************
//*:**********************************************
//*:* GRBuildSpellList
//*:*   (formerly SGBuildSpellList)
//*:**********************************************
//*:*
//*:*  Builds an "array" of removable spells to
//*:*  choose from.  A random number indexes into
//*:*  this table to pick which spell to remove
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 28, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
void GRBuildSpellList(object oTarget) {

    string TMP_ARRAY = "BREACH_TEMP";

    GRCreateArrayList(ARR_BREACH, SPELL, VALUE_TYPE_INT, oTarget);
    GRCreateArrayList(TMP_ARRAY, SPELL, VALUE_TYPE_INT, oTarget);

    effect eEff = GetFirstEffect(oTarget);

    while(GetIsEffectValid(eEff)) {
        if(GetEffectSubType(eEff)==SUBTYPE_MAGICAL) {
            int iSpellID = GetEffectSpellId(eEff);
            if(iSpellID>-1) {
                GRIntAdd(TMP_ARRAY, SPELL, iSpellID, oTarget);
            }
        }
        eEff = GetNextEffect(oTarget);
    }
    GRQuickSort(TMP_ARRAY, SPELL, 1, GRGetDimSize(TMP_ARRAY, SPELL, oTarget), oTarget);

    // add unique values out of sorted temp array to Breach effect array
    int i = 1;
    int iTemp;
    GRIntAdd(ARR_BREACH, SPELL, GRIntGetValueAt(TMP_ARRAY, SPELL, i, oTarget), oTarget);
    for(i=2; i<=GRGetDimSize(TMP_ARRAY, SPELL, oTarget); i++) {
        iTemp = GRIntGetValueAt(TMP_ARRAY, SPELL, i, oTarget);
        if(iTemp!=GRIntGetValueAt(TMP_ARRAY, SPELL, i-1, oTarget)) {
            GRIntAdd(ARR_BREACH, SPELL, iTemp, oTarget);
        }
    }

    GRDeleteArrayList(TMP_ARRAY, oTarget);
}

//*:**********************************************
//*:* GRDevourMagic
//*:**********************************************
//*:*
//*:* Used for Warlock Devour Magic and Voracious
//*:* dispelling
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**********************************************
int GRDevourMagic(object oTarget, int iCasterLevel, effect eVis, effect eImpact) {

    effect eEff = GetFirstEffect(oTarget);
    int iSpellLevels = 0;

    string ARR_DEVOUR = "GR_DEVOUR";
    string SPELL_EFFECT = "INDEX";

    GRCreateArrayList(ARR_DEVOUR, SPELL_EFFECT, VALUE_TYPE_INT, oTarget);

    while(GetIsEffectValid(eEff)) {
        if(GetEffectSubType(eEff)==SUBTYPE_MAGICAL && GetEffectCreator(eEff)!=OBJECT_SELF) {
            int iSpellID = GetEffectSpellId(eEff);
            if(iSpellID>-1) {
                if(StringToInt(Get2DAString(SPELLS, SPELLS_USER_TYPE, iSpellID))==1) {
                    GRIntAdd(ARR_DEVOUR, SPELL_EFFECT, iSpellID, oTarget);
                }
            }
        }
        eEff = GetNextEffect(oTarget);
    }

    GRDispelMagic(oTarget, iCasterLevel, eVis, eImpact);

    int i;
    int iArraySize = GRGetDimSize(ARR_DEVOUR, SPELL_EFFECT, oTarget);
    for(i=1; i<=iArraySize; i++) {
        int iSpellID = GRIntGetValueAt(ARR_DEVOUR, SPELL_EFFECT, i, oTarget);
        if(!GetHasSpellEffect(iSpellID, oTarget)) {
            iSpellLevels += StringToInt(Get2DAString(SPELLS, SPELLS_INNATE, iSpellID));
        }
    }

    GRDeleteArrayList(ARR_DEVOUR, oTarget);

    return iSpellLevels;
}

//*:**********************************************
//*:* GRDispelMagic
//*:**********************************************
//*:*
//*:* Attempts a dispel on one target, with all safety
//*:* checks put in.
//*:*
//*:**********************************************
//*:* Created By: bioware
//*:* Created On:
//*:**********************************************
//*:* Updated On: February 9, 2007
//*:**********************************************
void GRDispelMagic(object oTarget, int iCasterLevel, effect eVis, effect eImpact, int bAll = TRUE, int bBreachSpells = FALSE) {
    //*:**********************************************
    //*:* Don't dispel magic on petrified targets
    //*:* this change is in to prevent weird things from
    //*:* happening with 'statue' creatures. Also creature
    //*:* can be scripted to be immune to dispel magic as well.
    //*:**********************************************
    if(GetHasEffect(EFFECT_TYPE_PETRIFY, oTarget) || GetLocalInt(oTarget, IMMUNE_TO_DISPEL) == 10) {
        return;
    }

    effect eDispel;
    float fDelay = GetRandomDelay(0.1, 0.3);
    int iId = GetSpellId();

    //*:**********************************************
    //*:* Fire hostile event only if the target is hostile...
    //*:**********************************************
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF)));

    //*:**********************************************
    //*:* GZ: Bugfix. Was always dispelling all effects,
    //*:* even if used for AoE
    //*:**********************************************
    if(bAll) {
        eDispel = EffectDispelMagicAll(iCasterLevel);
        object oItem;
        int i;

        for(i=INVENTORY_SLOT_HEAD; i<=INVENTORY_SLOT_CARMOUR; i++) { // loop all equipped items
            oItem = GetItemInSlot(i, oTarget);
            if(GetIsObjectValid(oItem)) {
                IPRemoveAllItemProperties(oItem, DURATION_TYPE_TEMPORARY); // remove all temporary item properties (usually added by spells)
            }
        }

        //*:**********************************************
        //*:* GZ: Support for Mord's disjunction
        //*:**********************************************
        if(bBreachSpells) {
            GRDoSpellBreach(oTarget, 6, 10, iId);
        }
    } else {
        eDispel = EffectDispelMagicBest(iCasterLevel);
        if(bBreachSpells) {
           GRDoSpellBreach(oTarget, 2, 10, iId);
        }
    }

    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDispel, oTarget));
}

//*:**********************************************
//*:* GRDoSpellBreach - wraps
//*:**********************************************
//*:* DoSpellBreach
//*:* Copyright (c) 2001 Bioware Corp.
//*:**********************************************
//*:*
//*:*  Performs a spell breach up to nTotal spells
//*:*  are removed and nSR spell resistance is
//*:*  lowered.
//*:*
//*:**********************************************
//*:* Created By: Brent
//*:* Created On: September 2002
//*:* Modified  : Georg, Oct 31, 2003
//*:**********************************************
//*:* Modified By: Karl Nickels (Syrus Greycloak)
//*:* Modified On: March 28, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
void GRDoSpellBreach(object oTarget, int iTotal, int iSR, int iSpellID) {

    if(iSpellID == -1) iSpellID =  SPELL_GREATER_SPELL_BREACH;

    effect eSR  = EffectSpellResistanceDecrease(iSR);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVis = EffectVisualEffect(VFX_IMP_BREACH);


    int iCnt = 0;
    int iIdx = 1;
    int iSpellToRemove;
    int iPrevIdx = 0;
    int bAllSpellsChecked = FALSE;

    if(!GetIsReactionTypeFriendly(oTarget)) {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, iSpellID));
        GRBuildSpellList(oTarget);
        if(GRGetDimSize(ARR_BREACH, SPELL, oTarget)<iTotal) iTotal = GRGetDimSize(ARR_BREACH, SPELL, oTarget);

        while(iIdx < iTotal && !bAllSpellsChecked) {
            if(iIdx==iPrevIdx) {
                // if did not have spell, increment to next position in list
                iCnt++; // not sure if this ever occurs with change to only current effects in list
            } else {
                // either 1st pass or last spell was removed
                // get random starting position in list
                iCnt = GetTimeHour()*GetTimeSecond();
                iCnt = (iCnt % GRGetDimSize(ARR_BREACH, SPELL, oTarget)) + 1;
            }
            iSpellToRemove = GRGetSpellBreachProtection(oTarget, iCnt);
            if(iSpellToRemove>=0) {
                iPrevIdx = iIdx;
                iIdx = iIdx + GRRemoveProtections(iSpellToRemove, oTarget);
            } else {
                bAllSpellsChecked = TRUE;
            }
        }
        effect eLink = EffectLinkEffects(eDur, eSR);
        //--------------------------------------------------------------------------
        // This can not be dispelled
        //--------------------------------------------------------------------------
        eLink = ExtraordinaryEffect(eLink);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10));
    }
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

    GRDeleteArrayList(ARR_BREACH, oTarget);
}

//*:**********************************************
//*:* GRGetSpellBreachProtection
//*:*   (formerly SGGetSpellBreachProtection)
//*:**********************************************
//*:*
//*:*  Returns first spell value in list != -1
//*:*  unless all spells have been checked
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 28, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetSpellBreachProtection(object oTarget, int iSpellIndex) {

    int iNewIndex = iSpellIndex;
    int bFirstPass = TRUE;

    int iSpellToRemove = GRIntGetValueAt(ARR_BREACH, SPELL, iNewIndex, oTarget);
    while(iSpellToRemove==-1 && (iNewIndex!=iSpellIndex || bFirstPass)) {
        bFirstPass=FALSE;
        iNewIndex++;
        if(iNewIndex>GRGetDimSize(ARR_BREACH, SPELL, oTarget)) iNewIndex = 1;
        iSpellToRemove = GRIntGetValueAt(ARR_BREACH, SPELL, iNewIndex, oTarget);
    }
    if(iSpellToRemove!=-1) {
        GRIntSetValueAt(ARR_BREACH, SPELL, iNewIndex, -1, oTarget);
    }

    return iSpellToRemove;
}

//*:**********************************************
//*:* GRRemoveProtections
//*:*   (formerly SGRemoveProtections)
//*:**********************************************
//*:*
//*:*  Attempts to remove spell effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 28, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRRemoveProtections(int iSpellID, object oTarget) {

    effect eProtection;
    int iCnt = 0;

    if(GetHasSpellEffect(iSpellID, oTarget)) {
        eProtection = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eProtection)) {
            if(GetEffectSpellId(eProtection) == iSpellID) {
                RemoveEffect(oTarget, eProtection);
                iCnt++;
            }
            eProtection = GetNextEffect(oTarget);
        }
    }

    if(iCnt > 0) {
        return 1;
    } else {
        return 0;
    }
}


//*:**************************************************************************
//*:**************************************************************************
