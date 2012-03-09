//*:**************************************************************************
//*:*  GR_S0_CRPCOLD.NSS
//*:**************************************************************************
//*:* Creeping Cold             - Spell Compendium (p. 55)
//*:* Creeping Cold, Greater    - Spell Compendium (p. 56)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 7, 2009
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void DoContinuingDamage(int iRoundNumber, int iEnergyType, int bSaveMade, struct SpellStruct spInfo) {

    if(GRGetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget, spInfo.oCaster)) {
        spInfo.iDmgNumDice = iRoundNumber;
        int iSecDamage = 0;
        int iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, spInfo.oCaster);
        if(bSaveMade) iDamage /= 2;
        if(GRGetSpellHasSecondaryDamage(spInfo)) {
            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                iDamage = iSecDamage;
            }
        }
        effect eVis     = EffectVisualEffect(GRGetEnergyVisualType(VFX_IMP_FROST_S, iEnergyType));
        effect eDam     = EffectDamage(iDamage, iEnergyType);
        effect eLink    = EffectLinkEffects(eDam, eVis);

        if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

        SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oCaster, spInfo.iSpellID));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
        }
    }
}
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
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = (spInfo.iSpellID==SPELL_CREEPING_COLD ? 3 : 4);
    int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID==SPELL_GREATER_CREEPING_COLD) {
        if(spInfo.iCasterLevel>=20) iDurAmount = 6;
        else if(spInfo.iCasterLevel>=15) iDurAmount = 5;
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
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetDuration(iDurAmount);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FROST_S, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster, iSaveType);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDur     = EffectVisualEffect(VFX_DUR_ICESKIN);
    effect eDam     = EffectDamage(iDamage, iEnergyType);
    effect eLink    = EffectLinkEffects(eDam, eVis);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
        }
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, fDuration);  // duration tracker
        int i;
        for(i=2; i<=iDurAmount; i++) {
            DelayCommand(RoundsToSeconds(i-1), DoContinuingDamage(i, iEnergyType, GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster), spInfo));
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
