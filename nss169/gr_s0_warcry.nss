//*:**************************************************************************
//*:*  GR_S0_WARCRY.NSS
//*:**************************************************************************
//*:* War Cry (NW_S0_WarCry) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Oct 22, 2001
//*:* Spell Compendium (p. 236)
//*:* (Grimoire - calling this one Greater Warcry)
//*:**************************************************************************
//*:* Warcry
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 30, 2008
//*:* Book of Exalted Deeds (p. 111)
//*:* (Grimoire - calling this one Lesser Warcry)
//*:**************************************************************************
//*:* Updated On: December 30, 2008
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

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = 4;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = (spInfo.iSpellID==SPELL_WAR_CRY ? spInfo.iCasterLevel : GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, 0));
    int     iDurType          = DUR_TYPE_ROUNDS;

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
    float   fRange          = (spInfo.iSpellID==SPELL_WAR_CRY ? FeetToMeters(15.0) : FeetToMeters(30.0));
    int     iSpellShape     = (spInfo.iSpellID==SPELL_WAR_CRY ? SHAPE_SPHERE : SHAPE_SPELLCONE);
    int     iSavingThrowType= (spInfo.iSpellID==SPELL_WAR_CRY ? SAVING_THROW_TYPE_FEAR : SAVING_THROW_TYPE_MIND_SPELLS);
    int     iSaveType       = (spInfo.iSpellID==SPELL_WAR_CRY ? SAVING_THROW_WILL : SAVING_THROW_FORT);

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
    effect eAttack  = EffectAttackIncrease(iBonus);
    effect eDamage  = EffectDamageIncrease(GRGetDamageBonusValue(iBonus));
    effect eFear    = (spInfo.iSpellID==SPELL_WAR_CRY ? EffectFrightened() : GREffectCowering());
    effect eVis     = EffectVisualEffect(VFX_IMP_HEAD_SONIC);
    effect eVisFear = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eLOS;
    if(GetGender(oCaster) == GENDER_FEMALE) {
        eLOS = EffectVisualEffect(290);
    } else {
        eLOS = EffectVisualEffect(VFX_FNF_HOWL_WAR_CRY);
    }

    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2    = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink    = EffectLinkEffects(eAttack, eDamage);
    eLink           = EffectLinkEffects(eLink, eDur2);
    effect eLink2   = EffectLinkEffects(eVisFear, eFear);
    eLink           = EffectLinkEffects(eLink, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLOS, oCaster);
    spInfo.oTarget = GRGetFirstObjectInShape(iSpellShape, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GRGetSaveResult(iSaveType, spInfo.oTarget, spInfo.iDC, iSavingThrowType)) {
                    DelayCommand(0.01, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink2, spInfo.oTarget, fDuration));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget);
    }

    if(spInfo.iSpellID==SPELL_WAR_CRY) {
        GRRemoveSpellEffects(SPELL_WAR_CRY, oCaster);
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_WAR_CRY, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);
        DelayCommand(0.01, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
