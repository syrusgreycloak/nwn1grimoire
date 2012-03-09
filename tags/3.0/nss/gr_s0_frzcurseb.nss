//*:**************************************************************************
//*:*  GR_S0_FRZCURSEB.NSS
//*:**************************************************************************
//*:*
//*:* Freezing Curse - OnHit
//*:* Swords & Sorcery:Relics & Rituals 1
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 31, 2003
//*:**************************************************************************
//*:* Updated On: February 25, 2008
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
    object  oItem           = GetSpellCastItem();
    struct  SpellStruct spInfo = GRGetSpellStruct(GRGetAOESpellId(oItem), oItem);

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
    //GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, OBJECT_SELF));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, OBJECT_SELF), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, OBJECT_SELF);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iStartHP        = GetLocalInt(spInfo.oTarget, "GR_FRZCURSE_HP");
    int     iCurrHP         = GetCurrentHitPoints(spInfo.oTarget);

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
    effect eDam     = EffectDamage(iCurrHP+11, DAMAGE_TYPE_MAGICAL, DAMAGE_POWER_PLUS_TWENTY);
    effect eVis     = EffectVisualEffect(VFX_COM_CHUNK_RED_LARGE);
    effect eImp     = EffectVisualEffect(VFX_FNF_ICESTORM);
    effect eDeath   = EffectDeath();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GetIsObjectValid(spInfo.oTarget)) {
        if( (iStartHP-iCurrHP>=5) ||
            (iCurrHP>iStartHP && (GetMaxHitPoints(spInfo.oTarget)-iCurrHP)>5)
        ) {
            if(GRGetHasSpellEffect(SPELL_GR_FREEZING_CURSE, spInfo.oTarget)) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRRemoveSpellEffects(SPELL_GR_FREEZING_CURSE, spInfo.oTarget);
                if(!GetIsImmune(spInfo.oTarget, IMMUNITY_TYPE_DEATH)) {
                    GRClearSpellInfo(spInfo.iSpellID, oItem);
                    DelayCommand(0.3, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                } else {
                    GRClearSpellInfo(spInfo.iSpellID, oItem);
                    DelayCommand(0.3, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                }
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, OBJECT_SELF);
}
//*:**************************************************************************
//*:**************************************************************************
