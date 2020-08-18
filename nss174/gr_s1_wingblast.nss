//*:**************************************************************************
//*:*  SPELL_TEMPLATE.NSS
//*:**************************************************************************
//*:* Dragon Wing Buffet (NW_S1_WingBlast) Copyright (c) 2001 Bioware Corp.
//*:* Created By: Preston Watamaniuk  Created On: Feb 4, 2002
//*:**************************************************************************
/*
    The dragon will launch into the air, knockdown
    all opponents who fail a Reflex Save and then
    land on one of those opponents doing damage
    up to a maximum of the Dragons HD + 10.
*/
//*:**************************************************************************
//*:* Updated On: November 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_DRAGONS"

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
    int     iDamage           = Random(spInfo.iCasterLevel)+11;
    //*:* int     iSecDamage        = 0;
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_ROUNDS;

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

    float   fDuration;       //= GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    float   fDelay          = 0.0f;

    spInfo.iDC = GRGetDragonWingBuffetDC(GRGetDragonAge(oCaster));
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
    effect eAppear;
    effect eKnockDown = EffectKnockdown();
    effect eDam = EffectDamage(iDamage, DAMAGE_TYPE_BLUDGEONING);
    /*** NWN1 SINGLE ***/ effect eVis = EffectVisualEffect(VFX_IMP_PULSE_WIND);
    //*** NWN2 SINGLE ***/ effect eVis = EffectVisualEffect(VFX_HIT_SPELL_SONIC);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    location lLocal = GetLocation(OBJECT_SELF);
    /*** NWN2 SPECIFIC ***

	effect eWingBuffet = EffectNWN2SpecialEffectFile("fx_reddr_wbuffet.sef");
	effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);

        PlayDragonBattleCry();
	PlayCustomAnimation(OBJECT_SELF, "*specialattack01", 0, 1.0f);
	DelayCommand(0.5f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eWingBuffet, OBJECT_SELF, 3.0f));
	DelayCommand(1.0f, GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eShake, lLocal));
    /*** END NWN2 SPECIFIC ***/


    /*** NWN1 SINGLE ***/ GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oCaster);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spInfo.lTarget, TRUE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
            /*** NWN1 SINGLE ***/ if(GetCreatureSize(spInfo.oTarget)!=CREATURE_SIZE_HUGE) {
                if(!GRGetSaveResult(SAVING_THROW_REFLEX, spInfo.oTarget, spInfo.iDC)) {
                    /*** NWN1 SPECIFIC ***/
                        DelayCommand(0.01, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spInfo.oTarget));
                        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockDown, spInfo.oTarget, fDuration);
                    /*** END NWN1 SPECIFIC ***/
                    /*** NWN2 SPECIFIC ***
                        fDelay = GetDistanceBetween(oCaster, spInfo.oTarget)/20;
                        fDuration = GetRandomDelay(3.0, 10.0);
                   	DelayCommand(0.5 + fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eKnockdown, oTarget, fDuration));
                        DelayCommand(0.5 + fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget, 1.0f));
                        DelayCommand(1.5 + fDelay, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget, 1.0f));
                    /*** END NWN2 SPECIFIC ***/
                }
            /*** NWN1 SINGLE ***/ }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_GARGANTUAN, spInfo.lTarget);
    }
    /*** NWN1 SPECIFIC ***/
        //Apply the VFX impact and effects
        eAppear = EffectDisappearAppear(lLocal);
        GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAppear, oCaster, fDuration);
    /*** END NWN1 SPECIFIC ***/

    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
