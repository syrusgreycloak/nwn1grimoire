//*:**************************************************************************
//*:*  GR_S3_IOUNSTONE.NSS
//*:**************************************************************************
//*:*
//*:* Compiled Ioun Stone scripts from Bioware into one master script
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 21, 2007
//*:**************************************************************************
//*:* Updated On: December 20, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_ITEMPROP"
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
    int     iDurAmount        = 60;
    int     iDurType          = DUR_TYPE_TURNS;

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

    int     iVisualEffect   = 500;
    object  oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCaster);

    itemproperty    ipAlertnessFeat  = ItemPropertyBonusFeat(IP_CONST_FEAT_ALERTNESS);
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVFX, eBonus, eLink;

    switch(spInfo.iSpellID) {
        case SPELL_IOUN_STONE_BLUE:                 //*:* Incandescent Blue +2 Enhancment bonus to WIS
            eBonus = EffectAbilityIncrease(ABILITY_WISDOM, 2);
            break;
        case SPELL_IOUN_STONE_DEEP_RED:             //*:* +2 Enhancement bonus to DEX
            iVisualEffect = 499;
            eBonus = EffectAbilityIncrease(ABILITY_DEXTERITY, 2);
            break;
        case SPELL_IOUN_STONE_DUSTY_ROSE:           //*:* +1 Insight Bonus to AC
            iVisualEffect = 501;
            eBonus = EffectACIncrease(1, AC_DEFLECTION_BONUS);
            break;
        case SPELL_IOUN_STONE_PALE_BLUE:            //*:* +2 Enhancement Bonus to STR
            eBonus = EffectAbilityIncrease(ABILITY_STRENGTH, 2);
            break;
        case SPELL_IOUN_STONE_PINK:                 //*:* +2 Enhancement Bonus to CON
            iVisualEffect = 499;
            eBonus = EffectAbilityIncrease(ABILITY_CONSTITUTION, 2);
            break;
        case SPELL_IOUN_STONE_PINK_GREEN:           //*:* +2 Enhancment Bonus to CHA
            iVisualEffect = 502;
            eBonus = EffectAbilityIncrease(ABILITY_CHARISMA, 2);
            break;
        case SPELL_IOUN_STONE_SCARLET_BLUE:         //*:* +2 Enhancement Bonus to INT
            eBonus = EffectAbilityIncrease(ABILITY_INTELLIGENCE, 2);
            break;
        case SPELL_GR_IOUN_STONE_ORANGE:            //*:* +1 caster level
            iVisualEffect = 501;
            eBonus = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
            break;
        case SPELL_GR_IOUN_STONE_PALE_GREEN:        //*:* +1 competence bonus on attack rolls, skill checks, and saves
            iVisualEffect = 502;
            eBonus = EffectAttackIncrease(1);
            eBonus = EffectLinkEffects(eBonus, EffectSavingThrowIncrease(SAVING_THROW_ALL,1));
            eBonus = EffectLinkEffects(eBonus, EffectSkillIncrease(SKILL_ALL_SKILLS, 1));
            break;
        case SPELL_GR_IOUN_STONE_PEARLY_WHITE:      //*:* +1hp regeneration per hour
            iVisualEffect = 501;
            eBonus = EffectRegenerate(1, HoursToSeconds(1));
            break;
        /*case SPELL_GR_IOUN_STONE_DARK_BLUE:           //*:* Alertness feat
        case SPELL_GR_IOUN_STONE_CLEAR:             //*:* Sustain without food and water
        case SPELL_GR_IOUN_STONE_VIBRANT_PURPLE:    //*:* Store 3 spells as Ring of Spell Storing
        case SPELL_GR_IOUN_STONE_IRIDESCENT:        //*:* Sustain without air
        case SPELL_GR_IOUN_STONE_PALE_LAVENDER:     //*:* Absorb up to 20 levels of spells (4th level or lower only)
        case SPELL_GR_IOUN_STONE_LAVENDER_GREEN:    //*:* Absorb up to 50 levels of spells (8th level or lower only)
            break;*/
    }

    eVFX = EffectVisualEffect(iVisualEffect);

    switch(spInfo.iSpellID) {
        case SPELL_GR_IOUN_STONE_DARK_BLUE:
            eLink = eVFX;
            break;
        default:
            eLink = EffectLinkEffects(eVFX, eBonus);
            break;
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* Remove all other ioun stone effects
    //*:* - we can use else if as you can only have one effect
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_IOUN_STONE_BLUE, oCaster)) {
        GRRemoveSpellEffects(SPELL_IOUN_STONE_BLUE, oCaster);
    } else if(GetHasSpellEffect(SPELL_IOUN_STONE_DEEP_RED, oCaster)) {
        GRRemoveSpellEffects(SPELL_IOUN_STONE_DEEP_RED, oCaster);
    } else if(GetHasSpellEffect(SPELL_IOUN_STONE_DUSTY_ROSE, oCaster)) {
        GRRemoveSpellEffects(SPELL_IOUN_STONE_DUSTY_ROSE, oCaster);
    } else if(GetHasSpellEffect(SPELL_IOUN_STONE_PALE_BLUE, oCaster)) {
        GRRemoveSpellEffects(SPELL_IOUN_STONE_PALE_BLUE, oCaster);
    } else if(GetHasSpellEffect(SPELL_IOUN_STONE_PINK, oCaster)) {
        GRRemoveSpellEffects(SPELL_IOUN_STONE_PINK, oCaster);
    } else if(GetHasSpellEffect(SPELL_IOUN_STONE_PINK_GREEN, oCaster)) {
        GRRemoveSpellEffects(SPELL_IOUN_STONE_PINK_GREEN, oCaster);
    } else if(GetHasSpellEffect(SPELL_IOUN_STONE_SCARLET_BLUE, oCaster)) {
        GRRemoveSpellEffects(SPELL_IOUN_STONE_SCARLET_BLUE, oCaster);
    } else if(GetHasSpellEffect(SPELL_GR_IOUN_STONE_ORANGE, oCaster)) {
        GRRemoveSpellEffects(SPELL_GR_IOUN_STONE_ORANGE, oCaster);
    } else if(GetHasSpellEffect(SPELL_GR_IOUN_STONE_PALE_GREEN, oCaster)) {
        GRRemoveSpellEffects(SPELL_GR_IOUN_STONE_PALE_GREEN, oCaster);
    } else if(GetHasSpellEffect(SPELL_GR_IOUN_STONE_DARK_BLUE, oCaster)) {
        GRRemoveSpellEffects(SPELL_GR_IOUN_STONE_DARK_BLUE, oCaster);
    } else if(GetHasSpellEffect(SPELL_GR_IOUN_STONE_PEARLY_WHITE, oCaster)) {
        GRRemoveSpellEffects(SPELL_GR_IOUN_STONE_PEARLY_WHITE, oCaster);
    }

    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);

    if(spInfo.iSpellID==SPELL_GR_IOUN_STONE_DARK_BLUE) {
        if(!GetIsObjectValid(oPCHide)) {
            oPCHide = CreateItemOnObject("x2_it_emptyskin", spInfo.oTarget);
        }
        GRIPSafeAddItemProperty(oPCHide, ipAlertnessFeat, fDuration);
        AssignCommand(oCaster, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));
    }


    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
