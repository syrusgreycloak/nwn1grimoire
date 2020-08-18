//*:**************************************************************************
//*:*  GR_S0_COMSTR.NSS
//*:**************************************************************************
//*:*
//*:* Companion's Strife - Swords & Sorcery: Rituals & Relics I
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 24, 2003
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

    float   fDuration       = GRGetDuration(spInfo.iCasterLevel);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iDuration       = spInfo.iCasterLevel;
    object  oAttackTarget;
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
    effect eAOE = GREffectAreaOfEffect(AOE_MOB_COMP_STRIFE);
    effect eVis = GREffectAreaOfEffect(VFX_DUR_MIND_AFFECTING_FEAR);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget,EventSpellCastAt(oCaster, SPELL_GR_COMP_STRIFE));

    if(GRGetIsHumanoid(spInfo.oTarget) && !GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_FEAR)) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, fDuration);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, fDuration);

            object oAOE = GRGetAOEOnObject(spInfo.oTarget, AOE_TYPE_COMP_STRIFE, oCaster);
            SetLocalInt(oAOE, "GR_DURATION_"+IntToString(SPELL_GR_COMP_STRIFE), iDuration);
            GRSetAOESpellId(spInfo.iSpellID, oAOE);
            GRSetSpellInfo(spInfo, oAOE);

            AssignCommand(spInfo.oTarget, ClearAllActions());
            DelayCommand(0.5f, SetCommandable(FALSE, spInfo.oTarget));
            oAttackTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE);
            if(GetIsObjectValid(oAttackTarget) && GetDistanceBetween(spInfo.oTarget, oAttackTarget)<FeetToMeters(6.5)) {
                SetCommandable(TRUE, spInfo.oTarget);
                SetIsTemporaryEnemy(oAttackTarget, spInfo.oTarget, TRUE, fDuration);
                AssignCommand(spInfo.oTarget, ActionEquipMostDamagingMelee(oAttackTarget));
                DelayCommand(0.1f, AssignCommand(spInfo.oTarget, ActionAttack(oAttackTarget)));
                DelayCommand(0.5f, SetCommandable(FALSE, spInfo.oTarget));
            } else {
                SetCommandable(TRUE, spInfo.oTarget);
                AssignCommand(spInfo.oTarget, ActionMoveAwayFromObject(oCaster, TRUE, 75.0));
                DelayCommand(0.5f, SetCommandable(FALSE, spInfo.oTarget));
            }
        }
        DelayCommand(fDuration, SetCommandable(TRUE, spInfo.oTarget));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
