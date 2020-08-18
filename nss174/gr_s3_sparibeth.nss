//*:**************************************************************************
//*:*  GR_S3_SPARIBETH.NSS
//*:**************************************************************************
//*:* OnHitCastSpell Misc Effects (x2_s3_misceffect) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-09-19
//*:**************************************************************************
/*
    Used for Aribeth in Hell...

    Based on Spell ID, has different effects

    791 - knockdown, DC = 10 + Caster Level
          will not work on PCs

    792 - freeze, DC = 10 + Caster Level,
                  Slow Creature hit or hitting for d3() rounds
*/
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
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    object  oItem           = GetSpellCastItem();

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

    float   fDuration       = GRGetDuration(d3());
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eKnock   = EffectKnockdown();
    effect eDur     = EffectVisualEffect(VFX_DUR_ICESKIN);
    effect eVis     = EffectVisualEffect(VFX_IMP_FROST_S);
    effect eSlow    = EffectSlow();
    effect eLink    = EffectLinkEffects(eDur, eSlow);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(oItem)) {
        if(!GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
            if(spInfo.iSpellID==791) {      // OnHitKnockDown
                if(!GetIsPC(oCaster)) {     // This does not work on PCs
                     spInfo.iDC = GRGetCasterLevel(oCaster)+10;
                     if(GetIsSkillSuccessful(spInfo.oTarget, SKILL_DISCIPLINE, spInfo.iDC)==0) {
                         GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, spInfo.oTarget, GRGetDuration(1));
                     }
                }
            } else if(spInfo.iSpellID==792) {// OnHitFreeze
                spInfo.iDC = GRGetCasterLevel(oCaster)+10;
                if(GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_COLD, oCaster)==0) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
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
