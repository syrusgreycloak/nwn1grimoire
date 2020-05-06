//*:**************************************************************************
//*:*  GR_S0_JETSTEAM.NSS
//*:**************************************************************************
//*:* Jet of Steam
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 16, 2008
//*:* Complete Mage (p. 108)
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

    int     iDieType          = 4;
    int     iNumDice          = MinInt(5, spInfo.iCasterLevel);
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
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(30.0);

    object oTarget2, oNextTarget;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
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
    effect eDamage;
    effect eVis     = EffectVisualEffect(VFX_COM_HIT_FIRE);
    effect eBeam    = EffectBeam(VFX_BEAM_BLACK, oCaster, BODY_NODE_HAND);
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    int iCnt = 1;

    oTarget2 = GetNearestObject(OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, OBJECT_SELF, iCnt);
    while(GetIsObjectValid(oTarget2) && GetDistanceToObject(oTarget2) <= fRange) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetPosition(oCaster));
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(spInfo.oTarget!=oCaster && oTarget2==spInfo.oTarget) {
                if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, SAVING_THROW_TYPE_FIRE, fDelay);
                        if(GRGetSpellHasSecondaryDamage(spInfo)) {
                            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                iDamage = iSecDamage;
                            }
                        }
                        eDamage = EffectDamage(iDamage, DAMAGE_TYPE_FIRE);
                        eLink = EffectLinkEffects(eVis, eDamage);
                        if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        if(iDamage > 0) {
                            fDelay = GetSpellEffectDelay(GetLocation(spInfo.oTarget), spInfo.oTarget);
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        }
                    }
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, 1.0);
                    oNextTarget = spInfo.oTarget;
                    eBeam = EffectBeam(VFX_BEAM_BLACK, oNextTarget, BODY_NODE_CHEST);
                }
           }
           spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetPosition(OBJECT_SELF));
        }
        iCnt++;
        oTarget2 = GetNearestObject(OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, OBJECT_SELF, iCnt);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
