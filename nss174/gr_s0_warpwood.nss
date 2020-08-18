//*:**************************************************************************
//*:*  GR_S0_WARPWOOD.NSS
//*:**************************************************************************
//*:* Warp Wood
//*:* Created By: Dennis Dollins (Danmar)  Created On: , 2004
//*:* 3.5 Player's Handbook (p. 300)
//*:**************************************************************************
//*:* Updated On: March 3, 2008
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
    //*:* int     iBonus            = 0;
    int     iDamage           = 0;
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object  oWeapon         = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,spInfo.oTarget);
    int     iGoldValue      = GetGoldPieceValue(oWeapon);
    int     iD20;
    int     iSlot           = 11;
    int     iD              =FALSE;
    int     iAffectMagic    = FALSE;

    spInfo.iDC             = spInfo.iCasterLevel*2;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_MAXIMIZE)) spInfo.iDC *= 2;
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
    effect eImpact = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_WARP_WOOD));
    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spInfo.oTarget);
        if((oWeapon!=OBJECT_INVALID) &&
            (!GetPlotFlag(oWeapon)) &&
            ((GetBaseItemType(oWeapon)==BASE_ITEM_HEAVYCROSSBOW)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_LIGHTCROSSBOW)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_LONGSWORD)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_SHORTBOW)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_SHORTSPEAR)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_DIREMACE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_DOUBLEAXE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_DWARVENWARAXE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_GREATAXE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_HALBERD)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_HANDAXE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_HEAVYFLAIL)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_KAMA)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_LIGHTFLAIL)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_LIGHTHAMMER)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_LIGHTMACE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_MAGICSTAFF)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_MORNINGSTAR)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_QUARTERSTAFF)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_SCYTHE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_SICKLE)||
             (GetBaseItemType(oWeapon)==BASE_ITEM_WARHAMMER)))
        {
            iD20 = d20();
            iD20= iD20 + (iGoldValue/300);
            if(iD20<spInfo.iDC) {
                iD = TRUE;
                DestroyObject(oWeapon);
                if(!GetIsPC(spInfo.oTarget)) {
                    FloatingTextStringOnCreature(GetName(spInfo.oTarget) + GetStringByStrRef(16939285), spInfo.oTarget, FALSE);
                } else {
                    FloatingTextStrRefOnCreature(16939286, spInfo.oTarget, FALSE);
                }
            }
        }
        while(iSlot!=15) {
            oWeapon = GetItemInSlot(iSlot, spInfo.oTarget);
            iGoldValue = GetGoldPieceValue(oWeapon);
            if((oWeapon!=OBJECT_INVALID) && (!GetPlotFlag(oWeapon))) {
                iD20 = d20();
                iD20= iD20 + (iGoldValue/300);
                if(iD20<spInfo.iDC) {
                    iD = TRUE;
                    DestroyObject(oWeapon);
                    if(!GetIsPC(spInfo.oTarget))                     {
                        FloatingTextStringOnCreature(GetName(spInfo.oTarget) + GetStringByStrRef(16939287),spInfo.oTarget,FALSE);
                    } else {
                        FloatingTextStrRefOnCreature(16939288, spInfo.oTarget, FALSE);
                    }
                }
            }
            iSlot += 2;
        }
        if(iD) GRApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_SMALL), spInfo.oTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
