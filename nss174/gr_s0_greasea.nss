//*:**************************************************************************
//*:*  GR_S0_GREASEA.NSS
//*:**************************************************************************
//*:*
//*:* Grease: On Enter (NW_S0_GreaseA.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 237)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Aug 1, 2001
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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

    spInfo.oTarget         = GetEnteringObject();
    spInfo.iDC             = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
    int     bWillDisbelief = FALSE;

    if(spInfo.iSpellSchool==SPELL_SCHOOL_ILLUSION) {
        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
            SetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_"+ObjectToString(oCaster)+"_WILLDISBELIEF", TRUE);
            bWillDisbelief = TRUE;
        }
    }

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    float   fDelay          = GetRandomDelay(1.0, 2.2);

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
    effect eVis     = EffectVisualEffect(VFX_IMP_SLOW);
    effect eSlow    = EffectMovementSpeedDecrease(50);
    effect eLink    = EffectLinkEffects(eVis, eSlow);
    //*** NWN2 SINGLE ***/ effect eHit = EffectVisualEffect(VFX_HIT_SPELL_ENCHANTMENT);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_GR_INCENDIARY_SLIME) {
        SetLocalInt(spInfo.oTarget, "GR_INCENDIARY_SLIME", TRUE);
    }

    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        if(!GetCreatureFlag(spInfo.oTarget, CREATURE_VAR_IS_INCORPOREAL) &&
            !GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, spInfo.oTarget) &&
            !GetHasSpellEffect(SPELLABILITY_GR_FREEDOM_OF_MOVEMENT, spInfo.oTarget)) {

            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget) && !bWillDisbelief) {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
                //*** NWN2 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHit, spInfo.oTarget);
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
