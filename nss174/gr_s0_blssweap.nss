//*:**************************************************************************
//*:*  GR_S0_BLSSWEAP.NSS
//*:**************************************************************************
//*:* Bless Weapon (X2_S0_BlssWeap) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Andrew Nobbs  Created On: Nov 28, 2002
//*:* 3.5 Player's Handbook (p. 205)
//*:**************************************************************************
//*:* Bless Weapon, Swift
//*:* Spell Compendium (p. 31)
//*:**************************************************************************
//*:* Corrupt Weapon (Blackguard)
//*:* DMG 3.5 (p. 182)
//*:**************************************************************************
//*:* Updated On: November 3, 2008
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

    if(spInfo.iSpellID==SPELL_GR_BG_CORRUPT_WEAPON) spInfo.iCasterLevel = GetLevelByClass(CLASS_TYPE_BLACKGUARD);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel*2;
    int     iDurType          = DUR_TYPE_TURNS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    if(spInfo.iSpellID==SPELL_GR_BLESS_WEAPON_SWIFT) {
        spInfo = GRSetSpellDurationInfo(spInfo, 0, iDurType, 9.0);
    } else { //*:* Bless Weapon, Swift
        spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);
    }

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object  oMyWeapon   =  IPGetTargetedOrEquippedMeleeWeapon();
    int     iAlignAgainst;

    switch(spInfo.iSpellID) {
        case SPELL_GR_BG_CORRUPT_WEAPON: iAlignAgainst = ALIGNMENT_GOOD; break;
        default: iAlignAgainst = ALIGNMENT_EVIL; break;
    }

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
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
   if(GetIsObjectValid(oMyWeapon)) {
        SignalEvent(GetItemPossessor(oMyWeapon), EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        if(fDuration>0.0) {
           GRAddVsAlignEnhancementToWeapon(oMyWeapon, iAlignAgainst, fDuration);
           GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, GetItemPossessor(oMyWeapon));
           GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, GetItemPossessor(oMyWeapon), fDuration);
        }
        return;
    } else {
           FloatingTextStrRefOnCreature(83615, oCaster);
           return;
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
