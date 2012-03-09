//*:**************************************************************************
//*:*  GR_S0_REBUKE.NSS
//*:**************************************************************************
//*:* Nybor's Reminders (sg_s0_nybor.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 5, 2004
//*:**************************************************************************
/*   Nybor's Gentle Reminder        :  Rebuke (Spell Compendium p. 170)
     Nybor's Mild Admonishment      :  Rebuke, Greater (Spell Compendium p. 170)
     Nybor's Stern Reproof          :  Rebuke, Final (Spell Comendium p. 170)
     Nybor's Wrathful Castigation   :  Wrathful Castigation (Spell Compendium p. 243) */
//*:**************************************************************************
//*:* Updated On: March 3, 2008
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    int     iPenalty;
    float   fSpecialDuration;

    switch(spInfo.iSpellID) {
        case SPELL_GR_NYBORS_GENTLE_REMINDER:
            fSpecialDuration = GRGetDuration(1);
            break;
        case SPELL_GR_NYBORS_MILD_ADMONISHMENT:
            fSpecialDuration = GRGetDuration(GRGetMetamagicAdjustedDamage(4, 1, spInfo.iMetamagic, 0));
            break;
        case SPELL_GR_NYBORS_STERN_REPROOF:
            fSpecialDuration = GRGetDuration(1);
            break;
        case SPELL_GR_NYBORS_WRATHFUL_CASTIGATION:
            fSpecialDuration = GRGetDuration(spInfo.iCasterLevel);
            break;
    }

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fDuration *= 2;
        fSpecialDuration *= 2;
    }
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
    effect eImpVis          = EffectVisualEffect(VFX_IMP_EVIL_HELP);
    effect eDeathVis        = EffectVisualEffect(VFX_IMP_DEATH);
    effect eDur             = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);

    effect eDaze            = EffectDazed();
    effect eCower           = GREffectCowering();
    effect eShaken          = GREffectShaken();
    effect eDeath           = EffectDeath();
    effect eSavePenalty     = EffectSavingThrowDecrease(SAVING_THROW_ALL, iPenalty);

    effect eLink            = EffectLinkEffects(eShaken, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(GRGetIsLiving(spInfo.oTarget)) {
            switch(spInfo.iSpellID) {
                case SPELL_GR_NYBORS_GENTLE_REMINDER:       // Rebuke
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDaze, spInfo.oTarget, fSpecialDuration);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    }
                    break;
                case SPELL_GR_NYBORS_MILD_ADMONISHMENT:     // Rebuke, Greater
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCower, spInfo.oTarget, fSpecialDuration);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    }
                    break;
                case SPELL_GR_NYBORS_STERN_REPROOF:         // Rebuke, Final
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH)) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeathVis, spInfo.oTarget);
                        DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                        GRSetKilledByDeathEffect(spInfo.oTarget);
                    } else {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDaze, spInfo.oTarget, fSpecialDuration);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    }
                    break;
                case SPELL_GR_NYBORS_WRATHFUL_CASTIGATION:  // Wrathful Castigation
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH)) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeathVis, spInfo.oTarget);
                        DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                        GRSetKilledByDeathEffect(spInfo.oTarget);
                    } else {
                        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS)) {
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget);
                            eLink = EffectLinkEffects(eDaze, eSavePenalty);
                            eLink = EffectLinkEffects(eDur, eLink);
                            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                        }
                    }
                    break;
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
