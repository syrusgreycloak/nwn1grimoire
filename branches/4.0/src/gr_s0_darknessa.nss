//*:**************************************************************************
//*:*  GR_S0_DARKNESS.NSS
//*:**************************************************************************
//*:* Darkness (NW_S0_Darkness.nss) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Jan 7, 2002
//*:* 3.5 Player's Handbook (p. 216)
//*:**************************************************************************
//*:* Darkness
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 23, 2008
//*:* Complete Arcane (p. 133)
//*:**************************************************************************
//*:* Updated On: April 23, 2008
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_LIGHTDARK"

//*:* #include "GR_IN_ENERGY"

//*:**************************************************************************
//*:* Main function
//*:**************************************************************************
void main() {
    //*:**********************************************
    //*:* Declare major variables
    //*:**********************************************
    object  oCaster         = GetAreaOfEffectCreator();
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    spInfo.oTarget          = GetEnteringObject();
    spInfo.iDC              = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
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
    /*** NWN1 SPECIFIC ***/
        effect eInvis   = EffectInvisibility(INVISIBILITY_TYPE_DARKNESS);
        effect eDark    = EffectDarkness();
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eInvis = EffectConcealment(20, MISS_CHANCE_TYPE_NORMAL);
    effect eDur     = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink    = EffectLinkEffects(eInvis, eDur);
    /*** NWN1 SINGLE ***/ eLink = EffectLinkEffects(eLink, eDark);


    effect eListenDec   = EffectSkillDecrease(SKILL_LISTEN, 10);
    effect eSearchDec   = EffectSkillDecrease(SKILL_SEARCH, 10);
    effect eSpotDec     = EffectSkillDecrease(SKILL_SPOT, 10);

    effect ePallTwilightLink = EffectLinkEffects(eListenDec, eSearchDec);
    ePallTwilightLink = EffectLinkEffects(ePallTwilightLink, eSpotDec);


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    //*:* July 2003: If has darkness then do not put it on it again
    /*** NWN1 SPECIFIC ***/
        if(GetHasEffect(EFFECT_TYPE_DARKNESS, spInfo.oTarget)) {
            return;
        }
    /*** END NWN1 SPECIFIC ***/

    if(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        } else {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
        }
        if(GRGetSpellResisted(oCaster, spInfo.oTarget)!=2) {
            if(spInfo.iSpellID!=SPELL_GR_LSE_DARKNESS || !GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                GRRemoveLowerLvlLightEffectsInArea(spInfo.iSpellID, spInfo.lTarget);
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
                if(spInfo.iSpellID==SPELL_GR_PALL_OF_TWILIGHT) {
                    if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                        GRApplyEffectToObject(DURATION_TYPE_PERMANENT, ePallTwilightLink, spInfo.oTarget);
                    }
                }
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
