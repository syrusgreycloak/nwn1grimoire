//*:**************************************************************************
//*:*  GR_S0_TIDEBATTLE.NSS
//*:**************************************************************************
//*:* Tide of Battle (x2_s0_TideBattle) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Keith Warner  Created On: Jan 2/03
//*:*
//*:**************************************************************************
/*
    Uses spell effect to cause d100 damage to
    all enemies and friends around pc, including pc.
    (Area effect always centered on PC)
    Minimum 30 points of damage will be done to each target
*/
//*:**************************************************************************
//*:* Updated On: December 20, 2007
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

    int     iDieType          = 100;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = RADIUS_SIZE_COLOSSAL;

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
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH_WARD);
    effect eVis2 = EffectVisualEffect(VFX_FNF_METEOR_SWARM);
    effect eDamage;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis2, spInfo.lTarget);
    spInfo.oTarget = GetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        fDelay = GetRandomDelay();
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(GRGetSpellHasSecondaryDamage(spInfo)) {
            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                iDamage = iSecDamage;
            }
        }
        if(iDamage < 30) iDamage = 30;
        eDamage = EffectDamage(iDamage, DAMAGE_TYPE_DIVINE);
        eLink = EffectLinkEffects(eVis, eDamage);
        if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));

        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
