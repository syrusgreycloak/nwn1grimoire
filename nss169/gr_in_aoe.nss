//*:**************************************************************************
//*:*  GR_IN_AOE.NSS
//*:**************************************************************************
//*:*
//*:* AOE functions to assist in getting the AOE object
//*:* to allow setting variables on the object.
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 17, 2005
//*:**************************************************************************
//*:* Updated On: February 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
#include "GR_IC_AOE"
#include "GR_IC_NAMES";


//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int     GRAOEAffectedByGoW(object oAOE);

object  GRGetAOEAtLocation(location lTarget, string sTag, object oCaster);
float   GRGetAOEDamagePercentage(object oAOE=OBJECT_SELF);
int     GRGetAOEIsUnderwater(object oAOE = OBJECT_SELF);
object  GRGetAOEOnObject(object oTarget, string sTag, object oCaster=OBJECT_INVALID);
int     GRGetAOESpellId(object oAOE = OBJECT_SELF);
int     GRGetAOEVisualType(object oAOE=OBJECT_SELF);

void    GRSetAOEDamagePercentage(float fPercent, object oAOE=OBJECT_SELF);
void    GRSetAOEIsUnderwater(int iTrueFalse, object oAOE = OBJECT_SELF);
void    GRSetAOESpellId(int iSpellID, object oAOE = OBJECT_SELF);
void    GRSetAOEVisualType(int iVisualType, object oAOE=OBJECT_SELF);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRAOEAffectedByGoW (Gust of Wind)
//*:*   (formerly SGAOEAffectedByGoW)
//*:**********************************************
//*:*
//*:* Checks if an AOE effect can be affected by
//*:* the Gust of Wind (GoW) spell
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 22, 2005
//*:**********************************************
//*:* Updated On: April 18, 2008
//*:**********************************************
//*:* Put in check of spell script name to see
//*:* if triggered by Cloud/Fog spell script to try
//*:* and catch any new spells I've added and didn't
//*:* put the tag in for (like the widened versions)
//*:**********************************************
int GRAOEAffectedByGoW(object oAOE) {

    int bAffected = GetLocalInt(oAOE, AFFECTED_BY_GUSTOFWIND);

    if(!bAffected) {
        string sAOETag = GetTag(oAOE);

        if (sAOETag==AOE_TYPE_FOGGHOUL ||               // Ghoul Touch
            sAOETag==AOE_TYPE_CREEPING_DOOM ||          // Creeping Doom
            sAOETag==AOE_TYPE_FOGSTINKSINGLE ||         // small Stinking Cloud effect
            sAOETag==AOE_TYPE_BLOODSTORM ||             // Blood Storm
            sAOETag==AOE_TYPE_ACID_STORM ||             // Acid Storm
            sAOETag==AOE_TYPE_GLITTERDUST ||            // Glitterdust
            sAOETag==AOE_TYPE_BREATH_JUNGLE) {          // Breath of the Jungle
                bAffected = TRUE;
        }
    }

    return bAffected;
}

//*:**********************************************
//*:* GRGetAOEAtLocation
//*:*   (formerly SGGetAOEAtLocation)
//*:**********************************************
//*:* Will scan through the first 10 nearest objects
//*:* with the matching tag, to see if the caster
//*:* created the object.
//*:*
//*:* Use with PERsistent effects
//*:*
//*:* NOTE:  It will return the first object it finds,
//*:* so if the caster drops two in the same location,
//*:* it may return the wrong one.
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 17, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
object GRGetAOEAtLocation(location lTarget, string sTag, object oCaster) {

    int i = 1;
    object oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget, i);

    while(GetIsObjectValid(oAOE) && GetTag(oAOE)!=sTag && GetAreaOfEffectCreator(oAOE)!=oCaster && i<10) {
        i++;
        oAOE = GetNearestObjectToLocation(OBJECT_TYPE_AREA_OF_EFFECT, lTarget, i);
    }

    if(GetIsObjectValid(oAOE) && GetTag(oAOE)!=sTag && GetAreaOfEffectCreator(oAOE)!=oCaster) {
        oAOE = OBJECT_INVALID;
    }

    return oAOE;

}

//*:**********************************************
//*:* GRGetAOEDamagePercentage
//*:**********************************************
//*:*
//*:* Returns the damage percentage stored on
//*:* the area of effect.  Used for shadow conj.
//*:* spells.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 20, 2007
//*:**********************************************
float GRGetAOEDamagePercentage(object oAOE = OBJECT_SELF) {
    float fPercent = GetLocalFloat(oAOE, "GR_RDI_PERCENT");

    fPercent = (fPercent==0.0 ? 1.0 : fPercent);

    return fPercent;
}

