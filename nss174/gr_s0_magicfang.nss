//*:**************************************************************************
//*:*  GR_S0_MAGICFANG.NSS
//*:**************************************************************************
//*:* Magic Fang (x0_s0_magicfang.nss) Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent Knowles  Created On: September 6, 2002
//*:* 3.5 Player's Handbook (p. 250)
//*:* Greater Magic Fang Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent Knowles  Created On: September 6, 2002
//*:* 3.5 Player's Handbook (p. 250)
//*:**************************************************************************
//*:* Magic Fang, Superior
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 6, 2007
//*:* Spell Compendium (p. 136)
//*:**************************************************************************
//*:* Updated On: December 3, 2007
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
    int     iBonus            = 1;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_TURNS;

    switch(spInfo.iSpellID) {
        case SPELL_GREATER_MAGIC_FANG:
            iBonus = MinInt(5, spInfo.iCasterLevel/4);
            iDurType = DUR_TYPE_HOURS;
            break;
        case SPELL_GR_SUPERIOR_MAGIC_FANG:
            iBonus = MinInt(5, spInfo.iCasterLevel/4);
            iDurType = DUR_TYPE_ROUNDS;
            break;
    }

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object  oItem           = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, spInfo.oTarget);
    int     bDone           = FALSE;
    int     iCount          = 1;
    itemproperty ipBonus    = ItemPropertyEnhancementBonus(IPGetDamageBonusConstantFromNumber(iBonus));

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
    effect eVis         = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eDur         = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsLiving(spInfo.oTarget)) {
        while(!bDone) {
            if(GetIsObjectValid(oItem)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRIPSafeAddItemProperty(oItem, ipBonus, fDuration);
                if(spInfo.iSpellID!=SPELL_GR_SUPERIOR_MAGIC_FANG) bDone = TRUE;
            }
            if(!bDone) {
                iCount++;
                if(iCount==2) {
                    oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, spInfo.oTarget);
                } else if(iCount==3) {
                    oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, spInfo.oTarget);
                } else if(iCount==4) {
                    bDone = TRUE;
                }
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
