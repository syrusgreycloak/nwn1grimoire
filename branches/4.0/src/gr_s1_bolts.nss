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
//*:* Supporting functions
//*:**************************************************************************
void DoAbilityDrainBolt(object oTarget, int iAbilityType, int iDrainAmount) {

    effect eBolt = EffectAbilityDecrease(iAbilityType, iDrainAmount);
    eBolt = SupernaturalEffect(eBolt);
    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eBolt, oTarget);
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

    int     iDieType          = 6;
    int     iNumDice          = MaxInt(1, spInfo.iCasterLevel/2);
    int     iBonus            = 0;
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;
    spInfo.iDC = 10 + spInfo.iCasterLevel/2;

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
    float   fDelay          = 0.0;
    //*:* float   fRange          = FeetToMeters(15.0);
    int     iTouch;
    int     iVisual         = -1;
    int     iSpellID        = GetSpellId();
    int     iDurationType   = DURATION_TYPE_INSTANT;
    int     iDamagePower    = DAMAGE_POWER_NORMAL;
    int     iDamageType     = -1;
    int     iAbility        = -1;
    int     iDisease;
    int     iPoison;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect  eVis;
    effect  eBolt;
    effect  eDur;
    effect  eDurVis;
    effect  eLightning;

    switch(iSpellID) {
        case 205:  // Drain Charisma Bolt
            iAbility = ABILITY_CHARISMA;
            break;
        case 206:  // Drain Constitution Bolt
            iAbility = ABILITY_CONSTITUTION;
            break;
        case 207:  // Drain Dexterity Bolt
            iAbility = ABILITY_DEXTERITY;
            break;
        case 208:  // Drain Intelligence Bolt
            iAbility = ABILITY_INTELLIGENCE;
            break;
        case 209:  // Drain Strength Bolt
            iAbility = ABILITY_STRENGTH;
            break;
        case 210:  // Drain Wisdom Bolt
            iAbility = ABILITY_WISDOM;
            break;
        case 211:  // Acid Bolt
            iVisual = VFX_IMP_ACID_S;
            iDamageType = DAMAGE_TYPE_ACID;
            break;
        case 212:  // Charm Bolt
            iVisual = VFX_IMP_CHARM;
            iNumDice = GetScaledDuration((spInfo.iCasterLevel+1)/2, spInfo.oTarget);
            fDuration = GRGetDuration(iNumDice);
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectCharmed();
            eBolt = GetScaledEffect(eBolt, spInfo.oTarget);
            eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            eBolt = EffectLinkEffects(eBolt, eDur);
            break;
        case 213:  // Cold Bolt
            iVisual = VFX_IMP_FROST_S;
            iDamageType = DAMAGE_TYPE_COLD;
            break;
        case 214:  // Confuse Bolt
            iVisual = VFX_IMP_CONFUSION_S;
            iNumDice = (spInfo.iCasterLevel+1)/2;
            fDuration = GRGetDuration(iNumDice);
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectConfused();
            /*** NWN1 SINGLE ***/ eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
            //*** NWN2 SINGLE ***/ eDurVis = EffectVisualEffect(VFX_DUR_SPELL_CONFUSION);
            eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            eBolt = EffectLinkEffects(eBolt, eDur);
            eBolt = EffectLinkEffects(eBolt, eDurVis);
            break;
        case 215:  // Daze Bolt
            iNumDice = (spInfo.iCasterLevel+1)/2;
            fDuration = GRGetDuration(GetScaledDuration(iNumDice, spInfo.oTarget));
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectDazed();
            eBolt = GetScaledEffect(eBolt, spInfo.oTarget);
            /*** NWN1 SINGLE ***/ eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
            //*** NWN2 SINGLE ***/ eDurVis = EffectVisualEffect(VFX_DUR_SPELL_DAZE);
            eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            eBolt = EffectLinkEffects(eBolt, eDur);
            eBolt = EffectLinkEffects(eBolt, eDurVis);
            break;
        case 216:  // Death Bolt
            eBolt = EffectDeath();
            break;
        case 217:  // Disease Bolt
            iDurationType = DURATION_TYPE_PERMANENT;
            eBolt = EffectDisease(GRGetDiseaseType(spInfo.iCasterLevel));
            break;
        case 218:  // Dominate Bolt
            iVisual = VFX_IMP_DOMINATE_S;
            iNumDice = (spInfo.iCasterLevel+1)/2;
            fDuration = GRGetDuration(GetScaledDuration(iNumDice, spInfo.oTarget));
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectDominated();
            eBolt = GetScaledEffect(eBolt, spInfo.oTarget);
            eDurVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
            eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            eBolt = EffectLinkEffects(eBolt, eDur);
            eBolt = EffectLinkEffects(eBolt, eDurVis);
            break;
        case 219:  // Fire Bolt
            iVisual = VFX_IMP_FLAME_S;
            iDamageType = DAMAGE_TYPE_FIRE;
            break;
        case 220:  // Knockdown Bolt
            iVisual = VFX_IMP_SONIC;
            iDamageType = DAMAGE_TYPE_BLUDGEONING;
            iNumDice = 1;
            iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
            fDuration = GRGetDuration(3);
            break;
        case 221:  // Level Drain Bolt
            iVisual = VFX_IMP_NEGATIVE_ENERGY;
            iDurationType = DURATION_TYPE_PERMANENT;
            eBolt = EffectNegativeLevel(1);
            eBolt = SupernaturalEffect(eBolt);
            break;
        case 222:  // Lightning Bolt
            iVisual = VFX_IMP_LIGHTNING_S;
            iDamageType = DAMAGE_TYPE_ELECTRICAL;
            eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oCaster, BODY_NODE_HAND);
            fDuration = 1.8;
            break;
        case 223:  // Paralyze Bolt
            iNumDice = (spInfo.iCasterLevel+1)/2;
            fDuration = GRGetDuration(GetScaledDuration(iNumDice, spInfo.oTarget));
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectParalyze();
            eBolt = GetScaledEffect(eBolt, spInfo.oTarget);
            eDurVis = EffectVisualEffect(VFX_DUR_PARALYZED);
            eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            eBolt = EffectLinkEffects(eBolt, eDur);
            eBolt = EffectLinkEffects(eBolt, eDurVis);
            break;
        case 224:  // Poison Bolt
            iDurationType = DURATION_TYPE_PERMANENT;
            eBolt = EffectPoison(GRGetPoisonType(spInfo.iCasterLevel));
            break;
        case 225:  // Shards Bolt
            iDamageType = DAMAGE_TYPE_PIERCING;
            iDamagePower = DAMAGE_POWER_PLUS_ONE;
            break;
        case 226:  // Slow Bolt
            iVisual = VFX_IMP_SLOW;
            iNumDice = (spInfo.iCasterLevel+1)/2;
            fDuration = GRGetDuration(iNumDice);
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectSlow();
            eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            eBolt = EffectLinkEffects(eBolt, eDur);
            break;
        case 227:  // Stun Bolt
            iVisual = VFX_IMP_STUN;
            iNumDice = (spInfo.iCasterLevel+1)/2;
            fDuration = GRGetDuration(GetScaledDuration(iNumDice, spInfo.oTarget));
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectStunned();
            eBolt = GetScaledEffect(eBolt, spInfo.oTarget);
            eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
            eBolt = EffectLinkEffects(eBolt, eDur);
            break;
        case 228:  // Web Bolt
            iNumDice = (spInfo.iCasterLevel+1)/2;
            fDuration = GRGetDuration(iNumDice);
            iDurationType = DURATION_TYPE_TEMPORARY;
            eBolt = EffectEntangle();
            eDurVis = EffectVisualEffect(VFX_DUR_WEB);
            eBolt = EffectLinkEffects(eBolt, eDurVis);
            break;
    }

    if(iAbility!=-1) {
        iVisual = VFX_IMP_NEGATIVE_ENERGY;
        iDamageType = DAMAGE_TYPE_MAGICAL;
        iDamage = spInfo.iCasterLevel/3;
        if(iDamage==0) iDamage=1;
    }

    if(iVisual!=-1) {
        eVis = EffectVisualEffect(iVisual);
    }

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, iSpellID));

    iTouch = GRTouchAttackRanged(spInfo.oTarget);

    if(iTouch > 0) {
        if(iVisual!=-1) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
        }
        if(iDamageType!=-1) {
            if(iSpellID>=211) iDamage *= iTouch;

            if(iDamage > 0) {
                if(iSpellID<211) {  // Ability Drain Bolts
                    if(iDamage>10) {
                        DelayCommand(1.3f, DoAbilityDrainBolt(spInfo.oTarget, iAbility, 10));
                        DelayCommand(1.3f, DoAbilityDrainBolt(spInfo.oTarget, iAbility, iDamage-10));
                    } else {
                        DelayCommand(1.3f, DoAbilityDrainBolt(spInfo.oTarget, iAbility, iDamage));
                    }
                } else {
                    eBolt = EffectDamage(iDamage, iDamageType, iDamagePower);
                    if(iSpellID==220) { // Knockdown Bolt
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, spInfo.oTarget);
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectKnockdown(), spInfo.oTarget, fDuration);
                    } else {
                        if(iSpellID==222) { // Lightning "Bolt"
                            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, spInfo.oTarget, fDuration);
                        }
                        DelayCommand(1.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iDamageType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    }
                }
            }
        } else {  // Other Bolts - Charm, Disease, Poison, etc.
            if(iDurationType!=DURATION_TYPE_TEMPORARY) {
                GRApplyEffectToObject(iDurationType, eBolt, spInfo.oTarget);
            } else {
                if(iSpellID!=228 || (iSpellID==228 && !GRGetIsIncorporeal(oCaster))) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBolt, spInfo.oTarget, fDuration);
                }
            }
        }
    }

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
