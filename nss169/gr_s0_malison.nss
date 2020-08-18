//*:**************************************************************************
//*:*  GR_S0_MALISON.NSS
//*:**************************************************************************
//*:* Lesser (Minor) Malison
//*:* Greater Malison
//*:* 2E Tome of Magic
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 10, 2004
//*:**************************************************************************
//*:* Updated On: March 10, 2008
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
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel*2;
    int     iDurType          = DUR_TYPE_ROUNDS;

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAOEType        = AOE_PER_MIN_MALISON;
    string  sAOEType        = AOE_TYPE_MIN_MALISON;
    int     iVisual         = VFX_FNF_LOS_NORMAL_30;

    if(spInfo.iSpellID==SPELL_GR_GREATER_MALISON) {
        iAOEType = AOE_PER_GREATER_MALISON;
        sAOEType = AOE_TYPE_GREATER_MALISON;
        iVisual = GRGetAlignmentImpactVisual(oCaster, 30.0f);
    }
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        if(spInfo.iSpellID==SPELL_GR_LESSER_MALISON) {
            iAOEType = AOE_PER_MIN_MALISON_WIDE;
            sAOEType = AOE_TYPE_MIN_MALISON_WIDE;
        } else {
            iAOEType = AOE_PER_GREATER_MALISON_WIDE;
            sAOEType = AOE_TYPE_GREATER_MALISON_WIDE;
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
    effect eImpVis = EffectVisualEffect(iVisual);
    effect eAOE = GREffectAreaOfEffect(iAOEType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpVis, spInfo.lTarget);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, fDuration);

    object oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
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
