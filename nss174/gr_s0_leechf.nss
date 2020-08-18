//*:**************************************************************************
//*:*  GR_S0_LEECHF.NSS
//*:**************************************************************************
//*:* Leech Field (SG_S0_LeechF.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 10, 2003
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

    int     iDieType          = 6;
    int     iNumDice          = MaxInt(1, MinInt(20, spInfo.iCasterLevel/2));
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 1;
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.2f;
    float   fRange          = FeetToMeters(10.0);

    int     iHeal           = 0;
    int     iTempHP         = 0;
    int     iCasterDamage   = 0;
    int     iNumUndead      = 0;
    int     iCurrHP         = GetCurrentHitPoints(oCaster);
    int     iMaxHP          = GetMaxHitPoints(oCaster);

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
    effect eImp1    = EffectVisualEffect(VFX_FNF_LEECH_FIELD);
    effect eImp2    = EffectVisualEffect(VFX_IMP_DEATH_WARD);
    effect eVisHeal = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eVisDmg  = EffectVisualEffect(VFX_IMP_CHARM);
    effect eDamage;
    effect eHeal;
    effect eTempHP;
    effect eDamageLink;
    effect eHealLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(SPELL_GR_LEECH_FIELD, oCaster, oCaster);

    SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_LEECH_FIELD, FALSE));
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eImp1, spInfo.lTarget, fDuration);
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp2, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_LEECH_FIELD));
            if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_UNDEAD && !GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, spInfo.oTarget, SAVING_THROW_TYPE_NEGATIVE, fDelay);
                iDamage = MinInt(iDamage, GetCurrentHitPoints(spInfo.oTarget)+10);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, oCaster);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                iHeal += iDamage;
                eDamage = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE, DAMAGE_POWER_PLUS_TWENTY);
                if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                eDamageLink = EffectLinkEffects(eVisDmg, eDamage);
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamageLink, spInfo.oTarget));
            } else if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
                if(GRGetSaveResult(SAVING_THROW_FORT, oCaster, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
                    iCasterDamage += iDamage;
                    iNumUndead++;
                    eDamage = EffectDamage(iDamage, DAMAGE_TYPE_NEGATIVE, DAMAGE_POWER_PLUS_TWENTY);
                    eDamageLink = EffectLinkEffects(eVisDmg, eDamage);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamageLink, oCaster));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }
    if(!GetIsDead(oCaster) && iHeal>0) {
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_LEECH_FIELD, FALSE));
        iCurrHP = GetCurrentHitPoints(oCaster);
        if(iHeal+iCurrHP<=iMaxHP) {
            eHeal = EffectHeal(iHeal);
            eHealLink = EffectLinkEffects(eVisHeal, eHeal);
        } else if(iMaxHP<=iCurrHP) {
            iTempHP=iHeal;
            iHeal=0;
            if(iTempHP+iCurrHP>iMaxHP)
               iTempHP = iCurrHP-iMaxHP;
            eTempHP = EffectTemporaryHitpoints(iTempHP);
            eHealLink = eVisHeal;
        } else // iCurrHP<iMaxHP and iHeal+iCurrHP>iMaxHP
        {
            iTempHP = iHeal-(iMaxHP-iCurrHP);
            eHeal = EffectHeal(iMaxHP-iCurrHP);
            eHealLink = EffectLinkEffects(eVisHeal,eHeal);
            if(iTempHP>iMaxHP)
               iTempHP = iMaxHP;
            eTempHP = EffectTemporaryHitpoints(iTempHP);
        }
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHealLink, oCaster);
        if(iTempHP>0)
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eTempHP, oCaster, GRGetDuration(1, DUR_TYPE_HOURS));
    }
    if(iCasterDamage>0) {
        iHeal = iCasterDamage/iNumUndead;
        eHeal = EffectHeal(iHeal);
        eHealLink = EffectLinkEffects(eVisHeal, eHeal);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        while(GetIsObjectValid(spInfo.oTarget) && iCasterDamage>0) {
            if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHealLink, spInfo.oTarget);
                iCasterDamage -= iHeal;
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
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
