//*:**************************************************************************
//*:*  GR_S0_ETHER.NSS
//*:**************************************************************************
//*:*
//*:* Etherealness (x0_s0_ether.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 228)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 7, 2002
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
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
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

    float   fDuration       = (spInfo.iSpellID==SPELL_ETHEREALNESS ? GRGetSpellDuration(spInfo) : GRGetDuration(5));
    //*:* float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(5.0);
    int     iVisualType     = (spInfo.iSpellID==SPELL_ETHEREALNESS ? VFX_DUR_SANCTUARY : VFX_DUR_BLUR);
    int     iNumAdditional  = spInfo.iCasterLevel/3;
    int     bMultiTarget    = (spInfo.iSpellID==SPELL_ETHEREALNESS);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSanc    = EffectEthereal();

    effect eLink    = EffectLinkEffects(eVis, eSanc);
    eLink = EffectLinkEffects(eLink, eDur);


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_ETHEREALNESS, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_ETHEREALNESS, spInfo.oTarget);
        GRSetIsIncorporeal(spInfo.oTarget, FALSE);
    } else if(GetHasSpellEffect(724, spInfo.oTarget)) {
        GRRemoveSpellEffects(724, spInfo.oTarget);
        GRSetIsIncorporeal(spInfo.oTarget, FALSE);
    }

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRSetIsIncorporeal(spInfo.oTarget, TRUE);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    DelayCommand(fDuration, GRSetIsIncorporeal(spInfo.oTarget, FALSE));

    spInfo.lTarget = GetLocation(spInfo.oTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    while(GetIsObjectValid(spInfo.oTarget) && iNumAdditional>0 && bMultiTarget) {
        // caster already affected
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, NO_CASTER)) {
            if(GetHasSpellEffect(SPELL_ETHEREALNESS, spInfo.oTarget)) {
                GRRemoveSpellEffects(SPELL_ETHEREALNESS, spInfo.oTarget);
                GRSetIsIncorporeal(spInfo.oTarget, FALSE);
            } else if(GetHasSpellEffect(724, spInfo.oTarget)) {
                GRRemoveSpellEffects(724, spInfo.oTarget);
                GRSetIsIncorporeal(spInfo.oTarget, FALSE);
            }

            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_ETHEREALNESS, FALSE));
            GRSetIsIncorporeal(spInfo.oTarget, TRUE);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
            DelayCommand(fDuration, GRSetIsIncorporeal(spInfo.oTarget, FALSE));
            iNumAdditional--;
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
