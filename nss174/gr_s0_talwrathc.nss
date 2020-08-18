//*:**************************************************************************
//*:*  GR_S0_TALWRATHC.NSS
//*:**************************************************************************
//*:* Talos' Wrath (SG_S0_TalWrath.nss) 2003 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 31, 2003
//*:*
//*:**************************************************************************
//*:* Updated On: February 26, 2008
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
    object  oCaster         = GetAreaOfEffectCreator();

    if(!GetIsObjectValid(oCaster)) {
        DestroyObject(OBJECT_SELF);
        return;
    }

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDieType          = 6;
    int     iNumDice          = MinInt(15, spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    //*:* int     iDurAmount        = spInfo.iCasterLevel;
    //*:* int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Set the info about the spell on the caster
    //*:**********************************************
    GRSetSpellInfo(spInfo, oCaster);

    //*:**********************************************
    //*:* Energy Spell Info
    //*:**********************************************
    int     iEnergyType     = GRGetEnergyDamageType(GRGetSpellEnergyDamageType(spInfo.iSpellID));
    int     iSpellType      = GRGetEnergySpellType(iEnergyType);

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
    float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    location lRgtLocation   = GetLocalLocation(OBJECT_SELF, "MY_RGT_LOC");
    location lLftLocation   = GetLocalLocation(OBJECT_SELF, "MY_LFT_LOC");
    location lFrtLocation   = GetLocalLocation(OBJECT_SELF, "MY_FRT_LOC");
    location lBckLocation   = GetLocalLocation(OBJECT_SELF, "MY_BCK_LOC");

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_LIGHTNING_M, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

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
    effect eImp = EffectVisualEffect(VFX_IMP_LIGHTNING_M);
    effect eImp2= EffectVisualEffect(VFX_IMP_DOOM);
    effect eVis = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1);
    effect eDam;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spInfo.lTarget);

    spInfo.oTarget = GetFirstInPersistentObject(OBJECT_SELF, OBJECT_TYPE_CREATURE | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_TALOS_WRATH));
            fDelay = GetRandomDelay(0.4, 1.75);
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eImp2, spInfo.oTarget);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget, fDelay)) {
                iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                if(GRGetSpellHasSecondaryDamage(spInfo)) {
                    iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                    if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                        iDamage = iSecDamage;
                    }
                }
                eDam = EffectDamage(iDamage, iEnergyType);
                if(iSecDamage>0) eDam = EffectLinkEffects(eDam, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                eLink = EffectLinkEffects(eDam, eImp);
                if(iDamage > 0) {
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
                DelayCommand(fDelay+0.1, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp, lRgtLocation));
                DelayCommand(fDelay+0.5, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp, lLftLocation));
                DelayCommand(fDelay+0.25, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp, lFrtLocation));
                DelayCommand(fDelay+0.37, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImp, lBckLocation));
            }
        }
        spInfo.oTarget = GetNextInPersistentObject(OBJECT_SELF, OBJECT_TYPE_CREATURE | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR);
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
