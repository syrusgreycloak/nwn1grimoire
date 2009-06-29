//*:**************************************************************************
//*:*  GR_S0_EVARDSC.NSS
//*:**************************************************************************
//*:* Evards Black Tentacles: Heartbeat (NW_S0_Evardsc) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: May 17, 2001
//*:* 3.5 Player's Handbook (p. 228)
//*:**************************************************************************
//*:* Chilling Tentacles
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: April 23, 2008
//*:* Complete Arcane (p. 132)
//*:**************************************************************************
//*:* Updated On: April 23, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType          = 6;
    int     iNumDice          = 1;
    int     iBonus            = 4;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetDuration(2);

    float   fDamagePercent  = 1.0;
    int     iTargetAC;       //= GetAC(spInfo.oTarget);
    int     iNumHits;
    int     iDieRoll;
    float   fDelay;
    int     bIllusion       = (spInfo.iSpellSchool==SPELL_SCHOOL_ILLUSION);

    int     iColdDamage;

    switch(spInfo.iSpellID) {
        case SPELL_GR_SHADES_EVARDS_TENTACLES:
            fDamagePercent = 0.8;
            break;
        case SPELL_GR_GSC_EVARDS_TENTACLES:
            fDamagePercent = 0.6;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eParal   = EffectParalyze();
    effect eDur     = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eLink    = EffectLinkEffects(eDur, eParal);
    effect eDam;

    effect eColdDam;    // = EffectDamage(iColdDamage, DAMAGE_TYPE_COLD);
    effect eColdVis = EffectVisualEffect(VFX_IMP_FROST_S);
    effect eColdLink;   // = EffectLinkEffects(eColdDam, eColdVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(spInfo.iSpellID==SPELL_I_CHILLING_TENTACLES) {
                iColdDamage = GRGetMetamagicAdjustedDamage(6, 2, spInfo.iMetamagic, 0);
                eColdDam = EffectDamage(iDamage, DAMAGE_TYPE_COLD);
                eColdLink = EffectLinkEffects(eColdDam, eColdVis);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eColdLink, spInfo.oTarget);
            }

            iTargetAC = GetAC(spInfo.oTarget);
            for(iNumHits=GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic); iNumHits > 0; iNumHits--) {
                iDamage = 0;
                fDelay = GetRandomDelay(1.0, 2.2);
                iDieRoll = 5 + d20();
                if(iDieRoll >= iTargetAC) {
                    iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
                    if(bIllusion) {
                        if(GetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_WILLDISBELIEF")) {
                            iDamage = FloatToInt(iDamage * fDamagePercent);
                        }
                    }
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                }
                if(iDamage > 0) {
                    eDam = EffectDamage(iDamage, DAMAGE_TYPE_BLUDGEONING, DAMAGE_POWER_PLUS_TWO);
                    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                    if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NONE, oCaster, fDelay)) {
                        if(bIllusion && GetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_WILLDISBELIEF")) {
                            if((d100()/100.0)<=fDamagePercent) {
                                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
                            }
                        } else {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
                        }
                    }
                }
            }
        }
        spInfo.oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
