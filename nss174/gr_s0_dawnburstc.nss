//*:**************************************************************************
//*:*  GR_S0_DAWNBURSTC.NSS
//*:**************************************************************************
//*:* Dawnburst: OnHeartbeat
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 18, 2008
//*:* Complete Mage (p. 101)
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
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eConceal     = EffectConcealment(20);
    effect eTorchLight  = EffectVisualEffect(VFX_DUR_LIGHT_ORANGE_10);
    effect eDamage;     // = EffectDamage(iDamage);

    effect eVis         = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    effect eLink;       // = EffectLinkEffects(eDamage, eVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eTorchLight, spInfo.oTarget);

            if(GetHasEffect(EFFECT_TYPE_INVISIBILITY, spInfo.oTarget)) {
                GRRemoveEffects(EFFECT_TYPE_INVISIBILITY, spInfo.oTarget);
                if(!GetHasEffect(EFFECT_TYPE_CONCEALMENT, spInfo.oTarget)) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eConceal, spInfo.oTarget, fDuration);
                }
            }
            if(GetActionMode(spInfo.oTarget, ACTION_MODE_STEALTH)) {
                SetActionMode(spInfo.oTarget, ACTION_MODE_STEALTH, FALSE);
            }

            if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD || GRGetIsLightSensitive(spInfo.oTarget)) {
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }

                if(iDamage>0) {
                    eDamage = EffectDamage(iDamage);
                    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    eLink = EffectLinkEffects(eDamage, eVis);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                }
            }
        }
        spInfo.oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
