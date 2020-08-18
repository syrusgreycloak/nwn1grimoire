//*:**************************************************************************
//*:*  GR_S0_VAMPTCH.NSS
//*:**************************************************************************
//*:* Vampiric Touch (NW_S0_VampTch) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Oct 29, 2001
//*:* 3.5 Player's Handbook (p. 298)
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
    int     iNumDice          = MinInt(10, spInfo.iCasterLevel/2);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_HOURS;

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
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iHealAmt;

    // GZ: * GetSpellCastItem() == OBJECT_INVALID is used to prevent feedback from showing up when used as OnHitCastSpell property
    int     iAttackResult   = TouchAttackMelee(spInfo.oTarget, GetSpellCastItem()==OBJECT_INVALID);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay) * iAttackResult;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay) * iAttackResult;
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    if(iDamage>GetCurrentHitPoints(spInfo.oTarget)+10) {
        iHealAmt = GetCurrentHitPoints(spInfo.oTarget)+10;
    } else {
        iHealAmt = iDamage;
    }
    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eHeal    = EffectTemporaryHitpoints(iHealAmt);
    /*** NWN1 SPECIFIC ***/
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eVis     = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
        effect eVisHeal = EffectVisualEffect(VFX_IMP_HEALING_M);
        effect eLink    = EffectLinkEffects(eHeal, eDur);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eVis     = EffectVisualEffect(VFX_HIT_SPELL_NECROMANCY);
        effect eVisHeal = EffectVisualEffect(VFX_IMP_HEALING_S);
        effect eLink    = eHeal;
    /*** END NWN2 SPECIFIC ***/

    effect eDamage  = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE);

    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_CREATURE) {
        if(GRGetRacialType(spInfo.oTarget) != RACIAL_TYPE_UNDEAD &&
            GRGetRacialType(spInfo.oTarget) != RACIAL_TYPE_CONSTRUCT &&
            !GetHasSpellEffect(SPELL_DEATH_WARD, spInfo.oTarget)) {

            SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_VAMPIRIC_TOUCH, FALSE));
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_VAMPIRIC_TOUCH,
                GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)));
            if(iDamage>0) {
                if(GRGetSpellResisted(OBJECT_SELF, spInfo.oTarget) == 0) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVisHeal, oCaster);
                    RemoveTempHitPoints();
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);
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
