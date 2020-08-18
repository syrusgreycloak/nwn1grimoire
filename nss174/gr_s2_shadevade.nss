//*:**************************************************************************
//*:*  GR_S2_SHADEVADE.NSS
//*:**************************************************************************
//*:* Shadow Evade (X0_S2_ShadEvade.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Oct 26, 2001
//*:* Created by Bioware (in place of Shadow Jump)
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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

    spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_SHADOWDANCER);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 5;
    int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetDuration(iDurAmount, iDurType);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iConceal        = 20;
    int     iDRAmount       = 5;
    int     iDRPower        = DAMAGE_POWER_PLUS_FIVE;
    int     iAC             = 4;

    if(spInfo.iCasterLevel<6) {
        iConceal = 5;
        iDRPower = DAMAGE_POWER_PLUS_ONE;
        iAC = 1;
    } else if(spInfo.iCasterLevel<8) {
        iConceal = 10;
        iDRPower = DAMAGE_POWER_PLUS_TWO;
        iAC = 2;
    } else if(spInfo.iCasterLevel<10) {
        iConceal = 15;
        iDRAmount = 10;
        iDRPower = DAMAGE_POWER_PLUS_TWO;
        iAC = 3;
    } else if(spInfo.iCasterLevel<15) {
        iDRAmount = 10;
        iDRPower = DAMAGE_POWER_PLUS_THREE;
    } else if(spInfo.iCasterLevel<20) {
        iDRAmount = 12;
        iDRPower = DAMAGE_POWER_PLUS_FOUR;
    } else {
        iDRAmount = MinInt(28, ((spInfo.iCasterLevel-11)/5)*2);
    }

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
    effect eVis     = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eConceal = EffectConcealment(iConceal);
    effect eDR      = EffectDamageReduction(iDRAmount, iDRPower);
    effect eAC      = EffectACIncrease(iAC);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eVis2    = EffectVisualEffect(VFX_DUR_PROT_SHADOW_ARMOR);

    effect eLink = EffectLinkEffects(eConceal, eDR);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eVis2);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, 477, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
