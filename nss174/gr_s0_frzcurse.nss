//*:**************************************************************************
//*:*  GR_S0_FRZCURSE.NSS
//*:**************************************************************************
//*:*
//*:* Freezing Curse
//*:* Swords & Sorcery: Relics & Rituals I
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
    object  oCaster         = OBJECT_SELF;
    struct  SpellStruct spInfo = GRGetSpellStruct(GetSpellId(), oCaster);

    int     iDieType          = 0;
    int     iNumDice          = 0;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 5;
    int     iDurType          = DUR_TYPE_HOURS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

    spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

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

    object  oPCHide;
    int     iOnHitSpell     = IP_CONST_ONHIT_CASTSPELL_FREEZING_CURSE_HIT;
    int     iVisualType1    = GRGetEnergyVisualType(VFX_IMP_FROST_L, iEnergyType);
    int     iVisualType2    = GRGetEnergyVisualType(VFX_IMP_FROST_S, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    itemproperty ipOnHitCastSpell = ItemPropertyOnHitCastSpell(iOnHitSpell, spInfo.iCasterLevel);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eVis     = EffectVisualEffect(iVisualType1);
    effect eImp     = EffectVisualEffect(VFX_DUR_ICESKIN);
    effect eImp2    = EffectVisualEffect(iVisualType2);
    effect ePara    = EffectCutsceneParalyze();
    effect eDam     = EffectDamage(iDamage, iEnergyType);
    effect eLink1   = EffectLinkEffects(eImp, ePara);
    effect eLink2   = EffectLinkEffects(eDam, eImp2);

    if(iSecDamage>0) eLink2 = EffectLinkEffects(eLink2, EffectDamage(iSecDamage, spInfo.iSecDmgType));
    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);

    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_FREEZING_CURSE));
    if(TouchAttackMelee(spInfo.oTarget,FALSE)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, iSaveType)) {
                GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink1, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp, spInfo.oTarget);

                oPCHide = GetItemInSlot(INVENTORY_SLOT_CARMOUR, spInfo.oTarget);
                if(!GetIsObjectValid(oPCHide)) {
                    oPCHide=CreateItemOnObject("x2_it_emptyskin",spInfo.oTarget);
                }
                GRIPSafeAddItemProperty(oPCHide, ipOnHitCastSpell, fDuration);
                AssignCommand(spInfo.oTarget, ActionEquipItem(oPCHide, INVENTORY_SLOT_CARMOUR));
                SetLocalInt(spInfo.oTarget, "GR_FRZCURSE_HP", GetCurrentHitPoints(spInfo.oTarget));
                GRSetAOESpellId(spInfo.iSpellID, oPCHide);
                GRSetSpellInfo(spInfo, oPCHide);
            } else {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink2, spInfo.oTarget);
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
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
