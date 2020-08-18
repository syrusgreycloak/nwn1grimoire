//*:**************************************************************************
//*:*  GR_S0_UNDEATH.NSS
//*:**************************************************************************
//*:* Undeath to Death
//*:* Created By: Karl Nickels (Syrus Greycloak) Created On: December 17, 2007
//*:* 3.5 Player's Handbook (p. 297)
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
//*:* Game Libraries
#include "X2_INC_TOOLLIB"

//*:**********************************************
//*:* Function Libraries
#include "GR_IN_SPELLS"
#include "GR_IN_SPELLHOOK"
#include "GR_IN_ARRLIST"

//*:* #include "GR_IN_ENERGY"

const string ARR_UNDEATH = "GR_UNDEATH";
const string OBJECT = "OBJECT";
const string HITDICE = "HITDICE";
const string DISTANCE = "DIST";

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRBuildAffectedCreatureList(location lTarget, float fRange, object oCaster=OBJECT_SELF) {

    int iNumCreatures = 0;

    GRCreateArrayList(ARR_UNDEATH, HITDICE, VALUE_TYPE_INT, oCaster, DISTANCE, VALUE_TYPE_FLOAT, OBJECT, VALUE_TYPE_OBJECT);

    //*:* Build array of affected creatures and then sort instead
    //*:* of looping and relooping the area over and over
    object oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    while(GetIsObjectValid(oTarget)) {
        if(GRGetRacialType(oTarget)==RACIAL_TYPE_UNDEAD && GetHitDice(oTarget)<9) {
            iNumCreatures++;
            GRObjectAdd(ARR_UNDEATH, OBJECT, oTarget);
            GRIntAdd(ARR_UNDEATH, HITDICE, GetHitDice(oTarget));
            GRFloatAdd(ARR_UNDEATH, DISTANCE, GetDistanceBetweenLocations(lTarget, GetLocation(oTarget)));
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    }

    if(iNumCreatures==0) {
        GRDeleteArrayList(ARR_UNDEATH);
        return FALSE; //*:* no affected creatures in area
    } else if(iNumCreatures>1) {
        //*:* sort the array
        int i, j;
        int iHD;
        object oCreature;
        float fDist;

        for(i=2; i<=GRGetDimSize(ARR_UNDEATH, OBJECT); i++) {
            iHD = GRIntGetValueAt(ARR_UNDEATH, HITDICE, i);
            oCreature = GRObjectGetValueAt(ARR_UNDEATH, OBJECT, i);
            fDist = GRFloatGetValueAt(ARR_UNDEATH, DISTANCE, i);
            j = i-1;
            while(j>0 && (GRIntGetValueAt(ARR_UNDEATH, HITDICE, j)>iHD ||
                (GRIntGetValueAt(ARR_UNDEATH, HITDICE, j)==iHD && GRFloatGetValueAt(ARR_UNDEATH, DISTANCE, j)>fDist))) {

                GRObjectSetValueAt(ARR_UNDEATH, OBJECT, j+1, GRObjectGetValueAt(ARR_UNDEATH, OBJECT, j));
                GRIntSetValueAt(ARR_UNDEATH, HITDICE, j+1, GRIntGetValueAt(ARR_UNDEATH, HITDICE, j));
                GRFloatSetValueAt(ARR_UNDEATH, DISTANCE, j+1, GRFloatGetValueAt(ARR_UNDEATH, DISTANCE, j));
                j--;
            }
            GRObjectSetValueAt(ARR_UNDEATH, OBJECT, j+1, oCreature);
            GRIntSetValueAt(ARR_UNDEATH, HITDICE, j+1, iHD);
            GRFloatSetValueAt(ARR_UNDEATH, DISTANCE, j+1, fDist);
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
    effect eImpact  = EffectVisualEffect(VFX_FNF_STRIKE_HOLY);
    effect eVis     = EffectVisualEffect(VFX_IMP_DEATH);
    effect eDeath;

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spInfo.lTarget);
    TLVFXPillar(VFX_FNF_LOS_HOLY_20, spInfo.lTarget, 3, 0.0f);

    if(GRBuildAffectedCreatureList(spInfo.lTarget, fRange)) {
        iNumCreatures = GRGetDimSize(ARR_UNDEATH, OBJECT);
        i=1;
        while(i<=iNumCreatures && iHDTotal>0) {
            spInfo.oTarget = GRObjectGetValueAt(ARR_UNDEATH, OBJECT, i);
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC)) {
                    iHDTotal -= GRIntGetValueAt(ARR_UNDEATH, HITDICE, i);
                    eDeath = EffectDamage(GetCurrentHitPoints(spInfo.oTarget), DAMAGE_TYPE_DIVINE, DAMAGE_POWER_ENERGY);
                    fDelay = (GetHitDice(spInfo.oTarget)*0.05) + GRFloatGetValueAt(ARR_UNDEATH, DISTANCE, i)/20.0;
                    DelayCommand(fDelay, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spInfo.oTarget));
                    DelayCommand(fDelay+0.5f, GRApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spInfo.oTarget));
                }
            }
            i++;
        }

        //*:* Delete list on caster
        GRDeleteArrayList(ARR_UNDEATH);
    }

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
