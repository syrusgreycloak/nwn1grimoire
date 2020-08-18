//*:**************************************************************************
//*:*  GR_S0_TRANSPOSE.NSS
//*:**************************************************************************
//*:* Baleful/Benign Transposition (sg_s0_transpose.nss) 2006 Karl Nickels (Syrus Greycloak)
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 9, 2006
//*:* Spell Compendium (p. 23 & 27)
//*:**************************************************************************
//*:* Updated On: March 12, 2008
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fDelay          = 0.0f;
    //*:* float   fRange          = FeetToMeters(15.0);

    int     bTranspose      = TRUE;
    int     bTargetHostile  = !GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_ALLALLIES, oCaster);
    location lCaster;

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
    effect eVis     = EffectVisualEffect(VFX_IMP_HEALING_G);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(spInfo.iSpellID==SPELL_GR_BALEFUL_TRANSPOSITION && bTargetHostile) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, bTargetHostile));
        if(GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            bTranspose = FALSE;
        } else if(GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
            bTranspose = FALSE;
        }
    } else if(spInfo.iSpellID==SPELL_GR_BENIGN_TRANSPOSITION && bTargetHostile) {
        bTranspose = FALSE;
    } else {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID, bTargetHostile));
    }

    if(bTranspose) {
        spInfo.lTarget = GetLocation(spInfo.oTarget);
        lCaster = GetLocation(oCaster);
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lCaster);
        AssignCommand(spInfo.oTarget, ClearAllActions(TRUE));
        AssignCommand(oCaster, ClearAllActions(TRUE));
        DelayCommand(0.1, AssignCommand(spInfo.oTarget, JumpToLocation(lCaster)));
        DelayCommand(0.1, AssignCommand(oCaster, JumpToLocation(spInfo.lTarget)));
        DelayCommand(0.15, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
