//*:**************************************************************************
//*:*  GR_S0_BLADEBAR.NSS
//*:**************************************************************************
//*:*
//*:* Blade Barrier (NW_S0_BladeBar.nss) Copyright (c) 2001 Bioware Corp.
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: July 20, 2001
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 6;
    int     iNumDice          = (spInfo.iCasterLevel>15 ? 15 : spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

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
    //*:* float   fRange          = FeetToMeters(15.0);

    object  oAOE;
    int     iAOEType = AOE_PER_WALLBLADE;
    string  sAOEType = AOE_TYPE_WALLBLADE;

    /*** NWN2 SPECIFIC ***
        if(spInfo.iSpellID==SPELL_BLADE_BARRIER_SELF) {
            iAOEType = AOE_MOB_BLADE_BARRIER;
            sAOEType = ObjectToString(oCaster)+IntToString(spInfo.iSpellID);
            object oBarrier = GetObjectByTag(sAOEType);
            if(GetIsObjectValid(oBarrier)) {
                DestroyObject(oBarrier);
            }
        } else {
            sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);
        }
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
            iAOEType = AOE_PER_WALLBLADE_WIDE;
            sAOEType = AOE_TYPE_WALLBLADE_WIDE;
        }
    /*** END NWN1 SPECIFIC ***/
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
    //*** NWN2 SINGLE ***/ effect eHold = EffectCutsceneImmobilize();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);
        oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        if(spInfo.iSpellID==SPELL_BLADE_BARRIER_SELF) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHold, spInfo.oTarget, fDuration);
        } else {
            GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);
        }
        oAOE = GetObjectByTag(sAOEType);
    /*** END NWN2 SPECIFIC ***/

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
