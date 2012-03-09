//*:**************************************************************************
//*:*  GR_S0_BOMBARD.NSS
//*:**************************************************************************
//*:*
//*:* Bombardment (X0_S0_Bombard) Copyright (c) 2002 Bioware Corp.
//*:* Player's Guide to Faerun (p. 100)
//*:*
//*:**************************************************************************
//*:* Created By: Brent
//*:* Created On: July 22 2002
//*:**************************************************************************
//*:* Updated On: November 26, 2007
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

    int     iDieType          = 8;
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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    float   fDelay          = 0.0f;

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
    effect eExplode = EffectVisualEffect(VFX_FNF_METEOR_SWARM);
    effect eVis     = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
        OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, TRUE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_BOMBARDMENT));
            fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC);
                eDam = EffectDamage(iDamage, DAMAGE_TYPE_BLUDGEONING);
                if(iDamage > 0) {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
