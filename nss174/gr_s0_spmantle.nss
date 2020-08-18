//*:**************************************************************************
//*:*  GR_S0_SPMANTLE.NSS
//*:**************************************************************************
//*:*
//*:* Lesser Spell Mantle Copyright (c) 2001 Bioware Corp.
//*:* Spell Mantle Copyright (c) 2001 Bioware Corp.
//*:* Greater Spell Mantle Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:*
//*:* Least Spell Mantle (NW_S0_LstSpTurn.nss) Copyright (c) 2006 Obsidian Entertainment, Inc.
//*:* Created By: Andrew Woo (AFW-OEI)  Created On: 05/22/2006
//*:**************************************************************************
//*:* Updated On: June 16, 2008
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
int PreventStacking(int iSpellID, object oCreature) {

    int bPrevent    = FALSE;

    int bHasLeast   = GetHasSpellEffect(SPELL_LEAST_SPELL_MANTLE, oCreature);
    int bHasLesser  = GetHasSpellEffect(SPELL_LESSER_SPELL_MANTLE, oCreature);
    int bHasNormal  = GetHasSpellEffect(SPELL_SPELL_MANTLE, oCreature);
    int bHasGreater = GetHasSpellEffect(SPELL_GREATER_SPELL_MANTLE, oCreature);

    switch(iSpellID) {
        case SPELL_LEAST_SPELL_MANTLE:
            if(bHasLeast) {
                GRRemoveSpellEffects(SPELL_LEAST_SPELL_MANTLE, oCreature);
            } else if(bHasLesser || bHasNormal || bHasGreater) {
                bPrevent = TRUE;
            }
            break;
        case SPELL_LESSER_SPELL_MANTLE:
            if(bHasLeast || bHasLesser) {
                if(bHasLeast) GRRemoveSpellEffects(SPELL_LEAST_SPELL_MANTLE, oCreature);
                else if(bHasLesser) GRRemoveSpellEffects(SPELL_LESSER_SPELL_MANTLE, oCreature);
            } else if(bHasNormal || bHasGreater) {
                bPrevent = TRUE;
            }
            break;
        case SPELL_SPELL_MANTLE:
            if(bHasLeast || bHasLesser || bHasNormal) {
                if(bHasLeast) GRRemoveSpellEffects(SPELL_LEAST_SPELL_MANTLE, oCreature);
                else if(bHasLesser) GRRemoveSpellEffects(SPELL_LESSER_SPELL_MANTLE, oCreature);
                else if(bHasNormal) GRRemoveSpellEffects(SPELL_SPELL_MANTLE, oCreature);
            } else if(bHasGreater) {
                bPrevent = TRUE;
            }
            break;
        case SPELL_GREATER_SPELL_MANTLE:
            if(bHasLeast) GRRemoveSpellEffects(SPELL_LEAST_SPELL_MANTLE, oCreature);
            else if(bHasLesser) GRRemoveSpellEffects(SPELL_LESSER_SPELL_MANTLE, oCreature);
            else if(bHasNormal) GRRemoveSpellEffects(SPELL_SPELL_MANTLE, oCreature);
            else if(bHasGreater) GRRemoveSpellEffects(SPELL_GREATER_SPELL_MANTLE, oCreature);
            break;
    }

    return bPrevent;
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

    int     iDieType        = 4;
    int     iNumDice        = 1;
    int     iBonus          = 6;
    int     iAbsorb         = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    switch(spInfo.iSpellID) {
        case SPELL_LEAST_SPELL_MANTLE:
            iDieType = 4;
            iBonus = 4;
            break;
        case SPELL_LESSER_SPELL_MANTLE:
            iDieType = 6;
            iBonus = 6;
            break;
        case SPELL_SPELL_MANTLE:
            iDieType = 8;
            iBonus = 8;
            break;
        case SPELL_GREATER_SPELL_MANTLE:
            iDieType = 12;
            iBonus = 10;
            break;
    }

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iDurVis         = VFX_DUR_CESSATE_POSITIVE;
    /*** NWN1 SINGLE ***/ int     iVisual         = VFX_DUR_SPELLTURNING;
    /*** NWN2 SPECIFIC ***
        int     iVisual         = VFX_HIT_SPELL_ABJURATION;
        switch(spInfo.iSpellID) {
            case SPELL_LEAST_SPELL_MANTLE: iDurVis = VFX_DUR_SPELL_LESSER_SPELL_MANTLE;     break;
            case SPELL_LESSER_SPELL_MANTLE: iDurVis = VFX_DUR_SPELL_LESSER_SPELL_MANTLE;    break;
            case SPELL_SPELL_MANTLE: iDurVis = VFX_DUR_SPELL_SPELL_MANTLE;                  break;
        }
    /*** END NWN2 SPECIFIC ***/

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iAbsorb = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisual);
    effect eDur     = EffectVisualEffect(iDurVis);
    effect eAbsorb  = EffectSpellLevelAbsorption(9, iAbsorb);

    effect eLink    = EffectLinkEffects(eDur, eAbsorb);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eVis);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));

    if(!PreventStacking(spInfo.iSpellID, spInfo.oTarget)) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
    } else if(GetIsPC(oCaster)) {
        SendMessageToPC(oCaster, GetName(spInfo.oTarget) + GetStringByStrRef(16939266));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
