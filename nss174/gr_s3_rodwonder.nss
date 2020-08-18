//*:**************************************************************************
//*:*  GR_S3_RODWONDER.NSS
//*:**************************************************************************
//*:* Rod of Wonder (X0_S2_RODWONDER) Copyright (c) 2002 Floodgate Entertainment
//*:* Created By: Naomi Novik  Created On: 11/25/2002
//*:**************************************************************************
//*:* Updated On: December 10, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* TEMPORARY CONSTANTS
//*:**************************************************************************
const int SPELL_GEM_SPRAY = 504;
const int SPELL_BUTTERFLY_SPRAY = 505;

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
//*:* Function Prototypes
//*:**************************************************************************
// Nothing happens message
void DoNothing(object oCaster);

// Windstorm-force gust of wind effect -- knocks down everyone in the area
void DoWindstorm(location lTarget);

// Give short-term premonition (d4 rounds & up to d4*5 hp damage absorbed)
void DoDetectThoughts(object oCaster);

// Summon a penguin, cow, or rat
void DoSillySummon(object oTarget);

// Do a blindness spell on all in the given radius of a cone for the given
// number of rounds in duration.
void DoBlindnessEffect(object oCaster, location lTarget, float fRadius, int nDuration);

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    spInfo.oTarget = GetAttemptedSpellTarget();

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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    object oCastingObject = CreateObject(OBJECT_TYPE_PLACEABLE, "x0_rodwonder", GetLocation(oCaster));

    int iPercentRoll = d100();

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
    //*:* list effect declarations here

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* All the random effects

    //*:*AutoDebugString("Rod iPercentRoll: " + IntToString(iPercentRoll));

    //*:* 1 - 5
    if(iPercentRoll < 6) { // slow target for 10 rounds - (Will DC 15 negates)
        effect eSlow = EffectSlow();
        if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, 15)) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, spInfo.oTarget, GRGetDuration(10));
        }
    //*:* 6 - 10
    } else if(iPercentRoll < 11) { // faerie fire on target, DC 11
        int iSpellID = SPELL_GR_FAERIE_FIRE;
        AssignCommand(oCastingObject, ActionCastSpellAtObject(iSpellID, spInfo.oTarget, METAMAGIC_NONE, TRUE, 11, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
    //*:* 11 - 15
    } else if(iPercentRoll < 16) { // delude wielder into thinking it's another effect
        int iFakeSpellID;
        effect eFakeEffect;
        if(Random(2) == 0) {
            iFakeSpellID = SPELL_FIREBALL;
            eFakeEffect = EffectVisualEffect(VFX_FNF_FIREBALL);
        } else {
            iFakeSpellID  = SPELL_LIGHTNING_BOLT;
            eFakeEffect = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
        }

        AssignCommand(oCastingObject, ActionCastFakeSpellAtObject(iFakeSpellID, spInfo.oTarget));

        if(iFakeSpellID == SPELL_LIGHTNING_BOLT) {
                /*** NWN1 SPECIFIC ***/
            effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, OBJECT_SELF, BODY_NODE_HAND);
                /*** END NWN1 SPECIFIC ***/
            AssignCommand(oCastingObject,
                ActionDoCommand(GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, spInfo.oTarget, 1.0)));
        }

        AssignCommand(oCastingObject,
            ActionDoCommand(GRApplyEffectToObject(DURATION_TYPE_INSTANT, eFakeEffect, spInfo.oTarget)));
    //*:* 16 - 20
    } else if(iPercentRoll < 21) { // windstorm-force gust of wind
        //*:* knock down everyone in the area and play a wind sound
        DoWindstorm(spInfo.lTarget);
    //*:* 21 - 25
    } else if(iPercentRoll < 26) { // detect thoughts -- give short-term premonition
        DoDetectThoughts(oCaster);
    //*:* 26 - 30
    } else if(iPercentRoll < 31) { // stinking cloud, 30 ft range
        effect eAOE = GREffectAreaOfEffect(AOE_PER_FOGSTINK);
        effect eImpact = EffectVisualEffect(259);
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, GRGetDuration(d4()));
    //*:* 31 - 33
    } else if(iPercentRoll < 34) { // heavy rain falls briefly
        PlaySound("as_wt_thundercl3");
        object oArea = GetArea(oCaster);
        SetWeather(oArea, WEATHER_RAIN);
        DelayCommand(GRGetDuration(5), SetWeather(oArea, WEATHER_USE_AREA_SETTINGS));
    //*:* 34 - 36
    } else if(iPercentRoll < 37) { // summon penguin, rat, or cow
        DoSillySummon(spInfo.oTarget);
    //*:* 37 - 43
    } else if(iPercentRoll < 44) { // lightning bolt
        int iDamage = d6(6);
        SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BOLT_LIGHTNING));

        iDamage = GetReflexAdjustedDamage(iDamage, spInfo.oTarget, 13, SAVING_THROW_TYPE_ELECTRICITY);

        //Make a ranged touch attack
        if (iDamage > 0 && TouchAttackRanged(spInfo.oTarget) > 0) {
                /*** END NWN1 SPECIFIC ***/
            effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oCaster, BODY_NODE_HAND);
                /*** END NWN1 SPECIFIC ***/
            effect eVis  = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
            effect eBolt = EffectDamage(iDamage, DAMAGE_TYPE_ELECTRICAL);

            //Apply the VFX impact and effects
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, spInfo.oTarget, 1.7);
        }
    //*:* 44 - 46
    } else if(iPercentRoll < 47) { // polymorph caster into a penguin
        effect ePoly = EffectPolymorph(POLYMORPH_TYPE_PENGUIN);
        effect eImp =  EffectVisualEffect(VFX_IMP_POLYMORPH);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, oCaster);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoly, oCaster, GRGetDuration(d4()));
        SetCustomToken(0, GetName(oCaster));
        FloatingTextStrRefOnCreature(9266, oCaster);
    //*:* 47 - 49   Butterflies
    } else if(iPercentRoll < 50) {
       ActionCastSpellAtObject(505, spInfo.oTarget, METAMAGIC_ANY, TRUE);
       ActionDoCommand(SetCommandable(TRUE));
       SetCommandable(FALSE);
    //*:* 50 - 53
    } else if(iPercentRoll < 54) { // enlarge target
        int iSpellID = SPELL_ENLARGE_PERSON;
        AssignCommand(oCastingObject, ActionCastSpellAtObject(iSpellID, spInfo.oTarget, METAMAGIC_NONE, TRUE, 11, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
    //*:* 54 - 58
    } else if(iPercentRoll < 59) { // darkness around target
        effect eAOE = GREffectAreaOfEffect(AOE_PER_DARKNESS);
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spInfo.lTarget, GRGetDuration(d4()));
    //*:* 59 - 62
    } else if(iPercentRoll < 63) { // grass grows around caster
        effect eAOE = GREffectAreaOfEffect(AOE_PER_ENTANGLE);
        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, GetLocation(oCaster), GRGetDuration(d6()));
    //*:* 63 - 65
    } else if(iPercentRoll < 66) { // turn target ethereal
        effect eVis = EffectVisualEffect(VFX_DUR_ETHEREAL_VISAGE);
        effect eDam = EffectDamageReduction(20, DAMAGE_POWER_PLUS_THREE);
        effect eSpell = EffectSpellLevelAbsorption(2);
        effect eConceal = EffectConcealment(25);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

        effect eLink = EffectLinkEffects(eDam, eVis);
        eLink = EffectLinkEffects(eLink, eSpell);
        eLink = EffectLinkEffects(eLink, eDur);
        eLink = EffectLinkEffects(eLink, eConceal);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, GRGetDuration(d4()));
    //*:* 66 - 69
    } else if(iPercentRoll < 70) { // reduce wielder
        int iSpellID = SPELL_GR_REDUCE;
        AssignCommand(oCastingObject, ActionCastSpellAtObject(iSpellID, oCaster, METAMAGIC_NONE, TRUE, 13, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
    //*:* 70 - 76
    } else if(iPercentRoll < 77) { // fireball
        AssignCommand(oCastingObject, ActionCastSpellAtObject(SPELL_FIREBALL, spInfo.oTarget, METAMAGIC_NONE, TRUE, 0,
                                    PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
    //*:* 77 - 79
    } else if(iPercentRoll < 80) { // polymorph target into a chicken
        effect ePoly = EffectPolymorph(POLYMORPH_TYPE_CHICKEN);
        effect eImp =  EffectVisualEffect(VFX_IMP_POLYMORPH);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoly, spInfo.oTarget, GRGetDuration(d4()));
        SetCustomToken(0, GetName(spInfo.oTarget));
        FloatingTextStrRefOnCreature( 9265, spInfo.oTarget);
    //*:* 80 - 84
    } else if (iPercentRoll < 85) { // wielder goes invisible
        effect eInvis = EffectInvisibility(INVISIBILITY_TYPE_NORMAL);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects(eInvis, eDur);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, GRGetDuration(d6()));
    //*:* 85 - 87
    } else if(iPercentRoll < 88) { // leaves grow from target
        // - long-term pixie dust visual effect on caster
        int nEffectPixieDust = 321;
        effect eDust =  EffectVisualEffect(nEffectPixieDust);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDust, oCaster, GRGetDuration(d10(3) + 10));
    //*:* 88 - 90
    } else if(iPercentRoll < 91) { // 10-40 gems fly out
        ActionCastSpellAtObject(SPELL_GEM_SPRAY, spInfo.oTarget, METAMAGIC_ANY, TRUE);
        ActionDoCommand(SetCommandable(TRUE));
        SetCommandable(FALSE);
    //*:* 91 - 95
    } else if(iPercentRoll < 96) { // shimmering colors blind
        ActionCastFakeSpellAtObject(SPELL_PRISMATIC_SPRAY, spInfo.oTarget, PROJECTILE_PATH_TYPE_DEFAULT);
        DoBlindnessEffect(oCaster, spInfo.lTarget, 20.0, d4());
    //*:* 96 - 97
    } else if(iPercentRoll < 98) { // wielder turns blue or purple
        effect eVis;
        SetCustomToken(0, GetName(oCaster));
        if (Random(2) == 0) {
            eVis = EffectVisualEffect(VFX_DUR_GHOSTLY_VISAGE);
            FloatingTextStrRefOnCreature(8861, oCaster);
        } else {
            eVis = EffectVisualEffect(VFX_DUR_ETHEREAL_VISAGE);
            FloatingTextStrRefOnCreature(8860, oCaster);
        }
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oCaster, GRGetDuration(3, DUR_TYPE_TURNS));
    //*:* 98 - 100
    } else  { // flesh to stone or stone to flesh
        int iSpell = SPELL_FLESH_TO_STONE;
        effect eEff = GetFirstEffect(spInfo.oTarget);
        while(GetIsEffectValid(eEff) && GetEffectType(eEff)!=EFFECT_TYPE_PETRIFY)
            eEff = GetNextEffect(spInfo.oTarget);

        if(GetIsEffectValid(eEff) && GetEffectType(eEff)==EFFECT_TYPE_PETRIFY)
            iSpell = SPELL_STONE_TO_FLESH; // if already stone

        AssignCommand(oCastingObject, ActionCastSpellAtObject(iSpell, spInfo.oTarget, METAMAGIC_NONE, TRUE, 0,
                                    PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
    }

    DestroyObject(oCastingObject, 6.0);

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);

}



