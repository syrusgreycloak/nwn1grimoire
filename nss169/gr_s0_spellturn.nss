//*:**************************************************************************
//*:*  GR_S0_SPELLTURN.NSS
//*:**************************************************************************
//*:* Spell Turning (sg_s0_spellturn.nss) 2004 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 10, 2004
//*:* 3.5 Player's Handbook (p. 282)
//*:*
//*:* Lesser (Minor) Spell Turning
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: May 10, 2004
//*:* 2E Tome of Magic
//*:**************************************************************************
//*:* Updated On: March 3, 2008
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

    int     iDieType          = 4;
    int     iNumDice          = 1;
    int     iBonus            = (spInfo.iSpellID==SPELL_GR_LESSER_SPELL_TURNING ? 0 : 6);
    int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = (spInfo.iSpellID==SPELL_GR_LESSER_SPELL_TURNING ? spInfo.iCasterLevel*3 : spInfo.iCasterLevel*10);
    int     iDurType          = (spInfo.iSpellID==SPELL_GR_LESSER_SPELL_TURNING ? DUR_TYPE_ROUNDS : DUR_TYPE_TURNS);

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
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType     = (spInfo.iSpellID==SPELL_GR_LESSER_SPELL_TURNING ? VFX_DUR_GLOBE_MINOR : VFX_DUR_GLOBE_INVULNERABILITY);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImpVis = EffectVisualEffect(iVisualType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetHasSpellEffect(SPELL_GR_LESSER_SPELL_TURNING, spInfo.oTarget)) {
        GRRemoveSpellEffects(SPELL_GR_LESSER_SPELL_TURNING, spInfo.oTarget);
        DeleteLocalInt(spInfo.oTarget, "GR_SPELLTURN_LEVELS");
    }
    if(GetHasSpellEffect(SPELL_SPELL_TURNING, spInfo.oTarget) && spInfo.iSpellID!=SPELL_GR_LESSER_SPELL_TURNING) {
        GRRemoveSpellEffects(SPELL_SPELL_TURNING, spInfo.oTarget);
        DeleteLocalInt(spInfo.oTarget, "GR_SPELLTURN_LEVELS");
    } else {
        FloatingTextStringOnCreature(GetName(spInfo.oTarget) + GetStringByStrRef(16939266), oCaster, FALSE);
        return;
    }

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eImpVis, spInfo.oTarget, fDuration);
    SetLocalInt(spInfo.oTarget, "GR_SPELLTURN_LEVELS", iDamage);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
