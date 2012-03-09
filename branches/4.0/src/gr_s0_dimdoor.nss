//*:**************************************************************************
//*:*  GR_S0_DIMDOOR.NSS
//*:**************************************************************************
//*:* Dimension Door
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: March 31, 2003
//*:* 3.5 Player's Handbook (p. 221)
//*:*
//*:* Flee the Scene
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 28, 2008
//*:* Complete Arcane (p. 134)
//*:**************************************************************************
//*:* Updated On: April 28, 2008
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

    location lCasterLoc     = GetLocation(oCaster);

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
    effect eVis     = EffectVisualEffect(VFX_FNF_SMOKE_PUFF);
    effect eVis1    = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
    effect eInvis   = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);


    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, spInfo.iSpellID, FALSE));
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis1, spInfo.lTarget);
    if(spInfo.iSpellID==SPELL_I_FLEE_THE_SCENE) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvis, oCaster, GRGetDuration(1));
    }

    AssignCommand(oCaster, ClearAllActions());
    AssignCommand(oCaster, ClearAllActions(TRUE));
    GRRemoveSpellEffects(SPELL_GR_BLACKFLAME, oCaster);

    if(spInfo.iSpellID==SPELL_I_FLEE_THE_SCENE) {
        object oMajorImage = CopyObject(oCaster, GetLocation(oCaster), oCaster, ObjectToString(oCaster));
        DestroyObject(oMajorImage, GRGetDuration(1));
    }
    DelayCommand(1.5f, AssignCommand(oCaster, JumpToLocation(spInfo.lTarget)));
    DelayCommand(1.6f, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, lCasterLoc));

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
