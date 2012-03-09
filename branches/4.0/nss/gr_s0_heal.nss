//*:**************************************************************************
//*:*  GR_S0_HEAL.NSS
//*:**************************************************************************
//*:* Heal [NW_S0_Heal.nss] Copyright (c) 2000 Bioware Corp.
//*:* Mass Heal [NW_S0_MasHeal.nss] Copyright (c) 2000 Bioware Corp
//*:* Created By: Preston Watamaniuk  Created On: Jan 12, 2001
//*:* 3.5 Player's Handbook (p. 239)
//*:**************************************************************************
//*:* Heal Animal Companion (sg_s0_healcomp.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 12, 2004
//*:* Spell Compendium (p. 110)
//*:**************************************************************************
//*:* Updated On: March 11, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS" - INCLUDED IN GR_IN_HEALHARM
#include "GR_IN_SPELLHOOK"
#include "GR_IN_HEALHARM"

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

    if(spInfo.iSpellID==SPELL_HEAL_ANIMAL_COMPANION && spInfo.oTarget!=GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)) {
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939262));
        }
        return;
    }

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = (spInfo.iSpellID!=SPELL_MASS_HEAL ? MinInt(15, spInfo.iCasterLevel): MinInt(25, spInfo.iCasterLevel))*10;
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(30.0);

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_MASS_HEAL);
    int     bHarmTouchSpell = (TRUE && !bMultiTarget);
    /*** NWN1 SINGLE ***/ int   vfx_impactNormalHurt = VFX_IMP_SUNSTRIKE;
    //*** NWN2 SINGLE ***/ int   vfx_impactNormalHurt = VFX_HIT_SPELL_INFLICT_6;
    int vfx_impactUndeadHurt    = VFX_IMP_HEALING_G;
    int vfx_impactHeal          = VFX_IMP_HEALING_X;

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
    /*** NWN1 SINGLE ***/ effect eStrike  = EffectVisualEffect(VFX_FNF_LOS_HOLY_10);
    effect eAOE;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eStrike, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            //*:* check undead so we don't hurt undead friendlies on easy game settings
            if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                    GRHealOrHarmTarget(spInfo.oTarget, iDamage, vfx_impactNormalHurt, vfx_impactUndeadHurt, vfx_impactHeal, spInfo.iSpellID,
                                TRUE, bHarmTouchSpell);
                }
            } else if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_CONSTRUCT) {
                //*:* Constructs are not living targets, so they are not affected
                if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                    GRHealOrHarmTarget(spInfo.oTarget, iDamage, vfx_impactNormalHurt, vfx_impactUndeadHurt, vfx_impactHeal, spInfo.iSpellID,
                                TRUE, FALSE);

                    //*:**********************************************
                    //*:*  remove all other effects cured by Heal
                    //*:**********************************************
                    GRRemoveMultipleSpellEffects(SPELL_GR_HEMORRHAGE, SPELL_FEEBLEMIND, spInfo.oTarget, FALSE, SPELL_STINKING_CLOUD, SPELL_GHOUL_TOUCH);
                    GRRemoveMultipleSpellEffects(SPELL_GR_IGEDRAZAARS_MIASMA, SPELL_INFESTATION_OF_MAGGOTS, spInfo.oTarget);

                    eAOE = GetFirstEffect(spInfo.oTarget);
                    while(GetIsEffectValid(eAOE)) {
                        switch(GetEffectType(eAOE)) {
                            case EFFECT_TYPE_DISEASE:
                            case EFFECT_TYPE_CONFUSED:
                            case EFFECT_TYPE_STUNNED:
                            case EFFECT_TYPE_DAZED:
                            case EFFECT_TYPE_BLINDNESS:
                            case EFFECT_TYPE_DEAF:
                            case EFFECT_TYPE_POISON:
                                GRRemoveEffect(eAOE, spInfo.oTarget);
                                break;
                            case EFFECT_TYPE_ABILITY_DECREASE:
                                if(GetEffectDurationType(eAOE)==DURATION_TYPE_TEMPORARY) {
                                    GRRemoveEffect(eAOE, spInfo.oTarget);
                                }
                                break;
                        }
                        eAOE = GetNextEffect(spInfo.oTarget);
                    }
                }
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
