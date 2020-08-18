//*:**************************************************************************
//*:*  GR_S0_INFESTMC.NSS
//*:**************************************************************************
//*:* Infestation of Maggots (X2_S0_InfestMag.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Nov 19, 2002
//*:* Spell Compendium (p. 123)
//*:**************************************************************************
//*:* Updated On: December 10, 2007
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
void RunInfestImpact(object oTarget, object oCaster, int iDamage) {
    //------------------------------------------------------------------
    // The trick that allows this spellscript to do stacking ability
    // score damage (which is not possible to do from normal scripts)
    // is that the ability score damage is done from a delaycommanded
    // function which will sever the connection between the effect
    // and the SpellId
    //------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // Effects
    //--------------------------------------------------------------------------
    effect eVis = EffectVisualEffect(VFX_IMP_DISEASE_S);
    effect eDam = ExtraordinaryEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION, iDamage));

    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);

    //------------------------------------------------------------------
    // If the target already is down to 3 points of constitution,
    // kill him. For immortal creatures, end the spell
    // This only kicks in in Hardcore+ difficulty
    //------------------------------------------------------------------
    if(GetAbilityScore(oTarget, ABILITY_CONSTITUTION)<=3 && GetGameDifficulty()>=GAME_DIFFICULTY_CORE_RULES) {
        if(!GetImmortal(oTarget)) {
            FloatingTextStrRefOnCreature(100932, oTarget);
            effect eKill = EffectDamage(GetCurrentHitPoints(oTarget)+1);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, oTarget);
            effect eVfx = EffectVisualEffect(VFX_IMP_DEATH_L);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVfx, oTarget);
         }
    } else {
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, oTarget);
    }
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

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
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
    //*:* list effect declarations here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(!GetIsDead(spInfo.oTarget)) {
        if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DISEASE, oCaster)) {
            DelayCommand(0.1, RunInfestImpact(spInfo.oTarget, oCaster, iDamage));
         } else {
            GRRemoveSpellEffects(SPELL_INFESTATION_OF_MAGGOTS, spInfo.oTarget);
            DestroyObject(OBJECT_SELF);
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
