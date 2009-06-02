//*:**************************************************************************
//*:*  GR_S0_DRAGBREATH.NSS
//*:**************************************************************************
//*:*
//*:* Blank template for spell scripts
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_DRAGONS"
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

    int     iDieType          = 6;
    int     iNumDice          = spInfo.iCasterLevel;
    int     iBonus            = 0;
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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    int     iSaveType       = SAVING_THROW_TYPE_NONE;
    int     iSavingThrow    = -1;
    int     iBreathType;
    int     iDamageType     = -1;
    int     iVisual         = -1;
    int     iDurationType   = DURATION_TYPE_INSTANT;
    int     iSpellTarget    = SPELL_TARGET_STANDARDHOSTILE;
    int     iObjectFilter   = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    float   fDelay;
    float   fRange          = 14.0;

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
    effect eBreath;
    effect eVis;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eFear;
    effect eParal;
    effect eDur2;

    switch(spInfo.iSpellID) {
        case 236: // Dragon Breath - Acid
            iDieType = 4;
            iBreathType = GR_DRAGON_BREATH_ACID;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            iDamageType = DAMAGE_TYPE_ACID;
            iSaveType = SAVING_THROW_TYPE_ACID;
            iVisual = VFX_IMP_ACID_S;
            iNumDice *= 2;
            break;
        case 237: // Dragon Breath - Cold
            iDieType = 6;
            iBreathType = GR_DRAGON_BREATH_COLD;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            iDamageType = DAMAGE_TYPE_COLD;
            iSaveType = SAVING_THROW_TYPE_COLD;
            iVisual = VFX_IMP_FROST_S;
            break;
        case 238: // Dragon Breath - Fear
            spInfo.iDC = GetDragonFearDC(iNumDice);
            eBreath = EffectFrightened();
            eFear = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
            eBreath = EffectLinkEffects(eBreath, eDur);
            eBreath = EffectLinkEffects(eBreath, eFear);
            iVisual = VFX_IMP_FEAR_S;
            iDurationType = DURATION_TYPE_TEMPORARY;
            iSavingThrow = SAVING_THROW_WILL;
            iObjectFilter = OBJECT_TYPE_CREATURE;
            iSaveType = SAVING_THROW_TYPE_FEAR;
            break;
        case 239: // Dragon Breath - Fire
            iDieType = 10;
            iBreathType = GR_DRAGON_BREATH_FIRE;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            iDamageType = DAMAGE_TYPE_FIRE;
            iSaveType = SAVING_THROW_TYPE_FIRE;
            iVisual = VFX_IMP_FLAME_M;
            break;
        case 240: // Dragon Breath - Gas
            iDieType = 6;
            iBreathType = GR_DRAGON_BREATH_GAS;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            iDamageType = DAMAGE_TYPE_ACID;
            iSaveType = SAVING_THROW_TYPE_ACID;
            iVisual = VFX_IMP_POISON_L;
            iNumDice *= 2;
            break;
        case 241: // Dragon Breath - Lightning
            iDieType = 8;
            iBreathType = GR_DRAGON_BREATH_LIGHTNING;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
            iVisual = VFX_IMP_LIGHTNING_S;
            iNumDice *= 2;
            break;
        case 242: // Dragon Breath - Paralyze
            iBreathType = GR_DRAGON_BREATH_PARALYZE;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            eBreath = EffectParalyze();
            eParal = EffectVisualEffect(VFX_DUR_PARALYZED);
            eDur2 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
            eBreath = EffectLinkEffects(eBreath, eDur);
            eBreath = EffectLinkEffects(eBreath, eDur2);
            eBreath = EffectLinkEffects(eBreath, eParal);
            iDurationType = DURATION_TYPE_TEMPORARY;
            fDuration = GRGetDuration(iNumDice);
            iSavingThrow = SAVING_THROW_FORT;
            iObjectFilter = OBJECT_TYPE_CREATURE;
            break;
        case 243: // Dragon Breath - Sleep
            iBreathType = GR_DRAGON_BREATH_SLEEP;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            eBreath = EffectSleep();
            eBreath = EffectLinkEffects(eBreath, eDur);
            iDurationType = DURATION_TYPE_TEMPORARY;
            iVisual = VFX_IMP_SLEEP;
            fDuration = GRGetDuration(iNumDice);
            iSavingThrow = SAVING_THROW_WILL;
            iObjectFilter = OBJECT_TYPE_CREATURE;
            iSaveType = SAVING_THROW_TYPE_SLEEP;
            break;
        case 244: // Dragon Breath - Slow
            iBreathType = GR_DRAGON_BREATH_SLOW;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            eBreath = EffectSlow();
            eBreath = EffectLinkEffects(eBreath, eDur);
            iDurationType = DURATION_TYPE_TEMPORARY;
            iVisual = VFX_IMP_SLOW;
            fDuration = GRGetDuration(iNumDice);
            iSavingThrow = SAVING_THROW_REFLEX;
            iObjectFilter = OBJECT_TYPE_CREATURE;
            iSaveType = SAVING_THROW_TYPE_MIND_SPELLS;
            break;
        case 245: // Dragon Breath - Weaken
            iBreathType = GR_DRAGON_BREATH_WEAKEN;
            spInfo.iDC = GRGetDragonBreathDC(iBreathType, iNumDice);
            eBreath = EffectAbilityDecrease(ABILITY_STRENGTH, iNumDice);
            eBreath = ExtraordinaryEffect(eBreath);
            iDurationType = DURATION_TYPE_PERMANENT;
            iVisual = VFX_IMP_REDUCE_ABILITY_SCORE;
            iSavingThrow = SAVING_THROW_REFLEX;
            iObjectFilter = OBJECT_TYPE_CREATURE;
            break;
        case 264: // Hell Hound Breath - Fire
            iDieType = 4;
            iDamageType = DAMAGE_TYPE_FIRE;
            iSaveType = SAVING_THROW_TYPE_FIRE;
            iVisual = VFX_IMP_FLAME_S;
            iSpellTarget = SPELL_TARGET_SELECTIVEHOSTILE;
            iNumDice = 1;
            iBonus = 1;
            fRange = 11.0;
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID!=264) PlayDragonBattleCry();
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, iObjectFilter, GetPosition(oCaster));

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, iSpellTarget, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
            if(iDamageType!=-1) {
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, iBonus);
                if(spInfo.iSpellID!=264) // Hell Hound has no save
                    iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType);
                if(spInfo.iSpellID==240 && GetHasSpellEffect(SPELL_GR_FILTER, spInfo.oTarget)) {
                    // Filter spell reduces damage from Gas by half
                    iDamage /= 2;
                }
                if(iDamage>0) {
                    eBreath = EffectDamage(iDamage, iDamageType);
                    if(iVisual!=-1) DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBreath, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
            } else {
                if(!GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                    if(iVisual!=-1)
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    if(spInfo.iSpellID==238) {
                        fDuration = GRGetDuration(GetScaledDuration(iNumDice, spInfo.oTarget));
                    }
                    if(iDurationType!=DURATION_TYPE_TEMPORARY) {
                        GRApplyEffectToObject(iDurationType, eBreath, spInfo.oTarget);
                    } else {
                        GRApplyEffectToObject(iDurationType, eBreath, spInfo.oTarget, fDuration);
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, iObjectFilter, GetPosition(oCaster));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
