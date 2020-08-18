//*:**************************************************************************
//*:*  GR_S0_DELFIREBC.NSS
//*:**************************************************************************
//*:*
//*:* DelayedBlastFireball:OnHeartbeat
//*:* 3.5 Player's Handbook (p. 217)
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2005
//*:**************************************************************************
//*:* Updated On: October 25, 2007
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

    //*:* spInfo = GRReplaceEnergyType(spInfo, GRGetSpellEnergyDamageType(spInfo.iSpellID, oCaster), iSpellType);

    //*:**********************************************
    //*:* Spellcast Hook Code
    //*:**********************************************
    //if(!GRSpellhookAbortSpell()) return;
    //spInfo = GRGetSpellInfoFromObject(spInfo.iSpellID, oCaster);

    //*:**********************************************
    //*:* Declare Spell Specific Variables & impose limiting
    //*:**********************************************

    //*:* float   fDuration       = GRGetSpellDuration(spInfo);
    float   fRange          = FeetToMeters(20.0);
    float   fDelay;

    int iDelayRounds = GetLocalInt(OBJECT_SELF, "GR_L_DELFIREB_RNDS");

    if(iDelayRounds!=0) {
        //*:* Not yet
        SetLocalInt(OBJECT_SELF, "GR_L_DELFIREB_RNDS", iDelayRounds-1);
    } else {
        //*:* BOOM time!
        //*:**********************************************
        //*:* Declare Spell Specific Variables & impose limiting
        //*:**********************************************
        int     iDieType        = 6;
        int     iNumDice        = (spInfo.iCasterLevel>20 ? 20 : spInfo.iCasterLevel);
        int     iBonus          = 0;
        int     iDamage         = 0;
        int     iSecDamage      = 0;

        int     iSaveType       = GRGetEnergySaveType(iEnergyType);
        int     iVisualType     = GRGetEnergyVisualType(VFX_IMP_FLAME_M, iEnergyType);
        int     iExplodeType    = GRGetEnergyExplodeType(iEnergyType, SPELL_DELAYED_BLAST_FIREBALL);


        //*:**********************************************
        //*:* Resolve Metamagic, if possible
        //*:**********************************************
        //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
        //*:* iDamage = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);

        //*:**********************************************
        //*:* Effects
        //*:**********************************************
        effect eDam;
        effect eExplode = EffectVisualEffect(iExplodeType);
        effect eVis     = EffectVisualEffect(iVisualType);
        effect eLink;

        //*:**********************************************
        //*:* Apply effects
        //*:**********************************************
        GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, spInfo.lTarget);
        spInfo.oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
            OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);

        while(GetIsObjectValid(spInfo.oTarget)) {
            if(GRGetIsSpellTarget(spInfo.oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, FALSE)) {
                SignalEvent(spInfo.oTarget, EventSpellCastAt(oCaster, SPELL_DELAYED_BLAST_FIREBALL));
                fDelay = GetDistanceBetweenLocations(spInfo.lTarget, GetLocation(spInfo.oTarget))/20.0;
                if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                    spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                    iDamage = GRGetSpellDamageAmount(spInfo, REFLEX_HALF, oCaster, iSaveType, fDelay);
                    if(GRGetSpellHasSecondaryDamage(spInfo)) {
                        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, REFLEX_HALF, oCaster);
                        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
                            iDamage = iSecDamage;
                        }
                    }
                    eDam = EffectDamage(iDamage, iEnergyType);
                    eLink = EffectLinkEffects(eDam, eVis);
                    if(iSecDamage>0) eLink = EffectLinkEffects(eLink, EffectDamage(iSecDamage, spInfo.iSecDmgType));
                    if(iDamage > 0) {
                        GRApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spInfo.oTarget);
                        if(GRGetHasSpellEffect(SPELL_GR_INCENDIARY_SLIME, spInfo.oTarget) && (iEnergyType==DAMAGE_TYPE_FIRE || spInfo.iSecDmgType==DAMAGE_TYPE_FIRE)) {
                            GRDoIncendiarySlimeExplosion(spInfo.oTarget);
                        }
                    }
                }
            }
            spInfo.oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, spInfo.lTarget, TRUE, OBJECT_TYPE_CREATURE |
                OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE);
        }

        DestroyObject(OBJECT_SELF);

    }

    //if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
