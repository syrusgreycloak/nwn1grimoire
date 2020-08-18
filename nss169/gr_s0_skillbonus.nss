//*:**************************************************************************
//*:*  GR_S0_SKILLBONUS.NSS
//*:**************************************************************************
//*:* Amplify (x0_s0_amplify.nss) Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent Knowles  Created On: July 30, 2002
//*:* Spell Compendium (p. 10)
//*:*
//*:* Camouflage (x0_s0_camo.nss) Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent Knowles  Created On: July 19, 2002
//*:* Spell Compendium (p. 43)
//*:*
//*:* Clairaudience / Clairvoyance (NW_S0_ClairAdVo.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Oct 21, 2001
//*:* 3.5 Player's Handbook (p. 209)
//*:*
//*:* Find Traps (NW_S0_FindTrap) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Oct 29, 2001
//*:* 3.5 Player's Handbook (p. 230)
//*:*
//*:* Legend Lore (NW_S0_Lore.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk Created On: Oct 22, 2001
//*:*
//*:* Divine Trickery (NW_S2_DivTrick.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: November 9, 2001
//*:*
//*:* Rogues Cunning AKA Potion of Extra Theiving
//*:* (NW_S0_ExtraThf.nss)  Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk   Created On: November 9, 2001
//*:**************************************************************************
//*:* Appraising Touch (sg_s0_apptouch.nss) 2006 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 15, 2006
//*:* Spell Compendium (p. 15)
//*:*
//*:* Mass Camouflage
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: September 18, 2007
//*:* Spell Compendium (p. 43)
//*:*
//*:* Chameleon Skin
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 31, 2001
//*:* Sword & Sorcery: Relics & Rituals I
//*:*
//*:* Glibness (sg_s3_glibness.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 6, 2004
//*:* 3.5 Player's Handbook (p. 235)
//*:*
//*:* One With The Land (sg_s0_oneland.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: July 28, 2003
//*:* Spell Compendium (p. 149)
//*:*
//*:* Towering Oak (sg_s0_toweroak.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 3, 2004
//*:* Spell Compendium (p. 221)
//*:*
//*:* Halfling Domain Power (sg_s2_halfdom.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 11, 2004
//*:*
//*:* Potion of Vision (sg_s3_vision.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 6, 2004
//*:*
//*:* Magic Savant
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 11, 2008
//*:* Complete Mage (p. 110)
//*:*
//*:* Mask of the Ideal
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 15, 2008
//*:* Complete Mage (p. 110)
//*:*
//*:* Beguiling Influence
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 22, 2008
//*:* Complete Arcane (p. 132)
//*:*
//*:* Leaps and Bounds
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 30, 2008
//*:* Complete Arcane (p. 134)
//*:*
//*:* Serene Visage
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 22, 2008
//*:* Spell Compendium (p. 139)
//*:*
//*:* Sticky Fingers
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 22, 2008
//*:* Spell Compendium (p. 206)
//*:*
//*:* Insidious Insight
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: December 23, 2008
//*:* Races of Eberron (p. 187)
//*:*
//*:**************************************************************************
//*:* Updated On: December 23, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
#include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

