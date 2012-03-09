//*:**************************************************************************
//*:*  GR_S0_ENTANGLEC.NSS
//*:**************************************************************************
//*:* Entangle (NW_S0_EntangleC.NSS) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: July 30, 2001
//*:* 3.5 Player's Handbook (p. 227)
//*:*
//*:* Vine Mine, Entangle C (X2_S0_VineMEntC) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Nov 25, 2002
//*:* Spell Compendium (p. 230)
//*:**************************************************************************
//*:* Updated On: December 19, 2007
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

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eHold        = EffectEntangle();
    effect eEntangle    = EffectVisualEffect(VFX_DUR_ENTANGLE);
    effect eLink        = EffectLinkEffects(eHold, eEntangle);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(!GetHasEffect(EFFECT_TYPE_ENTANGLE, spInfo.oTarget)) {
            if(!GetHasSpellEffect(SPELL_FREEDOM_OF_MOVEMENT, spInfo.oTarget) &&
               !GetHasSpellEffect(SPELLABILITY_GR_FREEDOM_OF_MOVEMENT, spInfo.oTarget) &&
               !GetCreatureFlag(spInfo.oTarget, CREATURE_VAR_IS_INCORPOREAL)) {

                if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    if(!GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC)) {
                        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
                    }
                }
            }
        } else {
            //*:**********************************************
            //*:* Make STR Check
            //*:**********************************************
            spInfo.iDC = 20;
            int iDieRoll = d20();
            int iSTRCheck = iDieRoll + GetAbilityModifier(ABILITY_STRENGTH, spInfo.oTarget);

            if(iSTRCheck > spInfo.iDC) {
                GRRemoveEffects(EFFECT_TYPE_ENTANGLE, spInfo.oTarget);
            }
        }
        spInfo.oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
