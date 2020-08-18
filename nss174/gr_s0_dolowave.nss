//*:**************************************************************************
//*:*  GR_S0_DOLOWAVE.NSS
//*:**************************************************************************
//*:*
//*:* Dolomar's Force Wave
//*:* Swords & Sorcery: Relics & Rituals I
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 31, 2003
//*:**************************************************************************
//*:* Updated On: February 25, 2008
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

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
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

    float   fDuration; //*:*        = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = 10.0 + IntToFloat(spInfo.iCasterLevel);

    float   fDistBetween;
    int     iTargetDC;
    int     iSTRCheck;
    float   fMoveAmount     = 0.0f;
    location lMoveToLoc;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eVis     = EffectVisualEffect(VFX_FNF_HOWL_MIND);
    effect eKnock   = EffectKnockdown();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, FeetToMeters(fRange), spInfo.lTarget, TRUE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_DOLOMAR_WAVE));
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                fDistBetween = GetDistanceBetween(spInfo.oTarget,oCaster);
                fDelay = fDistBetween/20;
                iTargetDC = 12 + spInfo.iCasterLevel/2;
                iSTRCheck = d20() + GetAbilityModifier(ABILITY_STRENGTH, spInfo.oTarget);
                if(iSTRCheck<iTargetDC) {
                    fMoveAmount = IntToFloat(5 + iTargetDC - iSTRCheck);
                    if(fDistBetween + fMoveAmount > fRange) {
                        fMoveAmount = fRange-fMoveAmount;
                    }
                    AssignCommand(spInfo.oTarget, ClearAllActions());
                    lMoveToLoc = GenerateNewLocationFromLocation(GetLocation(spInfo.oTarget), fMoveAmount,
                        GetNormalizedDirection(GetAngleBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))),
                        GetFacing(spInfo.oTarget));
                    AssignCommand(spInfo.oTarget, JumpToLocation(lMoveToLoc));
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnock, spInfo.oTarget, 3.0f));
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, FeetToMeters(fRange), spInfo.lTarget, TRUE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
