//*:**************************************************************************
//*:*  GR_S0_BANE.NSS
//*:**************************************************************************
//*:*
//*:* Bane - -1 to attacks, save vs fear for enemies (50 ft around caster)
//*:*           1 min/level
//*:* Created By: Preston Watamaniuk  Created On: July 24, 2001
//*:* 3.5 Player's Handbook (p. 203)
//*:**************************************************************************
//*:* Updated On: December 3, 2007
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = -1;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

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
    float   fDelay;
    float   fRange          = FeetToMeters(50.0);
    int     iSaveType       = SAVING_THROW_TYPE_FEAR;
    int     iNegVisType     = VFX_IMP_DOOM;
    int     iPosVisType     = VFX_IMP_HEAD_EVIL;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eNegVis = EffectVisualEffect(iNegVisType);

    effect eNegAttack   = EffectAttackDecrease(iBonus);
    effect eNegSave     = EffectSavingThrowDecrease(SAVING_THROW_ALL, iBonus);
    effect eNegDam      = EffectDamageDecrease(iBonus, DAMAGE_TYPE_DIVINE);
    effect eNegSkill    = EffectSkillDecrease(SKILL_ALL_SKILLS, iBonus);
    effect eNegDur      = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eNegLink     = EffectLinkEffects(eNegAttack, eNegSave);
    eNegLink            = EffectLinkEffects(eNegLink, eNegDur);
    if(spInfo.iSpellID!=SPELL_BANE) {
        eNegLink            = EffectLinkEffects(eNegLink, eNegDam);
        eNegLink            = EffectLinkEffects(eNegLink, eNegSkill);
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oCaster));

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                int iWillResult = WillSave(spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS);
                // * Bane is a mind affecting spell BUT its effects are not classified
                // * as mind affecting. To make this work I have to only apply
                // * the effects on the case of a failure, unlike most other spells.
                if(iWillResult == 0) {
                    fDelay = GetRandomDelay(0.4, 1.1);
                    if(GRGetHasSpellEffect(SPELL_BLESS, spInfo.oTarget)) {
                        GRRemoveSpellEffects(SPELL_BLESS, spInfo.oTarget);
                    } else {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eNegVis, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNegLink, spInfo.oTarget, fDuration));
                    }
                } else if(iWillResult==2) {
                    // * target will immune
                    SpeakStringByStrRef(40105, TALKVOLUME_WHISPER);
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, GetLocation(oCaster));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
