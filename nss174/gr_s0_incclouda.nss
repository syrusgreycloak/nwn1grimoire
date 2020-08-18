//*:**************************************************************************
//*:*  GR_INCCLOUDA.NSS
//*:**************************************************************************
//*:*
//*:* Incendiary Cloud OnEnter (NW_S0_IncCloudA.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 244)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: May 17, 2001
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

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType        = 6;
    int     iNumDice        = 4;
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
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
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo, iEnergyType, TRUE);
    //*:* float   fRange          = FeetToMeters(15.0);

    /*** NWN1 SINGLE ***/ int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_S, iEnergyType);
    //*** NWN2 SINGLE ***/ int     iVisualType     = GRGetEnergyVisualType(VFX_HIT_SPELL_FIRE, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    float   fDelay          = 0.0;
    float   fDamagePercentage = GRGetAOEDamagePercentage();
    int     bWillDisbelief  = FALSE;

    spInfo.oTarget         = GetEnteringObject();
    spInfo.iDC             = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType);
    if(spInfo.iSpellID==SPELL_GR_SHADES_INCENDIARY_CLOUD) {
        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SPELL, oCaster, fDelay)) {
            iDamage = FloatToInt(iDamage * fDamagePercentage);
            bWillDisbelief = TRUE;
        }
    }

    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis = EffectVisualEffect(iVisualType);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        fDelay = GetRandomDelay(0.5, 2.0);
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_INCENDIARY_CLOUD));
            SetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_WILLDISBELIEF", bWillDisbelief);
            eDam = EffectDamage(iDamage, iEnergyType);
            if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            if(iDamage > 0) {
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                if(GetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                }
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