//*:**********************************************
//*:* GRGetAOEIsUnderwater
//*:*   (formerly SGGetAOEIsUnderwater)
//*:**********************************************
//*:*
//*:* Gets a variable on the AOE that contains whether
//*:* or not the AOE is underwater
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 7, 2006
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetAOEIsUnderwater(object oAOE = OBJECT_SELF) {

    return GetLocalInt(oAOE, AOE_UNDERWATER);

}

//*:**********************************************
//*:* GRGetAOEOnObject
//*:*   (formerly SGGetAOEOnObject)
//*:**********************************************
//*:* Will scan through the first 10 nearest objects
//*:* with the matching tag, to see if the caster
//*:* created the object.
//*:*
//*:* Use with MOB effects
//*:*
//*:* NOTE:  It will return the first object it finds,
//*:* so if the caster drops two in the same location,
//*:* it may return the wrong one.
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 17, 2005
//*:**********************************************
//*:* Updated on: February 8, 2007
//*:**********************************************
object GRGetAOEOnObject(object oTarget, string sTag, object oCaster=OBJECT_INVALID) {

    int i = 1;
    object oAOE = GetNearestObjectByTag(sTag, oTarget, i);

    if(oCaster!=OBJECT_INVALID) {
        while(GetIsObjectValid(oAOE) && GetAreaOfEffectCreator(oAOE)!=oCaster && i<10) {
            i++;
            oAOE = GetNearestObjectByTag(sTag, oTarget, i);
        }

        if(GetIsObjectValid(oAOE) && GetAreaOfEffectCreator(oAOE)!=oCaster && !GetHasSpellEffect(GRGetAOESpellId(oAOE), oTarget)) {
            oAOE = OBJECT_INVALID;
        }
    } else {
        if(GetIsObjectValid(oAOE) && !GetHasSpellEffect(GRGetAOESpellId(oAOE), oTarget)) {
            oAOE = OBJECT_INVALID;
        }
    }


    return oAOE;

}

//*:**********************************************
//*:* GRGetAOEVisualType
//*:**********************************************
//*:*
//*:* Returns the energy visual type stored on
//*:* the area of effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 20, 2007
//*:**********************************************
int GRGetAOEVisualType(object oAOE = OBJECT_SELF) {

    return GetLocalInt(oAOE, ENERGY_VISUAL_TYPE);
}

//*:**********************************************
//*:* GRGetAOESpellId
//*:*   (formerly SGGetAOESpellId)
//*:**********************************************
//*:*
//*:* Returns the spell id stored on the area of
//*:* effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: May 17, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetAOESpellId(object oAOE = OBJECT_SELF) {
    int iSpellID = -1;

    if(GetIsObjectValid(oAOE))
        iSpellID = GetLocalInt(oAOE, AOE_SPELLID);

    return iSpellID;
}

//*:**********************************************
//*:* GRSetAOEDamagePercentage
//*:**********************************************
//*:*
//*:* Stores the damage percentage on
//*:* the area of effect.  Used for shadow conj.
//*:* spells.
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 20, 2007
//*:**********************************************
void GRSetAOEDamagePercentage(float fPercent, object oAOE = OBJECT_SELF) {

    SetLocalFloat(oAOE, AOE_DMG_PERCENTAGE, fPercent);
}

//*:**********************************************
//*:* GRSetAOEIsUnderwater
//*:*   (formerly SGSetAOEIsUnderwater)
//*:**********************************************
//*:*
//*:* Sets a variable on the AOE that contains whether
//*:* or not the AOE is underwater
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 7, 2006
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
void GRSetAOEIsUnderwater(int iTrueFalse, object oAOE = OBJECT_SELF) {

    SetLocalInt(oAOE, AOE_UNDERWATER, iTrueFalse);

}

//*:**********************************************
//*:* GRSetAOEVisualType
//*:**********************************************
//*:*
//*:* Stores the energy visual type on
//*:* the area of effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: February 20, 2007
//*:**********************************************
void GRSetAOEVisualType(int iVisualType, object oAOE = OBJECT_SELF) {

    SetLocalInt(oAOE, ENERGY_VISUAL_TYPE, iVisualType);
}

//*:**************************************************************************
//*:**************************************************************************
