//*:**************************************************************************
//*:*  GR_S0_HUNDARKA.NSS
//*:**************************************************************************
//*:* Hungry Darkness: OnEnter
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 29, 2008
//*:* Complete Arcane (p. 134)
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


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget)) {
        if(GetTag(spInfo.oTarget)=="GR_HUNDARK_BAT" && GetFactionEqual(spInfo.oTarget, oCaster)) {
            AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
            AssignCommand(spInfo.oTarget, ActionDoCommand(JumpToLocation(spInfo.lTarget)));
        } else if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(OBJECT_SELF, spInfo.iSpellID));

            GRRemoveLowerLvlLightEffectsInArea(spInfo.iSpellID, spInfo.lTarget);
            object oBat = GetNearestObjectByTag("GR_HUNDARK_BAT");
            if(!GetFactionEqual(spInfo.oTarget, oCaster)) {
                AssignCommand(oBat, ActionAttack(spInfo.oTarget));
            }

            //*:* July 2003: If has darkness then do not put it on it again
            /*** NWN1 SPECIFIC ***/
                if(GetHasEffect(EFFECT_TYPE_DARKNESS, spInfo.oTarget)) {
                    return;
                } else {
            /*** END NWN1 SPECIFIC ***/
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
                /*** NWN1 SINGLE ***/ }
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
