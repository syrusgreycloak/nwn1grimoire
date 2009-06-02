//*:**************************************************************************
//*:*  GR_IN_LIGHTDARK.NSS
//*:**************************************************************************
//*:*
//*:* Functions used for the various light and darkness spells
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2005
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IN_SPELLS"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************

//*:**********************************************
//*:* Light-related functions
//*:**********************************************
int     GRGetHigherLvlLightEffectsInArea(int iSpellID, location lTarget);
void    GRRemoveLowerLvlLightEffectsInArea(int iSpellID, location lTarget);

//*:**********************************************
//*:* Darkness-related functions
//*:**********************************************
int     GRGetHigherLvlDarknessEffectsInArea(int iSpellID, location lTarget);
void    GRRemoveLowerLvlDarknessEffectsInArea(int iSpellID, location lTarget);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetHigherLvlLightEffectsInArea
//*:**********************************************
//*:*
//*:* Returns whether a higher level light effect
//*:* is in the casting area.  If so, spell will not
//*:* be cast.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetHigherLvlLightEffectsInArea(int iSpellID, location lTarget) {

    object oTarget;
    int bHigherEffect = FALSE;
    float fRadius = FeetToMeters(20.0);

    if((iSpellID == SPELL_GR_DEEPER_DARKNESS) || (iSpellID == SPELL_GR_BLACKLIGHT)) fRadius = 60.0;

    oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);

    while(GetIsObjectValid(oTarget) && !bHigherEffect) {
        switch(iSpellID) {
            case SPELL_I_ENERVATING_SHADOW:
                if(GRGetSpellHasDescriptor(GRGetAOESpellId(oTarget), SPELL_TYPE_LIGHT, oTarget)) {
                    bHigherEffect = TRUE; // any light spells in area block this ability's effect
                }
                break;
            case SPELL_DARKNESS:
            case SPELL_I_DARKNESS:
            case SPELLABILITY_AS_DARKNESS:
            case SPELL_SHADOW_CONJURATION_DARKNESS:
            case 688:
                if(GetTag(oTarget)==AOE_TYPE_DAYLIGHT) bHigherEffect = TRUE;
                break;
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }

    return bHigherEffect;
}

//*:**********************************************
//*:* GRRemoveLowerLvlLightEffectsInArea
//*:**********************************************
//*:*
//*:* Removes light spell effects of equal or lower
//*:* level
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 16, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRRemoveLowerLvlLightEffectsInArea(int iSpellID, location lTarget) {

    object oTarget;
    int bLowerEffect = FALSE;
    float fRadius = FeetToMeters(20.0);

    if(iSpellID == SPELL_GR_DEEPER_DARKNESS) fRadius = FeetToMeters(60.0);

    oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR | OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT);

    while(GetIsObjectValid(oTarget)) {
        switch(iSpellID) {
            case SPELL_GR_BLACKLIGHT:
            case SPELL_GR_DEEPER_DARKNESS:
            case SPELL_I_HUNGRY_DARKNESS:
                if(GetObjectType(oTarget)==OBJECT_TYPE_AREA_OF_EFFECT) {
                    if(GetTag(oTarget)==AOE_TYPE_DAYLIGHT) {
                        DestroyObject(oTarget);
                        break;
                    }
                } else {
                    if(GetHasSpellEffect(SPELL_GR_DAYLIGHT, oTarget)) GRRemoveSpellEffects(SPELL_GR_DAYLIGHT, oTarget);
                }
            case SPELL_DARKNESS:
            case SPELL_I_DARKNESS:
            case SPELLABILITY_AS_DARKNESS:
            case SPELL_SHADOW_CONJURATION_DARKNESS:
            case 688:
                if(GetObjectType(oTarget)==OBJECT_TYPE_AREA_OF_EFFECT) {
                    if(GetTag(oTarget)==AOE_TYPE_LIGHT || GetTag(oTarget)==AOE_TYPE_DAWNBURST) {
                            DestroyObject(oTarget);
                    }
                } else {
                    GRRemoveMultipleSpellEffects(SPELL_LIGHT, SPELL_GR_DAWNBURST, oTarget);
                    if(GetHasSpellEffect(SPELL_GR_HEARTFIRE, oTarget)) GRRemoveEffectTypeBySpellId(EFFECT_TYPE_VISUALEFFECT, SPELL_GR_HEARTFIRE, oTarget);
                }
                break;
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR | OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT);
    }
}

