//*:**************************************************************************
//*:*  GR_S0_HYMNPRAISA.NSS
//*:**************************************************************************
//*:* Hymn of Praise (OnEnter)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 8, 2009
//*:* Spell Compendium (p. 117)
//*:*
//*:* Infernal Threnody (OnEnter)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 9, 2009
//*:* Spell Compendium (p. 122)
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

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    spInfo.oTarget = GetEnteringObject();
    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

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
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int iAlign = GetAlignmentGoodEvil(spInfo.oTarget);
    int bCleric = GetLevelByClass(CLASS_TYPE_CLERIC, spInfo.oTarget)==0;
    int bPaladin = GetLevelByClass(CLASS_TYPE_PALADIN, spInfo.oTarget)==0;
    int bBlackguard = GetLevelByClass(CLASS_TYPE_BLACKGUARD, spInfo.oTarget)==0;
    int bDruid = GetLevelByClass(CLASS_TYPE_DRUID, spInfo.oTarget)==0;
    int bRanger = GetLevelByClass(CLASS_TYPE_RANGER, spInfo.oTarget)==0;

    int bTarget = bCleric || bPaladin || bBlackguard || bDruid || bRanger;

    int iVisualType = (iAlign==ALIGNMENT_EVIL ? VFX_DUR_PROTECTION_EVIL_MINOR : VFX_DUR_PROTECTION_GOOD_MINOR);
    int bHostile;

    if(spInfo.iSpellID==SPELL_GR_HYMN_OF_PRAISE) {
        bHostile = (iAlign==ALIGNMENT_EVIL);
    } else {
        bHostile = (iAlign==ALIGNMENT_GOOD);
    }

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
    effect eDur = EffectVisualEffect(iVisualType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(iAlign!=ALIGNMENT_NEUTRAL && bTarget) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID, bHostile));
        if(!bHostile) {
            GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDur, spInfo.oTarget);
        } else {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SONIC, oCaster, 0.0f, FALSE, FALSE)==0) {
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDur, spInfo.oTarget);
                }
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
