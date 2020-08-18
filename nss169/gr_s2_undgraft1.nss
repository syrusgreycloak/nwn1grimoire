//*:**************************************************************************
//*:*  GR_S2_UNDGRAFT1.NSS
//*:**************************************************************************
//*:* Undead Graft (X2_S2_UndGraft1) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Feb 05, 2003
//*:* Updated On: 2003-07-24, Georg Zoeller (added elf immunity, touch attack check, fixed duration)
//*:**************************************************************************
//*:* Updated On: January 9, 2008
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

    spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_PALEMASTER, oCaster);
    spInfo.iDC = spInfo.iCasterLevel/2 + 14;

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = d6()+2;
    int     iDurType          = DUR_TYPE_ROUNDS;

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

    float   fDuration       = GRGetDuration(iDurAmount, iDurType);
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
    effect ePara    = EffectParalyze();
    effect eVis     = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2    = EffectVisualEffect(VFX_DUR_ICESKIN);
    effect eDur3    = EffectVisualEffect(VFX_DUR_FREEZE_ANIMATION);
    eDur = EffectLinkEffects(eDur2,eDur);
    eDur = EffectLinkEffects(eDur3,eDur);

    effect eLink    = EffectLinkEffects(ePara, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(TouchAttackMelee(spInfo.oTarget, TRUE)>0) {
        //GZ: whimpy elves are not effected by this spell, aarrg
        if(GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_ELF) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
            }
        } else {
            FloatingTextStrRefOnCreature(85591, spInfo.oTarget, FALSE);
            FloatingTextStrRefOnCreature(85591, oCaster, FALSE);
        }
    } else {
        // * GZ: According to TaB missed attacks are not wasted.
        if(spInfo.iSpellID == 625) {
            IncrementRemainingFeatUses(oCaster, 892);
        } else if(spInfo.iSpellID == 626) {
            IncrementRemainingFeatUses(oCaster, 893);
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
