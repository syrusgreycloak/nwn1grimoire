//*:**************************************************************************
//*:*  GR_S1_EYEBRAY.NSS
//*:**************************************************************************
//*:* Eyeball attacks (x1_s1_eyebray) Copyright (c) 2001 Bioware Corp.
//*:**************************************************************************
//*:* Updated On: January 28, 2008
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
//*:* Supporting functions
//*:**************************************************************************
int EBGetScaledBoltDamage(int iSpell) {

    int iLevel = GetHitDice(OBJECT_SELF);
    int iCount = MaxInt(1, iLevel/5);
    int iDamage;

    switch(iSpell) {
        case 710:  iDamage = d4(iCount) + (iLevel /2);
        case 711:  iDamage = d6(2) + (iCount*2);
        case 712:  iDamage = d6(iCount) + (iCount);
    }

    return iDamage;
}

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
    int     iDamage           = 0;
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration           = GRGetDuration(d3(2));
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iHD                 = GetHitDice(oCaster);
    int     iHit;
    int     iVisualType;
    int     iDamageType;
    int     iSpecialVisType     = -1;
    int     iSavingThrowType    = SAVING_THROW_TYPE_NONE;

    switch(spInfo.iSpellID) {
        case 710:
            iVisualType = VFX_IMP_FROST_S;
            iDamageType = DAMAGE_TYPE_COLD;
            iSpecialVisType = VFX_IMP_FROST_L;
            fDuration = 9.0;
            iSavingThrowType = SAVING_THROW_TYPE_COLD;
            break;
        case 711:
            iVisualType = VFX_IMP_NEGATIVE_ENERGY;
            iDamageType = DAMAGE_TYPE_NEGATIVE;
            iSpecialVisType = VFX_IMP_SLOW;
            break;
        case 712:
            iVisualType = VFX_IMP_FLAME_S;
            iDamageType = DAMAGE_TYPE_FIRE;
            iSpecialVisType = VFX_IMP_FLAME_M;
            fDuration = 9.0;
            break;
    }

    iDamage = EBGetScaledBoltDamage(spInfo.iSpellID);
    spInfo.iDC = 10 + (iHD/3);

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
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eBolt    = EffectDamage(iDamage, iDamageType);
    effect eSpecial;
    effect eSpecialVis = EffectVisualEffect(iSpecialVisType);

    switch(spInfo.iSpellID) {
        case 710:
            effect ePara = EffectParalyze();
            effect eIce = EffectVisualEffect(VFX_DUR_ICESKIN);
            eSpecial = EffectLinkEffects(eIce, ePara);
            break;
        case 711:
            eSpecial = EffectSlow();
            break;
        case 712:
            eSpecial = EffectKnockdown();
            break;
    }

    //*:**********************************************
    //*:* Apply Effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    iHit = TouchAttackRanged(spInfo.oTarget);
    if(iHit>0) {    // Attack hit
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, spInfo.oTarget);
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
        }
        if(iHit==2) { // on critical hit, apply special effects
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, iSavingThrowType, oCaster)) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSpecial, spInfo.oTarget, fDuration);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSpecialVis, spInfo.oTarget);
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
