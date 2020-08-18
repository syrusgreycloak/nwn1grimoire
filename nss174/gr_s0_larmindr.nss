//*:**************************************************************************
//*:*  GR_S0_LARMINDR.NSS
//*:**************************************************************************
//*:* Larloch's Minor Drain (sg_s0_larmindr.nss) 2005 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 12, 2005
//*:* Source: Baldur's Gate CRPG
//*:**************************************************************************
//*:* Updated On: March 11, 2008
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
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 10;
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iCurrHP         = GetCurrentHitPoints();
    int     iMaxHP          = GetMaxHitPoints();

    int     iAttackResult   = GRTouchAttackRanged(spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo) * iAttackResult;
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo) * iAttackResult;
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eDam     = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE);
    effect eLink    = EffectLinkEffects(eVis, eDam);
    effect eHealVis = EffectVisualEffect(VFX_IMP_HEALING_L);
    effect eHeal;
    effect eTempHP;

    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(iDamage>0) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_LARLOCHS_MINOR_DRAIN));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);

            if(iCurrHP+iDamage<=iMaxHP) {
                eHeal = EffectHeal(iDamage);
                SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_LARLOCHS_MINOR_DRAIN, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oCaster);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHealVis, oCaster);
            } else if(iCurrHP>=iMaxHP && iCurrHP<iMaxHP+20) {
                if(iCurrHP+iDamage>iMaxHP+20) {
                    iDamage = iMaxHP+20-iCurrHP;
                }
                eTempHP = EffectTemporaryHitpoints(iDamage);
                SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_LARLOCHS_MINOR_DRAIN, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHealVis, oCaster);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, oCaster, fDuration);
            } else if(iCurrHP<iMaxHP && iCurrHP+iDamage>iMaxHP) {
                eHeal = EffectHeal(iMaxHP-iCurrHP);
                eTempHP = EffectTemporaryHitpoints(iDamage-(iMaxHP-iCurrHP));
                SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_LARLOCHS_MINOR_DRAIN, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHealVis, oCaster);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oCaster);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, oCaster, fDuration);
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
