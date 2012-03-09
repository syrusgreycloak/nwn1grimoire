//*:**************************************************************************
//*:*  GR_S0_LIGHTLEAP.NSS
//*:**************************************************************************
//*:* Lightning Leap
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 17, 2008
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

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(60.0);

    object oTarget2, oNextTarget;

    int     iBeamType       = GRGetEnergyBeamType(iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    object  oFamiliar       = GetAssociate(ASSOCIATE_TYPE_FAMILIAR);
    string  sTag            = "GR_LL_CST_COPY";
    int     iCnt            = 1;

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
    if(GetDistanceBetweenLocations(GetLocation(oCaster), spInfo.lTarget)<fRange) {
        fRange = GetDistanceBetweenLocations(GetLocation(oCaster), spInfo.lTarget);
    } else if(GetDistanceBetweenLocations(GetLocation(oCaster), spInfo.lTarget)>fRange) {
        spInfo.lTarget = GenerateNewLocationFromLocation(GetLocation(oCaster), fRange, GetFacing(oCaster), GetFacing(oCaster));
    }
    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eDamage;
    effect eVis     = EffectVisualEffect(VFX_COM_HIT_FIRE);
    effect eBeam    = EffectBeam(iBeamType, oCaster, BODY_NODE_HAND);
    effect eInvis   = EffectVisualEffect(VFX_DUR_CUTSCENE_INVISIBILITY);
    effect eSmoke   = EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_1);
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    SignalEvent(oCaster, EventSpellCastAt(oCaster, SPELL_GR_LIGHTNING_LEAP, FALSE));
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, oCaster);
    DelayCommand(0.3, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvis, oCaster, GRGetDuration(1)));
    object oNewPC = CopyObject(oCaster, spInfo.lTarget, OBJECT_INVALID, sTag);
    SetPlotFlag(oNewPC, TRUE);

    oTarget2 = GetNearestObject(OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, OBJECT_SELF, iCnt);
    while(GetIsObjectValid(oTarget2) && GetDistanceToObject(oTarget2) <= fRange) {
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetPosition(oCaster));
        while(GetIsObjectValid(spInfo.oTarget)) {
            if(spInfo.oTarget!=oCaster && oTarget2==spInfo.oTarget) {
                if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
                    SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, spInfo.iSpellID));
                    if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                        iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                        if(GRGetSpellHasSecondaryDamage(spInfo)) {
                            iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                            if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                                iDamage = iSecDamage;
                            }
                        }
                        eDamage = EffectDamage(iDamage, iEnergyType);
                        eLink = EffectLinkEffects(eVis, eDamage);
                        if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                        if(iDamage > 0) {
                            fDelay = GetSpellEffectDelay(GetLocation(spInfo.oTarget), spInfo.oTarget);
                            DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget));
                        }
                    }
                    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, spInfo.oTarget, 1.0);
                    oNextTarget = spInfo.oTarget;
                    eBeam = EffectBeam(iBeamType, oNextTarget, BODY_NODE_CHEST);
                }
           }
           spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetPosition(OBJECT_SELF));
        }
        iCnt++;
        oTarget2 = GetNearestObject(OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, OBJECT_SELF, iCnt);
    }
    GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeam, oNewPC, 1.0);
    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eSmoke, oNewPC);
    DelayCommand(0.3, GRApplyEffectToObject(DURATION_TYPE_TEMPORARY, eInvis, oNewPC, GRGetDuration(1)));
    DelayCommand(0.3, SetPlotFlag(oNewPC, FALSE));
    DelayCommand(0.4, DestroyObject(oNewPC));
    DelayCommand(0.5, AssignCommand(oCaster, ActionDoCommand(ClearAllActions())));
    DelayCommand(0.6, AssignCommand(oCaster, ActionJumpToLocation(spInfo.lTarget)));

    GRRemoveSpellEffects(SPELL_GR_LIGHTNING_LEAP, oCaster);
    if(GetIsObjectValid(oFamiliar)) {
        DelayCommand(0.5, AssignCommand(oFamiliar, ActionDoCommand(ClearAllActions())));
        DelayCommand(0.6, AssignCommand(oFamiliar, ActionJumpToLocation(spInfo.lTarget)));
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
