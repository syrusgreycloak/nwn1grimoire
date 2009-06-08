//*:**************************************************************************
//*:*  GR_S0_VISDEITY.NSS
//*:**************************************************************************
//*:* Visage of the Deity           - Spell Compendium (p. 230)
//*:* Visage of the Deity, Greater  - Spell Compendium (p. 231)
//*:* Visage of the Deity, Lesser   - Spell Compendium (p. 231)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 7, 2009
//*:**************************************************************************
//*:* These spells have descriptor [Evil or Good], so they cannot be cast by
//*:* Neutral characters
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

    int     iAlign          = GetAlignmentGoodEvil(oCaster);

    if(iAlign==ALIGNMENT_GOOD) {
        GRSetSpellDescriptor(spInfo.iSpellID, SPELL_TYPE_GOOD);
    }
    GRSetSpellDescriptor(spInfo.iSpellID, SPELL_TYPE_GENERAL, oCaster, 2);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 4;
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
    float   fDelay          = GetRandomDelay();
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iResist         = 10;
    int     bHasHigherEffect= FALSE;

    int     iSTRBonus       = 0;
    int     iDEXBonus       = 0;
    int     iCONBonus       = 0;
    int     iINTBonus       = 0;
    int     iWISBonus       = 0;
    int     iCHABonus       = 4;
    int     iSpellResist    = 0;

    switch(spInfo.iSpellID) {
        case SPELL_GR_LESSER_VISAGE_OF_THE_DEITY:
            bHasHigherEffect = GetHasSpellEffect(SPELL_GR_VISAGE_OF_THE_DEITY, oCaster) || GetHasSpellEffect(SPELL_GREATER_VISAGE_OF_THE_DEITY, oCaster);
            break;
        case SPELL_GR_VISAGE_OF_THE_DEITY:
            bHasHigherEffect = GetHasSpellEffect(SPELL_GREATER_VISAGE_OF_THE_DEITY, oCaster);
            iResist = 20;
            iSpellResist = 20;
            break;
        case SPELL_GREATER_VISAGE_OF_THE_DEITY:
            iResist = 10;
            iSTRBonus = 4;
            iDEXBonus = (iAlign!=ALIGNMENT_EVIL ? 2 : 4);
            iCONBonus = (iAlign!=ALIGNMENT_EVIL ? 4 : 2);
            iINTBonus = (iAlign!=ALIGNMENT_EVIL ? 2 : 4);
            iWISBonus = (iAlign!=ALIGNMENT_EVIL ? 4 : 0);
            iCHABonus = (iAlign!=ALIGNMENT_EVIL ? 4 : 2);
            iSpellResist = 25;
            break;
    }

    if(bHasHigherEffect) {
        if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939246));
        }
        GRClearSpellInfo(spInfo.iSpellID, oCaster);
        return;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
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
    effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, 1.0f));
    effect eVis     = EffectVisualEffect(VFX_IMP_BREACH);
    effect eCHABonus= EffectAbilityIncrease(ABILITY_CHARISMA, iCHABonus);
    effect eAcid    = EffectDamageResistance(DAMAGE_TYPE_ACID, iResist);
    effect eCold    = EffectDamageResistance(DAMAGE_TYPE_COLD, iResist);
    effect eElec    = EffectDamageResistance(DAMAGE_TYPE_ELECTRICAL, iResist);
    effect eFire    = EffectDamageResistance(DAMAGE_TYPE_FIRE, iResist);
    effect eDur1    = EffectVisualEffect(VFX_DUR_PROT_PREMONITION);
    effect eDur2    = EffectVisualEffect(VFX_DUR_PROTECTION_ELEMENTS);

    effect eLink    = EffectLinkEffects(eDur1, eDur2);
    eLink = EffectLinkEffects(eLink, eCHABonus);

    switch(iAlign) {
        case ALIGNMENT_GOOD:
            eLink = EffectLinkEffects(eLink, eCold);
        case ALIGNMENT_NEUTRAL:
            eLink = EffectLinkEffects(eLink, eAcid);
            eLink = EffectLinkEffects(eLink, eElec);
            break;
        case ALIGNMENT_EVIL:
            eLink = EffectLinkEffects(eLink, eCold);
            eLink = EffectLinkEffects(eLink, eFire);
            break;
    }

    if(spInfo.iSpellID!=SPELL_GR_LESSER_VISAGE_OF_THE_DEITY) {
        effect eSpellResist     = EffectSpellResistanceIncrease(iSpellResist);
        effect eDamReduction    = EffectDamageReduction(10, DAMAGE_POWER_PLUS_ONE);
        eLink = EffectLinkEffects(eLink, eSpellResist);
        eLink = EffectLinkEffects(eLink, eDamReduction);

        if(spInfo.iSpellID==SPELL_GREATER_VISAGE_OF_THE_DEITY) {
            effect eACIncrease  = EffectACIncrease(1, AC_NATURAL_BONUS);
            effect eSTRBonus    = EffectAbilityIncrease(ABILITY_STRENGTH, iSTRBonus);
            effect eDEXBonus    = EffectAbilityIncrease(ABILITY_DEXTERITY, iDEXBonus);
            effect eCONBonus    = EffectAbilityIncrease(ABILITY_CONSTITUTION, iCONBonus);
            effect eINTBonus    = EffectAbilityIncrease(ABILITY_INTELLIGENCE, iINTBonus);
            effect eWISBonus    = EffectAbilityIncrease(ABILITY_WISDOM, iWISBonus);
            eLink = EffectLinkEffects(eLink, eACIncrease);
            eLink = EffectLinkEffects(eLink, eSTRBonus);
            eLink = EffectLinkEffects(eLink, eDEXBonus);
            eLink = EffectLinkEffects(eLink, eCONBonus);
            eLink = EffectLinkEffects(eLink, eINTBonus);

            switch(iAlign) {
                case ALIGNMENT_GOOD:
                case ALIGNMENT_NEUTRAL:
                    effect eDiseaseImmune   = EffectImmunity(IMMUNITY_TYPE_DISEASE);
                    effect eSaveBonus       = EffectSavingThrowIncrease(SAVING_THROW_ALL, 4, SAVING_THROW_TYPE_POISON);
                    effect eWISBonus        = EffectAbilityIncrease(ABILITY_WISDOM, iWISBonus);
                    eLink = EffectLinkEffects(eLink, eDiseaseImmune);
                    eLink = EffectLinkEffects(eLink, eSaveBonus);
                    eLink = EffectLinkEffects(eLink, eWISBonus);
                    break;
                case ALIGNMENT_EVIL:
                    effect ePoisonImmune    = EffectImmunity(IMMUNITY_TYPE_POISON);
                    eLink = EffectLinkEffects(eLink, ePoisonImmune);
                    break;
            }
        }
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRRemoveMultipleSpellEffects(SPELL_GREATER_VISAGE_OF_THE_DEITY, SPELL_GR_VISAGE_OF_THE_DEITY, oCaster, TRUE, SPELL_LESSER_VISAGE_OF_THE_DEITY);
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCaster);
    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster));
    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration));

    //*:**********************************************
    //*:* Visage and Greater Visage have other effects
    //*:* that must be added by other means
    //*:**********************************************
    if(spInfo.iSpellID!=SPELL_GR_LESSER_VISAGE_OF_THE_DEITY) {
        object oHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, oCaster);
        if(!GetIsObjectValid(oHide)) oHide = CreateItemOnObject("x2_it_emptyskin", oCaster);

        itemproperty ipDarkVision = ItemPropertyBonusFeat(IP_CONST_FEAT_DARKVISION);

        if(spInfo.iSpellID==SPELL_GR_VISAGE_OF_THE_DEITY) {
            int iIPSmiteType = (iAlign!=ALIGNMENT_EVIL ? IP_CONST_FEAT_SMITE_EVIL : IP_CONST_FEAT_SMITE_GOOD);
            itemproperty ipSmite = ItemPropertyBonusFeat(iIPSmiteType);
            DelayCommand(fDelay, GRIPSafeAddItemProperty(oHide, ipDarkVision, fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING));
            DelayCommand(fDelay, GRIPSafeAddItemProperty(oHide, ipSmite, fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING));
        } else {
            int iPrevWingType = GetCreatureWingType(oCaster);
            int iNewWingType = (iAlign!=ALIGNMENT_EVIL ? CREATURE_WING_TYPE_ANGEL : CREATURE_WING_TYPE_BAT);
            SetCreatureWingType(iNewWingType, oCaster);
            DelayCommand(fDelay + fDuration, SetCreatureWingType(iPrevWingType, oCaster));

            if(iAlign!=ALIGNMENT_EVIL) {
                itemproperty ipLowLightVision = ItemPropertyBonusFeat(IP_CONST_FEAT_LOWLIGHT_VISION);
                DelayCommand(fDelay, GRIPSafeAddItemProperty(oHide, ipLowLightVision, fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING));
            } else {
                itemproperty ipCreatureWeaponProficiency = ItemPropertyBonusFeat(IP_CONST_FEAT_CREATURE_WEAPON_PROF);
                DelayCommand(fDelay, GRIPSafeAddItemProperty(oHide, ipDarkVision, fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING));
                DelayCommand(fDelay, GRIPSafeAddItemProperty(oHide, ipCreatureWeaponProficiency, fDuration, X2_IP_ADDPROP_POLICY_IGNORE_EXISTING));

                int iCreatureSize = GRGetCreatureSize(oCaster);
                object oLeftWeapon = CreateItemOnObject((iCreatureSize>=CREATURE_SIZE_MEDIUM ? "nw_it_crewpsp026" : "nw_it_crewpsp002"), oCaster);
                object oRightWeapon = CreateItemOnObject((iCreatureSize>=CREATURE_SIZE_MEDIUM ? "nw_it_crewpsp026" : "nw_it_crewpsp002"), oCaster);
                object oBite = CreateItemOnObject((iCreatureSize>=CREATURE_SIZE_MEDIUM ? "nw_it_crewps005" : "nw_it_crewps002"), oCaster);
                AssignCommand(oCaster, ActionEquipItem(oLeftWeapon, INVENTORY_SLOT_CWEAPON_L));
                AssignCommand(oCaster, ActionEquipItem(oRightWeapon, INVENTORY_SLOT_CWEAPON_R));
                AssignCommand(oCaster, ActionEquipItem(oBite, INVENTORY_SLOT_CWEAPON_B));
                DelayCommand(fDelay + fDuration, DestroyObject(oLeftWeapon));
                DelayCommand(fDelay + fDuration, DestroyObject(oRightWeapon));
                DelayCommand(fDelay + fDuration, DestroyObject(oBite));
            }
        }
        AssignCommand(oCaster, ActionEquipItem(oHide, INVENTORY_SLOT_CARMOUR));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