#include "GR_IN_DEBUG"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
void GRPreventSkillBonusStacking(int iSpellID, object oTarget) {

    AutoDebugString("Preventing Stacking...");

    switch(iSpellID) {
        case SPELL_CAMOFLAGE:
        case SPELL_MASS_CAMOFLAGE:
        case SPELL_GR_CHAMELEON_SKIN:
            if(GetHasSpellEffect(SPELL_CAMOFLAGE, oTarget)) GRRemoveSpellEffects(SPELL_CAMOFLAGE, oTarget);
            else if(GetHasSpellEffect(SPELL_MASS_CAMOFLAGE, oTarget)) GRRemoveSpellEffects(SPELL_MASS_CAMOFLAGE, oTarget);
            else if(GetHasSpellEffect(SPELL_GR_CHAMELEON_SKIN, oTarget)) GRRemoveSpellEffects(SPELL_GR_CHAMELEON_SKIN, oTarget);
            break;
        default:
            GRRemoveSpellEffects(iSpellID, oTarget);
            break;
    }
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    int     iBonus            = 10;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    AutoDebugString("Determining duration for " + GRSpellToString(spInfo.iSpellID));
    switch(spInfo.iSpellID) {
        //*:* 10 Min per level
        case SPELL_CAMOFLAGE:
        case SPELL_MASS_CAMOFLAGE:
        case SPELL_GR_GLIBNESS:
        case SPELL_GR_MASK_OF_THE_IDEAL:
            iDurAmount *= 10;
        //*:* 1 Min per level
        case SPELL_AMPLIFY:
        case SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE:
        case SPELL_FIND_TRAPS:
        case SPELL_LEGEND_LORE:
        case SPELL_GR_RABBIT_FEET:
        case SPELL_GR_SERENE_VISAGE:
            iDurType = DUR_TYPE_TURNS;
            break;
        //*:* 1 Hour per level
        case SPELL_GR_APPRAISING_TOUCH:
        case SPELL_GR_CHAMELEON_SKIN:
        case SPELL_ONE_WITH_THE_LAND:
            iDurType = DUR_TYPE_HOURS;
            break;
        //*:* x Rounds per level
        case SPELL_GR_TOWERING_OAK:
            iDurAmount *= 3;
            break;
        //*:* Other specific values
        case SPELLABILITY_GR_HALFLING_DOMAIN_POWER:
            iDurAmount = 10;
            iDurType = DUR_TYPE_TURNS;
            break;
        case SPELLABILITY_DIVINE_TRICKERY:
            spInfo.iCasterLevel = GRGetLevelByClass(CLASS_TYPE_CLERIC);
            iDurAmount = GetAbilityModifier(ABILITY_CHARISMA)+5;
            iDurType = DUR_TYPE_TURNS;
            break;
        case SPELLABILITY_ROGUES_CUNNING:
            iDurAmount = 5;
            iDurType = DUR_TYPE_TURNS;
            break;
        case 1828: // Potion of Vision
            iDurAmount = 1;
            iDurType = DUR_TYPE_HOURS;
            break;
        case SPELL_I_BEGUILING_INFLUENCE:
        case SPELL_I_LEAPS_AND_BOUNDS:
            iDurAmount = 24;
            iDurType = DUR_TYPE_HOURS;
            break;
        case SPELL_GR_STICKY_FINGERS:
            iDurAmount = 2;
            break;
        case SPELL_GR_INSIDIOUS_INSIGHT:
            if(GRGetRacialType(oCaster)==RACIAL_TYPE_GNOME) {
                spInfo.iCasterLevel++;
                iDurAmount++;
            }
            iDurType = DUR_TYPE_DAYS;
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
    float   fRange          = FeetToMeters(15.0);
    float   fDelay          = 0.0;
    int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iVisual         = VFX_IMP_IMPROVE_ABILITY_SCORE;
    int     iVisDurType     = DURATION_TYPE_INSTANT;
    int     iSkill          = -1;
    int     iBonus2         =  0;
    int     iSkill2         = -1;
    int     iBonus3         =  0;
    int     iSkill3         = -1;
    int     iBonus4         =  0;
    int     iSkill4         = -1;
    int     iBonus5         =  0;
    int     iSkill5         = -1;
    int     iBonus6         =  0;
    int     iSkill6         = -1;
    int     iBonus7         =  0;
    int     iSkill7         = -1;
    int     bMultiTarget    = (spInfo.iSpellID==SPELL_MASS_CAMOFLAGE);
    int     bHasAOE         = FALSE;
    int     bSupernatural   = FALSE;
    int     bSpecialTarget  = FALSE;
    int     iAOEType        = -1;
    string  sAOEType        = "";

    AutoDebugString("Setting skill info for spell " + GRSpellToString(spInfo.iSpellID));
    switch(spInfo.iSpellID) {
        //*:**********************************************
        //*:* Skills - Animal Empathy, Move Silently, Search
        //*:**********************************************
        case SPELL_ONE_WITH_THE_LAND:
            //*:**********************************************
            //*:* Define Animal Empathy, Move Silently and Search
            //*:* Fall through for Hide skill (iSkill)
            //*:**********************************************
            iBonus = 2;
            iBonus2 = iBonus;
            iSkill2 = SKILL_ANIMAL_EMPATHY;
            iBonus3 = iBonus;
            iSkill3 = SKILL_MOVE_SILENTLY;
            iBonus4 = iBonus;
            iSkill4 = SKILL_SEARCH;
            //break; - fall through to pick up hide
        //*:**********************************************
        //*:* Skill - Hide
        //*:**********************************************
        case SPELL_GR_CHAMELEON_SKIN:
        case SPELL_CAMOFLAGE:
        case SPELL_MASS_CAMOFLAGE:
            // need to wrap in if statement for fall through
            // from One with the Land
            if(spInfo.iSpellID==SPELL_MASS_CAMOFLAGE) {
                bHasAOE = TRUE;
                iAOEType = AOE_MOB_MASS_CAMOFLAGE;
                sAOEType = AOE_TYPE_MASS_CAMOFLAGE;
            }
            if(spInfo.iSpellID==SPELL_GR_CHAMELEON_SKIN) {
                iBonus = MinInt(10, spInfo.iCasterLevel);
                iVisual = VFX_IMP_FORTITUDE_SAVING_THROW_USE;
            }
            iSkill = SKILL_HIDE;
            break;
        //*:**********************************************
        //*:* Skills - Spot/Listen
        //*:**********************************************
        case SPELL_CLAIRAUDIENCE_AND_CLAIRVOYANCE:
            iVisual = VFX_DUR_MAGICAL_SIGHT;
            iVisDurType = DURATION_TYPE_TEMPORARY;
            iSkill2  = SKILL_SPOT;
            iBonus2 = iBonus;
            iSkill2 = SKILL_LISTEN;
            break;
        //*:**********************************************
        //*:* Skill - Listen
        //*:**********************************************
        case SPELL_AMPLIFY:
            iBonus = 20;
            iSkill = SKILL_LISTEN;
            break;
        //*:**********************************************
        //*:* Skill - Appraise
        //*:**********************************************
        case SPELL_GR_APPRAISING_TOUCH:
            iVisual = VFX_IMP_WILL_SAVING_THROW_USE;
            iSkill = SKILL_APPRAISE;
            break;
        //*:**********************************************
        //*:* Skill - Lore
        //*:**********************************************
        case SPELL_LEGEND_LORE:
            iVisual = VFX_IMP_MAGICAL_VISION;
            iSkill = SKILL_LORE;
            iBonus = 10 + spInfo.iCasterLevel/2;
            break;
        //*:**********************************************
        //*:* Skill - Search
        //*:**********************************************
        case 1828:  // Potion of Vision
        case SPELL_FIND_TRAPS:
            iBonus = (spInfo.iSpellID==1828 ? 30 : MinInt(10, spInfo.iCasterLevel/2));
            iSkill = SKILL_SEARCH;
            iVisual = VFX_IMP_KNOCK;
            if(spInfo.iSpellID==SPELL_FIND_TRAPS) {
                iAOEType = AOE_MOB_FINDTRAPS;
                sAOEType = AOE_TYPE_FIND_TRAPS;
            }
            break;
        //*:**********************************************
        //*:* Skill - Tumble
        //*:**********************************************
        case SPELL_I_LEAPS_AND_BOUNDS:
            iSkill = SKILL_TUMBLE;
            iBonus = 4;
            break;
        //*:**********************************************
        //*:* Skill - Use Magic Device
        //*:**********************************************
        case SPELL_GR_MAGIC_SAVANT:
            iSkill = SKILL_USE_MAGIC_DEVICE;
            iBonus = 4;
            break;
        //*:**********************************************
        //*:* Skill - Intimidate
        //*:**********************************************
        case SPELL_GR_TOWERING_OAK:
            iVisual = VFX_IMP_MAGBLUE;
            iSkill  = SKILL_INTIMIDATE;
            break;
        //*:**********************************************
        //*:* Skills - Intimidate, Persuade, Bluff
        //*:**********************************************
        case SPELL_I_BEGUILING_INFLUENCE:
        case SPELL_GR_INSIDIOUS_INSIGHT:
            iBonus3 = (spInfo.iSpellID==SPELL_I_BEGUILING_INFLUENCE ? 6 : 10);
            iSkill3 = SKILL_INTIMIDATE;
        //*:**********************************************
        //*:* Skills - Persuade, Bluff
        //*:**********************************************
        case SPELL_GR_MASK_OF_THE_IDEAL:
            iBonus2 = (spInfo.iSpellID==SPELL_GR_MASK_OF_THE_IDEAL ? 4 : iBonus3);
            iSkill2 = SKILL_PERSUADE;
        //*:**********************************************
        //*:* Skill - Bluff
        //*:**********************************************
        case SPELL_GR_GLIBNESS:
        case SPELL_GR_SERENE_VISAGE:
            iSkill = SKILL_BLUFF;
            if(iBonus3>-1) iBonus = iBonus3;
            else if(iBonus2>-1) iBonus = iBonus2;
            if(iBonus==10 && spInfo.iSpellID!=SPELL_GR_INSIDIOUS_INSIGHT) {
                iBonus = (spInfo.iSpellID==SPELL_GR_GLIBNESS ? 30 : MinInt(20, MaxInt(0, spInfo.iCasterLevel/2)));
            }
            break;
        //*:**********************************************
        //*:* Skill - Pick Pocket (Sleight of Hand)
        //*:**********************************************
        case SPELL_GR_STICKY_FINGERS:
            iSkill = SKILL_PICK_POCKET;
            break;
        //*:**********************************************
        //*:* Skills - Search, Disable Trap, Hide, Move Silently
        //*:**********************************************
        case SPELLABILITY_DIVINE_TRICKERY:
        case SPELLABILITY_GR_HALFLING_DOMAIN_POWER:
            bSupernatural = TRUE;
            iBonus = (spInfo.iSpellID==SPELLABILITY_DIVINE_TRICKERY ? spInfo.iCasterLevel/2 + 1 : MaxInt(1, GetAbilityModifier(ABILITY_CHARISMA)));
        case SPELLABILITY_ROGUES_CUNNING:
            iVisual = (spInfo.iSpellID==SPELLABILITY_GR_HALFLING_DOMAIN_POWER ? VFX_IMP_DEATH : VFX_IMP_MAGICAL_VISION);
            iBonus7 = iBonus;
            iSkill7 = (spInfo.iSpellID!=SPELLABILITY_ROGUES_CUNNING ? SKILL_PERSUADE : SKILL_SET_TRAP);
            iBonus6 = iBonus;
            iSkill6 = SKILL_HIDE;
            iBonus5 = iBonus;
            iSkill5 = SKILL_PICK_POCKET;
            iBonus4 = (spInfo.iSpellID==SPELLABILITY_ROGUES_CUNNING ? 5 : iBonus);
            iSkill4 = SKILL_OPEN_LOCK;
            iBonus3 = iBonus;
            iSkill3 = SKILL_SEARCH;
            iBonus2 = iBonus;
            iSkill2 = SKILL_DISABLE_TRAP;
        //*:**********************************************
        //*:* Skill - Move Silently
        //*:**********************************************
        case SPELL_GR_RABBIT_FEET:
            iSkill = SKILL_MOVE_SILENTLY;
            if(spInfo.iSpellID==SPELL_GR_RABBIT_FEET) {
                iBonus = MinInt(18, spInfo.iCasterLevel*2);
            }
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
            fRange *= 2;
            switch(spInfo.iSpellID) {
                case SPELL_MASS_CAMOFLAGE:
                    iAOEType = AOE_MOB_MASS_CAMOFLAGE_WIDE;
                    sAOEType = AOE_TYPE_MASS_CAMOFLAGE_WIDE;
                    break;
            }
        }
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
    effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
    effect eAOE;
    if(bHasAOE) {
        eAOE = GREffectAreaOfEffect(iAOEType, "", "", "", sAOEType);
    }

    effect eVis     = EffectVisualEffect(iVisual);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSkill1  = EffectSkillIncrease(iSkill, iBonus);
    effect eSkill2, eSkill3, eSkill4, eSkill5, eSkill6, eSkill7;
    effect eStr     = EffectAbilityIncrease(ABILITY_STRENGTH, 2);
    effect eDex     = EffectAbilityIncrease(ABILITY_DEXTERITY, iBonus);

    effect eLink    = eSkill1;
    eLink = EffectLinkEffects(eSkill1, eDur);

    AutoDebugString("Building linked effect list");
    if(bHasAOE) eLink = EffectLinkEffects(eLink, eAOE);
    if(spInfo.iSpellID==SPELL_GR_TOWERING_OAK) eLink = EffectLinkEffects(eLink, eStr);
    if(spInfo.iSpellID==SPELL_I_LEAPS_AND_BOUNDS) eLink = EffectLinkEffects(eLink, eDex);

    if(iBonus2>0) {
        eSkill2 = EffectSkillIncrease(iSkill2, iBonus2);
        eLink = EffectLinkEffects(eLink, eSkill2);
    }
    if(iBonus3>0) {
        eSkill3 = EffectSkillIncrease(iSkill3, iBonus3);
        eLink = EffectLinkEffects(eLink, eSkill3);
    }
    if(iBonus4>0) {
        eSkill4 = EffectSkillIncrease(iSkill4, iBonus4);
        eLink = EffectLinkEffects(eLink, eSkill4);
    }
    if(iBonus5>0) {
        eSkill5 = EffectSkillIncrease(iSkill5, iBonus5);
        eLink = EffectLinkEffects(eLink, eSkill5);
    }
    if(iBonus6>0) {
        eSkill6 = EffectSkillIncrease(iSkill6, iBonus6);
        eLink = EffectLinkEffects(eLink, eSkill6);
    }
    if(iBonus7>0) {
        eSkill7 = EffectSkillIncrease(iSkill7, iBonus7);
        eLink = EffectLinkEffects(eLink, eSkill7);
    }

    if(bSupernatural) eLink = SupernaturalEffect(eLink);


    //*:**********************************************
    //*:* Insidious Insight
    //*:* While we can't make it versus a specific
    //*:* creature, we can come close
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_GR_INSIDIOUS_INSIGHT) {
        if(!GRGetIsLiving(spInfo.oTarget)) {
            //*:**********************************************
            //*:* Remove spell info from caster & exit
            //*:**********************************************
            if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
            GRClearSpellInfo(spInfo.iSpellID, oCaster);
            return;
        }

        eLink = VersusRacialTypeEffect(eLink, GRGetRacialType(spInfo.oTarget));
        eLink = VersusAlignmentEffect(eLink, GetAlignmentLawChaos(spInfo.oTarget), GetAlignmentGoodEvil(spInfo.oTarget));
        spInfo.oTarget = oCaster; // effect gets applied to caster not target
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    AutoDebugString("Applying effects");
    if(bMultiTarget) {
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        if(bHasAOE) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, oCaster);
            object oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
            GRSetAOESpellId(spInfo.iSpellID, oAOE);
            GRSetSpellInfo(spInfo, oAOE);
        }
    }

    AutoDebugString("Entering loop");
    if(GetIsObjectValid(spInfo.oTarget)) {
        spInfo.oTarget = (bMultiTarget ? GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget) : spInfo.oTarget);
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster)) {
                AutoDebugString("Target is " + GetName(spInfo.oTarget));
                AutoDebugString("bMultiTarget is " + GRBooleanToString(bMultiTarget));
                GRPreventSkillBonusStacking(spInfo.iSpellID, spInfo.oTarget);

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(iVisDurType, eVis, spInfo.oTarget, fDuration);
                GRApplyEffectToObject(iDurationType, eLink, spInfo.oTarget, fDuration);

            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
