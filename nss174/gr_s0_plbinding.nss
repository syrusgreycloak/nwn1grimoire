//*:**************************************************************************
//*:*  GR_S0_PLBINDING.NSS
//*:**************************************************************************
//*:*
//*:* Planar Ally (NW_S0_Planar.nss) Copyright (c) 2001 Bioware Corp.
//*:* Planar Binding (NW_S0_Planar.nss) Copyright (c) 2001 Bioware Corp.
//*:* Greater Planar Binding (NW_S0_GrPlanar.nss) Copyright (c) 2001 Bioware Corp.
//*:* Lesser Planar Binding (NW_S0_LsPlanar.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: April 12, 2001
//*:* 3.5 Player's Handbook (p. 261)
//*:*
//*:* Blackguard Fiendish Servant (x0_s2_fiend) Copyright (c) 2001 Bioware Corp.
//*:* Blackguard Epic Fiendish Servant (x0_s2_fiend) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Brent  Created On: April 2003
//*:**************************************************************************
//*:* Updated On: December 26, 2007
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

    if(spInfo.iSpellID==SPELLABILITY_BG_FIENDISH_SERVANT) {
        spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_BLACKGUARD, oCaster);
    }

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 2;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_HOURS;

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

    float   fDuration1      = GRGetDuration(spInfo.iCasterLevel/2);
    float   fDuration2      = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    string  sSummon;
    string  sSummonEvil     = (spInfo.bNWN2 ? "c_summ_succubus" : "NW_S_SUCCUBUS");
    string  sSummonGood     = (spInfo.bNWN2 ? "c_celestialbear" : "NW_S_CHOUND");
    string  sSummonNeutral  = (spInfo.bNWN2 ? "c_summ_sylph" : "NW_S_SLAADGRN");
    int     iAlignment      = GetAlignmentGoodEvil(oCaster);

    int     iEvilVisual     = VFX_FNF_SUMMON_GATE;
    int     iGoodVisual     = VFX_FNF_SUMMON_CELESTIAL;
    int     iNeutralVisual  = VFX_FNF_SUMMON_MONSTER_3;
    /*** NWN2 SPECIFIC ***
        if(spInfo.iSpellID==SPELL_PLANAR_ALLY) {
            iEvilVisual = VFX_HIT_SPELL_SUMMON_CREATURE;
            iGoodVisual = VFX_HIT_SPELL_SUMMON_CREATURE;
            iNeutralVisual = VFX_HIT_SPELL_SUMMON_CREATURE;
        }
    /*** END NWN2 SPECIFIC ***/

    switch(spInfo.iSpellID) {
        case SPELL_GREATER_PLANAR_BINDING:
            iBonus = 5;
            sSummonEvil = (spInfo.bNWN2 ? "c_erinyes" : "NW_S_VROCK");
            sSummonGood = (spInfo.bNWN2 ? "c_celestialdbear" : "NW_S_CTRUMPET");
            if(!spInfo.bNWN2) {
                sSummonNeutral = "NW_S_SLAADDETH";
            } else {
                sSummonNeutral = "c_elmairhuge";
                switch(d4()) {
                    case 2: sSummonNeutral = "c_elmfirehuge";      break;
                    case 3: sSummonNeutral = "c_elmearthhuge";     break;
                    case 4: sSummonNeutral = "c_elmwaterhuge";     break;
                }
            }
            break;
        case SPELL_LESSER_PLANAR_BINDING:
            iBonus = 0;
            sSummonEvil = (spInfo.bNWN2 ? "c_summ_imp" : "NW_S_IMP");
            sSummonGood = (spInfo.bNWN2 ? "c_celestialwolf" : "NW_S_CLANTERN");
            sSummonNeutral = (spInfo.bNWN2 ? "c_firemephit" : "NW_S_SLAADRED");
            break;
        case SPELLABILITY_BG_FIENDISH_SERVANT:
            iBonus = 0;
            if(iAlignment!=ALIGNMENT_EVIL) {
                iAlignment = ALIGNMENT_EVIL;
                AdjustAlignment(oCaster, ALIGNMENT_EVIL, 75);
            }
            if(spInfo.iCasterLevel<9) {
                sSummonEvil = (spInfo.bNWN2 ? "c_fiendrat7" : "NW_S_SUCCUBUS");
            /*** NWN1 SPECIFIC ***/
                } else if(spInfo.iCasterLevel<15) {
                    sSummonEvil = (spInfo.bNWN2 ? "c_fiendrat9" : "NW_S_VROCK");
                } else {
                    if(GetHasFeat(1003, oCaster)) {
                        sSummonEvil = "x2_s_vrock";
                    } else {
                        sSummonEvil = "NW_S_VROCK";
                    }
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                } else {
                    sSummonEvil = "c_fiendrat9";
            /*** END NWN2 SPECIFIC ***/
            }
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fDuration1 *= 2;
        fDuration2 *= 2;
    }
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
    effect eSummon;
    effect eGate;
    effect eDur     = EffectVisualEffect(VFX_DUR_PARALYZED);
    /*** NWN1 SPECIFIC ***/
        effect eDur2    = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        effect eDur3    = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
    /*** END NWN1 SPECIFIC ***/

    effect eLink = EffectLinkEffects(eDur, EffectParalyze());
    /*** NWN1 SPECIFIC ***/
        eLink = EffectLinkEffects(eLink, eDur2);
        eLink = EffectLinkEffects(eLink, eDur3);
    /*** END NWN1 SPECIFIC ***/

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget) && (spInfo.iSpellID!=SPELL_PLANAR_ALLY && spInfo.iSpellID!=SPELLABILITY_BG_FIENDISH_SERVANT)) {
        if(GRGetRacialType(spInfo.oTarget) == RACIAL_TYPE_OUTSIDER) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC + iBonus)) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration1);
                }
            }
        }
    } else {
        switch(iAlignment) {
            case ALIGNMENT_EVIL:
                eSummon = EffectSummonCreature(sSummonEvil, iEvilVisual, 3.0);
                break;
            case ALIGNMENT_GOOD:
                eSummon = EffectSummonCreature(sSummonGood, iGoodVisual, 3.0);
                break;
            case ALIGNMENT_NEUTRAL:
                eSummon = EffectSummonCreature(sSummonNeutral, iNeutralVisual, 1.0);
                break;
        }
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spInfo.lTarget, fDuration2);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
