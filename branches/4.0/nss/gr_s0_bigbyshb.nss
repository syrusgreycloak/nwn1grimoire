//*:**************************************************************************
//*:*  GR_S0_BIGBYSHB.NSS
//*:**************************************************************************
//*:*
//*:* Hearbeat script for Bigby's Grasping/Crushing hands
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
//*:**************************************************************************
//*:* Updated On: December 3, 2007
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

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    int     iCasterModifiers, iCasterRoll, iTargetRoll;

    switch(spInfo.iSpellID) {
        case SPELL_BIGBYS_CLENCHED_FIST:
            iDieType = 8;
            iNumDice = 1;
            iBonus = 11;
            iCasterModifiers = GRGetCasterAbilityModifierByClass(oCaster, spInfo.iSpellCastClass) + spInfo.iCasterLevel;
            iCasterRoll = d20(1) + iCasterModifiers + 11 + -1;
            iTargetRoll = GetAC(spInfo.oTarget);
            spInfo.iDC = GetLocalInt(OBJECT_SELF,"XP2_L_SPELL_SAVE_DC_" + IntToString(SPELL_BIGBYS_CLENCHED_FIST));
            break;
        case SPELL_BIGBYS_CRUSHING_HAND:
            iDieType = 6;
            iNumDice = 2;
            iBonus = 12;
            break;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDam = EffectDamage(iDamage, DAMAGE_TYPE_BLUDGEONING);
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_L);

    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if((iCasterRoll>=iTargetRoll) || spInfo.iSpellID==SPELL_BIGBYS_CRUSHING_HAND) {

        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);

        if(spInfo.iSpellID==SPELL_BIGBYS_CLENCHED_FIST) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
               GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectStunned(), spInfo.oTarget, 9.0f);
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
