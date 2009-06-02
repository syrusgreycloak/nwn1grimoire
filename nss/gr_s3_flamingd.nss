//*:**************************************************************************
//*:*  GR_S3_FLAMINGD.NSS
//*:**************************************************************************
//*:* 696 - OnHit Firedamage (x2_s3_flamgind) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-07-17
//*:*
//*:* 703 - OnHit Darkfire (x2_s3_darkfire) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-07-17
//*:*
//*:* 721 - OnHit Burning Armor (x2_s3_flameskin) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-07-31
//*:**************************************************************************
//*:* Updated On: January 28, 2008
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

    int     iDieType          = (spInfo.iSpellID==696 ? 4 : 6);
    int     iNumDice          = 1;
    int     iBonus            = 0;

    switch(spInfo.iSpellID) {
        case 696:
        case 721:
            iBonus = MaxInt(1, spInfo.iCasterLevel);
            break;
        case 703:
            iBonus = MaxInt(1, spInfo.iCasterLevel/2);
            break;
    }

    int     iDamage           = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, iBonus);
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
    object  oItem           = GetSpellCastItem();

    int     iDamageCutoff   = (spInfo.iSpellID==721 ? 15 : 10);
    int     iVisualType     = (iDamage<iDamageCutoff ? VFX_IMP_FLAME_S : VFX_IMP_FLAME_M);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, iBonus);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDmg     = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eLink    = EffectLinkEffects(eVis, eDmg);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID!=721) {
        if(GetIsObjectValid(spInfo.oTarget)) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
            if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                GRDoIncendiarySlimeExplosion(spInfo.oTarget);
            }
        }
    } else {
        if(GetIsObjectValid(oItem)) {
            if(GetIsObjectValid(spInfo.oTarget)) {
                object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, spInfo.oTarget);
                if(!GetIsObjectValid(oWeapon)) {
                    oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spInfo.oTarget);
                }
                if(!GetWeaponRanged(oWeapon) || !GetIsObjectValid(oWeapon)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
            }
        } else {
            // Error: Spell was not cast by an item
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
