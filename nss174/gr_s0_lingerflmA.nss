//*:**************************************************************************
//*:*  GR_S0_LINGERFLMA.NSS
//*:**************************************************************************
//*:* Lingering Flames: OnEnter
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 18, 2008
//*:* Complete Mage (p. 110)
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
    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GRGetAOESpellId());

    spInfo.oTarget = GetEnteringObject();

    //*:* int     iDieType            = 6;
    //*:* int     iNumDice            = MinInt(15, spInfo.iCasterLevel);
    //*:* int     iBonus              = 0;
    int     iDamage             = 0;
    int     iSecDamage          = 0;
    //*:* int     iDurAmount          = 3;
    //*:* int     iDurType            = DUR_TYPE_ROUNDS;

    //*:* spInfo = GRSetSpellDamageInfo(spInfo, iDieType, iNumDice, iBonus);
    //*:* spInfo = GRSetSpellDurationInfo(spInfo, iDurAmount, iDurType);

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
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    //*:* float   fRange          = FeetToMeters(15.0);
    //*:* float   fDelay          = 0.0;
    int     iObjectType     = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    int     bSRCheckDone    = GetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_SRCHECKDONE");
    int     bResisted       = GetLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_RESISTED");
    int     bDoSRCheck      = (!bSRCheckDone && !bResisted);
    int     bResistSpell    = (bDoSRCheck ? GRGetSpellResisted(oCaster, spInfo.oTarget) : bResisted);


    DeleteLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_SRCHECKDONE");
    DeleteLocalInt(spInfo.oTarget, "GR_"+IntToString(spInfo.iSpellID)+"_RESISTED");

    //if(GRGetIsUnderwater(oCaster) && iEnergyType==DAMAGE_TYPE_SONIC) fRange *= 2;
    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    /*if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        fRange *= 2;
        iAOEType = AOE_PER_FOGFIRE_WIDE;
        sAOEType = AOE_TYPE_FOGFIRE_WIDE;
    }*/
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
    effect eVisual      = EffectVisualEffect(iVisualType);
    //effect eExplode     = EffectVisualEffect(iExplodeType);
    //*:* effect eAOE         = GREffectAreaOfEffect(iAOEType, "gr_s0_lingerflma", "gr_s0_lingerflmc", "gr_s0_aoeexit");
    effect eDamage;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
        SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
        if(!bResistSpell) {
            spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);

            iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType);
            if(GRGetSpellHasSecondaryDamage(spInfo)) {
                iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster, iSaveType);
                if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                    iDamage = iSecDamage;
                }
            }

            eDamage = EffectDamage(iDamage, iEnergyType);
            eLink = EffectLinkEffects(eDamage, eVisual);
            if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
            if(iDamage > 0) {
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                }
            }
        }
    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
