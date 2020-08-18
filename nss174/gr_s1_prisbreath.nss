//*:**************************************************************************
//*:*  GR_S1_PRISBREATH.NSS
//*:**************************************************************************
//:: Prismatic Dragon Prismatic Breath (X2_S1_PrisSpray) Copyright (c) 2003 Bioware Corp.
//:: Created By: Georg Zoeller   Created On: Aug 09, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: February 15, 2008
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
int ApplyPrismaticEffect(int iEffectType, object oTarget, int iDC) {

    object oCaster = OBJECT_SELF;
    struct SpellStruct spInfo = GRGetSpellInfoFromObject(GetSpellId(), oCaster);
    int iDamage;
    int iVisualType;

    effect ePrism;
    effect eVis;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink;

    float fDelay = 0.5 + GetDistanceBetween(OBJECT_SELF, oTarget)/20;

    //Based on the random number passed in, apply the appropriate effect and set the visual to
    //the correct constant
    switch(iEffectType) {
        case 1://fire
            iDamage = 20;
            iVisualType = VFX_IMP_FLAME_S;
            iDamage = GRGetReflexAdjustedDamage(iDamage, oTarget, iDC, SAVING_THROW_TYPE_FIRE);
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }
        break;
        case 2: //Acid
            iDamage = 40;
            iVisualType = VFX_IMP_ACID_L;
            iDamage = GRGetReflexAdjustedDamage(iDamage, oTarget, iDC, SAVING_THROW_TYPE_ACID);
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_ACID);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
        break;
        case 3: //Electricity
            iDamage = 80;
            iVisualType = VFX_IMP_LIGHTNING_S;
            iDamage = GRGetReflexAdjustedDamage(iDamage, oTarget, iDC, SAVING_THROW_TYPE_ELECTRICITY);
            ePrism = EffectDamage(iDamage, DAMAGE_TYPE_ELECTRICAL);
            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
        break;
        case 4: //Poison
            {
                effect ePoison = EffectPoison(POISON_BEBILITH_VENOM);
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePoison, oTarget));
            }
        break;
        case 5: //Paralyze
            {
                effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZED);
                if(GRGetSaveResult(SAVING_THROW_FORT, oTarget, iDC) == 0) {
                    ePrism = EffectParalyze();
                    eLink = EffectLinkEffects(eDur, ePrism);
                    eLink = EffectLinkEffects(eLink, eDur2);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, GRGetDuration(10)));
                }
            }
        break;
        case 6: //Confusion
            {
                effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                ePrism = EffectConfused();
                eLink = EffectLinkEffects(eMind, ePrism);
                eLink = EffectLinkEffects(eLink, eDur);

                if(!GRGetSaveResult(SAVING_THROW_WILL, oTarget, iDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay)) {
                    iVisualType = VFX_IMP_CONFUSION_S;
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, GRGetDuration(10)));
                }
            }
        break;
        case 7: //Death
            {
                if(!GRGetSaveResult(SAVING_THROW_WILL, oTarget, iDC, SAVING_THROW_TYPE_DEATH, OBJECT_SELF, fDelay)) {
                    iVisualType = VFX_IMP_DEATH;
                    ePrism = EffectDeath();
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePrism, oTarget));
                }
            }
        break;
    }

    return iVisualType;
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

    spInfo.iCasterLevel = GetHitDice(oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
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

    float   fDuration       = GRGetDuration(iDurAmount);
    float   fDelay          = 0.0f;
    float   fRange          = 20.0f;
    int     iTargetHD;
    int     iEffectRoll;
    int     iVisualType1;
    int     iVisualType2;
    int     bTwoEffects;

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
    effect eVisual1, eVisual2;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

            iTargetHD = GetHitDice(spInfo.oTarget);
            if(iTargetHD <= 8) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectBlindness(), spInfo.oTarget, fDuration);
            }

            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
            //Determine if 1 or 2 effects are going to be applied
            iEffectRoll = d8();
            if(iEffectRoll == 8) {
                iVisualType1 = ApplyPrismaticEffect(Random(7) + 1, spInfo.oTarget, spInfo.iCasterLevel);
                iVisualType2 = ApplyPrismaticEffect(Random(7) + 1, spInfo.oTarget, spInfo.iCasterLevel);
            } else {
                iVisualType1 = ApplyPrismaticEffect(iEffectRoll, spInfo.oTarget, spInfo.iCasterLevel);
            }
            if(iVisualType1 != 0) {
                eVisual1 = EffectVisualEffect(iVisualType1);
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual1, spInfo.oTarget));
                if(bTwoEffects) {
                    eVisual2 = EffectVisualEffect(iVisualType2);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual2, spInfo.oTarget));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
