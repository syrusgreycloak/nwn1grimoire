//*:**************************************************************************
//*:*  GR_S2_DESTSMITE.NSS
//*:**************************************************************************
//*:* Smite (Destruction Domain Power) (sg_s2_destsmite.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 9, 2003
//*:*
//*:* Smite (Orc Domain Power) (sg_s2_orcsmite.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 9, 2003
//*:*
//*:* Smite Infidel (Divine Champion Ability) 2008 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 27, 2008
//*:* Player's Guide to Faerun (p. 50)
//*:**************************************************************************
//*:* Updated On: March 27, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_DEITIES"

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
    int     iBonus            = 1;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 2;
    int     iDurType          = DUR_TYPE_ROUNDS;
    float   fDurOverride      = 9.0f;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType, fDurOverride);

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
    /*if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);*/

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_10, oCaster)) {
        iBonus = 11;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_9, oCaster)) {
        iBonus = 10;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_8, oCaster)) {
        iBonus = 9;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_7, oCaster)) {
        iBonus = 8;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_6, oCaster)) {
        iBonus = 7;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_5, oCaster)) {
        iBonus = 6;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_4, oCaster)) {
        iBonus = 5;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_3, oCaster)) {
        iBonus = 4;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_2, oCaster)) {
        iBonus = 3;
    } else if(GetHasFeat(FEAT_EPIC_GREAT_SMITING_1, oCaster)) {
        iBonus = 2;
    }

    int     iAttBonus = (spInfo.iSpellID==SPELLABILITY_GR_SMITE_INFIDEL ? MaxInt(0, GetAbilityModifier(ABILITY_CHARISMA, oCaster)) : 4);

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
    effect eAttBonus    = EffectAttackIncrease(iAttBonus, ATTACK_BONUS_ONHAND);
    effect eDmgBonus    = EffectDamageIncrease(spInfo.iCasterLevel * iBonus, DAMAGE_TYPE_DIVINE);
    effect eVis         = EffectVisualEffect(VFX_IMP_DIVINE_STRIKE_HOLY);
    effect eLink        = EffectLinkEffects(eAttBonus, eDmgBonus);

    if(spInfo.iSpellID==SPELL_GR_ORC_SMITE) {
        eLink = eDmgBonus;
        if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ELF || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_DWARF) {
            eLink = EffectLinkEffects(eLink, eAttBonus);
        }
    }

    eLink = EffectLinkEffects(eLink, eVis);
    eLink = SupernaturalEffect(eLink);
    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID!=SPELLABILITY_GR_SMITE_INFIDEL || (GRGetDeity(oCaster)!=GRGetDeity(spInfo.oTarget))) {
        SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, fDuration);
        AssignCommand(oCaster, ClearAllActions(TRUE));
        DelayCommand(0.5, AssignCommand(oCaster, ActionAttack(spInfo.oTarget)));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
