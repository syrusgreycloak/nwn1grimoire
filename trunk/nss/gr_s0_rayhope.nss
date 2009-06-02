//*:**************************************************************************
//*:*  GR_S0_RAYHOPE.NSS
//*:**************************************************************************
//*:* Ray of Hope
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 22, 2008
//*:* Book of Exalted Deeds (p. 105)
//*:*
//*:* Sorrow
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 22, 2008
//*:* Book of Vile Darkness (p. 104)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 2;
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iVisType        = VFX_IMP_HEAD_HOLY;
    int     iDurType        = VFX_DUR_MIND_AFFECTING_POSITIVE;
    int     bHostile        = FALSE;
    int     iOppositeSpell  = SPELL_GR_SORROW;

    if(spInfo.iSpellID==SPELL_GR_SORROW) {
            iVistype = VFX_IMP_HEAD_EVIL;
            iDurType = VFX_DUR_MIND_AFFECTING_NEGATIVE;
            bHostile = TRUE;
            iOppositeSpell = SPELL_GR_RAY_OF_HOPE;
    }

    int     bApply          = !GetHasSpellEffect(iOppositeSpell, spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
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
    effect eVis     = EffectVisualEffect(iVisType);
    effect eDur     = EffectVisualEffect(iDurType);
    effect eAtt, eSave, eSkill;

    switch(spInfo.iSpellID) {
        case SPELL_GR_RAY_OF_HOPE:
            eAtt = EffectAttackIncrease(iBonus);
            eSave = EffectSavingThrowIncrease(SAVING_THROW_TYPE_ALL, iBonus);
            eSkill = EffectSkillIncrease(SKILL_ALL_SKILLS, iBonus);
            break;
        case SPELL_GR_SORROW:
            eAtt = EffectAttackDecrease(iBonus);
            eSave = EffectSavingThrowDecrease(SAVING_THROW_TYPE_ALL, iBonus);
            eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, iBonus);
            break;
    }

    effect eLink    = EffectLinkEffects(eDur, eAtt);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eSkill);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsLiving(spInfo.oTarget)) {

        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, bHostile));
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget) || !bHostile) {
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS) || !bHostile) {
                GRRemoveMultipleSpellEffects(SPELL_GR_RAY_OF_HOPE, SPELL_GR_SORROW, spInfo.oTarget);

                if(bApply) {  // did not dispel an effect
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget);
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
