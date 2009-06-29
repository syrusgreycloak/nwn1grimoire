//*:**************************************************************************
//*:*  GR_S0_ARMUND.NSS
//*:**************************************************************************
//*:*
//*:* Armor of Undeath
//*:* creates magical armor from remains of a humanoid
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 24, 2003
//*:**************************************************************************
//*:* Updated On: February 21, 2008
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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iGoodEvil       = GetAlignmentGoodEvil(spInfo.oTarget);

    object  oAOE;

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
    effect eArmorCheck  = GREffectArmorCheckPenalty(1);
    /* This part is to attach heartbeat script to spell to see how much damage the
       caster has taken each round to remove the spell when 25hp dmg has occurred. */
    effect eAOE         = GREffectAreaOfEffect(AOE_MOB_ARMOR_UNDEATH);
    effect eImp         = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eImp1        = EffectVisualEffect(VFX_IMP_AC_BONUS);
    effect eImpact      = EffectVisualEffect(VFX_COM_CHUNK_RED_MEDIUM);
    effect eACImp       = EffectACIncrease(2, AC_ARMOUR_ENCHANTMENT_BONUS);
    effect eTempHP      = EffectTemporaryHitpoints(25);
    effect eImpLink     = EffectLinkEffects(eImp,eImp1);

    effect eLink        = EffectLinkEffects(eACImp,eTempHP);
    eLink = EffectLinkEffects(eArmorCheck,eLink);
    eLink = EffectLinkEffects(eAOE,eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(SPELL_GR_ARMOR_UNDEATH, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_ARMOR_UNDEATH, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spInfo.oTarget);
    DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpLink, spInfo.oTarget));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);

    oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_ARMOR_UNDEATH, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);
    SetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_HP", GetCurrentHitPoints(spInfo.oTarget));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
