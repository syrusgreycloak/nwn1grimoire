//*:**************************************************************************
//*:*  GR_S0_FUGUEC.NSS
//*:**************************************************************************
//*:* Fugue (OnHeartbeat)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 20, 2009
//*:* Spell Compendium (p. 100)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_CONCEN"

#include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    if(!GetIsObjectValid(oCaster) || !GRGetCasterConcentrating(spInfo.iSpellID, oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    int     iDieType          = 6;
    int     iNumDice          = 3;
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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_SONIC, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    int     iPerformCheck   = d20()+GRGetSkillModifier(SKILL_PERFORM, oCaster);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
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
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDam, eDur;
    effect eProne   = EffectKnockdown();
    effect eNausea  = EffectDazed();
    effect eStun    = EffectStunned();
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    spInfo.oTarget = GetFirstInPersistentObject();

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+GetName(oCaster))) {

            if(iPerformCheck>40) {
                object oCreature = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, spInfo.oTarget);
                AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
                SetIsTemporaryEnemy(oCreature, spInfo.oTarget, TRUE, GRGetDuration(1));
                DelayCommand(0.2, AssignCommand(spInfo.oTarget, ActionAttack(oCreature)));
            } else if(iPerformCheck>35) {
                eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                eLink = EffectLinkEffects(eDur, eStun);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, GRGetDuration(1));
            } else if(iPerformCheck>30) {
                eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                eLink = EffectLinkEffects(eDur, eNausea);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, GRGetDuration(1));
            } else if(iPerformCheck>22) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eProne, spInfo.oTarget, GRGetDuration(1)-0.2);
            } else if(iPerformCheck>17) {
                iDamage = GRGetSpellDamageAmount(spInfo, SPELL_SAVE_NONE, oCaster);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                eDam = EffectDamage(iDamage, iEnergyType);
                eLink = EffectLinkEffects(eVis, eDam);
                if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
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