/**********************************************************************
 * FUNCTION DEFINITIONS
 * All the individual effect functions are below.
 ***********************************************************/

// Nothing happens message
void DoNothing(object oCaster) {
    FloatingTextStrRefOnCreature(8848, oCaster);
}


// Windstorm-force gust of wind effect
void DoWindstorm(location lTarget) {
    // Play a low thundering sound
    PlaySound("as_wt_thunderds4");

    // Capture the first target object in the shape.
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE |
                                           OBJECT_TYPE_DOOR | OBJECT_TYPE_AREA_OF_EFFECT);

    // Cycle through the targets within the spell shape
    while (GetIsObjectValid(oTarget)) {

        // Play a random sound
        switch (Random(5)) {
            case 0: AssignCommand(oTarget, PlaySound("as_wt_gustchasm1")); break;
            case 1: AssignCommand(oTarget, PlaySound("as_wt_gustcavrn1")); break;
            case 2: AssignCommand(oTarget, PlaySound("as_wt_gustgrass1")); break;
            case 3: AssignCommand(oTarget, PlaySound("as_wt_guststrng1")); break;
            case 4: AssignCommand(oTarget, PlaySound("fs_floatair")); break;
        }

        // Area-of-effect spells that are affected by Gust of Wind get blown away
        if(GetObjectType(oTarget) == OBJECT_TYPE_AREA_OF_EFFECT && GRAOEAffectedByGoW(oTarget)) {
            DestroyObject(oTarget);
        }

        // * unlocked doors will reverse their open state
        else if (GetObjectType(oTarget) == OBJECT_TYPE_DOOR) {
            if (!GetLocked(oTarget)) {
                if (GetIsOpen(oTarget) == FALSE)
                    AssignCommand(oTarget, ActionOpenDoor(oTarget));
                else
                    AssignCommand(oTarget, ActionCloseDoor(oTarget));
            }
        }

        // creatures will get knocked down, tough fort saving throw
        // to resist.
        else if (GetObjectType(oTarget) == OBJECT_TYPE_CREATURE) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, oTarget, 15)) {
                effect eKnockdown = EffectKnockdown();
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oTarget, GRGetDuration(1));
            }
        }

        // Get the next target within the spell shape.
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_HUGE, lTarget, TRUE, OBJECT_TYPE_CREATURE |
                                       OBJECT_TYPE_DOOR | OBJECT_TYPE_AREA_OF_EFFECT);
    }

}


