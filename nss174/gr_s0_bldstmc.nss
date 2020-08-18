//*:**************************************************************************
//*:*  GR_S0_BLDSTMC.NSS
//*:**************************************************************************
//*:*
//*:* Blood Storm: On Heartbeat
//*:* summons a whirlwind of blood that envelops the entire area of
//*:* effect and has several effects on those caught within it.
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: September 15, 2003
//*:**************************************************************************
//*:* Updated On: February 21, 2008
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
    object  oCaster         = GetAreaOfEffectCreator();

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType          = 0;
    int     iNumDice          = 0;
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
    //*:* int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    //*:* int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVisFright       = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eBlind           = EffectBlindness();
    effect eAttPenalty      = EffectAttackDecrease(4);
    effect eRangePenalty    = EffectConcealment(75, MISS_CHANCE_TYPE_VS_RANGED);
    eAttPenalty = EffectLinkEffects(eAttPenalty, eRangePenalty);

    effect eBloodDmg;       // damage effect for the acidic blood.  must define after amount is known
    effect eFrightened      = EffectFrightened();
    effect eLink            = EffectLinkEffects(eFrightened, eVisFright);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();
    while(GetIsObjectValid(spInfo.oTarget)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_BLOODSTORM));
        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eAttPenalty, spInfo.oTarget);
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
            if(!GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC) && !GetLocalInt(spInfo.oTarget, "GR_BSTM_IS_BLIND")) {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eBlind, spInfo.oTarget);
                SetLocalInt(spInfo.oTarget,"GR_BSTM_IS_BLIND",TRUE);
            }

            iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
             if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iDamage = iSecDamage;
                }
            }
            eBloodDmg = EffectDamage(iDamage, DAMAGE_TYPE_ACID);
            if(iSecDamage>0) eBloodDmg = EffectLinkEffects(eBloodDmg, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eBloodDmg, spInfo.oTarget);

            if(WillSave(spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_FEAR)==0) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                if(GetHitDice(spInfo.oTarget)<=8) {
                    AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                    AssignCommand(spInfo.oTarget, ActionMoveAwayFromLocation(spInfo.lTarget, TRUE, FeetToMeters(400.0f)));
                }
            }
        }
        spInfo.oTarget = GetNextInPersistentObject();
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
