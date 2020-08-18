//*:**************************************************************************
//*:*  GR_S0_METSWARM.NSS
//*:**************************************************************************
//*:*
//*:* Meteor Swarm
//*:* 3.0 Player's Handbook (p. 228)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 29, 2005
//*:**************************************************************************
//*:* Updated On: November 2, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
/*** NWN1 SPECIFIC ***/
#include "GR_IN_SPELLS"         // for NWN2 - INCLUDED IN GR_IN_METSWARM
#include "GR_IN_ENERGY"         // for NWN2 - INCLUDED IN GR_IN_METSWARM
/*** END NWN1 SPECIFIC ***/
//*** NWN2 SINGLE ***/ #include "GR_IN_METSWARM"

#include "GR_IN_SPELLHOOK"

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
/*** NWN1 SPECIFIC ***/
void GRDoBlast(location lTarget, int iMetamagic, int iEnergyType, int iVisualType, object oCaster = OBJECT_SELF) {

    struct  SpellStruct spInfo = GRGetSpellInfoFromObject(GetSpellId(), oCaster);
    float   fBlastRadius    = FeetToMeters(40.0);
    effect  eBlast          = EffectVisualEffect(GRGetEnergyExplodeType(iEnergyType, SPELL_METEOR_SWARM));
    effect  eVis            = EffectVisualEffect(iVisualType);
    effect  eDam;
    effect  eLink;
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);
    object  oTarget;
    int     iDC;
    int     iDamage;

    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eBlast, spInfo.lTarget);

    spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fBlastRadius, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    while(GetIsObjectValid(spInfo.oTarget)) {
        if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster)) {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_METEOR_SWARM));
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                iDamage = GRGetMetamagicAdjustedDamage(6, 6, iMetamagic);
                iDamage = GRGetReflexAdjustedDamage(iDamage, spInfo.oTarget, spInfo.iDC, iSaveType);
                if(iDamage>0) {
                    eDam = EffectDamage(iDamage, iEnergyType);
                    eLink = EffectLinkEffects(eDam, eVis);
                    GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                    if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                        GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                    }
                }
            }
        }
        spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fBlastRadius, spInfo.lTarget, FALSE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
    }
}
/*** END NWN1 SPECIFIC ***/
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
    int     iNumDice          = 24;
    int     iBonus            = 0;
    int     iDamage           = 0;
    int     iSecDamage        = 0;
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
    //*:* float   fRange          = FeetToMeters(15.0);

    int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
    int     iSaveType       = GRGetEnergySaveType(iEnergyType);

    float   fDist           = FeetToMeters(31.8198); //  distance in each direction to make diamond pattern
    location lBlast1        = GenerateNewLocationFromLocation(spInfo.lTarget, fDist, 0.0, GetFacing(oCaster));
    location lBlast2        = GenerateNewLocationFromLocation(spInfo.lTarget, fDist, 90.0, GetFacing(oCaster));
    location lBlast3        = GenerateNewLocationFromLocation(spInfo.lTarget, fDist, 180.0, GetFacing(oCaster));
    location lBlast4        = GenerateNewLocationFromLocation(spInfo.lTarget, fDist, 270.0, GetFacing(oCaster));

    float   fTargetDistance = GetDistanceBetweenLocations(GetLocation(oCaster), spInfo.lTarget) - fDist;
    int     bValid          = FALSE;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    iDamage = GRGetSpellDamageAmount(spInfo);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    effect eMeteor  = EffectVisualEffect(VFX_FNF_METEOR_SWARM);
    effect eVis     = EffectVisualEffect(iVisualType);
    effect eDam;
    effect eLink;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        //*:**********************************************
        //*:* Check for a creature in the path of the
        //*:* meteors
        //*:**********************************************
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPELLCYLINDER, fTargetDistance, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE, GetPosition(oCaster));

        while(GetIsObjectValid(spInfo.oTarget) && !bValid) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
                bValid = TRUE;
            } else {
                spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPELLCYLINDER, fTargetDistance, spInfo.lTarget, TRUE,
                OBJECT_TYPE_CREATURE, GetPosition(oCaster));
            }
        }
        if(GetIsObjectValid(spInfo.oTarget)) {
            // Apply all damage to first target in the path
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_METEOR_SWARM));
                eDam = EffectDamage(iDamage, iEnergyType);
                eLink = EffectLinkEffects(eDam, eVis);
                GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                    GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                }
            }
        } else {
            //--------------------------------------------------------------------------
            // No creature in path of meteors - do blast pattern
            //--------------------------------------------------------------------------
            GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eMeteor, spInfo.lTarget);
            DelayCommand(1.5, GRDoBlast(lBlast1, spInfo.iMetamagic, iEnergyType, iVisualType));
            DelayCommand(1.6, GRDoBlast(lBlast2, spInfo.iMetamagic, iEnergyType, iVisualType));
            DelayCommand(1.7, GRDoBlast(lBlast3, spInfo.iMetamagic, iEnergyType, iVisualType));
            DelayCommand(1.8, GRDoBlast(lBlast4, spInfo.iMetamagic, iEnergyType, iVisualType));
        }
    /*** END NWN1 SPECIFIC ***/

    /*** NWN2 SPECIFIC ***
        switch(spInfo.iSpellID) {
            case SPELL_METEOR_SWARM_TARGET_SELF:        //= 973;
                location lTarget;
                ExecuteDefaultMeteorSwarmBehavior(spInfo.oTarget, lTarget);
                GRHandleTargetSelf(spInfo);
                break;
            case SPELL_METEOR_SWARM_TARGET_LOCATION:    //= 974;
                if(spInfo.oTarget==oCaster) spInfo.oTarget = OBJECT_INVALID;
                ExecuteDefaultMeteorSwarmBehavior(spInfo.oTarget, spInfo.lTarget);
                GRHandleTargetLocation(spInfo.lTarget, spInfo);
                break;
            case SPELL_METEOR_SWARM_TARGET_CREATURE:    //= 975;
                GRHandleTargetCreature(spInfo.oTarget, spInfo);
                break;
        }
    /*** END NWN2 SPECIFIC ***/

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
