//*:**************************************************************************
//*:*  GR_S0_COMSTRC.NSS
//*:**************************************************************************
//*:*
//*:* Companion's Strife - Swords & Sorcery: Rituals & Relics I
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 24, 2003
//*:**************************************************************************
//*:* Updated On: April 12, 2007
//*:* BUGFIX: Duration counter value not being decremented
//*:**************************************************************************
//*:* Updated On: February 25, 2008
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    int     iDuration       = GetLocalInt(OBJECT_SELF, "GR_DURATION_"+IntToString(SPELL_GR_COMP_STRIFE));
    float   fDuration       = GRGetDuration(iDuration);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object oAttackTarget;
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
    //*:* write effects here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(iDuration>0) {
        iDuration--;
        SetLocalInt(OBJECT_SELF, "GR_DURATION_"+IntToString(SPELL_GR_COMP_STRIFE), iDuration);
        oAttackTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE);
        if(GetIsObjectValid(oAttackTarget) && GetDistanceBetween(spInfo.oTarget, oAttackTarget)<FeetToMeters(6.5)) {
            SetCommandable(TRUE, spInfo.oTarget);
            SetIsTemporaryEnemy(oAttackTarget, spInfo.oTarget, TRUE, fDuration);
            AssignCommand(spInfo.oTarget, ActionEquipMostDamagingMelee(oAttackTarget));
            DelayCommand(0.1f, AssignCommand(spInfo.oTarget, ActionAttack(oAttackTarget)));
            DelayCommand(0.5f, SetCommandable(FALSE, spInfo.oTarget));
        } else {
            if(GetIsObjectValid(oCaster)) {
                SetCommandable(TRUE, spInfo.oTarget);
                AssignCommand(spInfo.oTarget, ActionMoveAwayFromObject(oCaster, TRUE));
                DelayCommand(0.5f, SetCommandable(FALSE, spInfo.oTarget));
            }
        }
    } else {
        DestroyObject(OBJECT_SELF);
        SetCommandable(TRUE, spInfo.oTarget);
        GRRemoveSpellEffects(SPELL_GR_COMP_STRIFE, spInfo.oTarget, oCaster);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
