//*:**************************************************************************
//*:*  GR_S2_ENERVSHDW.NSS
//*:**************************************************************************
//*:* Enervating Shadow
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 24, 2008
//*:* Complete Arcane (p. 133)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
//#include "GR_IN_SPELLS" - included in GR_IN_LIGHTDARK
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    //*:* int     iDieType          = 0;
    //*:* int     iNumDice          = 0;
    //*:* int     iBonus            = 0;
    //*:* int     iDamage           = 0;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 5;
    int     iDurType          = DUR_TYPE_TURNS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
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
    effect eDur1    = EffectVisualEffect(VFX_DUR_GHOST_SMOKE);
    effect eDur2    = EffectVisualEffect(VFX_DUR_GHOST_SMOKE_2);
    effect eDur3    = EffectVisualEffect(VFX_DUR_GHOSTLY_PULSE);
    effect eConceal = EffectConcealment(100);
    effect eAOE     = GREffectAreaOfEffect(AOE_MOB_ENERVATING_SHADOW);

    effect eLink    = EffectLinkEffects(eDur1, eDur2);
    eLink = EffectLinkEffects(eDur3, eConceal);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_I_ENERVATING_SHADOW, FALSE));
    if(!GetIsAreaAboveGround(GetArea(oCaster)) || !(GetIsAreaNatural(GetArea(oCaster)) && GetIsDay())) {
        if(!GRGetHigherLvlLightEffectsInArea(SPELL_I_ENERVATING_SHADOW, GetLocation(oCaster))) {
            GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oCaster);
        } else if(GetIsPC(oCaster)) {
            SendMessageToPC(oCaster, GetStringByStrRef(16939267));
        }
    } else if(GetIsPC(oCaster)) {
        SendMessageToPC(oCaster, GetStringByStrRef(16939268));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
