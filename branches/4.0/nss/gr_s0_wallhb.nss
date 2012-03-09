//*:**************************************************************************
//*:*  GR_S0_WALLHB.NSS
//*:**************************************************************************
//*:*
//*:* Heartbeat Script used by the LOK Wall Objects
//*:*
//*:* These are designed to help NPC's beat the wall down.  Any NPC within 8
//*:* meters of the wall who isn't in combat, conversation, dead, a PC, a DM,
//*:* a DM possessing an NPC or a PC possessing their pets and who is hostile
//*:* to the creator of the wall will attempt to destroy it.
//*:* If they have no equipped weapon they'll try to equip their best melee
//*:* weapon.
//*:*
//*:**************************************************************************
//*:* Created By: Dennis Dollins (Danmar)
//*:* Created On: ?
//*:**************************************************************************
//*:* Updated On: March 3, 2008
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
int Busy(object oObject) {

    if(GetIsInCombat(oObject) || IsInConversation(oObject) || GetIsDead(oObject)) return TRUE;
    return FALSE;
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());
    object  oCaster         = spInfo.oCaster;

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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object  oWeapon;
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
    //*:* write effects here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, 8.0, spInfo.lTarget, FALSE);
    while(spInfo.oTarget!=OBJECT_INVALID) {
        if(!Busy(spInfo.oTarget) && !GetIsPC(spInfo.oTarget) && !GetIsPC(GetMaster(spInfo.oTarget)) && !GetIsDM(spInfo.oTarget) &&
            !GetIsDMPossessed(spInfo.oTarget)) {

            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spInfo.oTarget);
                if(oWeapon==OBJECT_INVALID) {
                    AssignCommand(spInfo.oTarget, ActionEquipMostDamagingMelee());
                }
                SetLocalObject(spInfo.oTarget, "Wall", OBJECT_SELF);
                DelayCommand(2.0, ExecuteScript("gr_s0_wwpnfctv", spInfo.oTarget));
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, 8.0, spInfo.lTarget, FALSE);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
