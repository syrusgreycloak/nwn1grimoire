//*:**************************************************************************
//*:*  GR_S2_CURSESONG.NSS
//*:**************************************************************************
//*:* Curse Song (X2_S2_CurseSong) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: May 16, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: January 10, 2007
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

    if(!GetHasFeat(FEAT_BARD_SONGS, oCaster)) {
        FloatingTextStrRefOnCreature(85587, oCaster); // no more bardsong uses left
        return;
    }

    if(GetHasEffect(EFFECT_TYPE_SILENCE, oCaster)) {
        FloatingTextStrRefOnCreature(85764, oCaster); // not useable when silenced
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    spInfo.iCasterLevel       = GRGetLevelByClass(CLASS_TYPE_BARD);
    spInfo.lTarget            = GetLocation(oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = 3;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
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
    if(GetHasFeat(870)) iDurAmount *= 10;       //*:* Check if has Lasting Impression
    if(GetHasFeat(424)) iDurAmount += 5;        //*:* Check if has Lingering Song

    float   fDuration       = GRGetDuration(iDurAmount, iDurType);
    float   fDelay          = 0.0f;
    float   fRange          = RADIUS_SIZE_COLOSSAL;

    int iAttack             = 2;
    int iWill               = 3;
    int iFort               = 2;
    int iReflex             = 2;
    int iHP                 = 0;
    int iAC                 = 6;
    int iSkill              = 0;
    int     iRanks          = GetSkillRank(SKILL_PERFORM);
    int     iPerform        = iRanks;

    if(iPerform>=100 && spInfo.iCasterLevel>=30) {
        iHP = 48;
        iAC = 7;
        iSkill = 18;
    } else if(iPerform>=95 && spInfo.iCasterLevel>=29) {
        iHP = 46;
        iSkill = 17;
    } else if(iPerform>=90 && spInfo.iCasterLevel>=28) {
        iHP = 44;
        iSkill = 16;
    } else if(iPerform>=85 && spInfo.iCasterLevel>=27) {
        iHP = 42;
        iSkill = 15;
    } else if(iPerform>=80 && spInfo.iCasterLevel>=26) {
        iHP = 40;
        iSkill = 14;
    } else if(iPerform>=75 && spInfo.iCasterLevel>=25) {
        iHP = 38;
        iSkill = 13;
    } else if(iPerform>=70 && spInfo.iCasterLevel>=24) {
        iHP = 36;
        iAC = 5;
        iSkill = 12;
    } else if(iPerform>=65 && spInfo.iCasterLevel>=23) {
        iHP = 34;
        iAC = 5;
        iSkill = 11;
    } else if(iPerform>=60 && spInfo.iCasterLevel>=22) {
        iHP = 32;
        iAC = 5;
        iSkill = 10;
    } else if(iPerform>=55 && spInfo.iCasterLevel>=21) {
        iHP = 30;
        iAC = 5;
        iSkill = 9;
    } else if(iPerform>=50 && spInfo.iCasterLevel>=20) {
        iHP = 28;
        iAC = 5;
        iSkill = 8;
    } else if(iPerform>=45 && spInfo.iCasterLevel>=19) {
        iHP = 26;
        iAC = 5;
        iSkill = 7;
    } else if(iPerform>=40 && spInfo.iCasterLevel>=18) {
        iHP = 24;
        iAC = 5;
        iSkill = 6;
    } else if(iPerform>=35 && spInfo.iCasterLevel>=17) {
        iHP = 22;
        iAC = 5;
        iSkill = 5;
    } else if(iPerform>=30 && spInfo.iCasterLevel>=16) {
        iHP = 20;
        iAC = 5;
        iSkill = 4;
    } else if(iPerform>=24 && spInfo.iCasterLevel>=15) {
        iWill = 2;
        iHP = 16;
        iAC = 4;
        iSkill = 3;
    } else if(iPerform>=21 && spInfo.iCasterLevel>=14) {
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iHP = 16;
        iAC = 3;
        iSkill = 2;
    } else if(iPerform>=18 && spInfo.iCasterLevel>=12) {
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iHP = 8;
        iAC = 2;
        iSkill = 2;
    } else if(iPerform>=15 && spInfo.iCasterLevel>=8) {
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iHP = 8;
        iAC = 0;
        iSkill = 1;
    } else if(iPerform>=12 && spInfo.iCasterLevel>=6) {
        iAttack = 1;
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iAC = 0;
        iSkill = 1;
    } else if(iPerform>=9 && spInfo.iCasterLevel>=3) {
        iAttack = 1;
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 0;
        iAC = 0;
    } else if(iPerform>=6 && spInfo.iCasterLevel>=2) {
        iAttack = 1;
        iDamage = 1;
        iWill = 1;
        iFort = 0;
        iReflex = 0;
        iAC = 0;
    } else if(iPerform>=3 && spInfo.iCasterLevel>=1) {
        iAttack = 1;
        iDamage = 1;
        iWill = 0;
        iFort = 0;
        iReflex = 0;
        iAC = 0;
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
    effect eVis         = EffectVisualEffect(VFX_IMP_DOOM);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2        = EffectVisualEffect(507);
    effect eImpact      = EffectVisualEffect(VFX_IMP_HEAD_SONIC);
    effect eFNF         = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eAttack      = EffectAttackDecrease(iAttack);
    effect eDamage      = EffectDamageDecrease(iDamage, DAMAGE_TYPE_SLASHING);
    effect eWill;
    effect eFort;
    effect eReflex;
    effect eHP;
    effect eAC;
    effect eSkill;

    effect eLink        = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eDur);

    if(iWill>0) {
        eWill = EffectSavingThrowDecrease(SAVING_THROW_WILL, iWill);
        eLink = EffectLinkEffects(eLink, eWill);
    }
    if(iFort>0) {
        eFort = EffectSavingThrowDecrease(SAVING_THROW_FORT, iFort);
        eLink = EffectLinkEffects(eLink, eFort);
    }
    if(iReflex>0) {
        eReflex = EffectSavingThrowDecrease(SAVING_THROW_REFLEX, iReflex);
        eLink = EffectLinkEffects(eLink, eReflex);
    }
    if(iHP>0) {
        eHP = ExtraordinaryEffect(EffectDamage(iHP, DAMAGE_TYPE_SONIC, DAMAGE_POWER_NORMAL));
    }
    if(iAC>0) {
        eAC = EffectACDecrease(iAC, AC_DODGE_BONUS);
        eLink = EffectLinkEffects(eLink, eAC);
    }
    if(iSkill>0) {
        eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, iSkill);
        eLink = EffectLinkEffects(eLink, eSkill);
    }

    eLink = ExtraordinaryEffect(eLink);


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);


    if(!GetHasFeatEffect(871, spInfo.oTarget)&& !GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur2, OBJECT_SELF, fDuration);
    }
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)) {
             // * GZ Oct 2003: If we are deaf, we do not have negative effects from curse song
            if(!GetHasEffect(EFFECT_TYPE_DEAF, spInfo.oTarget)) {
                if(!GetHasFeatEffect(871, spInfo.oTarget)&& !GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
                    if(iHP>0) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SONIC), spInfo.oTarget);
                        DelayCommand(0.01, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHP, spInfo.oTarget));
                    }

                    if(!GetIsDead(spInfo.oTarget)) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                        DelayCommand(GetRandomDelay(0.1,0.5), GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                   }
                }
            } else {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE), spInfo.oTarget);
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }
    DecrementRemainingFeatUses(oCaster, FEAT_BARD_SONGS);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
