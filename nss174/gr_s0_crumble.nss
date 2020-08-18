//*:**************************************************************************
//*:*  GR_S0_CRUMBLE.NSS
//*:**************************************************************************
//*:* Crumble (X2_S0_Crumble) Copyright (c) 2001 Bioware Corp.
//*:* Spell Compendium (p. 56)
//*:*
//*:**************************************************************************
//*:* Created By: Georg Zoeller
//*:* Created On: Oct 2003/
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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
//*:* Supporting functions
//*:**************************************************************************
//*:**************************************************************************
//*:* This part is moved into a delayed function in order to alllow it to bypass
//*:* Golem Spell Immunity. Magic works by rendering all effects applied
//*:* from within a spellscript useless. Delaying the creation and application of
//*:* an effect causes it to lose it's SpellId, making it possible to ignore
//*:* Magic Immunity. Hacktastic!
//*:**************************************************************************
void DoCrumble (int iDamage, object oCaster, struct SpellStruct spInfo) {

    float  fDist    = GetDistanceBetween(oCaster, spInfo.oTarget);
    float  fDelay   = fDist/(3.0 * log(fDist) + 2.0);
    effect eDam     = EffectDamage(iDamage, DAMAGE_TYPE_SONIC);
    effect eMissile = EffectVisualEffect(477);
    effect eCrumb   = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    effect eVis     = EffectVisualEffect(135);

    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCrumb, spInfo.oTarget);
    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget));
    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
    DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spInfo.oTarget));
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

    int     iDieType        = 6;
    int     iNumDice        = MinInt(10, spInfo.iCasterLevel);
    int     iBonus          = 0;
    int     iDamage         = 0;
    //*:* int     iSecDamage        = 0;
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iObjectType         = GetObjectType(spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eCrumb = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eCrumb, spInfo.oTarget);

    if(iObjectType!=OBJECT_TYPE_CREATURE && iObjectType!=OBJECT_TYPE_PLACEABLE && iObjectType!=OBJECT_TYPE_DOOR) {
        return;
    }

    if(iObjectType==OBJECT_TYPE_CREATURE && GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_CONSTRUCT &&
        GRGetLevelByClass(CLASS_TYPE_CONSTRUCT, spInfo.oTarget)==0) {

        return;
    }

    if(iDamage>0) {
        //*:**********************************************
        //*:* Sever the tie between spellId and effect,
        //*:* allowing it to bypass any magic resistance
        //*:**********************************************
        DelayCommand(0.1f, DoCrumble(iDamage, oCaster, spInfo));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
