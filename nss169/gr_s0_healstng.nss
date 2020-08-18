//*:**************************************************************************
//*:*  GR_S0_HEALSTNG.NSS
//*:**************************************************************************
//:: Healing Sting (X2_S0_HealStng) Copyright (c) 2001 Bioware Corp.
//:: Created By: Andrew Nobbs  Created On: Nov 19, 2002
//*:* Spell Compendium (p. 110)
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

    int     iDieType          = 12;
    int     iNumDice          = 1;
    int     iBonus            = MinInt(10, spInfo.iCasterLevel);
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eHeal = EffectHeal(iDamage);
    effect eVs = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eLink = EffectLinkEffects(eVs,eHeal);

    effect eDamage = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE);
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eLink2 = EffectLinkEffects(eVis,eDamage);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_CREATURE) {
        if(GRGetIsLiving(spInfo.oTarget)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_HEALING_STING));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink2, spInfo.oTarget);
                    if(!GRGetIsImmuneToMagicalHealing(oCaster))  {
                        SignalEvent(OBJECT_SELF, EventSpellCastAt(oCaster, SPELL_HEALING_STING, FALSE));
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, oCaster);
                    }
                }
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
