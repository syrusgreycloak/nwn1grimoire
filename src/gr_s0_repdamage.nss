//*:**************************************************************************
//*:*  GR_S0_REPDAMAGE.NSS
//*:**************************************************************************
//*:* Repair Damage series (Min,Lgt,Mod,Ser,Crit) (SG_S0_RepDamage.nss)
//*:* 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 21, 2003
//*:* Spell Compendium (p. 173)
//*:**************************************************************************
//*:* Updated On: February 27, 2008
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

    int     iVisual;
    int     iDieType          = 8;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;
    switch(spInfo.iSpellID) {
        case SPELL_GR_REP_MINOR_DAMAGE:
            iDieType = 1;
            iNumDice = 1;
            iBonus = 0;
            iVisual = VFX_IMP_HEAD_HEAL;
            break;
        case SPELL_GR_REP_LIGHT_DAMAGE:
            iNumDice = 1;
            iBonus = MinInt(5, spInfo.iCasterLevel);
            iVisual = VFX_IMP_HEALING_L;
            break;
        case SPELL_GR_REP_MODERATE_DAMAGE:
            iNumDice = 2;
            iBonus = MinInt(10, spInfo.iCasterLevel);
            iVisual = VFX_IMP_HEALING_M;
            break;
        case SPELL_GR_REP_SERIOUS_DAMAGE:
            iNumDice = 3;
            iBonus = MinInt(15, spInfo.iCasterLevel);
            iVisual = VFX_IMP_HEALING_S;
            break;
        case SPELL_GR_REP_CRITICAL_DAMAGE:
            iNumDice = 4;
            iBonus = MinInt(20, spInfo.iCasterLevel);
            iVisual = VFX_IMP_HEALING_G;
            break;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisual);
    effect eHeal    = EffectHeal(iDamage);
    effect eLink    = EffectLinkEffects(eHeal, eVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_CONSTRUCT) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
