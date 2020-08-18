//*:**************************************************************************
//*:*  GR_S0_CIRCDEATH.NSS
//*:**************************************************************************
//*:* Circle of Death
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: April 12, 2003
//*:* 3.5 Player's Handbook (p. 209)
//*:**************************************************************************
//*:* Updated On: December 17, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_ARRLIST"

const string sName = "GR_CIRCDEATH";
const string sDim1 = "HD";
const string sDim2 = "DIST";
const string sDim3 = "OBJECT";

//*:* #include "GR_IN_ENERGY"
//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRBuildAffectedCreatureList(location lTarget, float fRange, object oCaster=OBJECT_SELF) {

    int iNumCreatures = 0;

    GRCreateArrayList(sName, sDim1, VALUE_TYPE_INT, oCaster, sDim2, VALUE_TYPE_FLOAT, sDim3, VALUE_TYPE_OBJECT);

    //*:* Build array of affected creatures and then sort instead
    //*:* of looping and relooping the area over and over
    object oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    while(GetIsObjectValid(oTarget)) {
        if(GRGetIsLiving(oTarget) && GetHitDice(oTarget)<9) {
            iNumCreatures++;
            GRIntAdd(sName, sDim1, GetHitDice(oTarget), oCaster);
            GRFloatAdd(sName, sDim2, GetDistanceBetweenLocations(GetLocation(oTarget), lTarget));
            GRObjectAdd(sName, sDim3, oTarget, oCaster);
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    }

    if(iNumCreatures==0) {
        GRDeleteArrayList(sName, oCaster);
        return FALSE; //*:* no affected creatures in area
    } else if(iNumCreatures==1) {
        // do nothing - array already sorted
    } else {
        //*:* sort the array
        int i, j;
        int iHD;
        float fDist;
        object oCreature;

        for(i=2; i<=GRGetDimSize(sName, sDim1, oCaster); i++) {
            iHD = GRIntGetValueAt(sName, sDim1, i, oCaster);
            fDist = GRFloatGetValueAt(sName, sDim2, i, oCaster);
            oCreature = GRObjectGetValueAt(sName, sDim3, i, oCaster);
            j = i-1;
            while(j>0 && (GRIntGetValueAt(sName, sDim1, j, oCaster)>iHD ||
                    (GRIntGetValueAt(sName, sDim1, j, oCaster)==iHD && GRFloatGetValueAt(sName, sDim1, j, oCaster)>fDist))) {
                GRIntSetValueAt(sName, sDim1, j+1, GRIntGetValueAt(sName, sDim1, j, oCaster), oCaster);
                GRFloatSetValueAt(sName, sDim1, j+1, GRFloatGetValueAt(sName, sDim1, j, oCaster), oCaster);
                GRObjectSetValueAt(sName, sDim1, j+1, GRObjectGetValueAt(sName, sDim1, j, oCaster), oCaster);
                j--;
            }
            GRIntSetValueAt(sName, sDim1, j+1, iHD, oCaster);
            GRFloatSetValueAt(sName, sDim1, j+1, fDist, oCaster);
            GRObjectSetValueAt(sName, sDim1, j+1, oCreature, oCaster);
        }
    }
    return TRUE;
}

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
    int     iNumDice          = MinInt(20, spInfo.iCasterLevel);
    int     iBonus            = 0;
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
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(40.0);
    int     iNumCreatures, i;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    //*:* if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) fRange *= 2;
    int iHDTotal = GRGetMetamagicAdjustedDamage(iDieType, iNumDice, spInfo.iMetamagic, iBonus);
    /* if(GRGetSpellHasSecondaryDamage(spInfo)) {
        iSecDamage = GRGetSpellSecondaryDamageAmount(iDamage, spInfo, SPELL_SAVE_NONE, oCaster, SAVING_THROW_TYPE_NONE, fDelay);
        if(spInfo.iSecDmgAmountType==SECDMG_TYPE_HALF) {
            iDamage = iSecDamage;
        }
    }*/

    //*:**********************************************
    //*:* Effects
    //*:**********************************************
    /*** NWN1 SPECIFIC ***/
        effect eImpact  = EffectVisualEffect(GRGetAlignmentImpactVisual(oCaster, fRange));
        effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);
    /*** END NWN1 SPECIFIC ***/
    //*** NWN2 SINGLE ***/ effect eVis     = EffectVisualEffect(VFX_HIT_SPELL_NECROMANCY);
    effect eDeath   = EffectDeath();

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    /*** NWN1 SINGLE ***/ GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);

    if(GRBuildAffectedCreatureList(spInfo.lTarget, fRange)) {
        iNumCreatures = GRGetDimSize(sName, sDim1, oCaster);
        i=1;
        while(i<=iNumCreatures && iHDTotal>0) {
            spInfo.oTarget = GRObjectGetValueAt(sName, sDim3, i, oCaster);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GRGetSaveResult(SAVING_THROW_FORT, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_DEATH)) {
                    iHDTotal -= GRIntGetValueAt(sName, sDim1, i, oCaster);
                    fDelay = (GetHitDice(spInfo.oTarget)*0.05 + GRFloatGetValueAt(sName, sDim2, i, oCaster))/20.0;
                    GRSetKilledByDeathEffect(spInfo.oTarget);
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    DelayCommand(fDelay+0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));

                }
            }
            i++;
        }

        //*:* Delete any remaining locals on caster
        GRDeleteArrayList(sName, oCaster);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
