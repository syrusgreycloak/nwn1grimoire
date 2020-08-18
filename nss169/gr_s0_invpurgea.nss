//*:**************************************************************************
//*:*  GR_S0_INVPURGE.NSS
//*:**************************************************************************
//*:*
//*:* Invisibilty Purge: On Enter (NW_S0_InvPurgeA) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 245)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 7, 2002
//*:**************************************************************************
//*:* Updated On: November 2, 2007
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
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo.oTarget = GetEnteringObject();

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     bEffectRemoved      = FALSE;

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
    //*** NWN2 SINGLE ***/ effect eHit = EffectVisualEffect(VFX_DUR_SPELL_INVISIBILITY_PURGE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_INVISIBILITY, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_INVISIBILITY, spInfo.oTarget);
        bEffectRemoved = TRUE;
    } else if(GetHasSpellEffect(SPELL_GREATER_INVISIBILITY, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_GREATER_INVISIBILITY, spInfo.oTarget);
        bEffectRemoved = TRUE;
    } else if(GetHasSpellEffect(SPELLABILITY_AS_INVISIBILITY, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELLABILITY_AS_INVISIBILITY, spInfo.oTarget);
        bEffectRemoved = TRUE;
    } else if(GetHasSpellEffect(SPELL_GR_INVISIBILITY_SWIFT, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_GR_INVISIBILITY_SWIFT, spInfo.oTarget);
        bEffectRemoved = TRUE;
    } else if(GetHasSpellEffect(SPELL_I_RETRIBUTIVE_INVISIBILITY, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_I_RETRIBUTIVE_INVISIBILITY, spInfo.oTarget);
        bEffectRemoved = TRUE;
    } else if(GetHasSpellEffect(799, spInfo.oTarget)) {
        GRRemoveSpellEffects(799, spInfo.oTarget);
        bEffectRemoved = TRUE;
    } else if(GetHasSpellEffect(SPELL_INVISIBILITY_SPHERE, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_INVISIBILITY_SPHERE, spInfo.oTarget);
        bEffectRemoved = TRUE;
    } else if(GetHasSpellEffect(SPELL_I_WALK_UNSEEN, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_I_WALK_UNSEEN, spInfo.oTarget);
        bEffectRemoved = TRUE;
    }

    effect  eInvis = GetFirstEffect(spInfo.oTarget);
    int     bIsGreaterInvis;

    while(GetIsEffectValid(eInvis)) {
        /*** NWN1 SINGLE ***/ bIsGreaterInvis = (GetEffectType(eInvis)==EFFECT_TYPE_IMPROVEDINVISIBILITY);
        //*** NWN2 SINGLE ***/ bIsGreaterInvis = (GetEffectType(eInvis)==EFFECT_TYPE_GREATERINVISIBILITY);

        if(GetEffectType(eInvis)==EFFECT_TYPE_INVISIBILITY || bIsGreaterInvis) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_INVISIBILITY_PURGE,
                    GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)));

            if(bIsGreaterInvis) {
                GRRemoveSpellEffects(SPELL_GREATER_INVISIBILITY, spInfo.oTarget);
            }
            if(GetIsEffectValid(eInvis)) GRRemoveEffect(eInvis, spInfo.oTarget);
            bEffectRemoved = TRUE;
        }
        eInvis = GetNextEffect(spInfo.oTarget);
    }

    //*** NWN2 SINGLE ***/ if(bEffectRemoved) GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, spInfo.oTarget);

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
