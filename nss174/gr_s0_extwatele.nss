//*:**************************************************************************
//*:*  GR_S0_EXTWATELE.NSS
//*:**************************************************************************
//*:* Extract Water Elemental
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: January 8, 2009
//*:* Spell Compendium (p. 86)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
/*** NWN2 SPECIFIC ***
//*:* #include "nwn2_inc_spells"
/*** END NWN2 SPECIFIC ***/

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

    int     iDieType          = 6;
    int     iNumDice          = MinInt(20, spInfo.iCasterLevel);
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
    int     iDurAmount        = 1;
    int     iDurType          = DUR_TYPE_TURNS;

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
    float   fDelay          = RoundsToSeconds(1)/2.0f;
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* int     iDurationType   = DURATION_TYPE_TEMPORARY;

    int     iCreatureSize   = GRGetCreatureSize(spInfo.oTarget);

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    /*** END NWN1 SPECIFIC ***/
    /*** NWN2 SPECIFIC ***
        //*:* fDuration     = ApplyMetamagicDurationMods(fDuration);
        //*:* iDurationType = ApplyMetamagicDurationTypeMods(iDurationType);
    /*** END NWN2 SPECIFIC ***/
    iDamage = GRGetSpellDamageAmount(spInfo, FORTITUDE_HALF, oCaster);
    if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eImp1    = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MAJOR);
    effect eImp2    = EffectVisualEffect(VFX_DUR_PROT_PREMONITION);
    effect eDur     = EffectLinkEffects(eImp1, eImp2);
    effect eDam     = EffectDamage(iDamage);
    effect eVis     = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eLink    = EffectLinkEffects(eVis, eDam);

    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_GR_EXTRACT_WATER_ELEMENTAL));
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spInfo.oTarget, fDelay);
    if(GRGetIsLiving(spInfo.oTarget)) {
        if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
            GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
            if(GetIsDead(spInfo.oTarget) && GRGetLastKiller(spInfo.oTarget)==oCaster) {

                string sSummon;
                switch(iCreatureSize) {
                    case CREATURE_SIZE_TINY:
                    case CREATURE_SIZE_SMALL:
                        sSummon = "x1_s_watersmall";
                        break;
                    case CREATURE_SIZE_MEDIUM:
                    case CREATURE_SIZE_LARGE:
                        sSummon = "gr_s_water";
                        break;
                    case CREATURE_SIZE_HUGE:
                    default:
                        sSummon = "nw_s_waterhuge";
                        break;
                }
                effect eSummon = EffectSummonCreature(sSummon, VFX_IMP_DISPEL);
                GRApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, GetLocation(spInfo.oTarget), fDuration);
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