// Give premonition for a few rounds, up to d4*5 hp
void DoDetectThoughts(object oCaster)
{
    int nRounds = d4();
    int nLimit = nRounds * 5;

    effect ePrem = EffectDamageReduction(30, DAMAGE_POWER_PLUS_FIVE, nLimit);
    effect eVis = EffectVisualEffect(VFX_DUR_PROT_PREMONITION);

    //Link the visual and the damage reduction effect
    effect eLink = EffectLinkEffects(ePrem, eVis);

    //Fire cast spell at event for the specified target
    SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_PREMONITION, FALSE));

    //Apply the linked effect
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, GRGetDuration(nRounds));
}

// Summon something extremely silly (rats will be hostile to caster!)
void DoSillySummon(object oTarget)
{
    location lTarget = GetOppositeLocation(oTarget);
    int nSummon = d100();
    string sSummon = "";
    if (nSummon < 26) {
        sSummon = "x0_penguin001";
    } else if (nSummon < 51) {
        sSummon = "nw_cow";
    } else {
        sSummon = "nw_rat001";
    }

    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1), lTarget);

    CreateObject(OBJECT_TYPE_CREATURE, sSummon, lTarget, TRUE);
}


// Do a blindness spell on all in the given radius of a cone for the given
// number of rounds in duration.
void DoBlindnessEffect(object oCaster, location lTarget, float fRadius, int nDuration)
{
    vector vOrigin = GetPosition(oCaster);

    effect eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectBlindness();
    eLink = EffectLinkEffects(eLink, eDur);

    object oTarget = GetFirstObjectInShape(SHAPE_CONE, fRadius, lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin);

    while (GetIsObjectValid(oTarget)) {
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF,
                    SPELL_BLINDNESS_AND_DEAFNESS));

        //Do SR check
        if(!GRGetSpellResisted(OBJECT_SELF, oTarget)) {
            // Make Fortitude save to negate
            if(!GRGetSaveResult(SAVING_THROW_FORT, oTarget, 13)) {
                //Apply visual and effects
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget,
                                    GRGetDuration(nDuration));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
        }
        oTarget = GetNextObjectInShape(SHAPE_CONE, fRadius, lTarget, TRUE, OBJECT_TYPE_CREATURE, vOrigin);
    }
}
//*:**************************************************************************
//*:**************************************************************************
