//*:**************************************************************************
//*:*  GR_S3_PARATOUCH.NSS
//*:**************************************************************************
//*:* Demilich paralzying touch (x2_s3_demitouch) Copyright (c) 2003 Bioware Corp.
//*:* Dracolich paralyzing touch (X2_S3_DracTouch) Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-08-27
//*:**************************************************************************
//*:* Updated On: February 19, 2008
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

    //  Demi-lich touch spell id = 758, Dracolich touch spell id = 760

    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    object  oItem           = GetSpellCastItem();
    spInfo.iDC = (spInfo.iSpellID==758 ? 38 : 10 + GetHitDice(oCaster)/2 + GetAbilityModifier(ABILITY_CHARISMA, oCaster));
    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = d6(2);      // Dracolich paralyzing touch is 2d6 rounds
    int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID==758) {
        //*:***********************************************
        //*:* Updated demi-lich paralyzing touch duration.
        //*:* while still not permanent, it's more difficult
        //*:* than standard as demi-liches should be hard
        //*:* to fight, and inspire a little bit of fear ;>
        //*:***********************************************
        switch(GetGameDifficulty()) {
            case GAME_DIFFICULTY_VERY_EASY:
                iDurAmount = 1;
                break;
            case GAME_DIFFICULTY_EASY:
                iDurAmount = 2;
                break;
            case GAME_DIFFICULTY_NORMAL:
                iDurAmount = 1;
                iDurType = DUR_TYPE_TURNS;
                break;
            case GAME_DIFFICULTY_CORE_RULES:
                iDurAmount = 3;
                iDurType = DUR_TYPE_TURNS;
                break;
            case GAME_DIFFICULTY_DIFFICULT:
                iDurAmount = 5;
                iDurType = DUR_TYPE_TURNS;
                break;
        }
    } else {
        if(GetGameDifficulty()<GAME_DIFFICULTY_NORMAL) {
            iDurAmount = d6();
        }
    }

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

    float   fDuration       = GRGetDuration(iDurAmount, iDurType);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

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
    effect eVis     = EffectVisualEffect(VFX_IMP_STUN);
    effect eDur     = EffectVisualEffect(VFX_DUR_PARALYZED);

    effect ePara    = EffectParalyze();
    ePara = EffectLinkEffects(eDur,ePara);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(oItem)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        if(!GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_ALL)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePara, spInfo.oTarget, fDuration);
            }
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
