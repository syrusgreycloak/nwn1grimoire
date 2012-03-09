//*:**************************************************************************
//*:*  GR_S0_STONESKN.NSS
//*:**************************************************************************
//*:* Stoneskin (nw_s0_stoneskn.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: March 16 , 2001
//*:* 3.5 Player's Handbook (p. 284)
//*:* Greater Stoneskin (NW_S0_GrStoneSk) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: March 16 , 2001
//*:* created by Bioware
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    int     iDamage           = MinInt(150, spInfo.iCasterLevel*10);
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_HOURS;

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

    int     bCast           = TRUE;

    int     iSoakAmount     = 10;
    int     iVis            = VFX_DUR_PROT_STONESKIN;
    int     iVis2           = VFX_IMP_POLYMORPH;
    int     iDur            = VFX_DUR_CESSATE_POSITIVE;

    //*** NWN2 SINGLE ***/ iDur  = (spInfo.iSpellID==SPELL_GREATER_STONESKIN ? VFX_DUR_SPELL_GREATER_STONESKIN : VFX_DUR_SPELL_STONESKIN);

    if(spInfo.iSpellID==SPELL_GREATER_STONESKIN) {
        iDamage = MinInt(340, spInfo.iCasterLevel*20);
        iSoakAmount = 20;
    }

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
    effect eVis2    = EffectVisualEffect(iVis2);
    /*** NWN1 SINGLE ***/ effect eStone   = EffectDamageReduction(iSoakAmount, DAMAGE_POWER_PLUS_FIVE, iDamage);
    //*** NWN2 SINGLE ***/ effect eStone = EffectDamageReduction(iSoakAmount, GMATERIAL_METAL_ADAMANTINE, nDamage, DR_TYPE_GMATERIAL);
    effect eVis     = EffectVisualEffect(iVis);
    effect eDur     = EffectVisualEffect(iDur);

    //Link the texture replacement and the damage reduction effect
    effect eLink = EffectLinkEffects(eDur, eStone);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    if(spInfo.iSpellID==SPELL_STONESKIN) {
        if(GetHasSpellEffect(SPELL_STONESKIN, spInfo.oTarget)) {
            GRRemoveSpellEffects(SPELL_STONESKIN, spInfo.oTarget);
        } else if(GRGetHasSpellEffect(SPELL_GREATER_STONESKIN, spInfo.oTarget)) {
            FloatingTextStringOnCreature(GetName(spInfo.oTarget) + GetStringByStrRef(16939266), oCaster, FALSE);
            bCast = FALSE;
        }
    } else {
        GRRemoveMultipleSpellEffects(SPELL_STONESKIN, SPELL_GREATER_STONESKIN, spInfo.oTarget);
    }


    if(bCast) {
        /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
