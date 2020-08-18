//*:**************************************************************************
//*:*  GR_S0_CIRCALIGNA.NSS
//*:**************************************************************************
//*:*
//*:* Magic Circle against <alignment>: On enter
//*:* 3.5 Player's Handbook (p. 249-250)
//*:*
//*:* Combines all magic circle scripts into one master script plus AOEs
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 1, 2003
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
#include "GR_IN_ALIGNMENT"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellStruct(GRGetAOESpellId());

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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iAlignAgainst   = GetLocalInt(OBJECT_SELF, "GR_L_PROT_ALIGN");
    int     iAlignFor       = GetLocalInt(OBJECT_SELF, "GR_L_ALIGN_FOR");
    int     iAlignAxis;
    int     iSpellID        = GRGetAOESpellId();

    if(iAlignFor==ALIGNMENT_GOOD || iAlignFor==ALIGNMENT_EVIL) {
        iAlignAxis = ALIGNMENT_AXIS_GOODEVIL;
    } else {
        iAlignAxis = ALIGNMENT_AXIS_LAWCHAOS;
    }

    spInfo.oTarget         = GetEnteringObject();

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
    effect eLink = GREffectProtectionFromAlignment(iAlignAgainst);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oCaster);
    } else {
        if((GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OUTSIDER || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ELEMENTAL ||
            GetLocalInt(spInfo.oTarget, "GR_L_AM_SUMMON")) &&
            !GRGetCreatureAlignmentEqual(spInfo.oTarget, iAlignFor, iAlignAxis)) {

            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.lTarget = GetBehindLocation(spInfo.oTarget);
                AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                AssignCommand(spInfo.oTarget, JumpToLocation(spInfo.lTarget));
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
