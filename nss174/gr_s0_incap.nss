//*:**************************************************************************
//*:* GR_S0_INCAP.NSS
//*:**************************************************************************
//*:* Incapacitate (sg_s0_incap.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 28, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: February 25, 2008
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
    //*:* int     iBonus            = 0;
    int     iDamage           = MinInt(150, spInfo.iCasterLevel*10);
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iSTR            = GetAbilityScore(spInfo.oTarget,ABILITY_STRENGTH)-3;
    int     iDEX            = GetAbilityScore(spInfo.oTarget,ABILITY_DEXTERITY)-3;
    int     iCON            = GetAbilityScore(spInfo.oTarget,ABILITY_CONSTITUTION)-3;
    int     iINT            = GetAbilityScore(spInfo.oTarget,ABILITY_INTELLIGENCE)-3;
    int     iWIS            = GetAbilityScore(spInfo.oTarget,ABILITY_WISDOM)-3;
    int     iCHA            = GetAbilityScore(spInfo.oTarget,ABILITY_CHARISMA)-3;
    int     iHeal           = GetMaxHitPoints(spInfo.oTarget)-GetCurrentHitPoints(spInfo.oTarget);
    int     iRoll;

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
    effect eCurse       = EffectCurse(iSTR,iDEX,iCON,iINT,iWIS,iCHA);

    effect eCastVis     = EffectVisualEffect(VFX_FNF_LOS_EVIL_10);
    effect eImp1        = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eImp2        = EffectVisualEffect(VFX_IMP_DOOM);
    effect eImpLink     = EffectLinkEffects(eImp1,eImp2);
    effect eVisDur      = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);
    effect eCurseLink   = EffectLinkEffects(eVisDur,eCurse);
    effect eVis         = EffectVisualEffect(246);
    effect eVis2        = EffectVisualEffect(VFX_IMP_HEALING_G);
    effect eHeal        = EffectHeal(iDamage);
    effect eDam         = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_INCAPACITATE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCastVis, oCaster);
    if(TouchAttackMelee(spInfo.oTarget)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
                if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spInfo.oTarget);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget);
                } else {
                    eImpLink = EffectLinkEffects(eVis, eImpLink);
                    DelayCommand(2.0f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                }
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpLink, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eCurseLink, spInfo.oTarget);
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
