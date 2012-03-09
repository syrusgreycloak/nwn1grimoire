//*:**************************************************************************
//*:*  GR_S0_BESCURSE.NSS
//*:**************************************************************************
//*:* Bestow Curse (NW_S0_BesCurse.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Bob McCabe   Created On: March 6, 2001
//*:* 3.5 Player's Handbook (p. 203)
//*:**************************************************************************
//*:* Last Updated By: Preston Watamaniuk
//*:* VFX Pass By: Preston W, On: June 20, 2001
//*:* Update Pass By: Preston W, On: July 20, 2001
//*:**************************************************************************
//*:*
//*:* Added a -3 penalty to attack rolls, saving throws, and skill checks
//*:* (should get -1 due to ability decrease above) to make it more as described
//*:* in the PHB (option #2)
//*:**************************************************************************
//*:* Bestow Curse, Greater (Spell Compendium p. 27)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: October 25, 2007
//*:*
//*:* Curse of Despair (Complete Arcane p. 132)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:**************************************************************************
///*:* Updated On: April 23, 2008
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
    int     iBonus            = (spInfo.iSpellID==SPELL_BESTOW_CURSE ? 1 : 2);
    int     iDamage           = (spInfo.iSpellID==SPELL_BESTOW_CURSE ? 3 : 7);
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
    /*** NWN1 SINGLE ***/ effect eVis         = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    //*** NWN2 SINGLE ***/ effect eVis         = EffectVisualEffect(VFX_DUR_SPELL_BESTOW_CURSE);
    effect eCurse       = EffectCurse(iBonus, iBonus, iBonus, iBonus, iBonus, iBonus);
    effect eSkillCurse  = EffectSkillDecrease(SKILL_ALL_SKILLS, iDamage);
    effect eAttackCurse = EffectAttackDecrease(iDamage);
    effect eSaveCurse   = EffectSavingThrowDecrease(SAVING_THROW_ALL, iDamage);

    effect eLink = EffectLinkEffects(eCurse, eSkillCurse);
    eLink = EffectLinkEffects(eLink, eAttackCurse);
    eLink = EffectLinkEffects(eLink, eSaveCurse);
    //*** NWN2 SINGLE ***/ eLink = EffectLinkEffects(eLink, eVis);

    eLink = SupernaturalEffect(eLink);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(spInfo.oTarget, spInfo.iSpellID));
    if(TouchAttackMelee(spInfo.oTarget)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
            if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
            } else if(spInfo.iSpellID==SPELL_I_CURSE_OF_DESPAIR) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(EffectAttackDecrease(1)), spInfo.oTarget, GRGetDuration(1, DUR_TYPE_TURNS));
                //*** NWN2 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_HIT_SPELL_NECROMANCY), spInfo.oTarget);
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
