//*:**************************************************************************
//*:*  GR_S0_SILENCE.NSS
//*:**************************************************************************
//*:* Silence (NW_S0_Silence.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 279)
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"

// NWN2 includes nw_i0_generic, which is already included through x0_i0_spells
// x0_i0_spells is included under gr_in_spells below, so we already have access
// to it
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iAOEType        = AOE_MOB_SILENCE;
    string  sAOEType        = AOE_TYPE_SILENCE;
    object  oAOE;

    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
            iAOEType = AOE_MOB_SILENCE_WIDE;
            sAOEType = AOE_TYPE_SILENCE_WIDE;
        }
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        fDuration     = ApplyMetamagicDurationMods(fDuration);
        iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
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
    effect eAOE = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);
    //*** NWN2 SINGLE ***/ effect eHit = EffectVisualEffect(VFX_DUR_SPELL_SILENCE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                    GRApplyEffectToObject(iDurationType, eAOE, spInfo.oTarget, fDuration);
                    /*** NWN2 SPECIFIC ***
                        GRApplyEffecttoObject(DURATION_TYPE_INSTANT, eHit, spInfo.oTarget);
                        SetLocalInt(spInfo.oTarget, EVENFLW_SILENCE, TRUE);
                        /* NWN2: not sure why we're applying a VFX_DUR_ effect with a duration of instant, but
                         * that's how they had it in their script
                         */
                    /*** END NWN2 SPECIFIC ***/
                }
            }
            if(!GetIsInCombat(spInfo.oTarget))
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_SILENCE));
        } else {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_SILENCE, FALSE));
            GRApplyEffectToObject(iDurationType, eAOE, spInfo.oTarget, fDuration);
            /*** NWN2 SPECIFIC ***
                GRApplyEffecttoObject(DURATION_TYPE_INSTANT, eHit, spInfo.oTarget);
                SetLocalInt(spInfo.oTarget, EVENFLW_SILENCE, TRUE);
                /* NWN2: not sure why we're applying a VFX_DUR_ effect with a duration of instant, but
                 * that's how they had it in their script
                 */
            /*** END NWN2 SPECIFIC ***/
        }
        /*** NWN1 SINGLE ***/ oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
    } else {
        GRApplyEffectAtLocation(iDurationType, eAOE, spInfo.lTarget, fDuration);
        /*** NWN1 SINGLE ***/ oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
    }
    //*** NWN2 SINGLE ***/ oAOE = GetObjectByTag(sAOEType);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
