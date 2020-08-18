//*:**************************************************************************
//*:*  GR_S0_RAYS.NSS
//*:**************************************************************************
//*:*
//*:* MASTER SCRIPT FOR THE VARIOUS "RAY OF" AND OTHER RAY SPELLS
//*:**************************************************************************
//*:* Flame Lash (NW_S0_FlmLash.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Nov 21, 2001
//*:* created by Bioware
//*:*
//*:* Ray of Enfeeblement [NW_S0_rayEnfeeb.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk Created On: Feb 2, 2001
//*:* 3.5 Player's Handbook (p. 269)
//*:*
//*:* Ray of Frost [NW_S0_RayFrost.nss] Copyright (c) 2000 Bioware Corp.
//*:* Created By: Preston Watamaniuk Created On: feb 4, 2001
//*:* 3.5 Player's Handbook (p. 269)
//*:*
//*:* Searing Light (nw_s0_SearLght.nss) Copyright (c) 2000 Bioware Corp.
//*:* Created By: Keith Soleski Created On: 02/05/2001
//*:* 3.5 Player's Handbook (p. 275)
//*:*
//*:* Negative Energy Ray [NW_S0_NegRay] Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Sept 13, 2001
//*:* Tome & Blood (p. 93)
//*:*
//*:* Electric Jolt [x0_s0_ElecJolt.nss] Copyright (c) 2002 Bioware Corp.
//*:* Created By: Brent  Created On: July 17 2002
//*:* Spell Compendium (p. 78)
//*:**************************************************************************
//*:*
//*:* Darkbolt                  Spell Compendium (p. 58)
//*:* Dartan's Shadow Bolt      SSRRI
//*:* Disrupt Undead            3.5 Player's Handbook (p. 223)
//*:* Disrupt Undead, Greater   Spell Compendium (p. 68)
//*:* Life Bolt                 Spell Compendium (p. 131)
//*:* Polar Ray                 3.5 Player's Handbook (p. 262)
//*:* Ray of Clumsiness         Spell Compendium (p. 166)
//*:* Ray of Deanimation        Spell Compendium (p. 166)
//*:* Ray of Entropy            Spell Compendium (p. 167)
//*:* Ray of Flame              Spell Compendium (p. 167)
//*:* Ray of Ice                Spell Compendium (p. 167)
//*:* Ray of Light              Spell Compendium (p. 167)
//*:* Ray of Stupidity          Spell Compendium (p. 167)
//*:* Ray of Weakness           Spell Compendium (p. 168)
//*:* Lesser Shadow Evocation: Ray of Frost
//*:* Lesser Shadow Evocation: Ray of Flame
//*:* Lesser Shadow Evocation: Ray of Ice
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: October 4, 2007
//*:**************************************************************************
//*:* Avasculate
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 6, 2009
//*:* Spell Compendium (p. 9)
//*:**************************************************************************
//*:* Updated On: January 6, 2009
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IC_MESSAGES"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************


