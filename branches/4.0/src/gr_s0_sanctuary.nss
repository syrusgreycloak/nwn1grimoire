//*:**************************************************************************
//*:*  GR_S0_SANCTUARY.NSS
//*:**************************************************************************
//*:* Sanctuary (NW_S0_Sanctuary.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Players Handbook (p. 274)
//*:**************************************************************************
//*:* Sanctuary, Mass
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 7, 2007
//*:* Spell Compendium (p. 179)
//*:*
//*:* Hide from Animals
//*:* Hide from Undead
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: July 30, 2004
//*:* 3.5 Player's Handbook (p. 241)
//*:**************************************************************************
//*:* Updated On: February 29, 2008
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
    int     iDurAmount        = spInfo.iCasterLevel;
    int     iDurType          = DUR_TYPE_ROUNDS;

    if(spInfo.iSpellID==SPELL_GR_INVISIBILITY_TO_ANIMALS || spInfo.iSpellID==SPELL_GR_INVISIBILITY_TO_UNDEAD) {
        iDurAmount *= 10;
        iDurType = DUR_TYPE_TURNS;
        //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
        spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);
    }

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
    float   fRange          = FeetToMeters(15.0);

    int     bMultiTarget    = (spInfo.iSpellID!=SPELL_SANCTUARY);
    int     iNumCreatures   = spInfo.iCasterLevel;
    int     iRacialType     = -1;
    int     iExtraBonus     = 0;

    switch(spInfo.iSpellID) {
        case SPELL_GR_INVISIBILITY_TO_ANIMALS:
            iRacialType = RACIAL_TYPE_ANIMAL;
            break;
        case SPELL_GR_INVISIBILITY_TO_UNDEAD:
            iRacialType = RACIAL_TYPE_UNDEAD;
            iExtraBonus = 20;  /* only intelligent undead are supposed to get a will save, make it much more difficult instead
                                since we can't specify */
            break;
        default:
            iRacialType = -1;
            break;
    }

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*** NWN1 SINGLE ***/ if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    /*** NWN1 SPECIFIC ***/
        effect eMassVis = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eVis     = EffectVisualEffect(VFX_DUR_SANCTUARY);
        effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eVis = EffectVisualEffect(VFX_DUR_SPELL_SANCTUARY);
    effect eSanc    = EffectSanctuary(GRGetSpellSaveDC(oCaster, OBJECT_INVALID)+iExtraBonus);

    effect eLink    = EffectLinkEffects(eSanc, eVis);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDur);
    if(iRacialType>-1) eLink = VersusRacialTypeEffect(eLink, iRacialType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(bMultiTarget) {
        /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eMassVis, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
    }

    if(GetIsObjectValid(spInfo.oTarget)) {
        do {
            if(!bMultiTarget || GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster, TRUE)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                iNumCreatures--;
            }
            if(bMultiTarget) {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget);
            }
        } while(GetIsObjectValid(spInfo.oTarget) && bMultiTarget && iNumCreatures>0);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
