//*:**************************************************************************
//*:*  GR_S0_FEVDREAM.NSS
//*:**************************************************************************
//*:* Fever Dream
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 8, 2009
//*:* Complete Mage (p. 104)
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 5;
    int     iDurType          = DUR_TYPE_ROUNDS;

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
    float   fDelay          = RoundsToSeconds(1);
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iLuminousSwarmDCBonus       = (GetHasSpellEffect(SPELL_GR_LUMINOUS_SWARM, spInfo.oTarget) ? 2 : 0);
    int     iPricklingTormentDCBonus    = (GetHasSpellEffect(SPELL_GR_PRICKLING_TORMENT, spInfo.oTarget) ? 2 : 0);

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
    effect eDur         = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eConfused    = EffectConfused();
    effect eLink        = EffectLinkEffects(eDur, eConfused);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_FEVER_DREAM));
    if(GRGetIsLiving(spInfo.oTarget)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC + iLuminousSwarmDCBonus, SAVING_THROW_TYPE_MIND_SPELLS, oCaster,
                0.0f, FALSE, FALSE)==0) {

                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, fDuration);
                GRApplySpecialEffectToObject(DURATION_TYPE_PERMANENT, SPECIALEFFECT_TYPE_FATIGUE, spInfo.oTarget);
                SetLocalInt(spInfo.oTarget, "GR_FEVERDREAM_DC", spInfo.iDC + iLuminousSwarmDCBonus);

                if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC + iPricklingTormentDCBonus)) {
                    GRApplySpecialEffectToObject(DURATION_TYPE_PERMANENT, SPECIALEFFECT_TYPE_EXHAUSTION, spInfo.oTarget);
                }

                DelayCommand(fDuration, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDelay));
            }
        }
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
