//*:**************************************************************************
//*:*  GR_S2_CHAOSSHLD.NSS
//*:**************************************************************************
//*:* The dreaded ChaosShield (x2_s3_chaosshld)  Copyright (c) 2003 Bioware Corp.
//*:* Created By: Georg Zoeller  Created On: 2003-10-17
//*:*
//*:**************************************************************************
//*:* Updated On: January 10, 2007
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

    object  oItem           = GetSpellCastItem();

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

    int     iChance         = spInfo.iCasterLevel*2;

    if(d100()>iChance) return;

    if(GetHasSpellEffect(spInfo.iSpellID, spInfo.oTarget)) return;


    if(GetIsObjectValid(oItem)) {
        int bMelee = GetDistanceBetween(oCaster, spInfo.oTarget)< 4.0f;
        int iRandom;

        FloatingTextStrRefOnCreature(100925, oCaster);
        FloatingTextStrRefOnCreature(100925, spInfo.oTarget);

        if(!bMelee) {
           iRandom = Random(4);
        } else {
           iRandom = Random(4)+4;
        }

        effect eVis;
        effect eDur;
        effect eEffect;
        effect eDur2;
        switch(iRandom) {
            case 0:
                eEffect = EffectStunned();
                eDur = EffectBeam(VFX_BEAM_CHAIN,OBJECT_SELF, BODY_NODE_CHEST);
                eVis = EffectVisualEffect(VFX_COM_SPARKS_PARRY);
                eDur = EffectLinkEffects(eEffect, eDur);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, GRGetDuration(d2()));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                break;
            case 1:
                eEffect = EffectDamage(d6()+1, DAMAGE_TYPE_FIRE);
                eVis = EffectBeam(444, OBJECT_SELF, BODY_NODE_CHEST);
                eDur = EffectVisualEffect(VFX_DUR_INFERNO);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 4.0f);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, spInfo.oTarget);
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                }
                DelayCommand(0.3f, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, 4.0f));
                break;
            case 2:
                eEffect = EffectDamage(d8()+1, DAMAGE_TYPE_ELECTRICAL);
                eVis = EffectBeam(VFX_BEAM_LIGHTNING, OBJECT_SELF, BODY_NODE_CHEST);
                eDur = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spInfo.oTarget, 4.0f);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eEffect, spInfo.oTarget);
                DelayCommand(0.3f,GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDur, spInfo.oTarget));
                break;
            case 3:
                eEffect = EffectBlindness();
                eDur = EffectBeam(VFX_BEAM_BLACK, OBJECT_SELF, BODY_NODE_CHEST);
                eDur2 =EffectVisualEffect(VFX_DUR_BLIND);
                eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
                eDur = EffectLinkEffects(eEffect, eDur);
                eDur = EffectLinkEffects(eDur2, eDur);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, GRGetDuration(d2()));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                break;
            //------------------------------------------------------------------
            // Melee
            //------------------------------------------------------------------
            case 4:
                eEffect = EffectSlow();
                eVis = EffectVisualEffect(VFX_IMP_SLOW);
                eDur = EffectVisualEffect(VFX_DUR_ICESKIN);
                eDur = EffectLinkEffects(eEffect, eDur);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, GRGetDuration(d4()));
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                break;
            case 5:
                eEffect = EffectKnockdown();
                eVis = EffectVisualEffect(VFX_IMP_STUN);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, spInfo.oTarget, 6.0f);
                break;
            case 6:
                eEffect = EffectDamage(d4(2),DAMAGE_TYPE_FIRE);
                eDur = EffectVisualEffect(VFX_DUR_ELEMENTAL_SHIELD);
                eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eEffect, spInfo.oTarget, 6.0f);
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                }
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, 4.0f);
                break;
            case 7:
                eEffect = EffectMissChance(50, MISS_CHANCE_TYPE_VS_MELEE);
                eDur = EffectVisualEffect(VFX_DUR_STONEHOLD);
                eDur = EffectLinkEffects(eDur, eEffect);
                eDur = EffectLinkEffects(EffectCutsceneImmobilize(), eDur);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget);
                GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, GRGetDuration(d3()));
                break;
        }
    }
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
