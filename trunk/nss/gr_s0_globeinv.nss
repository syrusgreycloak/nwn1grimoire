//*:**************************************************************************
//*:*  GR_S0_GLOBEINV.NSS
//*:**************************************************************************
//*:*
//*:* Globe of Invulnerability (NW_S0_GlobeInv.nss) Copyright (c) 2001 Bioware Corp.
//*:* Minor Globe of Invulnerability (NW_S0_MinGlobe.nss) Copyright (c) 2001 Bioware Corp.
//*:*   (Globe of Invulnerability, Lesser)
//*:* 3.5 Player's Handbook (p. 236) - spells not immoble as noted
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:*
//*:**************************************************************************
//*:* Protection From Cantrips  2003 Karl Nickels
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 31, 2003
//*:* 2nd Edition spell
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType;
    int     iSpellLevel;
    int     bInstantVis     = FALSE;

    switch(spInfo.iSpellID) {
        case SPELL_GLOBE_OF_INVULNERABILITY:
            /*** NWN1 SINGLE ***/ iVisualType = VFX_DUR_GLOBE_INVULNERABILITY;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_DUR_SPELL_GLOBE_INV_GREAT;
            iSpellLevel = 4;
            break;
        case SPELL_LESSER_GLOBE_OF_INVULNERABILITY:
            /*** NWN1 SINGLE ***/ iVisualType = VFX_DUR_GLOBE_MINOR;
            //*** NWN2 SINGLE ***/ iVisualType = VFX_DUR_SPELL_GLOBE_INV_LESS;
            iSpellLevel = 3;
            break;
        case SPELL_GR_PROTECTION_CANTRIPS:
            /*** NWN1 SPECIFIC ***/
                iVisualType = VFX_IMP_MAGIC_PROTECTION;
                bInstantVis = TRUE;
            /*** END NWN1 SPECIFIC ***/
            //*** NWN2 SINGLE ***/ iVisualType = VFX_DUR_SPELL_SPELL_RESISTANCE;
            iSpellLevel = 0;

            break;
    }

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
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eSpell   = EffectSpellLevelAbsorption(iSpellLevel, 0);

    /*** NWN1 SPECIFIC ***/
        effect eLink = EffectLinkEffects(eDur, eSpell);
        if(!bInstantVis) eLink = EffectLinkEffects(eLink, eVis);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eLink = EffectLinkEffects(eVis, eSpell);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(spInfo.iSpellID, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    if(bInstantVis) GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
