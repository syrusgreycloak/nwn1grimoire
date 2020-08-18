//*:**************************************************************************
//*:*  GR_S0_GHOULTCH.NSS
//*:**************************************************************************
//*:*
//*:* Ghoul Touch (NW_S0_GhoulTch.nss) Copyright (c) 2001 Bioware Corp.
//*:* 3.5 Player's Handbook (p. 235)
//*:*
//*:**************************************************************************
//*:* Created By: Preston Watamaniuk
//*:* Created On: Nov 7, 2001
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

    float   fDuration       = GRGetDuration(GRGetMetamagicAdjustedDamage(6, 1, spInfo.iMetamagic, 2));
    //*:* float   fRange          = FeetToMeters(15.0);

    string  sAOEType        = AOE_TYPE_FOGGHOUL;
    //*** NWN2 SINGLE ***/ sAOEType = GRGetUniqueSpellIdentifier(spInfo.iSpellID, oCaster);

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
    effect eAOE     = GREffectAreaOfEffect(AOE_PER_FOGGHOUL, "", "", "", sAOEType);
    effect eParal   = EffectParalyze();
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2    = EffectVisualEffect(VFX_DUR_PARALYZED);
    //*** NWN2 SINGLE ***/ effect eHit = EffectVisualEffect(VFX_HIT_SPELL_NECROMANCY);

    effect eLink = EffectLinkEffects(eDur2, eDur);
    eLink = EffectLinkEffects(eLink, eParal);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GHOUL_TOUCH));
        if(TouchAttackMelee(spInfo.oTarget, GetSpellCastItem()==OBJECT_INVALID)>0 && GRGetIsHumanoid(spInfo.oTarget) &&
            GRGetIsLiving(spInfo.oTarget)) {

            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_NEGATIVE)) {
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spInfo.oTarget, fDuration);
                    if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_POISON)) {
                        //*** NWN2 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eHit, spInfo.oTarget);
                        GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, GetLocation(spInfo.oTarget), fDuration);

                        /*** NWN1 SINGLE ***/ object oAOE = GRGetAOEAtLocation(GetLocation(spInfo.oTarget), sAOEType, oCaster);
                        //*** NWN2 SINGLE ***/ object oAOE = GetObjectByTag(sAOEType);
                        GRSetAOESpellId(spInfo.iSpellID, oAOE);
                        GRSetSpellInfo(spInfo, oAOE);
                    }
                }
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
