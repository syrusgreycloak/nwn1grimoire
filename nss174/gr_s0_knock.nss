//*:**************************************************************************
//*:*  GR_S0_KNOCK.NSS
//*:**************************************************************************
//*:*
//*:* Knock (NW_S0_Knock) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 246)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Nov 29, 2001
//*:**************************************************************************
//*:* Updated On: November 2, 2007
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
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    float   fDelay;
    int     iResist;

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
    /*** NWN1 SINGLE ***/ effect eVis = EffectVisualEffect(VFX_IMP_KNOCK);
    //*** NWN2 SINGLE ***/ effect eVis = EffectVisualEffect(VFX_HIT_SPELL_TRANSMUTATION);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, 50.0, spInfo.lTarget, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        fDelay = GetRandomDelay(0.5, 2.5);
        if(!GetPlotFlag(spInfo.oTarget) && GetLocked(spInfo.oTarget)) {
            iResist = GetDoorFlag(spInfo.oTarget, DOOR_FLAG_RESIST_KNOCK);
            if(iResist==0) {
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                AssignCommand(spInfo.oTarget, ActionUnlockObject(spInfo.oTarget));
            } else if(iResist==1) {
                FloatingTextStrRefOnCreature(83887, oCaster);
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, 50.0, spInfo.lTarget, FALSE, OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
