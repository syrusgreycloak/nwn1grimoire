//*:**************************************************************************
//*:*  GR_S2_DTHMSTTCH.NSS
//*:**************************************************************************
//:: Deathless Master Touch (X2_S2_dthmsttch) Copyright (c) 2003 Bioware Corp.
//:: Created By: Georg Zoeller  Created On: July, 24, 2003
//*:**************************************************************************
//*:* Updated On: December 26, 2007
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

    spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_PALEMASTER, oCaster);
    spInfo.iDC = 17;

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);
    int     iEpicModifier       = spInfo.iCasterLevel - 10;

    if(iEpicModifier>0) spInfo.iDC += iEpicModifier/2;

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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eSlay    = EffectDeath();
    effect eVis     = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eVis2    = EffectVisualEffect(VFX_IMP_DEATH);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(TouchAttackMelee(spInfo.oTarget, TRUE)>0) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, 624));
        if((GRGetCreatureSize(spInfo.oTarget)>CREATURE_SIZE_LARGE) && (GetModuleSwitchValue(MODULE_SWITCH_SPELL_CORERULES_DMASTERTOUCH)==TRUE)) {
            return; // creature too large to be affected.
        }

        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget);
            DelayCommand(1.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSlay, spInfo.oTarget));
            if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_DEATH)) {
                GRSetKilledByDeathEffect(spInfo.oTarget);
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
