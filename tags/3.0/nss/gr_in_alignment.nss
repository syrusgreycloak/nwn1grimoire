//*:**************************************************************************
//*:*  GR_IN_ALIGNMENT.NSS
//*:**************************************************************************
//*:*
//*:* Alignment functions
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 29, 2005
//*:**************************************************************************
//*:* Updated On: February 8, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IC_ALIGNMENT"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int     GRGetCreatureAlignmentEqual(object oCreature, int iCompareAlignTo, int iAxis = ALIGNMENT_AXIS_GOODEVIL);
int     GRGetCreatureAlignment(object oCreature);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetCreatureAlignmentEqual
//*:*   (formerly SGGetCreatureAlignmentEqual)
//*:**********************************************
//*:*
//*:* Wraps the alignment check functions into one call
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 29, 2005
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetCreatureAlignmentEqual(object oCreature, int iCompareAlignTo, int iAxis = ALIGNMENT_AXIS_GOODEVIL) {

    int iAlignment;

    if(iAxis==ALIGNMENT_AXIS_GOODEVIL) {
        iAlignment=GetAlignmentGoodEvil(oCreature);
    } else {
        iAlignment=GetAlignmentLawChaos(oCreature);
    }

    return (iAlignment==iCompareAlignTo);
}


//*:**********************************************
//*:* GRGetCreatureAlignment
//*:*   (formerly SGGetCreatureAlignment)
//*:**********************************************
//*:*
//*:* Wraps the alignment check functions into one call
//*:* and returns one alignment constant for a particular
//*:* alignment
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: July 14, 2006
//*:**********************************************
//*:* Updated On: February 8, 2007
//*:**********************************************
int GRGetCreatureAlignment(object oCreature) {

    int iAlignmentGE = GetAlignmentGoodEvil(oCreature);
    int iAlignmentLC = GetAlignmentLawChaos(oCreature);

    int iAlignment;

    if(iAlignmentLC==ALIGNMENT_LAWFUL) {
        if(iAlignmentGE==ALIGNMENT_GOOD) {
            iAlignment = ALIGNMENT_LG;
        } else if(iAlignmentGE==ALIGNMENT_NEUTRAL) {
            iAlignment = ALIGNMENT_LN;
        } else {
            iAlignment = ALIGNMENT_LE;
        }
    } else if(iAlignmentLC==ALIGNMENT_NEUTRAL) {
        if(iAlignmentGE==ALIGNMENT_GOOD) {
            iAlignment = ALIGNMENT_NG;
        } else if(iAlignmentGE==ALIGNMENT_NEUTRAL) {
            iAlignment = ALIGNMENT_N;
        } else {
            iAlignment = ALIGNMENT_NE;
        }
    } else {
        if(iAlignmentGE==ALIGNMENT_GOOD) {
            iAlignment = ALIGNMENT_CG;
        } else if(iAlignmentGE==ALIGNMENT_NEUTRAL) {
            iAlignment = ALIGNMENT_CN;
        } else {
            iAlignment = ALIGNMENT_CE;
        }
    }

    return iAlignment;
}
//*:**************************************************************************
//*:**************************************************************************
