//*:**************************************************************************
//*:*  GR_S0_CONES.NSS
//*:**************************************************************************
//*:* Burning Hands (NW_S0_BurnHand) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: April 5, 2001
//*:* 3.5 Player's Handbook (p. 207)
//*:*
//*:* Cone of Cold (NW_S0_ConeCold) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Noel Borstad  Created On: 10/18/2000
//*:* 3.5 Player's Handbook (p. 212)
//*:**************************************************************************
//*:* Blast of Flame
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: August 6, 2007
//*:* Spell Compendium (p. 31)
//*:*
//*:* Incendiary Surge
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 17, 2008
//*:* Complete Mage (p. 108)
//*:**************************************************************************
//*:* Updated On: April 17, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

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

    int     iDieType        = 0;
    int     iNumDice        = 0;
    int     iBonus          = 0;
    int     iDamage         = 0;
    int     iSecDamage      = 0;
    int     iDurAmount      = spInfo.iCasterLevel;
    int     iDurType        = DUR_TYPE_ROUNDS;
    int     iEnergyType     = DAMAGE_TYPE_MAGICAL;
    int     iSpellType      = SPELL_TYPE_GENERAL;
    int     iSaveType       = SAVING_THROW_TYPE_NONE;
    int     iSpellSaveType  = SPELL_SAVE_NONE;
    int     iSavingThrow    = SAVING_THROW_NONE;

    int     bDamageSpell        = TRUE;
    int     bInstantSpell       = TRUE;
    int     bEnergySpell        = TRUE;
    int     bSpecialTarget      = FALSE;
    int     bPassSpecialTarget  = TRUE;
    int     bNoSR               = FALSE;
    int     bNoSave             = FALSE;

    int     iVisualType         = -1;
    int     iRacialType;
    float   fRange              = FeetToMeters(60.0);
    float   fDamagePercentage   = 1.0;

    //*** NWN2 SINGLE ***/ int  iConeType;

    switch(spInfo.iSpellID) {
        case SPELL_GR_BLAST_OF_FLAME:
            bNoSR = TRUE;
            bNoSave = TRUE;  //*:* set to true because save is done in damage calculation
            iSpellSaveType = REFLEX_HALF;
            iDieType = 6;
            iNumDice = MinInt(10, spInfo.iCasterLevel);
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_FLAME_M;
            /*** NWN2 SPECIFIC ***
                iVisualType = VFX_HIT_SPELL_FIRE;
                iConeType = VFX_DUR_CONE_FIRE;
            /*** END NWN2 SPECIFIC ***/
            break;
        case SPELL_GR_LSE_BURNING_HANDS:
            fDamagePercentage = 0.2;
        case SPELL_BURNING_HANDS:
            bNoSave = TRUE;  //*:* set to true because save is done in damage calculation
            iSpellSaveType = REFLEX_HALF;
            iDieType = 4;
            iNumDice = MinInt(5, spInfo.iCasterLevel);
            fRange = FeetToMeters(15.0);
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_FLAME_S;
            /*** NWN2 SPECIFIC ***
                iVisualType = VFX_HIT_SPELL_FIRE;
                iConeType = VFX_DUR_SPELL_BURNING_HANDS;
            /*** END NWN2 SPECIFIC ***/
            break;
        case SPELL_GR_GSE1_CONE_OF_COLD:
            fDamagePercentage = 0.6;
        case SPELL_CONE_OF_COLD:
            bNoSave = TRUE;  //*:* set to true because save is done in damage calculation
            iSpellSaveType = REFLEX_HALF;
            iDieType = 6;
            iNumDice = MinInt(15, spInfo.iCasterLevel);
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_FROST_L;
            /*** NWN2 SPECIFIC ***
                iVisualType = VFX_HIT_SPELL_ICE;
                iConeType = VFX_DUR_CONE_ICE;
            /*** END NWN2 SPECIFIC ***/
            break;
        case SPELL_GR_INCENDIARY_SURGE:
            bNoSave = TRUE;  //*:* set to true because save is done in damage calculation
            iSpellSaveType = REFLEX_HALF;
            iDieType = (GRGetHasSpellEffect(spInfo.iSpellID, oCaster, oCaster) ? 8 : 6);
            iNumDice = MinInt(10, spInfo.iCasterLevel);
            /*** NWN1 SINGLE ***/ iVisualType = VFX_IMP_FLAME_M;
            /*** NWN2 SPECIFIC ***
                iVisualType = VFX_HIT_SPELL_FIRE;
                iConeType = VFX_DUR_CONE_FIRE;
            /*** END NWN2 SPECIFIC ***/
            fRange = FeetToMeters(30.0);
            break;
    }

    if(bDamageSpell) spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    if(!bInstantSpell) spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    if(bEnergySpell) {
        iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
        iSpellType      = GRGetEnergySpellType(iEnergyType);
    }

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
    float   fDelay          = 0.0f;
    //*** NWN2 SINGLE ***/ float    fMaxDelay       = 0.0f;

    if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_SONIC) fRange*=2.0;

    if(bEnergySpell) {
        iVisualType     = GRGetEnergyVisualType(iVisualType, iEnergyType);
        iSaveType       = GRGetEnergySaveType(iEnergyType);
        //*** NWN2 SINGLE ***/ iConeType = GRGetEnergyConeType(iConeType, iEnergyType);
    }


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
    effect eVis, eDam, eLink;
    eVis = EffectVisualEffect(iVisualType);
    /*** NWN2 SPECIFIC ***
        effect eCone = EffectVisualEffect(iConeType);
        effect eSurgeVis = EffectVisualEffect(VFX_DUR_SPELL_PROT_ALIGN);
    /*** END NWN2 SPECIFIC ***/

    /*** NWN1 SINGLE ***/ effect eSurgeVis = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_GR_INCENDIARY_SURGE) {
        SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_INCENDIARY_SURGE, FALSE));
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSurgeVis, oCaster, GRGetDuration(2));
    }

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR |
        OBJECT_TYPE_PLACEABLE);

    while(GetIsObjectValid(spInfo.oTarget)) {
        if(bSpecialTarget) {
            //*:* don't have any that need special/racial targets yet
            bPassSpecialTarget = TRUE;
        }
        if(bPassSpecialTarget && GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
            fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20.0;
            //*** NWN2 SINGLE ***/ if(fDelay>fMaxDelay) fMaxDelay = fDelay;
            if(bNoSR || !GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(bNoSave || !GRGetSaveResult(iSavingThrow, spInfo.oTarget, spInfo.iDC, iSaveType, oCaster, fDelay)) {
                    iDamage = GRGetSpellDamageAmount(spInfo, iSpellSaveType, oCaster, iSaveType, fDelay);

                    if(fDamagePercentage!=1.0) {
                        //*:* Will disbelief for illusion
                        if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_SPELL, oCaster, fDelay)) {
                            iDamage = FloatToInt(iDamage*fDamagePercentage);
                        }
                    }

                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, iSpellSaveType, oCaster, iSaveType, fDelay);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    eDam = EffectDamage(iDamage, iEnergyType);
                    eLink = EffectLinkEffects(eVis, eDam);
                    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    if(iDamage > 0) {
                        DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCONE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR |
            OBJECT_TYPE_PLACEABLE);
    }

    //*** NWN2 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCone, OBJECT_SELF, fMaxDelay);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
