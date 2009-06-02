//*:**************************************************************************
//*:*  GR_S0_LIVESTEPC.NSS
//*:**************************************************************************
//*:* Lively Step
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 29, 2008
//*:* Spell Compendium (p. 133)
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
#include "GR_IN_ARRLIST"
#include "GR_IN_CONCEN"

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRDoMoveActionCheck(object oTarget) {

    int bMoveAction = TRUE;

    if(GetIsObjectValid(oTarget)) {
        int iCurrentAction = GetCurrentAction(oTarget);

        switch(iCurrentAction) {
            case ACTION_DISABLETRAP:
            case ACTION_TAUNT:
            case ACTION_PICKPOCKET:
            case ACTION_ATTACKOBJECT:
            case ACTION_COUNTERSPELL:
            case ACTION_FLAGTRAP:
            case ACTION_CASTSPELL:
            case ACTION_ITEMCASTSPELL:
                bMoveAction = FALSE;
                break;
            }
        }
    }

    return bMoveAction;
}
//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = GetLocalInt(oCaster, "GR_LIVELY_DUR");
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
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    //*:* write effects here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* Run through list to see if anyone is doing anything
    //*:* but moving

    int iNumAffected = GRGetDimSize("GR_LIVELY_STEP", "AFFECTED", oCaster);
    int i = 1;
    int bDispel = !GRGetCasterConcentrating(SPELL_GR_LIVELY_STEP, oCaster);
    object oTarget;
    iDurAmount--;

    while(i<=iNumAffected && !bDispel) {
        oTarget = GRObjectGetValueAt("GR_LIVELY_STEP", "AFFECTED", i, oCaster);
        //*:* check if the target still has the spell effect, just in case hit by targeted dispel
        //*:* or received better haste-type spell and no longer has the spell effect
        if(!GRDoMoveActionCheck(oTarget) && GetHasSpellEffect(SPELL_GR_LIVELY_STEP, oTarget)) bDispel = TRUE;
        i++;
    }

    //*:* if somebody is doing something other than moving, remove the spell from all affected
    if(bDispel) {
        for(i=1; i<=iNumAffected; i++) {
            oTarget = GRObjectGetValueAt("GR_LIVELY_STEP", "AFFECTED", i, oCaster);
            GRRemoveSpellEffects(SPELL_GR_LIVELY_STEP, oTarget);
        }
    }

    //*:* Update remaining duration
    SetLocalInt(oCaster, "GR_LIVELY_DUR", iDurAmount);

    //*:* if dispelled or no remaining duration, delete the array holding the affected targets
    if(bDispel || iDurAmount==0) {
        GRDeleteArrayList("GR_LIVELY_STEP", oCaster);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
