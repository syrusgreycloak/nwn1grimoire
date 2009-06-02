//*:**************************************************************************
//*:*  GR_S0_AURENERGY.NSS
//*:**************************************************************************
//*:* MASTER SCRIPT FOR ENERGY AURA TYPES
//*:**************************************************************************
//*:* Aura of Cold, Greater
//*:* Aura of Cold, Lesser
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 12, 2008
//*:* Frostburn (p. 88)
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    switch(spInfo.iSpellID) {
        case SPELL_GR_LESSER_AURA_OF_COLD:
            iDieType = 6;
            iNumDice = 1;
            break;
        case SPELL_GR_GREATER_AURA_OF_COLD:
            iDieType = 6;
            iNumDice = 2;
            break;
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType;
    int     bHasGreaterEffect = FALSE;
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iAOEType;
    string  sAOEType;

    switch(spInfo.iSpellID) {
        case SPELL_GR_LESSER_AURA_OF_COLD:
            iVisualType = VFX_IMP_FROST_S;
            iAOEType = AOE_MOB_LSR_AURA_OF_COLD;
            sAOEType = AOE_TYPE_LSR_AURA_OF_COLD;
            break;
        case SPELL_GR_GREATER_AURA_OF_COLD:
            iVisualType = VFX_IMP_FROST_L;
            iAOEType = AOE_MOB_GR_AURA_OF_COLD;
            sAOEType = AOE_TYPE_GR_AURA_OF_COLD;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        switch(spInfo.iSpellID) {
            case SPELL_GR_LESSER_AURA_OF_COLD:
                iAOEType = AOE_MOB_LSR_AURA_OF_COLD_WIDE;
                sAOEType = AOE_TYPE_LSR_AURA_OF_COLD_WIDE;
                break;
            case SPELL_GR_GREATER_AURA_OF_COLD:
                iAOEType = AOE_MOB_GR_AURA_OF_COLD_WIDE;
                sAOEType = AOE_TYPE_GR_AURA_OF_COLD_WIDE;
                break;
        }
    }
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
    effect eImp = EffectVisualEffect(iVisualType);
    effect eAOE = GREffectAreaOfEffect(iAOEType);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAOE, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* Check for spell stacking
    switch(spInfo.iSpellID) {
        case SPELL_GR_LESSER_AURA_OF_COLD:
            if(GetHasSpellEffect(SPELL_GR_GREATER_AURA_OF_COLD, oCaster)) {
                bHasGreaterEffect = TRUE;
            } else {
                GRRemoveSpellEffects(SPELL_GR_LESSER_AURA_OF_COLD, oCaster);
            }
            break;
        case SPELL_GR_GREATER_AURA_OF_COLD:
            GRRemoveMultipleSpellEffects(SPELL_GR_GREATER_AURA_OF_COLD, SPELL_GR_LESSER_AURA_OF_COLD, oCaster);
            break;
    }

    if(!bHasGreaterEffect) {
        SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oCaster);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);

        object oAOE = GRGetAOEOnObject(oCaster, sAOEType, oCaster);
        GRSetAOESpellId(spInfo.iSpellID, oAOE);
        GRSetSpellInfo(spInfo, oAOE);
    } else {
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939246));
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
