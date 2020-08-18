//*:**************************************************************************
//*:*  GR_S2_GWBURN.NSS
//*:**************************************************************************
//:: Outsider Shape - Azer - Fire stream (x2_s2_gwburn) Copyright (c) 2003Bioware Corp.
//:: Created By: Georg Zoeller  Created On: July, 07, 2003
//*:**************************************************************************
//*:* Azer shoot fire ability. The fire they breathe is natural, so there is
//*:* no SR check against it
//*:**************************************************************************
//*:* Updated On: February 15, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_SHIFTER"

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

    spInfo.iDC = ShifterGetSaveDC(oCaster, SHIFTER_DC_NORMAL);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = ((GRGetLevelByClass(CLASS_TYPE_SHIFTER, oCaster)/3)* d4()) + GetAbilityModifier(ABILITY_WISDOM, oCaster);
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

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
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = GetDistanceBetween(spInfo.oTarget, OBJECT_SELF)/14;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAttackResult   = GRTouchAttackRanged(spInfo.oTarget);
    iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_FIRE, oCaster) * iAttackResult;

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
    effect eRay     = EffectBeam(444, oCaster, BODY_NODE_CHEST, (iDamage==0));
    //*:* SG: changed above to iDamage==0 because evasion/improved evasion means target avoids damage, or attack 'misses'
    effect eDur     = EffectVisualEffect(498);
    effect eDamage  = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);

    effect eHit     = EffectVisualEffect(VFX_IMP_FLAME_S);
    eHit = EffectLinkEffects(eDamage, eHit);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spInfo.oTarget, 1.7f);
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

    if(iDamage>0) {
        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, 3.0f));
        DelayCommand(fDelay+0.3f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, spInfo.oTarget, 3.0f));
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
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