//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType            = 0;
    int     iNumDice            = 0;
    int     iBonus              = 0;
    int     iDamage             = 0;
    int     iSecDamage          = 0;
    int     iDurAmount          = spInfo.iCasterLevel;
    int     iDurType            = DUR_TYPE_ROUNDS;
    int     iEnergyType = DAMAGE_TYPE_MAGICAL;

    int     bDamageSpell        = TRUE;
    int     bEnergySpell        = FALSE;
    int     bInstantSpell       = TRUE;
    int     bNoRangeTouch       = FALSE;
    int     bNoSave             = TRUE;
    int     bNoSR               = FALSE;
    int     bPassSpecialTarget  = TRUE;
    int     bSpecialEffect      = FALSE;

    int     iAbilityType        = -1;
    int     iVisualType         = -1;
    int     iBeamType           = -1;
    int     iDurVisType         = -1;
    int     iSavingThrow        = SAVING_THROW_NONE;
    int     iSaveType           = SAVING_THROW_TYPE_NONE;
    int     iSpellSaveType      = SPELL_SAVE_NONE;
    int     iSpellDurationType  = DURATION_TYPE_INSTANT;
    int     iSpecialDurationType= DURATION_TYPE_TEMPORARY;

    float   fDmgPercent         = 1.0f;
    int     bWillDisbelief      = FALSE;

    switch(spInfo.iSpellID) {
        case SPELL_GR_DARKBOLT:
            bInstantSpell = TRUE;
            bSpecialEffect = TRUE;
            iDieType = 8;
            iNumDice = 2*spInfo.iCasterLevel/2;
            if(iNumDice<2) iNumDice = 2;
            if(iNumDice>14) iNumDice = 14;
            iBeamType = VFX_BEAM_BLACK;
            iVisualType = VFX_IMP_NEGATIVE_ENERGY;
            /*** NWN1 SINGLE ***/ iDurVisType = VFX_DUR_MIND_AFFECTING_DISABLED;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_DAZE;
            break;
        case SPELL_GR_DARTAN_SBOLT:
            bInstantSpell = TRUE;
            iDieType = 6;
            iNumDice = MinInt(spInfo.iCasterLevel, 12);
            iBeamType = VFX_BEAM_BLACK;
            iVisualType = VFX_IMP_FROST_S;
            iSavingThrow = SAVING_THROW_FORT;
            iSpellSaveType = FORTITUDE_HALF;
            break;
        case SPELL_GR_DIMENSIONAL_ANCHOR:
            bDamageSpell = FALSE;
            bSpecialEffect = TRUE;
            iDurType = DUR_TYPE_TURNS;
            bNoSR = TRUE;
            iVisualType = VFX_IMP_ACID_S;
            /*** NWN1 SINGLE ***/ iDurVisType = VFX_DUR_PIXIEDUST;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SOOTHINGLIGHT;
            iBeamType = VFX_BEAM_DISINTEGRATE;
            break;
        case SPELL_GR_LIFE_BOLT:
            iDieType = 12;
            iNumDice = MinInt((spInfo.iCasterLevel+1)/2, 5);
            /*** NWN1 SINGLE ***/ iBeamType = VFX_BEAM_FIRE;
            //*** NWN2 SINGLE ***/ iBeamType = GRGetSpellSchoolBeam(spInfo.iSpellSchool);
            iVisualType = VFX_COM_HIT_DIVINE;
        case SPELL_GR_GREATER_DISRUPT_UNDEAD:
        case SPELL_GR_DISRUPT_UNDEAD:
            iDieType = (spInfo.iSpellID==SPELL_GR_DISRUPT_UNDEAD ? 6 : 8);
            iNumDice = (spInfo.iSpellID==SPELL_GR_DISRUPT_UNDEAD ? 1: MinInt(spInfo.iCasterLevel, 10));

            bPassSpecialTarget = (GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD);
            iEnergyType = DAMAGE_TYPE_POSITIVE;
            /*** NWN1 SPECIFIC ***/
                iBeamType = (spInfo.iSpellID==SPELL_GR_DISRUPT_UNDEAD && iBeamType==-1 ? VFX_BEAM_HOLY : VFX_BEAM_BLACK);
                iVisualType = (spInfo.iSpellID==SPELL_GR_DISRUPT_UNDEAD && iVisualType==-1 ? VFX_IMP_HEAD_HOLY : VFX_IMP_DIVINE_STRIKE_HOLY);
            /*** END NWN1 SPECIFIC ***/
            /*** NWN2 SPECIFIC ***
                iBeamType = VFX_BEAM_BLACK;
                iVisualType = GRGetSpellSchoolVisual(spInfo.iSpellSchool);
            /*** END NWN2 SPECIFIC ***/
            break;
        case SPELL_FLAME_LASH:
            bEnergySpell = TRUE;
            bNoRangeTouch = TRUE;
            iSpellSaveType = REFLEX_HALF;
            iSavingThrow = SAVING_THROW_REFLEX;
            iDieType = 6;
            iNumDice = MinInt(2+(MinInt(3, spInfo.iCasterLevel)-3)/3, 5);
            iVisualType = VFX_IMP_FLAME_S;
            break;
        case SPELL_NEGATIVE_ENERGY_RAY:
            iDieType = 6;
            iNumDice = MinInt((spInfo.iCasterLevel+1)/2, 5);
            iBeamType = VFX_BEAM_EVIL;
            iVisualType = VFX_IMP_NEGATIVE_ENERGY;
            iEnergyType = DAMAGE_TYPE_NEGATIVE;
            break;
        case SPELL_POLAR_RAY:
            bEnergySpell = TRUE;
            iDieType = 6;
            iNumDice = MinInt(spInfo.iCasterLevel, 25);
            iVisualType = VFX_IMP_FROST_L;
            break;
        case SPELL_GR_RAY_OF_DEANIMATION:
            bPassSpecialTarget = (GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_CONSTRUCT);
            bNoSR = TRUE;
            iDieType = 6;
            iNumDice = MinInt(spInfo.iCasterLevel, 15);
            iVisualType = VFX_IMP_NEGATIVE_ENERGY;
            iBeamType = VFX_BEAM_EVIL;
            break;
        case SPELL_GR_RAY_OF_CLUMSINESS:
        case SPELL_RAY_OF_ENFEEBLEMENT:
        case SPELL_GR_RAY_OF_STUPIDITY:
            bSpecialEffect = TRUE;
            bInstantSpell = FALSE;
            iSpellDurationType = DURATION_TYPE_TEMPORARY;
            iSavingThrow = SAVING_THROW_FORT;
            iSaveType = SAVING_THROW_TYPE_NEGATIVE;
            iSpellSaveType = FORTITUDE_NEGATES;
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_REDUCE_ABILITY_SCORE;
            /*** NWN1 SINGLE ***/ iDurVisType = VFX_DUR_CESSATE_NEGATIVE;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_RAY_ENFEEBLE;

            iDieType = 6;
            iNumDice = 1;
            iBonus = MinInt((spInfo.iCasterLevel+1)/2, 5);
            iDurType = DUR_TYPE_TURNS;

            if(spInfo.iSpellID==SPELL_GR_RAY_OF_CLUMSINESS) {
                iBeamType = VFX_BEAM_DISINTEGRATE;
                iAbilityType = ABILITY_DEXTERITY;
            } else if(spInfo.iSpellID==SPELL_RAY_OF_ENFEEBLEMENT) {
                /*** NWN1 SINGLE ***/ iBeamType = VFX_BEAM_ODD;
                //*** NWN2 SINGLE ***/ iBeamType = VFX_BEAM_NECROMANCY;
                iAbilityType = ABILITY_STRENGTH;
            } else if(spInfo.iSpellID==SPELL_GR_RAY_OF_STUPIDITY) {
                iBeamType = VFX_BEAM_HOLY;
                iAbilityType = ABILITY_INTELLIGENCE;
                iDieType = 4;
                iBonus = 1;
                iSpellDurationType = DURATION_TYPE_PERMANENT;
            }
            break;
        case SPELL_GR_RAY_OF_ENTROPY:
            bSpecialEffect = TRUE;
            bInstantSpell = FALSE;
            iBonus = 4;
            iDurType = DUR_TYPE_TURNS;
            iVisualType = VFX_IMP_REDUCE_ABILITY_SCORE;
            iDurVisType = VFX_DUR_CESSATE_NEGATIVE;
            iBeamType = VFX_BEAM_BLACK;
            iSpellDurationType = DURATION_TYPE_TEMPORARY;
            break;
        case SPELL_GR_LSE_RAY_OF_FLAME:
        case SPELL_GR_LSE_RAY_OF_ICE:
            fDmgPercent = 0.2f;
        case SPELL_GR_RAY_OF_FLAME:
        case SPELL_GR_RAY_OF_ICE:
            //bSpecialEffect = TRUE;  // have permanent effects applied after damage
            bEnergySpell = (spInfo.iSpellSchool!=SPELL_SCHOOL_ILLUSION);
            iDieType = 6;
            iNumDice = MinInt((spInfo.iCasterLevel+1)/2, 5);
            switch(spInfo.iSpellID) {
                case SPELL_GR_RAY_OF_FLAME:
                case SPELL_GR_LSE_RAY_OF_FLAME:
                    iVisualType = VFX_IMP_FLAME_S;
                    break;
                case SPELL_GR_RAY_OF_ICE:
                case SPELL_GR_LSE_RAY_OF_ICE:
                    iVisualType = VFX_IMP_FROST_S;
                    break;
            }
            break;
        case SPELL_GR_LSE_RAY_OF_FROST:
            fDmgPercent = 0.2f;
        case SPELL_ELECTRIC_JOLT:
        case SPELL_RAY_OF_FROST:
            bEnergySpell = (spInfo.iSpellSchool!=SPELL_SCHOOL_ILLUSION);
            iDieType = 3;
            iNumDice = 1;
            /*** NWN1 SINGLE ***/ iVisualType = (spInfo.iSpellID==SPELL_ELECTRIC_JOLT ? VFX_IMP_LIGHTNING_S : VFX_IMP_FROST_S);
            //*** NWN2 SINGLE ***/ iVisualType = (spInfo.iSpellID==SPELL_ELECTRIC_JOLT ? VFX_HIT_SPELL_LIGHTNING : VFX_HIT_SPELL_ICE);
            break;
        case SPELL_GR_RAY_OF_LIGHT:
            bSpecialEffect = TRUE;
            bInstantSpell = FALSE;
            bDamageSpell = FALSE;
            iDieType = 4;
            iNumDice = 1;
            iDurAmount = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
            iDurVisType = VFX_DUR_BLIND;
            iSpellDurationType = DURATION_TYPE_TEMPORARY;
            iBeamType = VFX_BEAM_SILENT_FIRE;
            break;
        case SPELL_GR_RAY_OF_WEAKNESS:
            bSpecialEffect = TRUE;
            bInstantSpell = FALSE;
            iBonus = 4;
            iDurType = DUR_TYPE_TURNS;
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_REDUCE_ABILITY_SCORE;
            /*** NWN1 SINGLE ***/ iDurVisType = VFX_DUR_CESSATE_NEGATIVE;
            //*** NWN2 SINGLE ***/ iDurVisType = VFX_DUR_SPELL_RAY_ENFEEBLE;
            iBeamType = VFX_BEAM_BLACK;
            iSpellDurationType = DURATION_TYPE_TEMPORARY;
            break;
        case SPELL_SEARING_LIGHT:
            iDieType = 8;
            iNumDice = MinInt(spInfo.iCasterLevel/2, 5);
            if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                iDieType = (GRGetIsLightSensitive(spInfo.oTarget) ? 8 : 6);
                iNumDice = MinInt(spInfo.iCasterLevel, 10);
            } else if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_CONSTRUCT || GetObjectType(spInfo.oTarget)!=OBJECT_TYPE_CREATURE) {
                iDieType = 6;
            }
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_SUNSTRIKE;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_HIT_SPELL_SEARING_LIGHT;
            iBeamType = VFX_BEAM_HOLY;
            iEnergyType = DAMAGE_TYPE_DIVINE;
            break;
        case SPELL_GR_SCORCHING_RAY:
            bEnergySpell = TRUE;
            iDieType = 6;
            iNumDice = MinInt(12,4*(spInfo.iCasterLevel-3)/4); // 4d6 * max of 3 rays = 12d6
            iVisualType = VFX_IMP_FLAME_M;
            break;
        case SPELL_AVASCULATE:
            bInstantSpell = TRUE;
            iBeamType = VFX_BEAM_BLACK;
            iVisualType = VFX_COM_BLOOD_LRG_RED;
            bSpecialEffect = TRUE;
            iDurAmount = 1;
            break;
    }

    int     iAttackResult = (bNoRangeTouch ? 1 : GRTouchAttackRanged(spInfo.oTarget));

    //*:**********************************************
    //*:* Set appropriate spell info
    //*:**********************************************

    if(bDamageSpell) spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    if(!bInstantSpell) spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int iSpellType  = SPELL_TYPE_GENERAL;

    if(bEnergySpell) {
        iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
        iSpellType      = GRGetEnergySpellType(iEnergyType);

        spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);
    }

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    if(!GRSpellhookAbortSpell()) return;
    spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    float   fDelay = 0.0;
    int     bHasRayDeflection = GetHasSpellEffect(SPELL_GR_RAY_DEFLECTION, spInfo.oTarget) && spInfo.iSpellID!=SPELL_FLAME_LASH;
    int     iDuration       = iNumDice;
    int     bHasAOE         = FALSE;
    string  sAOEType;

    if(bEnergySpell) {
        iVisualType = GRGetEnergyVisualType(iVisualType, iEnergyType);
        iBeamType   = GRGetEnergyBeamType(iEnergyType);
        iSaveType   = GRGetEnergySaveType(iEnergyType);
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fDuration *= 2;
        iDuration *= 2;
    }
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    if(bDamageSpell) {
        if(spInfo.iSpellID!=SPELL_AVASCULATE) iDamage = GRGetSpellDamageAmount(spInfo, iSpellSaveType, oCaster, iSaveType, fDelay)*iAttackResult;
        else iDamage = GetCurrentHitPoints(spInfo.oTarget)/2;
        if(GRGetSpellHasSecondaryDamage(spInfo)) {
            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                iDamage = iSecDamage;
            }
        }
        if(spInfo.iSpellID==SPELL_SCHOOL_ILLUSION) {
            if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster)) {
                iDamage = FloatToInt(iDamage*fDmgPercent);
                bWillDisbelief = TRUE;
            }
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImpVis, eDurVis, eDamage, eSecDamage, eSpecial, eRay, eLink, eAOE;

    eRay = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND, (iAttackResult==0) || bHasRayDeflection);
    if(iVisualType>-1) eImpVis = EffectVisualEffect(iVisualType);
    if(iDurVisType>-1) eDurVis = EffectVisualEffect(iDurVisType);

    if(bInstantSpell) {
        switch(spInfo.iSpellID) {
            case SPELL_NEGATIVE_ENERGY_RAY:
                if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) {
                    eDamage = EffectHeal(iDamage);
                    eImpVis = EffectVisualEffect(VFX_IMP_HEALING_M);
                }
                break;
            case SPELL_GR_RAY_OF_FLAME:
            case SPELL_GR_LSE_RAY_OF_FLAME:
                bHasAOE = TRUE;
                eAOE = GREffectAreaOfEffect(AOE_MOB_RAY_OF_FLAME);
                sAOEType = AOE_TYPE_RAY_OF_FLAME;
                eDamage = EffectDamage(iDamage, iEnergyType);
                break;
            case SPELL_GR_RAY_OF_ICE:
            case SPELL_GR_LSE_RAY_OF_ICE:
                bHasAOE = TRUE;
                eAOE = GREffectAreaOfEffect(AOE_MOB_RAY_OF_ICE);
                eAOE = EffectLinkEffects(eAOE, EffectCutsceneImmobilize());
                sAOEType = AOE_TYPE_RAY_OF_ICE;
                eDamage = EffectDamage(iDamage, iEnergyType);
                break;
            default:
                eDamage = EffectDamage(iDamage, iEnergyType);
                break;
        }

        eLink = EffectLinkEffects(eImpVis, eDamage);
        eLink = (iSecDamage>0 ? EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType)) : eLink);
    }

    if(bSpecialEffect) {
        switch(spInfo.iSpellID) {
            case SPELL_GR_DARKBOLT:
                eSpecial = EffectDazed();
                break;
            case SPELL_GR_DIMENSIONAL_ANCHOR:
                eDamage = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                break;
            case SPELL_GR_RAY_OF_CLUMSINESS:
            case SPELL_RAY_OF_ENFEEBLEMENT:
            case SPELL_GR_RAY_OF_STUPIDITY:
                eDamage = EffectAbilityDecrease(iAbilityType, iDamage);
                break;
            case SPELL_GR_RAY_OF_ENTROPY:
                eDamage     = EffectAbilityDecrease(ABILITY_STRENGTH, iDamage);
                eSecDamage  = EffectAbilityDecrease(ABILITY_CONSTITUTION, iDamage);
                eDamage     = EffectLinkEffects(eDamage, eSecDamage);
                eSecDamage  = EffectAbilityDecrease(ABILITY_DEXTERITY, iDamage);
                eDamage     = EffectLinkEffects(eDamage, eSecDamage);
                break;
            case SPELL_GR_RAY_OF_LIGHT:
                eDamage = EffectBlindness();
                break;
            case SPELL_GR_RAY_OF_WEAKNESS:
                eDamage = EffectAttackDecrease(iDamage);
                eDamage = EffectLinkEffects(eDamage, EffectMovementSpeedDecrease(33));
                break;
            case SPELL_AVASCULATE:
                eSpecial = EffectStunned();
                break;
        }
        if(!bInstantSpell) {
            eLink = EffectLinkEffects(eDurVis, eDamage);
        } else {
            eSpecial = EffectLinkEffects(eSpecial, eDurVis);
        }
    }


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spInfo.oTarget, 1.7);

    if(!bHasRayDeflection) {
        if(bPassSpecialTarget) {
            if(bNoRangeTouch || iAttackResult>0) {
                if(bNoSR || !GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    if(bNoSave || (!GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay) && !bDamageSpell) ||
                       iDamage>0) {
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spInfo.oTarget, 1.7);
                        if(iVisualType>-1 && !bInstantSpell) DelayCommand(1.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpVis, spInfo.oTarget));
                        DelayCommand(1.5f, GRApplyEffectToObject(iSpellDurationType, eLink, spInfo.oTarget, fDuration));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            DelayCommand(1.5f, GRDoIncendiarySlimeExplosion(spInfo.oTarget));
                        }
                        if(bInstantSpell && bSpecialEffect) {
                            if(spInfo.iSpellID!=SPELL_AVASCULATE || !GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH)) {
                                DelayCommand(1.5f, GRApplyEffectToObject(iSpecialDurationType, eSpecial, spInfo.oTarget, fDuration));
                            }
                        }
                        if(bHasAOE && !bWillDisbelief) {
                            if(!GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC, iSaveType)) {
                                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAOE, spInfo.oTarget, GRGetDuration(iDuration));

                                object oAOE = GRGetAOEOnObject(spInfo.oTarget, sAOEType, oCaster);
                                GRSetAOESpellId(spInfo.iSpellID, oAOE);
                                GRSetSpellInfo(spInfo, oAOE);
                            }
                        }
                    }
                }
            }
        }
    } else {
        if(GetIsPC(oCaster)) {
            SetLocalObject(GetModule(), "GR_RAYDEFLECT_CASTER", oCaster);
            SignalEvent(GetModule(), EventUserDefined(GR_MESSAGE_RAYDEFLECT_CASTER));
        }
        if(GetIsPC(spInfo.oTarget)) {
            SetLocalObject(GetModule(), "GR_RAYDEFLECT_TARGET", spInfo.oTarget);
            SignalEvent(GetModule(), EventUserDefined(GR_MESSAGE_RAYDEFLECT_TARGET));
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
