//*:**************************************************************************
//*:*  GR_S3_BERRY.NSS
//*:**************************************************************************
//:: x0_s3_berry
//:: Copyright (c) 2001 Bioware Corp.
//*:**************************************************************************
/*
    Ice berry - gives animal companion ice-centered
        abilities

    Flame berry - gives animal companion fire-centered
        abilities

    Lasts for 1 turn per caster level
*/
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

    if(GetSpellCastItem()==oCaster) {
        oCaster = GetItemPossessor(OBJECT_SELF);
    }

    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
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

    int     iRangerLvls     = GRGetLevelByClass(CLASS_TYPE_RANGER, oCaster);
    int     iDruidLvls      = GRGetLevelByClass(CLASS_TYPE_DRUID, oCaster);
    int     iLevels         = iRangerLvls + iDruidLvls;

    float   fDuration       = GRGetDuration(iLevels, DUR_TYPE_TURNS);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object  oMyCompanion    = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oCaster);
    int     iVisualType;
    int     iDamageType;
    int     iDamageBonus    = DAMAGE_BONUS_1d10;
    int     iReduction      = 10;

    switch(spInfo.iSpellID) {
        case 617:       // Ice berry
            iVisualType = VFX_IMP_FROST_L;
            iDamageType = DAMAGE_TYPE_COLD;
            break;
        case 618:       // Flame berry
            iVisualType = VFX_IMP_FLAME_M;
            iDamageType = DAMAGE_TYPE_FIRE;
            break;
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
    effect eVis         = EffectVisualEffect(iVisualType);
    effect eDamage      = EffectDamageIncrease(iDamageBonus, iDamageType);
    effect eReduction   = EffectDamageResistance(iDamageType, iReduction);
    effect eHaste       = EffectHaste();
    effect eRegen       = EffectRegenerate(1, 6.0);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink        = EffectLinkEffects(eDamage, eReduction);
    eLink = EffectLinkEffects(eLink, eHaste);
    eLink = EffectLinkEffects(eLink, eRegen);
    eLink = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(oMyCompanion) && GetIsObjectValid(spInfo.oTarget) && spInfo.oTarget==oMyCompanion) {
        //*:* Prevent Stacking
        GRRemoveMultipleSpellEffects(617, 618, spInfo.oTarget);

        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
        }
    } else {
        SpeakStringByStrRef(40076);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
