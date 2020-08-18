//*:**************************************************************************
//*:*  GR_S0_CAUSTICSMB.NSS
//*:**************************************************************************
//*:* Caustic Smoke
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 16, 2008
//*:* Complete Mage (p. 98)
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
    object  oCaster         = GetAreaOfEffectCreator();
    struct SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    int     iDurAmount        = 2;
    int     iDurType          = DUR_TYPE_ROUNDS;

    spInfo.oTarget         = GetExitingObject();

    spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    float   fDuration       = GRGetSpellDuration(spInfo);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eAttackDec   = EffectAttackDecrease(5);
    effect eSpotDec     = EffectSkillDecrease(SKILL_SPOT, 5);
    effect eSearchDec   = EffectSkillDecrease(SKILL_SEARCH, 5);
    effect eCausticLink = EffectLinkEffects(eAttackDec, eSpotDec);
    eCausticLink = EffectLinkEffects(eCausticLink, eSearchDec);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRRemoveSpellEffects(SPELL_GR_CAUSTIC_SMOKE, spInfo.oTarget, oCaster);
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_CAUSTIC_SMOKE));
    if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC)) {
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eCausticLink, spInfo.oTarget, fDuration);
    }
}
//*:**************************************************************************
//*:**************************************************************************
