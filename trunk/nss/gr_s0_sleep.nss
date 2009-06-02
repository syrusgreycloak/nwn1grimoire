//*:**************************************************************************
//*:*  GR_S0_SLEEP.NSS
//*:**************************************************************************
//*:* Sleep (NW_S0_Sleep) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: March 7 , 2001
//*:* 3.5 Player's Handbook (p. 280)
//*:**************************************************************************
//*:* Deep Slumber
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 6, 2007
//*:* 3.5 Player's Handbook (p. 217)
//*:*
//*:* Hiss of Sleep
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 8, 2007
//*:* Spell Compendium (p. 114)
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_ARRLIST"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = (spInfo.iSpellID!=SPELL_HISS_OF_SLEEP ? DUR_TYPE_TURNS : DUR_TYPE_ROUNDS);

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(10.0);
    float   fDelay;

    object  oLowest;
    int     bContinueLoop   = FALSE;
    int     iCurrentHD;
    int     bAlreadyAffected;
    int     iMaxHD          = 4;    // maximun hd creature affected
    int     iHDTotal        = 4;    // num hd that can be affected
    int     iLowestHD;
    string  sSpellLocal     = "BIOWARE_SPELL_LOCAL_SLEEP_" + ObjectToString(OBJECT_SELF);
    int     iSpellShape     = SHAPE_SPHERE;
    int     iNumCreatures   = spInfo.iCasterLevel;
    string  sListName       = "GR_SLEEPLIST_OBJ";
    string  sListDist       = "GR_SLEEPLIST_DIST";
    //*** NWN2 SINGLE ***/ int iDurVis = (spInfo.iSpellID==SPELL_HISS_OF_SLEEP ? VFX_DUR_SPELL_HISS_OF_SLEEP : VFX_DUR_SPELL_SLEEP);

    if(spInfo.iSpellID==SPELL_DEEP_SLUMBER) {
        iMaxHD = 10;
        iHDTotal = 10;
    } else if(spInfo.iSpellID==SPELL_HISS_OF_SLEEP) {
        fRange = FeetToMeters(25.0 + 5.0*(spInfo.iCasterLevel/2));
    }

    int     iDurationType   = DURATION_TYPE_TEMPORARY;
    int     i;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    //*:* iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eSleep   = EffectSleep();
    /*** NWN1 SPECIFIC ***/
        effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eMind    = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        effect eVis     = EffectVisualEffect(VFX_IMP_SLEEP);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eDur = EffectVisualEffect(iDurVis);

    effect eLink = EffectLinkEffects(eSleep, eDur);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eMind);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(iSpellShape, fRange, spInfo.lTarget);

    if(GetIsObjectValid(spInfo.oTarget)) {
        if(spInfo.iSpellID==SPELL_HISS_OF_SLEEP) {
            do {
                if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER) && GRGetIsLiving(spInfo.oTarget)) {
                    fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20.0;
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SLEEP)) {
                        DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration));
                    }
                    iNumCreatures--;
                }
                spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget);
            } while(GetIsObjectValid(spInfo.oTarget) && iNumCreatures>0);
        } else {
            //*:**********************************************
            //*:* Build list of creatures in area
            //*:**********************************************
            iNumCreatures = 0;

            string sName = "ARR_SLEEP";
            string sHitDice = "HITDICE";
            string sDistance = "DIST";
            string sObject = "OBJECT";

            GRCreateArrayList(sName, sHitDice, VALUE_TYPE_INT, oCaster, sDistance, VALUE_TYPE_FLOAT, sObject, VALUE_TYPE_OBJECT);

            while(GetIsObjectValid(spInfo.oTarget)) {
                if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER) && GRGetIsLiving(spInfo.oTarget)) {
                    iCurrentHD = GetHitDice(spInfo.oTarget);
                    if(iCurrentHD<=iMaxHD) {
                        iNumCreatures++;
                        GRIntAdd(sName, sHitDice, iCurrentHD);
                        GRFloatAdd(sName, sDistance, GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget)));
                        GRObjectAdd(sName, sObject, spInfo.oTarget);
                    }
                }
                spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget);
            }

            if(iNumCreatures>0) {
                if(iNumCreatures>1) {
                    //*:**********************************************
                    //*:* Sort list of creatures lowest to highest
                    //*:**********************************************
                    object oTarget;
                    int iHD;
                    float fDist;
                    int j;

                    for(i=2; i<=GRGetDimSize(sName, sObject); i++) {
                        oTarget = GRObjectGetValueAt(sName, sObject, i);
                        iHD = GRIntGetValueAt(sName, sHitDice, i);
                        fDist = GRFloatGetValueAt(sName, sDistance, i);
                        j = i-1;
                        while(j>0 && (GRIntGetValueAt(sName, sHitDice, j)>iHD ||
                            (GRIntGetValueAt(sName, sHitDice, j)==iHD && GRFloatGetValueAt(sName, sDistance, j)>fDist))) {

                            GRObjectSetValueAt(sName, sObject, j+1, GRObjectGetValueAt(sName, sObject, j));
                            GRIntSetValueAt(sName, sHitDice, j+1, GRIntGetValueAt(sName, sHitDice, j));
                            GRFloatSetValueAt(sName, sDistance, j+1, GRFloatGetValueAt(sName, sDistance, j));
                            j--;
                        }
                        GRObjectSetValueAt(sName, sObject, j+1, oTarget);
                        GRIntSetValueAt(sName, sHitDice, j+1, iHD);
                        GRFloatSetValueAt(sName, sDistance, j+1, fDist);
                    }
                }

                //*:**********************************************
                //*:* Put creatures to sleep in order until exceed HD total
                //*:**********************************************
                i=1;
                spInfo.oTarget = GRObjectGetValueAt(sName, sObject, i);
                iCurrentHD = GRIntGetValueAt(sName, sHitDice, i);
                while(iCurrentHD<iHDTotal && i<=GRGetDimSize(sName, sObject)) {
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        fDelay = GRFloatGetValueAt(sName, sDistance, i)/20.0;
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SLEEP)) {
                            DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration));
                        }
                    }
                    iHDTotal -= iCurrentHD;
                    i++;
                    if(i<=GRGetDimSize(sName, sObject)) {
                        spInfo.oTarget = GRObjectGetValueAt(sName, sObject, i);
                        iCurrentHD = GRIntGetValueAt(sName, sHitDice, i);
                    }
                }
                //*:**********************************************
                //*:* Clear listing from caster
                //*:**********************************************
                GRDeleteArrayList(sName);
            }
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************