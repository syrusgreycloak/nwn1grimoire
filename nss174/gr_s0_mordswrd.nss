//*:**************************************************************************
//*:*  GR_S0_MORDSWRD.NSS
//*:**************************************************************************
//*:*
//*:* Mordenkainen's Sword   2005 Karl Nickels (Syrus Greycloak)
//*:* 3.5 Player's Handbook (p. 256)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 30, 2005
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

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting function
//*:**************************************************************************
//*:* Creates the weapon that the creature will be using.
void GRSetMordSwordToHitAdjustment(struct SpellStruct spInfo, object oCaster=OBJECT_SELF) {

    int iStat = 3;
    int iClass = spInfo.iSpellCastClass;
    int iLevel = GRGetLevelByClass(iClass);
    int iCasterLevel = spInfo.iCasterLevel;

    // cast from scroll
    if (GetSpellCastItem() != OBJECT_INVALID) {
        iStat += 17;
    } else {
        int iCha = GetAbilityModifier(ABILITY_CHARISMA, oCaster);
        int iInt = GetAbilityModifier(ABILITY_INTELLIGENCE, oCaster);
        int iWis = GetAbilityModifier(ABILITY_WISDOM, oCaster);

        switch(iClass) {
            case CLASS_TYPE_WIZARD:
                iStat += iInt + iCasterLevel;
                break;
            case CLASS_TYPE_SORCERER:
            case CLASS_TYPE_BARD:
                iStat += iCha + iCasterLevel;
                break;
            case CLASS_TYPE_CLERIC: // in case of domain spell
                iStat += iWis + iCasterLevel;
                break;
        }
    }

    if(iStat>20) iStat = 20;

    object oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oSummon);
    if(iStat > 0) {
        itemproperty ipAttackBonus = ItemPropertyAttackBonus(iStat);
        GRIPSafeAddItemProperty(oWeapon, ipAttackBonus);
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    /*** NWN1 SINGLE ***/ int     iVisualType           = VFX_FNF_SUMMON_MONSTER_3;
    //*** NWN2 SINGLE ***/ int     iVisualType           = VFX_HIT_SPELL_ENLARGE_PERSON;
    string  sSummon         = (spInfo.bNWN2 ? "c_msword" : "gr_s_mordswd");

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
    effect eSummon  = EffectSummonCreature(sSummon);
    effect eVis     = EffectVisualEffect(iVisualType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eVis, spInfo.lTarget);
    GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spInfo.lTarget, fDuration);
    /*** NWN1 SINGLE ***/ DelayCommand(1.5f, GRSetMordSwordToHitAdjustment(spInfo, oCaster));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
