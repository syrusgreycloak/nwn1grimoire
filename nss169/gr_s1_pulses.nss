//*:**************************************************************************
//*:*  SPELL_TEMPLATE.NSS
//*:**************************************************************************
//*:*
//*:* Blank template for spell scripts
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On:
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
    int     iNumDice          = spInfo.iCasterLevel;
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;
    spInfo.iDC = 10 + spInfo.iCasterLevel;

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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    int     iVisual         = VFX_IMP_NEGATIVE_ENERGY;
    int     iImpact         = VFX_IMP_PULSE_NEGATIVE;
    int     iDamageType     = -1;
    int     iAbilityType    = -1;
    int     iDurationType   = DURATION_TYPE_INSTANT;
    int     iSaveType       = SAVING_THROW_TYPE_NEGATIVE;
    int     iSavingThrow    = SAVING_THROW_FORT;
    int     iSpellTarget    = SPELL_TARGET_SELECTIVEHOSTILE;
    int     iDisease        = DISEASE_SOLDIER_SHAKES;
    int     bDamageBypass   = FALSE;
    int     iPoison;
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
    effect eVis;
    effect eVis2;
    effect eHowl;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);;
    effect eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eImpact;
    effect eLightning;
    effect eDam;


    switch(spInfo.iSpellID) {
        case 281: // Drown Pulse
            iVisual = VFX_IMP_FROST_S;
            iImpact = VFX_IMP_PULSE_WATER;
            iSaveType = SAVING_THROW_TYPE_NONE;
            iDamage = GetCurrentHitPoints(oCaster)/2;
            if(iDamage==0) iDamage = 1;
            spInfo.iDC = 20;
            eHowl = EffectDeath();
            break;
        case 298: // Disease Pulse
            switch(GRGetRacialType(spInfo.oTarget)) {
                case RACIAL_TYPE_VERMIN:
                    iDisease = DISEASE_VERMIN_MADNESS;
                    break;
                case RACIAL_TYPE_UNDEAD:
                    iDisease = DISEASE_FILTH_FEVER;
                    break;
                case RACIAL_TYPE_OUTSIDER:
                    iDisease = DISEASE_DEMON_FEVER;
                    break;
                case RACIAL_TYPE_MAGICAL_BEAST:
                    iDisease = DISEASE_SOLDIER_SHAKES;
                    break;
                case RACIAL_TYPE_ABERRATION:
                    iDisease = DISEASE_BLINDING_SICKNESS;
                    break;
                default:
                    iDisease = DISEASE_MINDFIRE;
                    break;
            }
        case 282: // Spores Pulse
            iVisual = -1;
            iImpact = VFX_IMP_PULSE_NATURE;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
            bDamageBypass = TRUE;
                // diseases don't get separate save (save occurs when applied)
                // so we are setting it to run through the damaging (reflex 1/2) section
                // and bypassing the damage rolls/reflex save check by means of the boolean
            eHowl = EffectDisease(iDisease);
            break;
        case 283: // Whirlwind Pulse
            iVisual = -1;
            iImpact = VFX_IMP_PULSE_WIND;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
            iSavingThrow = SAVING_THROW_REFLEX;
            iSaveType = SAVING_THROW_TYPE_NONE;
            iDurationType = DURATION_TYPE_TEMPORARY;
            spInfo.iDC = 14;
            iNumDice = spInfo.iCasterLevel/2;
            iDamage = GRGetMetamagicAdjustedDamage(3, iNumDice, METAMAGIC_NONE, 0);
            fDuration = GRGetDuration(2);
            eHowl = EffectKnockdown();
            eDam = EffectDamage(iDamage, DAMAGE_TYPE_SLASHING);
            break;
        case 284: // Fire Pulse
            iVisual = VFX_IMP_FLAME_S;
            iImpact = VFX_IMP_PULSE_FIRE;
            iSaveType = SAVING_THROW_TYPE_FIRE;
            iDamageType = DAMAGE_TYPE_FIRE;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
            break;
        case 285: // Electric Pulse
            iVisual = VFX_IMP_LIGHTNING_S;
            iImpact = VFX_IMP_PULSE_COLD;
            iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
                /*** NWN1 SPECIFIC ***/
            eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oCaster, BODY_NODE_CHEST);
                /*** END NWN1 SPECIFIC ***/
            break;
        case 286: // Cold Pulse
            iVisual = VFX_IMP_FROST_S;
            iImpact = VFX_IMP_PULSE_COLD;
            iSaveType = SAVING_THROW_TYPE_COLD;
            iDamageType = DAMAGE_TYPE_COLD;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
            break;
        case 287: // Negative Pulse
            iSaveType = SAVING_THROW_TYPE_NEGATIVE;
            eVis2 = EffectVisualEffect(VFX_IMP_HEALING_M);
            iDieType = 4;
            iDamageType = DAMAGE_TYPE_NEGATIVE;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
            break;
        case 288: // Holy/Healing Pulse
            iVisual = VFX_IMP_SUNSTRIKE;
            iImpact = VFX_IMP_PULSE_HOLY;
            iSaveType = SAVING_THROW_TYPE_DIVINE;
            eVis2 = EffectVisualEffect(VFX_IMP_HEALING_M);
            iDieType = 4;
            iDamageType = DAMAGE_TYPE_DIVINE;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
            break;
        case 289: // Death Pulse
            iVisual = VFX_IMP_DEATH;
            iSaveType = SAVING_THROW_TYPE_DEATH;
            eHowl = EffectDeath();
            break;
        case 290: // Level Drain Pulse
            iSaveType = SAVING_THROW_TYPE_NEGATIVE;
            iDurationType = DURATION_TYPE_PERMANENT;
            eHowl = EffectNegativeLevel(1);
            break;
        case 291: // Intelligence Drain Pulse
            iAbilityType = ABILITY_INTELLIGENCE;
            break;
        case 292: // Charisma Drain Pulse
            iAbilityType = ABILITY_CHARISMA;
            break;
        case 293: // Constitution Drain Pulse
            iAbilityType = ABILITY_CONSTITUTION;
            break;
        case 294: // Dexterity Drain Pulse
            iAbilityType = ABILITY_DEXTERITY;
            break;
        case 295: // Strength Drain Pulse
            iAbilityType = ABILITY_STRENGTH;
            break;
        case 296: // Wisdom Drain Pulse
            iAbilityType = ABILITY_WISDOM;
            break;
        case 297: // Poison Pulse
            iVisual = -1;
            iImpact = VFX_IMP_PULSE_NATURE;
            iSpellTarget = SPELL_TARGET_STANDARDHOSTILE;
            iPoison = GRGetPoisonType(spInfo.iCasterLevel, oCaster);
            bDamageBypass = TRUE;
                // Poisons don't get separate save (save occurs when applied)
                // so we are setting it to run through the damaging (reflex 1/2) section
                // and bypassing the damage rolls/reflex save check by means of the boolean
            eHowl = EffectPoison(iPoison);
            break;
    }

    if(iAbilityType!=-1) {
        iSaveType = SAVING_THROW_TYPE_NEGATIVE;
        iDurationType = DURATION_TYPE_PERMANENT;
        iDamage = spInfo.iCasterLevel/5;
        if(iDamage==0) iDamage = 1;
        eHowl = EffectAbilityDecrease(iAbilityType, iDamage);
        eHowl = SupernaturalEffect(eHowl);
    }

    if(iVisual!=-1)
        eVis = EffectVisualEffect(iVisual);

    eImpact = EffectVisualEffect(iImpact);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID!=285) {
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCaster);
    } else {
        DelayCommand(0.5, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oCaster));
    }

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, spInfo.lTarget);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, iSpellTarget, oCaster, NO_CASTER)) {
            // Conditional target checks
            if( (spInfo.iSpellID!=281 || (spInfo.iSpellID==281 && GRGetIsLiving(spInfo.oTarget) &&
                    GRGetRacialType(spInfo.oTarget)!=RACIAL_TYPE_ELEMENTAL)) &&
                (spInfo.iSpellID!=287 || (spInfo.iSpellID==287 && GRGetIsLiving(spInfo.oTarget))) &&
                (spInfo.iSpellID!=288 || (spInfo.iSpellID==288 && GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD))
            ) {

                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
                if(iDamageType!=-1 || bDamageBypass) {
                    if(!bDamageBypass) {  // compute damage if necessary
                        iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, METAMAGIC_NONE, 0);
                        iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType);
                        eHowl = EffectDamage(iDamage, iDamageType);
                    }
                    if(iDamage>0 || bDamageBypass) {
                        if(iVisual!=-1)
                            DelayCommand(fDelay-0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eHowl, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                        if(spInfo.iSpellID==285)  // Apply Lightning Beam for Electric Pulse
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, spInfo.oTarget, 0.5));
                    }
                } else if(!GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                    if(iVisual!=-1)
                        DelayCommand(fDelay-0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    if(iDurationType!=DURATION_TYPE_TEMPORARY) {
                        DelayCommand(fDelay, GRApplyEffectToObject(iDurationType, eHowl, spInfo.oTarget));
                    } else {
                        if(spInfo.iSpellID==283) {  // Whirlwind Pulse Damage
                            DelayCommand(fDelay-0.1, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                        }
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHowl, spInfo.oTarget, fDuration));
                    }
                }
            }
        } else if(spInfo.oTarget!=oCaster && (
                (spInfo.iSpellID==287 && GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster) &&
                    GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD) ||
                (spInfo.iSpellID==288 && GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster) &&
                    GRGetIsLiving(spInfo.oTarget) && !GRGetIsImmuneToMagicalHealing(spInfo.oTarget))
            )) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
                eHowl = EffectHeal(iDamage);
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spInfo.oTarget));
                DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, spInfo.oTarget));
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, spInfo.lTarget);
    }
    if(spInfo.iSpellID==281) { // Drown Pulse damages Caster 1/2 current hp
        eHowl = EffectDamage(iDamage);
        GRApplyEffectToObject(iDurationType, eHowl, oCaster);
    }

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
