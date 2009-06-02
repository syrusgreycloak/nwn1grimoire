//*:**************************************************************************
//*:*  GR_S2_BARDSONG.NSS
//*:**************************************************************************
//*:* Bard Song (NW_S2_BardSong) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Feb 25, 2002
//*:**************************************************************************
//*:* Updated On: November 26, 2007
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

    if(GetHasEffect(EFFECT_TYPE_SILENCE, oCaster)) {
        FloatingTextStrRefOnCreature(85764,oCaster); // not useable when silenced
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    spInfo.iCasterLevel    = GRGetLevelByClass(CLASS_TYPE_BARD);
    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 10;
    int     iDurType          = DUR_TYPE_ROUNDS;

    //*:**********************************************
    //*:* Check to see if the caster has Lasting
    //*:* Impression and increase duration.
    //*:**********************************************
    if(GetHasFeat(870)) iDurAmount *= 10;

    //*:**********************************************
    //*:* Check if caster has Lingering Song
    //*:**********************************************
    if(GetHasFeat(424)) iDurAmount += 5;

    //*:**********************************************
    //*:* Check if caster has Inspirational Boost
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_INSPIRATIONAL_BOOST, oCaster)) {
        iBonus++;
    }

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iRanks          = GetSkillRank(SKILL_PERFORM);
    int     iCHAMod         = GetAbilityModifier(ABILITY_CHARISMA);
    int     iPerform        = iRanks;

    string  sTag            = GetTag(oCaster);
    if(sTag=="x0_hen_dee" || sTag=="x2_hen_deekin") {
        // * Deekin has a chance of singing a doom song
        // * same effect, better tune
        if(Random(100) + 1 > 80) {
            // the Xp2 Deekin knows more than one doom song
            if (d3() ==1 && sTag == "x2_hen_deekin") {
                DelayCommand(0.0, PlaySound("vs_nx2deekM_050"));
            } else {
                DelayCommand(0.0, PlaySound("vs_nx0deekM_074"));
                DelayCommand(5.0, PlaySound("vs_nx0deekM_074"));
            }
        }
    }

    int     iAttack         = 2;
    int     iDamage         = 3;
    int     iWill           = 3;
    int     iFort           = 2;
    int     iReflex         = 2;
    int     iHP;
    int     iAC             = 5;
    int     iSkill;

    if(iPerform >= 75 && spInfo.iCasterLevel >= 25) iAC = 6;

    if(iPerform >= 100 && spInfo.iCasterLevel >= 30) {
        iHP = 48;
        iAC = 7;
        iSkill = 19;
    } else if(iPerform >= 95 && spInfo.iCasterLevel >= 29) {
        iHP = 46;
        iSkill = 18;
    } else if(iPerform >= 90 && spInfo.iCasterLevel >= 28) {
        iHP = 44;
        iSkill = 17;
    } else if(iPerform >= 85 && spInfo.iCasterLevel >= 27) {
        iHP = 42;
        iSkill = 16;
    } else if(iPerform >= 80 && spInfo.iCasterLevel >= 26) {
        iHP = 40;
        iSkill = 15;
    } else if(iPerform >= 75 && spInfo.iCasterLevel >= 25) {
        iHP = 38;
        iSkill = 14;
    } else if(iPerform >= 70 && spInfo.iCasterLevel >= 24) {
        iHP = 36;
        iSkill = 13;
    } else if(iPerform >= 65 && spInfo.iCasterLevel >= 23) {
        iHP = 34;
        iSkill = 12;
    } else if(iPerform >= 60 && spInfo.iCasterLevel >= 22) {
        iHP = 32;
        iSkill = 11;
    } else if(iPerform >= 55 && spInfo.iCasterLevel >= 21) {
        iHP = 30;
        iSkill = 9;
    } else if(iPerform >= 50 && spInfo.iCasterLevel >= 20) {
        iHP = 28;
        iSkill = 8;
    } else if(iPerform >= 45 && spInfo.iCasterLevel >= 19) {
        iHP = 26;
        iSkill = 7;
    } else if(iPerform >= 40 && spInfo.iCasterLevel >= 18) {
        iHP = 24;
        iSkill = 6;
    } else if(iPerform >= 35 && spInfo.iCasterLevel >= 17) {
        iHP = 22;
        iSkill = 5;
    } else if(iPerform >= 30 && spInfo.iCasterLevel >= 16) {
        iHP = 20;
        iSkill = 4;
    } else if(iPerform >= 24 && spInfo.iCasterLevel >= 15) {
        iHP = 16;
        iAC = 4;
        iSkill = 3;
    } else if(iPerform >= 21 && spInfo.iCasterLevel >= 14) {
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iHP = 16;
        iAC = 3;
        iSkill = 2;
    } else if(iPerform >= 18 && spInfo.iCasterLevel >= 11) {
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iHP = 8;
        iAC = 2;
        iSkill = 2;
    } else if(iPerform >= 15 && spInfo.iCasterLevel >= 8) {
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iHP = 8;
        iAC = 0;
        iSkill = 1;
    } else if(iPerform >= 12 && spInfo.iCasterLevel >= 6) {
        iAttack = 1;
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 1;
        iHP = 0;
        iAC = 0;
        iSkill = 1;
    } else if(iPerform >= 9 && spInfo.iCasterLevel >= 3) {
        iAttack = 1;
        iDamage = 2;
        iWill = 1;
        iFort = 1;
        iReflex = 0;
        iHP = 0;
        iAC = 0;
        iSkill = 0;
    } else if(iPerform >= 6 && spInfo.iCasterLevel >= 2) {
        iAttack = 1;
        iDamage = 1;
        iWill = 1;
        iFort = 0;
        iReflex = 0;
        iHP = 0;
        iAC = 0;
        iSkill = 0;
    } else if(iPerform >= 3 && spInfo.iCasterLevel >= 1) {
        iAttack = 1;
        iDamage = 1;
        iWill = 0;
        iFort = 0;
        iReflex = 0;
        iHP = 0;
        iAC = 0;
        iSkill = 0;
    }

    iAttack = (iAttack>0 ? iAttack+iBonus : iAttack);
    iDamage = (iDamage>0 ? iDamage+iBonus : iDamage);
    iWill = (iWill>0 ? iWill+iBonus : iWill);
    iFort = (iFort>0 ? iFort+iBonus : iFort);
    iReflex = (iReflex>0 ? iReflex+iBonus : iReflex);
    iHP = (iHP>0 ? iHP+iBonus : iHP);
    iSkill = (iSkill>0 ? iSkill+iBonus : iSkill);
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
    effect eVis     = EffectVisualEffect(VFX_DUR_BARD_SONG);
    effect eImpact  = EffectVisualEffect(VFX_IMP_HEAD_SONIC);
    effect eFNF     = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    effect eAttack  = EffectAttackIncrease(iAttack);
    effect eDamage  = EffectDamageIncrease(iDamage, DAMAGE_TYPE_BLUDGEONING);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink    = EffectLinkEffects(eAttack, eDamage);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eWill;
    effect eFort;
    effect eReflex;
    effect eHP;
    effect eAC;
    effect eSkill;

    if(iWill > 0) {
        eWill = EffectSavingThrowIncrease(SAVING_THROW_WILL, iWill);
        eLink = EffectLinkEffects(eLink, eWill);
    }

    if(iFort > 0) {
        eFort = EffectSavingThrowIncrease(SAVING_THROW_FORT, iFort);
        eLink = EffectLinkEffects(eLink, eFort);
    }

    if(iReflex > 0) {
        eReflex = EffectSavingThrowIncrease(SAVING_THROW_REFLEX, iReflex);
        eLink = EffectLinkEffects(eLink, eReflex);
    }

    if(iHP > 0) {
        //SpeakString("HP Bonus " + IntToString(iHP));
        eHP = EffectTemporaryHitpoints(iHP);
        eHP = ExtraordinaryEffect(eHP);
        //eLink = EffectLinkEffects(eLink, eHP);
    }

    if(iAC > 0) {
        eAC = EffectACIncrease(iAC, AC_DODGE_BONUS);
        eLink = EffectLinkEffects(eLink, eAC);
    }

    if(iSkill > 0) {
        eSkill = EffectSkillIncrease(SKILL_ALL_SKILLS, iSkill);
        eLink = EffectLinkEffects(eLink, eSkill);
    }

    eLink = ExtraordinaryEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eFNF, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(!GetHasFeatEffect(FEAT_BARD_SONGS, spInfo.oTarget) && !GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
             if(!GetHasEffect(EFFECT_TYPE_SILENCE, spInfo.oTarget) && !GetHasEffect(EFFECT_TYPE_DEAF, spInfo.oTarget)) {
                if(spInfo.oTarget == oCaster) {
                    effect eLinkBard = EffectLinkEffects(eLink, eVis);
                    eLinkBard = ExtraordinaryEffect(eLinkBard);
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLinkBard, spInfo.oTarget, fDuration);
                    if(iHP > 0) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, spInfo.oTarget, fDuration);
                    }
                } else if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, NO_CASTER)) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    if(iHP > 0) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHP, spInfo.oTarget, fDuration);
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
