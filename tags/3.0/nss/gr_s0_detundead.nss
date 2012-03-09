//*:**************************************************************************
//*:*  GR_S0_DETUNDEAD.NSS
//*:**************************************************************************
//*:* Detect Undead
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: March 13, 2008
//*:* 3.5 Player's Handbook (p. 220)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IC_DETECT"

#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRGetUndeadAuraStrength(object oTarget) {

    int iAuraStrength       = AURA_NONE;
    int iHD                 = GetHitDice(oTarget);
    string sAuraMessage;

    if(!GetHasSpellEffect(SPELL_GR_UNDETECTABLE_ALIGNMENT, oTarget)) {
        if(iHD<=1) {
            iAuraStrength = AURA_FAINT;
        } else if(iHD<=4) {
            iAuraStrength = AURA_MODERATE;
        } else if(iHD<=10) {
            iAuraStrength = AURA_STRONG;
        } else {
            iAuraStrength = AURA_OVERWHELMING;
        }
    }

    switch(iAuraStrength) {
        case AURA_FAINT:
            sAuraMessage = GetStringByStrRef(16939254) + GetStringByStrRef(16939258);
            break;
        case AURA_MODERATE:
            sAuraMessage = GetStringByStrRef(16939255) + GetStringByStrRef(16939258);
            break;
        case AURA_STRONG:
            sAuraMessage = GetStringByStrRef(16939256) + GetStringByStrRef(16939258);
            break;
        case AURA_OVERWHELMING:
            sAuraMessage = GetStringByStrRef(16939257) + GetStringByStrRef(16939258);
            break;
    }

    SetLocalString(oTarget, "GR_UNDEAD_AURA", sAuraMessage);

    return iAuraStrength;
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

    float   fDuration           = 3.0;
    float   fRange              = FeetToMeters(60.0);
    int     bTargetMatch;
    int     bAlignMatch;
    int     bDeityMatch;
    int     bClassMatch;
    int     bCasterOpposite;

    int     iClassLevels        = spInfo.iCasterLevel;
    int     iDetectVis          = VFX_COM_SPECIAL_BLUE_RED;
    int     iSpellShape         = SHAPE_SPELLCONE;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
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
    effect eVis     = EffectVisualEffect(iDetectVis);
    effect eStun    = EffectStunned();
    effect eStunVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eLink    = EffectLinkEffects(eStun, eStunVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));

    spInfo.oTarget = GRGetFirstObjectInShape(iSpellShape, fRange, spInfo.lTarget, TRUE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetRacialType(spInfo.oTarget)==RACIAL_TYPE_UNDEAD && !GRGetAlignmentDetectionBlocked(spInfo.oTarget)) {
            spInfo.oTarget = GRCheckMisdirection(spInfo.oTarget, oCaster);
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 3.0);
            if(GRGetUndeadAuraStrength(spInfo.oTarget)==AURA_OVERWHELMING && GetHitDice(spInfo.oTarget)>=(2*iClassLevels) &&
                GetAlignmentGoodEvil(oCaster)==ALIGNMENT_GOOD) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, GRGetDuration(2));
            }
            if(GetIsPC(oCaster)) {
                SendMessageToPC(oCaster, GetName(spInfo.oTarget) + GetLocalString(spInfo.oTarget, "GR_UNDEAD_AURA"));
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(iSpellShape, fRange, spInfo.lTarget, TRUE);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
