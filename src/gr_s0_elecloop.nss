//*:**************************************************************************
//*:*  GR_S0_ELECLOOP.NSS
//*:**************************************************************************
//*:*
//*:* Gedlee's Electric Loop (X2_S0_ElecLoop) Copyright (c) 2001 Bioware Corp.
//*:* Spell Compendium (p. 78)
//*:*
//*:**************************************************************************
//*:* Created By: Georg Zoeller
//*:* Created On: Oct 19 2003
//*:**************************************************************************
//*:* Updated On: December 10, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

#include "GR_IN_ENERGY"

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
    int     iNumDice          = MinInt(5, (spInfo.iCasterLevel+1)/2);
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
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_LIGHTNING_S, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iBeamType       = GRGetEnergyBeamType(iEnergyType);

    int     iNumAffected    = MinInt(4, (spInfo.iCasterLevel+2)/3);
    int     iPotential;
    object  oLastValid;

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
    effect   eStrike    = EffectVisualEffect(iVisualType);
    effect   eBeam;
    effect   eDam;
    effect   eStun      = EffectLinkEffects(EffectVisualEffect(VFX_IMP_STUN),EffectStunned());

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE);
    while(GetIsObjectValid(spInfo.oTarget) && iNumAffected>0) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));

            //*:**********************************************
            //*:* Calculate delay until spell hits current
            //*:* target. If we are the first target, the delay
            //*:* is the time until the spell hits us
            //*:**********************************************
            if(GetIsObjectValid(oLastValid)) {
                   fDelay += 0.2f;
                   fDelay += GetDistanceBetweenLocations(GetLocation(oLastValid), GetLocation(spInfo.oTarget))/20;
            } else {
                fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20;
            }

            //*:**********************************************
            //*:* If there was a previous target, draw a
            //*:* lightning beam between us and iterate delay
            //*:* so it appears that the beam is jumping from
            //*:* target to target
            //*:**********************************************
            if(GetIsObjectValid(oLastValid)) {
                 eBeam = EffectBeam(iBeamType, oLastValid, BODY_NODE_CHEST);
                 DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget,1.5f));
            }

            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }

                //*:* Lesser Shadow Evocation
                if(spInfo.iSpellSchool==SPELL_SCHOOL_ILLUSION) {
                    if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                        iDamage = FloatToInt(iDamage*0.2f);
                    }
                }
                //*:**********************************************
                //*:* If we failed the reflex save, we save vs will
                //*:* or are stunned for one round
                //*:**********************************************
                if(!GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster)) {
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, fDelay)) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, spInfo.oTarget, 9.0f));
                    }
                }

                if(iDamage>0) {
                    eDam = EffectDamage(iDamage, iEnergyType);
                    if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eStrike, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
            }

            //*:**********************************************
            //*:* Store Target to make it appear that the
            //*:* lightning bolt is jumping from target to target
            //*:**********************************************
            oLastValid = spInfo.oTarget;
            iNumAffected--;
        }
        if(!GRGetIsUnderwater(oCaster) && iEnergyType!=DAMAGE_TYPE_ELECTRICAL) {
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE);
        } else {
            //*:**********************************************
            //*:* Since spell is similar to chain lightning,
            //*:* we'll keep the spell from jumping targets
            //*:* when underwater if electrical
            //*:**********************************************
            spInfo.oTarget = OBJECT_INVALID;
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
