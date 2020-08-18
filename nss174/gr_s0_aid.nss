//*:**************************************************************************
//*:*  GR_S0_AID.NSS
//*:**************************************************************************
//*:* Aid (nw_s0_aid) by Bioware Corp
//*:* Created By: Preston Watamaniuk  Created On: Sept 6, 2001
//*:* 3.5 Player's Handbook (p. 196)
//*:*
//*:* Virtue (NW_S0_Virtue.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Sept 6, 2001
//*:* 3.5 Player's Handbook (p. 298)
//*:**************************************************************************
//*:* Mass Aid - Spell Compendium (p. 8)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 25, 2007
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
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
    //*:* Declare major variables & impose limiting
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 8;
    int     iNumDice          = 1;
    int     iBonus            = spInfo.iCasterLevel;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

    switch(spInfo.iSpellID) {
        case SPELL_AID:
            iBonus = MinInt(10, iBonus);
            break;
        case SPELL_GR_MASS_AID:
            iBonus = MinInt(15, iBonus);
            break;
        case SPELL_VIRTUE:
            iDurAmount = 1;
            break;
    }

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
    //*:* Declare Spell Specific Variables
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(15.0);
    int     iDurationType        = DURATION_TYPE_TEMPORARY;

    int     bMultiTarget    = (spInfo.iSpellID==SPELL_GR_MASS_AID);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration   = ApplyMetamagicDurationMods(fDuration);
        iDurationType  = ApplyMetamagicDurationTypeMods(iDurationType);
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
    /*** NWN1 SPECIFIC ***/
        effect eImpVis  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eVis     = EffectVisualEffect(VFX_IMP_HOLY_AID);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eDur     = EffectVisualEffect(spInfo.iSpellID!=SPELL_VIRTUE ? VFX_DUR_SPELL_AID : VFX_DUR_SPELL_VIRTUE);
    effect eAttack  = EffectAttackIncrease(1);
    effect eSave    = EffectSavingThrowIncrease(SAVING_THROW_ALL, 1, SAVING_THROW_TYPE_FEAR);
    effect eHP;      //= EffectTemporaryHitpoints(iDamage);

    effect eLink;
    if(spInfo.iSpellID!=SPELL_VIRTUE) {
        eLink = EffectLinkEffects(eAttack, eSave);
        eLink = EffectLinkEffects(eLink, eDur);
    } else {
        eLink = eDur;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpVis, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                if(GetHasEffect(EFFECT_TYPE_TEMPORARY_HITPOINTS, spInfo.oTarget)) {
                    GRRemoveEffects(EFFECT_TYPE_TEMPORARY_HITPOINTS, spInfo.oTarget);
                }
                iDamage = (spInfo.iSpellID==SPELL_VIRTUE ? 1 : GRGetSpellDamageAmount(spInfo));
                eHP = EffectTemporaryHitpoints(iDamage);
                /*** NWN2 SPECIFIC ***
                    if(spInfo.iSpellID!=SPELL_VIRTUE) {
                        eOnDispell = EffectOnDispel(0.0f, GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget));
                        eLink = EffectLinkEffects(eLink, eOnDispell);
                        eHP = EffectLinkEffects(eHP, eOnDispell);
                    }
                /*** END NWN2 SPECIFIC ***/

                eLink = EffectLinkEffects(eLink, eHP);
                /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);
            }

            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
