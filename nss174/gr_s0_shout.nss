//*:**************************************************************************
//*:*  GR_S0_SHOUT.NSS
//*:**************************************************************************
//*:* Shout (sg_s0_shout.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: November 12, 2004
//*:* 3.5 Player's Handbook (p. 279)
//*:*
//*:* Shout, Greater
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 16, 2006
//*:* 3.5 Player's Handbook (p. 279)
//*:**************************************************************************
//*:* Updated On: March 10, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
//#include "X0_I0_POSITION"     - INCLUDED IN GR_IN_LIB

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

    //spInfo.lTarget          = GetAheadLocation(oCaster);

    int     iDieType          = 6;
    int     iNumDice          = 5;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;

    int     iDurNum           = 2;
    float   fFeet             = 30.0;

    if(spInfo.iSpellID==SPELL_GREATER_SHOUT) {
        iNumDice *= 2;
        iDurNum *= 2;
        fFeet *= 2;
    }

    int     iDurAmount        = GRGetMetamagicAdjustedDamage(6, iDurNum, spInfo.iMetamagic);
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fStunDur        = GRGetDuration(1);
    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(fFeet);

    int     iVisualType     = GRGetEnergyVisualType(VFX_COM_HIT_SONIC, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iObjectFilter   = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;

    if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_SONIC) fRange *= 2;
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) {
        fDuration *= 2;
        fStunDur *= 2;
    }
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    //*:* iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eStun    = EffectStunned();
    effect eStunVis = EffectVisualEffect(VFX_IMP_STUN);
    effect eDeaf    = EffectDeaf();
    effect eDeafVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eDur     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDmgVis  = EffectVisualEffect(iVisualType);
    effect eDamage;
    effect eLink    = EffectLinkEffects(eDeaf, eDur);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, iObjectFilter);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay) || GetObjectType(spInfo.oTarget)==OBJECT_TYPE_CREATURE) {
                if(!GetHasEffect(EFFECT_TYPE_SILENCE, spInfo.oTarget)) {
                    iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster, iSaveType, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, FORTITUDE_HALF, oCaster);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    //*:* Shadow Evocation 2 - Shout: Will disbelief check
                    if(spInfo.iSpellSchool==SPELL_SCHOOL_ILLUSION) {
                        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NONE, oCaster, fDelay)) {
                            iDamage = FloatToInt(iDamage * 0.4);
                        }
                    }
                    eDamage = EffectDamage(iDamage, iEnergyType);
                    int bSaveMade = GRGetSpellDmgSaveMade(spInfo.iSpellID, oCaster);
                    if(iSecDamage>0) eDamage = EffectLinkEffects(eDamage, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDmgVis, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }

                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spInfo.oTarget));
                    if(spInfo.iSpellID==SPELL_GREATER_SHOUT && bSaveMade) fDuration /= 2.0;
                    if(!bSaveMade || (bSaveMade && spInfo.iSpellID==SPELL_GREATER_SHOUT)) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeafVis, spInfo.oTarget));
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration));
                        if(!bSaveMade && spInfo.iSpellID==SPELL_GREATER_SHOUT) {
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eStunVis, spInfo.oTarget));
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eStun, spInfo.oTarget, fStunDur));
                        }
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, iObjectFilter);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
