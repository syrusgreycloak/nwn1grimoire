//*:**************************************************************************
//*:*  GR_S0_DISMAGIC.NSS
//*:**************************************************************************
//*:*
//*:* Dispel Magic (NW_S0_DisMagic.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 223)
//*:* Lesser Dispel (NW_S0_LsDispel.nss) Copyright (c) 2001 Bioware Corp.
//*:* created by Bioware
//*:* Greater Dispelling (NW_S0_GrDispel.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 223)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Jan 7, 2002
//*:* Updated On: Oct 20, 2003, Georg Zoeller
//*:**************************************************************************
//*:* Updated On: October 25, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS"   - INCLUDED IN GR_IN_BREACH
#include "GR_IN_SPELLHOOK"
#include "GR_IN_BREACH"

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
    int     iBonus            = 0;
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
    float   fRange          = FeetToMeters(20.0);

    int     iCheckLevel     = 10;

    /*** NWN1 SPECIFIC ***/
        int     iVisual         = VFX_IMP_BREACH;
        int     iImpact         = VFX_FNF_DISPEL;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        int     iVisual         = VFX_HIT_SPELL_ABJURATION;
        int     iImpact         = GRGetSpellSchoolAOEVisual(spInfo.iSpellSchool);
    /*** END NWN2 SPECIFIC ***/


    switch(spInfo.iSpellID) {
        case SPELL_LESSER_DISPEL:
            iCheckLevel = 5;
            /*** NWN1 SINGLE ***/ iVisual = VFX_IMP_HEAD_SONIC;
            break;
        case SPELL_GREATER_DISPELLING:
            iCheckLevel = 20;
            break;
    }

    iBonus = (spInfo.iCasterLevel>iCheckLevel ? iCheckLevel : spInfo.iCasterLevel);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;

    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;

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
    effect    eVis         = EffectVisualEffect(iVisual);
    effect    eImpact      = EffectVisualEffect(iImpact);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget)) {
        //*:**********************************************
        //*:* Targeted Dispel - Dispel all
        //*:**********************************************
        GRDispelMagic(spInfo.oTarget, iBonus, eVis, eImpact);
    } else {
        //*:**********************************************
        //*:* Area of Effect - Only dispel best effect
        //*:**********************************************

        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE );
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_AREA_OF_EFFECT) {
                //*:**********************************************
                //*:* Handle Area of Effects
                //*:**********************************************
                spellsDispelAoE(spInfo.oTarget, oCaster, spInfo.iCasterLevel);
            } else if(GetObjectType(spInfo.oTarget) == OBJECT_TYPE_PLACEABLE) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            } else {
                GRDispelMagic(spInfo.oTarget, iBonus, eVis, eImpact, FALSE);
            }

            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_AREA_OF_EFFECT | OBJECT_TYPE_PLACEABLE);
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
