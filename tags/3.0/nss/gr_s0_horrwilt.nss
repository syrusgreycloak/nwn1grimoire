//*:**************************************************************************
//*:*  GR_S0_HORRWILT.NSS
//*:**************************************************************************
//*:* Horrid Wilting (NW_S0_HorrWilt) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Sept 12 , 2001
//*:* 3.5 Player's Handbook (p. 242)
//*:**************************************************************************
//*:* Deadly Sunstroke
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: January 8, 2009
//*:* Complete Mage (p. 101)
//*:**************************************************************************
//*:* Updated On: January 8, 2009
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_LOCALE"

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

    int     bExtremeHeat      = GRGetExtremeHeatLocale(spInfo.oTarget);
    int     iDieType          = 6;
    int     iNumDice          = MinInt(20, spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID==SPELL_GR_DEADLY_SUNSTROKE) {
        if(bExtremeHeat) iDieType = 8;
        iNumDice = MinInt(25, spInfo.iCasterLevel);
    }

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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(30.0);

    int     iVisualType     = (spInfo.iSpellID==SPELL_HORRID_WILTING ? VFX_FNF_HORRID_WILTING : VFX_FNF_FIRESTORM);
    int     iNumCreatures   = spInfo.iCasterLevel;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eExplode = EffectVisualEffect(iVisualType);
    effect eVis     = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eDam;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);

    while(GetIsObjectValid(spInfo.oTarget) && iNumCreatures>0) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iCasterLevel));
            fDelay = GetRandomDelay(1.5, 2.5);
            if(spInfo.iSpellID==SPELL_GR_DEADLY_SUNSTROKE) iNumCreatures--;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                if(GRGetIsLiving(spInfo.oTarget)) {
                    if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_ELEMENTAL && FindSubString(GetStringLowerCase(GetTag(spInfo.oTarget)),"wat")>-1) {
                        spInfo.iDmgDieType = 8;
                    }

                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                    if(spInfo.iSpellID==SPELL_GR_DEADLY_SUNSTROKE) {
                        if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) iDamage = FloatToInt(iDamage*1.5f);
                    }

                    int bSaveMade = GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }

                    eDam = EffectDamage(iDamage, DAMAGE_TYPE_MAGICAL);
                    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    if(spInfo.iSpellID==SPELL_GR_DEADLY_SUNSTROKE) {
                        if(!bSaveMade) {
                            GRApplySpecialEffectToObject(DURATION_TYPE_PERMANENT, SPECIALEFFECT_TYPE_FATIGUE, spInfo.oTarget);
                            if(bExtremeHeat) GRApplySpecialEffectToObject(DURATION_TYPE_PERMANENT, SPECIALEFFECT_TYPE_EXHAUSTION, spInfo.oTarget);
                        }
                    }
                }
             }
        }
       spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
