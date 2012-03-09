//*:**************************************************************************
//*:*  GR_S0_DETALIGN.NSS
//*:**************************************************************************
//*:* Detect Chaos/Evil/Good/Law
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: November 15, 2007
//*:* 3.5 Player's Handbook (p. 218-219)
//*:**************************************************************************

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************
const int AURA_NONE = 0;
const int AURA_FAINT = 1;
const int AURA_MODERATE = 2;
const int AURA_STRONG = 3;
const int AURA_OVERWHELMING = 4;

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_DEITIES"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRGetAlignmentAuraStrength(object oTarget, int iDetectAlign) {

    int iAuraStrength       = AURA_NONE;
    int iHD                 = GetHitDice(oTarget);
    int iClassLevels        = GRGetLevelByClass(CLASS_TYPE_CLERIC);
    string sAlignString     = "";
    string sAuraMessage     = GetStringByStrRef(16939249);

    if(!GetHasSpellEffect(SPELL_GR_UNDETECTABLE_ALIGNMENT, oTarget)) {
        switch(iDetectAlign) {
            case ALIGNMENT_GOOD:
                sAlignString = GetStringByStrRef(16939250);
                iClassLevels += GRGetLevelByClass(CLASS_TYPE_PALADIN);
                break;
            case ALIGNMENT_EVIL:
                sAlignString = GetStringByStrRef(16939251);
                iClassLevels += GRGetLevelByClass(CLASS_TYPE_BLACKGUARD);
                iClassLevels += GRGetLevelByClass(CLASS_TYPE_PALADIN);
                break;
            case ALIGNMENT_LAWFUL:
                sAlignString = GetStringByStrRef(16939252);
                iClassLevels += GRGetLevelByClass(CLASS_TYPE_PALADIN);
                break;
            case ALIGNMENT_CHAOTIC:
                sAlignString = (iDetectAlign==ALIGNMENT_LAWFUL ? GetStringByStrRef(16939252) : GetStringByStrRef(16939253));
                break;
        }

        switch(GRGetRacialType(oTarget)) {
            case RACIAL_TYPE_OUTSIDER:
                if(iHD<=1) {
                    iAuraStrength = AURA_FAINT;
                } else if(iHD<=4) {
                    iAuraStrength = AURA_MODERATE;
                } else if(iHD<=10) {
                    iAuraStrength = AURA_STRONG;
                } else {
                    iAuraStrength = AURA_OVERWHELMING;
                }
                break;
            case RACIAL_TYPE_UNDEAD:
                if(iHD<=2) {
                    iAuraStrength = AURA_FAINT;
                } else if(iHD<=8) {
                    iAuraStrength = AURA_MODERATE;
                } else if(iHD<=20) {
                    iAuraStrength = AURA_STRONG;
                } else {
                    iAuraStrength = AURA_OVERWHELMING;
                }
                break;
            default:
                if(iClassLevels>0) {
                    iHD = iClassLevels;
                    if(iHD<=1) {
                        iAuraStrength = AURA_FAINT;
                    } else if(iHD<=4) {
                        iAuraStrength = AURA_MODERATE;
                    } else if(iHD<=10) {
                        iAuraStrength = AURA_STRONG;
                    } else {
                        iAuraStrength = AURA_OVERWHELMING;
                    }
                } else {
                    if(iHD<=10) {
                        iAuraStrength = AURA_FAINT;
                    } else if(iHD<=25) {
                        iAuraStrength = AURA_MODERATE;
                    } else if(iHD<=50) {
                        iAuraStrength = AURA_STRONG;
                    } else {
                        iAuraStrength = AURA_OVERWHELMING;
                    }
                }
                break;
        }
    }

    switch(iAuraStrength) {
        case AURA_FAINT:
            sAuraMessage = GetStringByStrRef(16939254) + sAlignString;
            break;
        case AURA_MODERATE:
            sAuraMessage = GetStringByStrRef(16939255) + sAlignString;
            break;
        case AURA_STRONG:
            sAuraMessage = GetStringByStrRef(16939256) + sAlignString;
            break;
        case AURA_OVERWHELMING:
            sAuraMessage = GetStringByStrRef(16939257) + sAlignString;
            break;
    }

    SetLocalString(oTarget, "GR_ALIGN_AURA"+IntToString(iDetectAlign), sAuraMessage);

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
    string  sOriginalName;

    int     iClassLevels        = spInfo.iCasterLevel;
    int     iDetectAlign;
    int     iOppositeAlign;
    int     iDetectVis;
    int     iSpellShape         = SHAPE_SPHERE;

    switch(spInfo.iSpellID) {
        case SPELLABILITY_DETECT_EVIL:
            iSpellShape = SHAPE_SPHERE;
        case SPELL_GR_DETECT_EVIL:
            iDetectAlign = ALIGNMENT_EVIL;
            iDetectVis = VFX_COM_SPECIAL_RED_WHITE;
            iOppositeAlign = ALIGNMENT_GOOD;
            break;
        case SPELL_GR_DETECT_CHAOS:
            iDetectAlign = ALIGNMENT_CHAOTIC;
            iDetectVis = VFX_COM_SPECIAL_WHITE_ORANGE;
            iOppositeAlign = ALIGNMENT_LAWFUL;
            break;
        case SPELL_GR_DETECT_GOOD:
            iDetectAlign = ALIGNMENT_GOOD;
            iDetectVis = VFX_COM_SPECIAL_WHITE_BLUE;
            iOppositeAlign = ALIGNMENT_EVIL;
            break;
        case SPELL_GR_DETECT_LAW:
            iDetectAlign = ALIGNMENT_LAWFUL;
            iDetectVis = VFX_COM_SPECIAL_PINK_ORANGE;
            iOppositeAlign = ALIGNMENT_CHAOTIC;
            break;
    }


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
        sOriginalName = GetName(spInfo.oTarget);
        spInfo.oTarget = GRCheckMisdirection(spInfo.oTarget, oCaster);
        switch(iDetectAlign) {
            case ALIGNMENT_EVIL:
                bAlignMatch = GetAlignmentGoodEvil(spInfo.oTarget)==iDetectAlign;
                bDeityMatch = GRGetDeityAlignGoodEvil(GRGetDeity(spInfo.oTarget))==iDetectAlign;
                bCasterOpposite = GetAlignmentGoodEvil(oCaster)==iOppositeAlign;
                if(spInfo.iSpellID!=SPELLABILITY_DETECT_EVIL && bCasterOpposite) iClassLevels += GRGetLevelByClass(CLASS_TYPE_PALADIN);
                break;
            case ALIGNMENT_GOOD:
                bAlignMatch = GetAlignmentGoodEvil(spInfo.oTarget)==iDetectAlign;
                bDeityMatch = GRGetDeityAlignGoodEvil(GRGetDeity(spInfo.oTarget))==iDetectAlign;
                bCasterOpposite = GetAlignmentGoodEvil(oCaster)==iOppositeAlign;
                if(bCasterOpposite) {
                    iClassLevels += GRGetLevelByClass(CLASS_TYPE_BLACKGUARD, oCaster);
                    iClassLevels += GRGetLevelByClass(CLASS_TYPE_PALADIN, oCaster);
                }
                break;
            case ALIGNMENT_LAWFUL:
                bAlignMatch = GetAlignmentLawChaos(spInfo.oTarget)==iDetectAlign;
                bDeityMatch = GRGetDeityAlignGoodEvil(GRGetDeity(spInfo.oTarget))==iDetectAlign;
                bCasterOpposite = GetAlignmentLawChaos(oCaster)==iOppositeAlign;
                break;
            case ALIGNMENT_CHAOTIC:
                bAlignMatch = GetAlignmentLawChaos(spInfo.oTarget)==iDetectAlign;
                bDeityMatch = GRGetDeityAlignGoodEvil(GRGetDeity(spInfo.oTarget))==iDetectAlign;
                bCasterOpposite = GetAlignmentLawChaos(oCaster)==iOppositeAlign;
                if(bCasterOpposite) iClassLevels += GRGetLevelByClass(CLASS_TYPE_PALADIN, oCaster);
                break;
        }
        bClassMatch = GRGetHasClass(CLASS_TYPE_CLERIC, spInfo.oTarget) || GRGetHasClass(CLASS_TYPE_PALADIN, spInfo.oTarget) ||
                        GRGetHasClass(CLASS_TYPE_BLACKGUARD, spInfo.oTarget);
        bTargetMatch = bAlignMatch || (bClassMatch && bDeityMatch);

        if(bTargetMatch && !GRGetAlignmentDetectionBlocked(spInfo.oTarget)) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 3.0);
            if(GRGetAlignmentAuraStrength(spInfo.oTarget, iDetectAlign)==AURA_OVERWHELMING && GetHitDice(spInfo.oTarget)>=(2*iClassLevels)) {
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster, GRGetDuration(2));
            }
            if(GetIsPC(oCaster)) {
                SendMessageToPC(oCaster, sOriginalName + GetLocalString(spInfo.oTarget, "GR_ALIGN_AURA"+IntToString(iDetectAlign)));
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
