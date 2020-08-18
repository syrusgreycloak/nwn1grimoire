//*:**************************************************************************
//*:*  GR_S0_SUNBEAM.NSS
//*:**************************************************************************
//:: Sunbeam (nw_s0_Sunbeam.nss) Copyright (c) 2001 Bioware Corp.
//:: Created By: Keith Soleski  Created On: Feb 22, 2001
//*:* 3.5 Player's Handbook (p. 289)
//*:**************************************************************************
//*:* Updated On: November 8, 2007
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

    int     iDieType          = 6;
    int     iNumDice          = MinInt(24, 4*spInfo.iCasterLevel/3);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = GetDistanceBetween(oCaster, spInfo.oTarget) + FeetToMeters(3.0);
    int     iDurationType   = (GetGameDifficulty()<GAME_DIFFICULTY_CORE_RULES ? DURATION_TYPE_TEMPORARY : DURATION_TYPE_PERMANENT);
    float   fDelay;

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
    effect eBeam    = EffectBeam(VFX_BEAM_HOLY, oCaster, BODY_NODE_HAND);
    /*** NWN1 SINGLE ***/ effect eVis     = EffectVisualEffect(VFX_IMP_SUNSTRIKE);
    //*** NWN2 SINGLE ***/ effect eVis = EffectVisualEffect(VFX_HIT_SPELL_HOLY);
    effect eBlind   = EffectBlindness();
    effect eDam;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, 1.7f);
    spInfo.lTarget = GetLocation(spInfo.oTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR |
        OBJECT_TYPE_PLACEABLE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            spInfo.iDmgNumDice = MinInt(24, 4*spInfo.iCasterLevel/3);
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
                if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD || GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_OOZE) {
                    spInfo.iDmgNumDice = MinInt(60, spInfo.iCasterLevel*spInfo.iCasterLevel/3);
                }
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                if(GRGetIsLightSensitive(spInfo.oTarget)) iDamage *= 2;
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster) && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD &&
                    GRGetIsLightSensitive(spInfo.oTarget)) {
                        //*:* if failed save and is light-sensitive undead, kill the target
                        if(!GetIsPC(spInfo.oTarget)) {
                            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                            DelayCommand(fDelay, DestroyObject(spInfo.oTarget));
                        } else {
                            iDamage = GetCurrentHitPoints(spInfo.oTarget);
                            eDam = EffectDamage(iDamage, DAMAGE_TYPE_DIVINE);
                            eLink = EffectLinkEffects(eDam, eVis);
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        }
                } else {
                    eDam = EffectDamage(iDamage, DAMAGE_TYPE_DIVINE);
                    eLink = EffectLinkEffects(eDam, eVis);
                    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    if(iDamage>0) {
                        if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                            DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eBlind, spInfo.oTarget, fDuration));
                        }
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR |
            OBJECT_TYPE_PLACEABLE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
