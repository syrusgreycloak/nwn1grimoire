//*:**************************************************************************
//*:*  GR_S2_IMBUEARROW.NSS
//*:**************************************************************************
//*:* x1_s2_imbuearrow  (Copyright (c) 2001 Bioware Corp.)
//*:*
//*:**************************************************************************
//*:* Arcane Archer Imbue Arrow Power (PCs Only due to AI selection)
//*:* 3.5 Dungeon Master's Guide (p. 177)
//*:**************************************************************************
//*:* This power has been changed for PCs to create a copy of an arrow in the player's inventory
//*:* called "Imbued Arrow", and reduces the stack size targeted by one (if a stack).
//*:*
//*:* Since items do not have an "OnSpellCastAt" script, I will put a check into the
//*:* spellhook script that will check if the target is an "Imbued Arrow" and then will check against
//*:* a list of area spells to see if it is a valid spell to put on the arrow.
//*:* Damaging spells will be put on as an "on hit cast spell" property.
//*:* Beneficial spells will cause the arrow to get an "on use" script that will
//*:* perform a TouchAttackRanged on the target and if successful, cause the target
//*:* to run the spell script.
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 14, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void GRRevertName(object oImbuedArrow) {
    SetName(oImbuedArrow, GetLocalString(oImbuedArrow, "GR_ORIG_ITEM_NAME"));
}

void GRCreateImbuedArrowItem(struct SpellStruct spInfo, object oCaster) {

    object  oArrowStack     = spInfo.oTarget;
    object  oEquippedArrow  = GetItemInSlot(INVENTORY_SLOT_ARROWS, oCaster);
    int     bDestroyed      = FALSE;
    int     bEquipped       = FALSE;

    if(oArrowStack==oCaster) {
        oArrowStack = oEquippedArrow;
    }
    if(oArrowStack==oEquippedArrow) {
        bEquipped = TRUE;
    }

    if(!GetIsObjectValid(oArrowStack)) {
        SendMessageToPC(oCaster, GetStringByStrRef(16939269));
        return;
    } else if(GetBaseItemType(oArrowStack)!=BASE_ITEM_ARROW) {
        SendMessageToPC(oCaster, GetStringByStrRef(16939270));
        return;
    }

    object oImbuedArrow = CreateItemOnObject("gr_it_imbarrow", oCaster);

    IPCopyItemProperties(oArrowStack, oImbuedArrow, FALSE);
    SetLocalString(oImbuedArrow, "GR_ORIG_ITEM_TAG", GetTag(oArrowStack));
    SetLocalString(oImbuedArrow, "GR_ORIG_ITEM_NAME", GetName(oArrowStack));
    SetLocalObject(oImbuedArrow, "GR_MY_CREATOR", oCaster);

    if(GetItemStackSize(oArrowStack)>1) {
        SetItemStackSize(oArrowStack, GetItemStackSize(oArrowStack)-1);
    } else {
        DestroyObject(oArrowStack);
        bDestroyed = TRUE;
    }

    DelayCommand(GRGetDuration(4), SetLocalInt(oImbuedArrow, "GR_IMBUE_EXPIRED", TRUE));
    AssignCommand(oCaster, ActionEquipItem(oImbuedArrow, INVENTORY_SLOT_ARROWS));
    if((!bEquipped && GetIsObjectValid(oEquippedArrow)) || (!bDestroyed && bEquipped)) {
        DelayCommand(GRGetDuration(4), AssignCommand(oCaster, ActionEquipItem(oEquippedArrow, INVENTORY_SLOT_ARROWS)));
    }
    DelayCommand(GRGetDuration(4), GRRevertName(oImbuedArrow));
}

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    if(GetIsPC(oCaster)) {
        GRCreateImbuedArrowItem(spInfo, oCaster);
        return;
    }

    int     iDieType          = 6;
    int     iNumDice          = MinInt(10, spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(15.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    int     iExplodeType    = GRGetEnergyExplodeType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iTouchAttack;

    // Epic Progression for Arcane Archer
    if(GRGetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCaster)>10) {
        iNumDice += (GRGetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCaster)-10)/2;
    }
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
    effect eExplode = EffectVisualEffect(iExplodeType);
    effect eVis = EffectVisualEffect(iVisualType);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    // * GZ: Add arrow damage if targeted on creature...
    if(GetIsObjectValid(spInfo.oTarget)) {
        iTouchAttack = TouchAttackRanged(spInfo.oTarget, TRUE);
        if(iTouchAttack > 0) {
            iDamage = ArcaneArcherDamageDoneByBow(iTouchAttack==2);
            iBonus = ArcaneArcherCalculateBonus() ;
            effect ePhysical = EffectDamage(iDamage, DAMAGE_TYPE_PIERCING, IPGetDamagePowerConstantFromNumber(iBonus));
            effect eMagic = EffectDamage(iBonus, DAMAGE_TYPE_MAGICAL);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, ePhysical, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eMagic, spInfo.oTarget);
        }
    }

    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_FIREBALL, TRUE));
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                eDam = EffectDamage(iDamage, iEnergyType);
                if(iDamage>0) {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
