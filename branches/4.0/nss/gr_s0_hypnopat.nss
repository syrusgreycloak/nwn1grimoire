//*:**************************************************************************
//*:*  GR_S0_HYPNOPAT.NSS
//*:**************************************************************************
//*:* Hypnotic Pattern
//*:* Created By: Karl Nickels (Syrus Greycloak)  Created On: April 9, 2008
//*:* 3.5 Player's Handbook (p. 242)
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

//*:* #include "GR_IN_ENERGY"

const string ARR_HYPNO = "GR_HYP";
const string HITDICE = "HD";
const string DIST = "DIST";
const string OBJECT = "OBJECT";

//*:**************************************************************************
//*:* Supporting functions
//*:**************************************************************************
int GRBuildAffectedCreatureList(location lTarget, float fRange, object oCaster=OBJECT_SELF) {

    int iNumCreatures = 0;

    GRCreateArrayList(ARR_HYPNO, HITDICE, VALUE_TYPE_INT, oCaster, DIST, VALUE_TYPE_FLOAT, OBJECT, VALUE_TYPE_OBJECT);

    //*:* Build array of affected creatures and then sort instead
    //*:* of looping and relooping the area over and over
    object oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    while(GetIsObjectValid(oTarget)) {
        if(GRGetIsLiving(oTarget) && GRGetRacialType(oTarget)!=RACIAL_TYPE_OOZE) {
            if(GRGetIsSpellTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster, NO_CASTER)) {
                iNumCreatures++;
                GRIntAdd(ARR_HYPNO, HITDICE, GetHitDice(oTarget));
                GRFloatAdd(ARR_HYPNO, DIST, GetDistanceBetweenLocations(GetLocation(oTarget), lTarget));
                GRObjectAdd(ARR_HYPNO, OBJECT, oTarget);
            }
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRange, lTarget);
    }

    if(iNumCreatures==0) {
        GRDeleteArrayList(ARR_HYPNO);
        return FALSE; //*:* no affected creatures in area
    } else if(iNumCreatures>1){
        //*:* sort the array
        int i, j;
        int iHD;
        object oCreature;
        float fDist;

        for(i=2; i<=GRGetDimSize(ARR_HYPNO, OBJECT); i++) {
            iHD = GRIntGetValueAt(ARR_HYPNO, HITDICE, i);
            oCreature = GRObjectGetValueAt(ARR_HYPNO, OBJECT, i);
            fDist = GRFloatGetValueAt(ARR_HYPNO, DIST, i);
            j = i-1;
            while(j>0 && (GRIntGetValueAt(ARR_HYPNO, HITDICE, j)>iHD ||
                (GRIntGetValueAt(ARR_HYPNO, HITDICE, j)==iHD && GRFloatGetValueAt(ARR_HYPNO, DIST, j)>fDist))) {

                GRObjectSetValueAt(ARR_HYPNO, OBJECT, j+1, GRObjectGetValueAt(ARR_HYPNO, OBJECT, j));
                GRIntSetValueAt(ARR_HYPNO, HITDICE, j+1, GRIntGetValueAt(ARR_HYPNO, HITDICE, j));
                GRFloatSetValueAt(ARR_HYPNO, DIST, j+1, GRFloatGetValueAt(ARR_HYPNO, DIST, j));
                j--;
            }
            GRObjectSetValueAt(ARR_HYPNO, OBJECT, j+1, oCreature);
            GRIntSetValueAt(ARR_HYPNO, HITDICE, j+1, iHD);
            GRFloatSetValueAt(ARR_HYPNO, DIST, j+1, fDist);
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
    int     iNumDice          = 2;
    int     iBonus            = MinInt(10, spInfo.iCasterLevel);
    int     iDamage           = 0;
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

    float   fDuration       = GRGetSpellDuration(spInfo);
    float   fDelay          = 0.0f;
    float   fRange          = FeetToMeters(10.0);

    int     iAOEType            = AOE_PER_HYPNOTIC_PATTERN;
    string  sAOEType            = AOE_TYPE_HYPNOTIC_PATTERN;

    //*:**********************************************
    //*:* Resolve Metamagic, if possible
    //*:**********************************************
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_EXTEND)) fDuration *= 2;
    if(GRGetMetamagicUsed(spInfo.iMetamagic, METAMAGIC_WIDEN)) {
        fRange *= 2;
        iAOEType = AOE_PER_HYPNOTIC_PATTERN_WIDE;
        sAOEType = AOE_TYPE_HYPNOTIC_PATTERN_WIDE;
    }
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
    effect eDur     = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eStunned = EffectStunned();
    effect eLink    = EffectLinkEffects(eDur, eStunned);

    effect eAOE     = GREffectAreaOfEffect(iAOEType);

    //*:**********************************************
    //*:* Apply effects
    //*:**********************************************
    GRApplyEffectAtLocation(DURATION_TYPE_PERMANENT, eAOE, spInfo.lTarget);
    object oAOE = GRGetAOEAtLocation(spInfo.lTarget, sAOEType, oCaster);
    GRSetAOESpellId(spInfo.iSpellID, oAOE);
    GRSetSpellInfo(spInfo, oAOE);

    GRBuildAffectedCreatureList(spInfo.lTarget, fRange, oCaster);

    int iCounter = 1;
    int iHD;
    int iListSize = GRGetDimSize(ARR_HYPNO, OBJECT);

    while(iCounter<=iListSize && iDamage>0) {
        iHD = GRIntGetValueAt(ARR_HYPNO, HITDICE, iCounter);
        spInfo.oTarget = GRObjectGetValueAt(ARR_HYPNO, OBJECT, iCounter);
        spInfo.iDC = GRGetSpellSaveDC(oCaster, spInfo.oTarget);
        fDelay = GRFloatGetValueAt(ARR_HYPNO, DIST, iCounter)/20.0;

        if(iDamage>=iHD) {
            if(!GRGetSpellResisted(oCaster, spInfo.oTarget)) {
                if(!GRGetSaveResult(SAVING_THROW_WILL, spInfo.oTarget, spInfo.iDC, SAVING_THROW_TYPE_MIND_SPELLS, oCaster, fDelay)) {
                    GRApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spInfo.oTarget);
                }
            }
        }
        iDamage -= iHD;
        iCounter++;
    }

    GRDeleteArrayList(ARR_HYPNO);

    if(spInfo.iXPCost>0) GRApplyXPCostToCaster(spInfo.iXPCost);
    //*:**********************************************
    //*:* Remove spell info from caster
    //*:**********************************************
    GRClearSpellInfo(spInfo.iSpellID, oCaster);
}
//*:**************************************************************************
//*:**************************************************************************
