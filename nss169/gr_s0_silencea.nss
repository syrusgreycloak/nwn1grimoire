//*:**************************************************************************
//*:*  GR_S0_SILENCEA.NSS
//*:**************************************************************************
//*:* Silence: On Enter (NW_S0_SilenceA.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 279)
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

    int     bHostile        = GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE);
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
    /*** NWN1 SPECIFIC ***/
        effect eDur1    = EffectVisualEffect(VFX_IMP_SILENCE);
        effect eDur2    = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        effect eDur1    = EffectVisualEffect(VFX_HIT_SPELL_ILLUSION);
        effect eDur2    = EffectVisualEffect(VFX_DUR_SPELL_SILENCE);
    /*** END NWN2 SPECIFIC ***/
    effect eSilence = EffectSilence();
    effect eImmune  = EffectDamageImmunityIncrease(DAMAGE_TYPE_SONIC, 100);

    effect eLink    = EffectLinkEffects(eDur2, eSilence);
    eLink = EffectLinkEffects(eLink, eImmune);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(!GetIsInCombat(spInfo.oTarget))
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_SILENCE, bHostile));
        if((bHostile && !GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) || !bHostile) {
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
        }
    }
    /*** NWN2 SPECIFIC ***
    if(!GetLocalInt(spInfo.oTarget, EVENFLW_SILENCE)) {
        SetLocalObject(spInfo.oTarget, EVENFLW_SILENCE, OBJECT_SELF);
    } else {
        SetLocalObject(spInfo.oTarget, EVENFLW_SILENCE, OBJECT_INVALID);
    }
    /*** END NWN2 SPECIFIC ***/

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