//*:**********************************************
//*:* GRGetHigherLvlDarknessEffectsInArea
//*:**********************************************
//*:*
//*:* Returns whether a higher level darkness effect
//*:* is in the casting area.  If so, spell will not
//*:* be cast.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 5, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetHigherLvlDarknessEffectsInArea(int iSpellID, location lTarget) {

    object oTarget;
    int bHigherEffect = FALSE;
    float fRadius = FeetToMeters(20.0);

    if((iSpellID == SPELL_GR_DEEPER_DARKNESS) || (iSpellID == SPELL_GR_BLACKLIGHT)) fRadius = 60.0;

    oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    while(GetIsObjectValid(oTarget) && !bHigherEffect) {
        switch(iSpellID) {
            case SPELL_LIGHT:
            case SPELL_GR_DAWNBURST:
                if(GetTag(oTarget)==AOE_TYPE_DARKNESS) bHigherEffect = TRUE;
            case SPELL_GR_HEARTFIRE:
                if(GetTag(oTarget)==AOE_TYPE_BLACKLIGHT || GetTag(oTarget)==AOE_TYPE_DEEPER_DARKNESS || GetTag(oTarget)==AOE_TYPE_HUNGRY_DARKNESS)
                    bHigherEffect = TRUE;
                break;
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_AREA_OF_EFFECT);
    }

    return bHigherEffect;
}

//*:**********************************************
//*:* GRRemoveLowerLvlDarknessEffectsInArea
//*:**********************************************
//*:*
//*:* Removes darkness spell effects of equal or lower
//*:* level
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 5, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRRemoveLowerLvlDarknessEffectsInArea(int iSpellID, location lTarget) {

    object oTarget;
    int bLowerEffect = FALSE;
    float fRadius = FeetToMeters(20.0);

    if(iSpellID==SPELL_GR_DAYLIGHT) fRadius = FeetToMeters(60.0);
    else if(iSpellID==SPELL_SUNBURST) fRadius = FeetToMeters(80.0);

    oTarget = GRGetFirstObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR | OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT);

    while(GetIsObjectValid(oTarget)) {
        switch(iSpellID) {
            case SPELL_SUNBURST:
                GRRemoveSpellEffects(SPELL_GR_ARMOR_DARKNESS, oTarget);
            case SPELL_GR_DAYLIGHT:
                if(GetObjectType(oTarget)==OBJECT_TYPE_AREA_OF_EFFECT) {
                    if(GetTag(oTarget)==AOE_TYPE_DEEPER_DARKNESS || GetTag(oTarget)==AOE_TYPE_BLACKLIGHT || GetTag(oTarget)==AOE_TYPE_HUNGRY_DARKNESS) {
                        DestroyObject(oTarget);
                    }
                } else {
                    GRRemoveMultipleSpellEffects(SPELL_GR_DEEPER_DARKNESS, SPELL_GR_BLACKLIGHT, oTarget);
                }
            case SPELL_GR_HEARTFIRE:
                if(GetObjectType(oTarget)==OBJECT_TYPE_AREA_OF_EFFECT) {
                    if(GetTag(oTarget)==AOE_TYPE_DARKNESS) {
                        DestroyObject(oTarget);
                    }
                } else {
                    GRRemoveMultipleSpellEffects(SPELL_DARKNESS, SPELL_I_DARKNESS, oTarget, TRUE, SPELLABILITY_AS_DARKNESS, 688);
                }
                break;
        }
        oTarget = GRGetNextObjectInShape(SHAPE_SPHERE, fRadius, lTarget, FALSE, OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_DOOR | OBJECT_TYPE_CREATURE | OBJECT_TYPE_AREA_OF_EFFECT);
    }
}

//*:**************************************************************************
//*:**************************************************************************
