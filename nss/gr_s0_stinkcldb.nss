//*:**************************************************************************
//*:*  GR_S0_STINKCLDB.NSS
//*:**************************************************************************
//*:* Stinking Cloud (NW_S0_StinkCld.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: May 17, 2001
//*:* 3.5 Player's Handbook (p. 284)
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
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = 1;

    object  oTarget         = GetExitingObject();

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetDuration(GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus));
    //*:* float   fRange          = FeetToMeters(15.0);

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
    //*:* Stinking Cloud
    effect eNauseated   = EffectDazed();
    /*** NWN1 SINGLE ***/ effect eNauseatedVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    //*** NWN1 SINGLE ***/ effect eNauseatedVis = EffectVisualEffect(VFX_DUR_SPELL_DAZE);
    eNauseated = EffectLinkEffects(eNauseated, eNauseatedVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(GRGetAOESpellId(), oTarget, oCaster);
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_POISON) && !GetLocalInt(spInfo.oTarget, "GR_"+IntToString(GRGetAOESpellId())+"_WILLDISBELIEF")) {
       GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eNauseated, spInfo.oTarget, fDuration);
    }

    DeleteLocalInt(spInfo.oTarget, "GR_"+IntToString(GRGetAOESpellId())+"_WILLDISBELIEF");

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
