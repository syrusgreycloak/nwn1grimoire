//*:**************************************************************************
//*:*  GR_IN_ARRLIST.NSS
//*:**************************************************************************
//*:*
//*:* Array/list functions
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: December 17, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Constants
//*:**************************************************************************

//*:**************************************************************************
//*:* Include the following files
//*:**************************************************************************
#include "GR_IC_ARRLIST"
#include "GR_IN_STRCMP"

//*:**************************************************************************
//*:* Function Prototypes
//*:**************************************************************************
void GRCreateArrayList(string sName, string sDim1, int iDim1Type, object oStorage=OBJECT_SELF, string sDim2="",
    int iDim2Type=VALUE_TYPE_INVALID, string sDim3="", int iDim3Type=VALUE_TYPE_INVALID);

string GRGetFullDimName(string sName, string sDimName);

string GRGetDimensionName(int iDimension, string sName, object oStorage=OBJECT_SELF);
void GRSetDimensionName(int iDimension, string sName, string sDimName, object oStorage=OBJECT_SELF);

int GRGetDimensionType(int iDimension, string sName, object oStorage=OBJECT_SELF);
void GRSetDimensionType(int iDimension, string sName, int iDimType, object oStorage=OBJECT_SELF);

int GRGetDimNumber(string sName, string sDimName, object oStorage=OBJECT_SELF);

int GRGetDimSize(string sName, string sDimName, object oStorage=OBJECT_SELF);
void GRSetDimSize(string sName, string sDimName, int iSize, object oStorage=OBJECT_SELF);

int GRGetArrayDimensions(string sName, object oStorage=OBJECT_SELF);
void GRSetArrayDimensions(string sName, int iNumDimensions, object oStorage=OBJECT_SELF);

void GRAddArrayDimension(string sName, string sDim, int iDimType, object oStorage=OBJECT_SELF);

void GRDeleteValue(string sName, string sDimName, int iPosition, object oStorage=OBJECT_SELF);
void GRDeletePosition(string sName, int iPosition, object oStorage=OBJECT_SELF);
void GRDeleteArrayDimension(string sName, string sDimName, object oStorage=OBJECT_SELF);
void GRDeleteArrayList(string sName, object oStorage=OBJECT_SELF);

void GRIntAdd(string sName, string sDimName, int iValue, object oStorage=OBJECT_SELF);
void GRBooleanAdd(string sName, string sDimName, int bValue, object oStorage=OBJECT_SELF);
void GRFloatAdd(string sName, string sDimName, float fValue, object oStorage=OBJECT_SELF);
void GRObjectAdd(string sName, string sDimName, object oObject, object oStorage=OBJECT_SELF);
void GRLocationAdd(string sName, string sDimName, location lLoc, object oStorage=OBJECT_SELF);
void GRStringAdd(string sName, string sDimName, string sValue, object oStorage=OBJECT_SELF);

int GRIntPop(string sName, string sDimName, object oStorage=OBJECT_SELF);
int GRBooleanPop(string sName, string sDimName, object oStorage=OBJECT_SELF);
object GRObjectPop(string sName, string sDimName, object oStorage=OBJECT_SELF);
location GRLocationPop(string sName, string sDimName, object oStorage=OBJECT_SELF);
string GRStringPop(string sName, string sDimName, object oStorage=OBJECT_SELF);
float GRFloatPop(string sName, string sDimName, object oStorage=OBJECT_SELF);

int GRIntIndexOf(string sName, string sDimName, int iValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF);
int GRBooleanIndexOf(string sName, string sDimName, int bValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF);
int GRFloatIndexOf(string sName, string sDimName, float fValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF);
int GRObjectIndexOf(string sName, string sDimName, object oObjectToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF);
int GRLocationIndexOf(string sName, string sDimName, location lLocToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF);
int GRStringIndexOf(string sName, string sDimName, string sValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF);

int GRIntGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
float GRFloatGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
int GRBooleanGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
object GRObjectGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
location GRLocationGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
string GRStringGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);

int GRIntGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
int GRBooleanGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
float GRFloatGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
object GRObjectGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
location GRLocationGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);
string GRStringGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF);

void GRIntInsert(string sName, string sDimName, int iArrayIndex, int iValue, object oStorage=OBJECT_SELF);
void GRBooleanInsert(string sName, string sDimName, int iArrayIndex, int bValue, object oStorage=OBJECT_SELF);
void GRFloatInsert(string sName, string sDimName, int iArrayIndex, float fValue, object oStorage=OBJECT_SELF);
void GRObjectInsert(string sName, string sDimName, int iArrayIndex, object oObject, object oStorage=OBJECT_SELF);
void GRLocationInsert(string sName, string sDimName, int iArrayIndex, location lLoc, object oStorage=OBJECT_SELF);
void GRStringInsert(string sName, string sDimName, int iArrayIndex, string sValue, object oStorage=OBJECT_SELF);

void GRIntSetValueAt(string sName, string sDimName, int iArrayIndex, int iValue, object oStorage=OBJECT_SELF);
void GRFloatSetValueAt(string sName, string sDimName, int iArrayIndex, float fValue, object oStorage=OBJECT_SELF);
void GRBooleanSetValueAt(string sName, string sDimName, int iArrayIndex, int bValue, object oStorage=OBJECT_SELF);
void GRObjectSetValueAt(string sName, string sDimName, int iArrayIndex, object oObject, object oStorage=OBJECT_SELF);
void GRLocationSetValueAt(string sName, string sDimName, int iArrayIndex, location lLoc, object oStorage=OBJECT_SELF);
void GRStringSetValueAt(string sName, string sDimName, int iArrayIndex, string sValue, object oStorage=OBJECT_SELF);

void GRIntSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
void GRBooleanSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
void GRFloatSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
void GRObjectSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
void GRLocationSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
void GRStringSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
void GRSwapAll(string sName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);

void GRInsertionSort(string sName, string sKey1, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
int GRQSPartition(string sName, string sKey1, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);
void GRQuickSort(string sName, string sKey1, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF);

//*:**************************************************************************
//*:***********************************************
//*:* GRCreateArrayList
//*:***********************************************
/**:*  Creates an array list of up to 3 dimensions
  *:*  Inputs: Major Name, subname for dimension 1, type for dimension 1, storage object,
  *:*           subnames, types for dimensions 2 & 3
  *:***********************************************/
void GRCreateArrayList(string sName, string sDim1, int iDim1Type, object oStorage=OBJECT_SELF, string sDim2="",
    int iDim2Type=VALUE_TYPE_INVALID, string sDim3="", int iDim3Type=VALUE_TYPE_INVALID) {

    int iNumDimensions = 1;
    GRSetDimensionName(iNumDimensions, sName, sDim1, oStorage);
    GRSetDimensionType(iNumDimensions, sName, iDim1Type, oStorage);
    GRSetDimSize(sName, sDim1, 0, oStorage);
    if(sDim2!="") {
        iNumDimensions++;
        GRSetDimensionName(iNumDimensions, sName, sDim2, oStorage);
        GRSetDimensionType(iNumDimensions, sName, iDim2Type, oStorage);
        GRSetDimSize(sName, sDim2, 0, oStorage);
        if(sDim3!="") {
            iNumDimensions++;
            GRSetDimensionName(iNumDimensions, sName, sDim3, oStorage);
            GRSetDimensionType(iNumDimensions, sName, iDim3Type, oStorage);
            GRSetDimSize(sName, sDim3, 0, oStorage);
        }
    }
    GRSetArrayDimensions(sName, iNumDimensions, oStorage);
}

//*:***********************************************
//*:* GRGetDimensionName
//*:***********************************************
//*:*  Returns the name of the specified array dimension
//*:***********************************************
string GRGetDimensionName(int iDimension, string sName, object oStorage=OBJECT_SELF) {
    return GetLocalString(oStorage, "ARRAY_"+sName+"_NAME_DIM"+IntToString(iDimension));
}

//*:***********************************************
//*:* GRSetDimensionName
//*:***********************************************
//*:*  Sets the name of the specified array dimension
//*:***********************************************
void GRSetDimensionName(int iDimension, string sName, string sDimName, object oStorage=OBJECT_SELF) {
    SetLocalString(oStorage, "ARRAY_"+sName+"_NAME_DIM"+IntToString(iDimension), sDimName);
}

//*:***********************************************
//*:* GRGetDimensionType
//*:***********************************************
//*:*  Returns the data type of the specified array dimension
//*:***********************************************
int GRGetDimensionType(int iDimension, string sName, object oStorage=OBJECT_SELF) {
    return GetLocalInt(oStorage, "ARRAY_"+sName+"_TYPE_DIM"+IntToString(iDimension));
}

//*:***********************************************
//*:* GRSetDimensionType
//*:***********************************************
//*:*  Sets the data type of the specified array dimension
//*:***********************************************
void GRSetDimensionType(int iDimension, string sName, int iDimType, object oStorage=OBJECT_SELF) {
    SetLocalInt(oStorage, "ARRAY_"+sName+"_TYPE_DIM"+IntToString(iDimension), iDimType);
}

//*:***********************************************
//*:* GRGetFullDimName
//*:***********************************************
//*:*  Returns the size of the array dimension
//*:***********************************************
string GRGetFullDimName(string sName, string sDimName) {
    return sName+"_"+sDimName;
}

//*:***********************************************
//*:* GRGetDimNumber
//*:***********************************************
//*:*  Returns the numeric dimension number
//*:***********************************************
int GRGetDimNumber(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);
    int i;
    for(i=1; i<=iNumDimensions; i++) {
        if(GRGetDimensionName(i, sName, oStorage)==sDimName) return i;
    }
    return 0;
}

//*:***********************************************
//*:* GRGetDimSize
//*:***********************************************
//*:*  Returns the size of the array dimension
//*:***********************************************
int GRGetDimSize(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    return GetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(0));
}

//*:***********************************************
//*:* GRSetDimSize
//*:***********************************************
//*:*  Sets the size of the array dimension
//*:***********************************************
void GRSetDimSize(string sName, string sDimName, int iSize, object oStorage=OBJECT_SELF) {
    if(iSize<0) iSize = 0;
    SetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(0), iSize);
}

//*:***********************************************
//*:* GRGetArrayDimensions
//*:***********************************************
//*:*  Gets the number of dimensions in the array
//*:***********************************************
int GRGetArrayDimensions(string sName, object oStorage=OBJECT_SELF) {
    return GetLocalInt(oStorage, "ARRAY_"+sName+"_NUM_DIMENSIONS");
}

//*:***********************************************
//*:* GRSetArrayDimensions
//*:***********************************************
//*:*  Sets the number of dimensions in the array
//*:***********************************************
void GRSetArrayDimensions(string sName, int iNumDimensions, object oStorage=OBJECT_SELF) {
    SetLocalInt(oStorage, "ARRAY_"+sName+"_NUM_DIMENSIONS", iNumDimensions);
}

//*:***********************************************
//*:* GRAddArrayDimension
//*:***********************************************
//*:*  Adds another dimension to an existing array
//*:*  list
//*:***********************************************
void GRAddArrayDimension(string sName, string sDim, int iDimType, object oStorage=OBJECT_SELF) {

    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);

    iNumDimensions++;
    GRSetDimensionName(iNumDimensions, sName, sDim, oStorage);
    GRSetDimensionType(iNumDimensions, sName, iDimType, oStorage);
    GRSetDimSize(sName, sDim, 0, oStorage);
    GRSetArrayDimensions(sName, iNumDimensions, oStorage);
}

void GRDeleteValue(string sName, string sDimName, int iPosition, object oStorage=OBJECT_SELF) {
    int iDataType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iPosition==0) iDataType = VALUE_TYPE_INT;
    switch(iDataType) {
        case VALUE_TYPE_BOOLEAN:
        case VALUE_TYPE_INT:
            DeleteLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iPosition));
            break;
        case VALUE_TYPE_STRING:
            DeleteLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iPosition));
            break;
        case VALUE_TYPE_OBJECT:
            DeleteLocalObject(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iPosition));
            break;
        case VALUE_TYPE_LOCATION:
            DeleteLocalLocation(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iPosition));
            break;
        case VALUE_TYPE_FLOAT:
            DeleteLocalFloat(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iPosition));
            break;
        case VALUE_TYPE_INVALID:
        default:
            //*** DEBUG *** AutoDebugString("Attempting to delete invalid data type.");
            //*** DEBUG *** AutoDebugString(sName, " ", sDimName, " ", IntToString(iPosition), " ", iDataType);
            break;
    }
}

void GRDeletePosition(string sName, int iPosition, object oStorage=OBJECT_SELF) {
    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);
    int iType;

    int i;
    for(i=1; i<=iNumDimensions; i++) {
        iType = GRGetDimensionType(i, sName, oStorage);
        string sDimName = GRGetDimensionName(i, sName, oStorage);
        switch(iType) {
            case VALUE_TYPE_INT:
                int n = GRIntGetAndRemoveValue(sName, sDimName, iPosition, oStorage);
                break;
            case VALUE_TYPE_BOOLEAN:
                int b = GRBooleanGetAndRemoveValue(sName, sDimName, iPosition, oStorage);
                break;
            case VALUE_TYPE_FLOAT:
                float f = GRFloatGetAndRemoveValue(sName, sDimName, iPosition, oStorage);
                break;
            case VALUE_TYPE_OBJECT:
                object o = GRObjectGetAndRemoveValue(sName, sDimName, iPosition, oStorage);
                break;
            case VALUE_TYPE_LOCATION:
                location l = GRLocationGetAndRemoveValue(sName, sDimName, iPosition, oStorage);
                break;
            case VALUE_TYPE_STRING:
                string s = GRStringGetAndRemoveValue(sName, sDimName, iPosition, oStorage);
                break;
        }
        //GRSetDimSize(sName, sDimName, GRGetDimSize(sName, sDimName, oStorage)-1, oStorage);   // update each dimension size
    }
}

void GRDeleteArrayDimension(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iPos = GRGetDimNumber(sName, sDimName, oStorage);
    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);

    int i;
    for(i=iSize; i>=0; i--) {
       GRDeleteValue(sName, sDimName, i, oStorage);
    }
    if(iPos<GRGetArrayDimensions(sName, oStorage)) {
        for(i=iPos+1; i<=GRGetArrayDimensions(sName, oStorage); i++) {
            GRSetDimensionName(i-1, sName, GRGetDimensionName(i, sName, oStorage), oStorage);
            GRSetDimensionType(i-1, sName, GRGetDimensionType(i, sName, oStorage), oStorage);
        }
    }
    DeleteLocalString(oStorage, "ARRAY_"+sName+"_NAME_DIM"+IntToString(iNumDimensions));
    DeleteLocalInt(oStorage, "ARRAY_"+sName+"_TYPE_DIM"+IntToString(iNumDimensions));
    iNumDimensions--;
    GRSetArrayDimensions(sName, iNumDimensions, oStorage);
}

void GRDeleteArrayList(string sName, object oStorage=OBJECT_SELF) {
    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);

    int i, j;
    for(i=iNumDimensions; i>0; i--) {
        GRDeleteArrayDimension(sName, GRGetDimensionName(i, sName, oStorage), oStorage);
    }
}

void GRIntAdd(string sName, string sDimName, int iValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_INT) {
        iSize++;
        SetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize), iValue);
        GRSetDimSize(sName, sDimName, iSize, oStorage);
    }
}

void GRBooleanAdd(string sName, string sDimName, int bValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_BOOLEAN) {
        iSize++;
        SetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize), bValue!=FALSE);
        GRSetDimSize(sName, sDimName, iSize, oStorage);
    }
}

void GRFloatAdd(string sName, string sDimName, float fValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_FLOAT) {
        iSize++;
        SetLocalFloat(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize), fValue);
        GRSetDimSize(sName, sDimName, iSize, oStorage);
    }
}

void GRObjectAdd(string sName, string sDimName, object oObject, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_OBJECT) {
        iSize++;
        SetLocalObject(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize), oObject);
        GRSetDimSize(sName, sDimName, iSize, oStorage);
    }
}

void GRLocationAdd(string sName, string sDimName, location lLoc, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_LOCATION) {
        iSize++;
        SetLocalLocation(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize), lLoc);
        GRSetDimSize(sName, sDimName, iSize, oStorage);
    }
}

void GRStringAdd(string sName, string sDimName, string sValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_STRING) {
        iSize++;
        SetLocalString(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize), sValue);
        GRSetDimSize(sName, sDimName, iSize, oStorage);
    }
}

int GRIntPop(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    int iValue = -9999;

    if(iType==VALUE_TYPE_INT) {
        if(iSize>0) {
            iValue = GetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize));
            GRDeleteValue(sName, sDimName, iSize, oStorage);
            GRSetDimSize(sName, sDimName, iSize--, oStorage);
        }
    }
    return iValue;
}

int GRBooleanPop(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    int bValue = FALSE;

    if(iType==VALUE_TYPE_BOOLEAN) {
        if(iSize>0) {
            bValue = GetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize));
            GRDeleteValue(sName, sDimName, iSize, oStorage);
            GRSetDimSize(sName, sDimName, iSize--, oStorage);
        }
    }
    return bValue;
}

object GRObjectPop(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    object oObject = OBJECT_INVALID;

    if(iType==VALUE_TYPE_OBJECT) {
        if(iSize>0) {
            oObject = GetLocalObject(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize));
            GRDeleteValue(sName, sDimName, iSize, oStorage);
            GRSetDimSize(sName, sDimName, iSize--, oStorage);
        }
    }
    return oObject;
}

location GRLocationPop(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    location lLoc = GetLocation(oStorage);

    if(iType==VALUE_TYPE_LOCATION) {
        if(iSize>0) {
            lLoc = GetLocalLocation(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize));
            GRDeleteValue(sName, sDimName, iSize, oStorage);
            GRSetDimSize(sName, sDimName, iSize--, oStorage);
        }
    }
    return lLoc;
}

string GRStringPop(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    string sValue = "";

    if(iType==VALUE_TYPE_STRING) {
        if(iSize>0) {
            sValue = GetLocalString(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize));
            GRDeleteValue(sName, sDimName, iSize, oStorage);
            GRSetDimSize(sName, sDimName, iSize--, oStorage);
        }
    }
    return sValue;
}

float GRFloatPop(string sName, string sDimName, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    float fValue = -9999.0f;

    if(iType==VALUE_TYPE_FLOAT) {
        if(iSize>0) {
            fValue = GetLocalFloat(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iSize));
            GRDeleteValue(sName, sDimName, iSize, oStorage);
            GRSetDimSize(sName, sDimName, iSize--, oStorage);
        }
    }
    return fValue;
}

int GRIntIndexOf(string sName, string sDimName, int iValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_INT) {
        int i;
        for(i=iAtOrAfterPosition; i<=iSize; i++) {
            if(iValueToFind==GetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(i))) return i;
        }
    }
    return -1;
}

int GRBooleanIndexOf(string sName, string sDimName, int bValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_BOOLEAN) {
        int i;
        for(i=iAtOrAfterPosition; i<=iSize; i++) {
            if(bValueToFind==GetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(i))) return i;
        }
    }
    return -1;
}

int GRFloatIndexOf(string sName, string sDimName, float fValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_FLOAT) {
        int i;
        for(i=iAtOrAfterPosition; i<=iSize; i++) {
            if(fValueToFind==GetLocalFloat(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(i))) return i;
        }
    }
    return -1;
}

int GRObjectIndexOf(string sName, string sDimName, object oObjectToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_OBJECT) {
        int i;
        for(i=iAtOrAfterPosition; i<=iSize; i++) {
            if(oObjectToFind==GetLocalObject(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(i))) return i;
        }
    }
    return -1;
}

int GRLocationIndexOf(string sName, string sDimName, location lLocToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_LOCATION) {
        int i;
        for(i=iAtOrAfterPosition; i<=iSize; i++) {
            if(lLocToFind==GetLocalLocation(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(i))) return i;
        }
    }
    return -1;
}

int GRStringIndexOf(string sName, string sDimName, string sValueToFind, int iAtOrAfterPosition=1, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_STRING) {
        int i;
        for(i=iAtOrAfterPosition; i<=iSize; i++) {
            if(sValueToFind==GetLocalString(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(i))) return i;
        }
    }
    return -1;
}

int GRIntGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    int iValue = -9999;

    if(iType==VALUE_TYPE_INT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            iValue = GetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex));
        }
    }
    return iValue;
}

float GRFloatGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    float fValue = -9999.0f;

    if(iType==VALUE_TYPE_FLOAT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            fValue = GetLocalFloat(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex));
        }
    }
    return fValue;
}

int GRBooleanGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    int bValue = FALSE;

    if(iType==VALUE_TYPE_BOOLEAN) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            bValue = GetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex));
        }
    }
    return bValue;
}

object GRObjectGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    object oObject = OBJECT_INVALID;

    if(iType==VALUE_TYPE_OBJECT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            oObject = GetLocalObject(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex));
        }
    }
    return oObject;
}

location GRLocationGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    location lLoc = GetLocation(oStorage);

    if(iType==VALUE_TYPE_LOCATION) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            lLoc = GetLocalLocation(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex));
        }
    }
    return lLoc;
}

string GRStringGetValueAt(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);
    string sValue = "";

    if(iType==VALUE_TYPE_STRING) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            sValue = GetLocalString(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex));
        }
    }
    return sValue;
}

int GRIntGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int iValue = GRIntGetValueAt(sName, sDimName, iArrayIndex, oStorage);
    int i;
    int iDimSize = GRGetDimSize(sName, sDimName, oStorage);

    for(i=iArrayIndex; i<iDimSize; i++) {
        GRIntSetValueAt(sName, sDimName, i, GRIntGetValueAt(sName, sDimName, i+1, oStorage), oStorage);
    }

    GRDeleteValue(sName, sDimName, iDimSize, oStorage);
    GRSetDimSize(sName, sDimName, iDimSize--, oStorage);

    return iValue;
}

int GRBooleanGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    int bValue = GRBooleanGetValueAt(sName, sDimName, iArrayIndex, oStorage);
    int i;
    int iDimSize = GRGetDimSize(sName, sDimName, oStorage);

    for(i=iArrayIndex; i<iDimSize; i++) {
        GRIntSetValueAt(sName, sDimName, i, GRIntGetValueAt(sName, sDimName, i+1, oStorage), oStorage);
    }

    GRDeleteValue(sName, sDimName, iDimSize, oStorage);
    GRSetDimSize(sName, sDimName, iDimSize--, oStorage);

    return bValue;
}

float GRFloatGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    float fValue = GRFloatGetValueAt(sName, sDimName, iArrayIndex, oStorage);
    int i;
    int iDimSize = GRGetDimSize(sName, sDimName, oStorage);

    for(i=iArrayIndex; i<iDimSize; i++) {
        GRIntSetValueAt(sName, sDimName, i, GRIntGetValueAt(sName, sDimName, i+1, oStorage), oStorage);
    }

    GRDeleteValue(sName, sDimName, iDimSize, oStorage);
    GRSetDimSize(sName, sDimName, iDimSize--, oStorage);

    return fValue;
}

object GRObjectGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    object oObject = GRObjectGetValueAt(sName, sDimName, iArrayIndex, oStorage);
    int i;
    int iDimSize = GRGetDimSize(sName, sDimName, oStorage);

    for(i=iArrayIndex; i<iDimSize; i++) {
        GRIntSetValueAt(sName, sDimName, i, GRIntGetValueAt(sName, sDimName, i+1, oStorage), oStorage);
    }

    GRDeleteValue(sName, sDimName, iDimSize, oStorage);
    GRSetDimSize(sName, sDimName, iDimSize--, oStorage);

    return oObject;
}

location GRLocationGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    location lLoc = GRLocationGetValueAt(sName, sDimName, iArrayIndex, oStorage);
    int i;
    int iDimSize = GRGetDimSize(sName, sDimName, oStorage);

    for(i=iArrayIndex; i<iDimSize; i++) {
        GRIntSetValueAt(sName, sDimName, i, GRIntGetValueAt(sName, sDimName, i+1, oStorage), oStorage);
    }

    GRDeleteValue(sName, sDimName, iDimSize, oStorage);
    GRSetDimSize(sName, sDimName, iDimSize--, oStorage);

    return lLoc;
}

string GRStringGetAndRemoveValue(string sName, string sDimName, int iArrayIndex, object oStorage=OBJECT_SELF) {
    string sValue = GRStringGetValueAt(sName, sDimName, iArrayIndex, oStorage);
    int i;
    int iDimSize = GRGetDimSize(sName, sDimName, oStorage);

    for(i=iArrayIndex; i<iDimSize; i++) {
        GRIntSetValueAt(sName, sDimName, i, GRIntGetValueAt(sName, sDimName, i+1, oStorage), oStorage);
    }

    GRDeleteValue(sName, sDimName, iDimSize, oStorage);
    GRSetDimSize(sName, sDimName, iDimSize--, oStorage);

    return sValue;
}

void GRIntInsert(string sName, string sDimName, int iArrayIndex, int iValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_INT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            iSize++;
            int i, iTemp;
            string sTemp = GRGetFullDimName(sName, sDimName);
            for(i=iSize; i>iArrayIndex; i--) {
                iTemp = GRIntGetValueAt(sName, sDimName, i-1, oStorage);
                SetLocalInt(oStorage, sTemp+IntToString(i), iTemp);
            }
            SetLocalInt(oStorage, sTemp+IntToString(iArrayIndex), iValue);
            GRSetDimSize(sName, sDimName, iSize, oStorage);
        }
    }
}

void GRBooleanInsert(string sName, string sDimName, int iArrayIndex, int bValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_BOOLEAN) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            iSize++;
            int i, bTemp;
            string sTemp = GRGetFullDimName(sName, sDimName);
            for(i=iSize; i>iArrayIndex; i--) {
                bTemp = GRBooleanGetValueAt(sName, sDimName, i-1, oStorage);
                SetLocalInt(oStorage, sTemp+IntToString(i), bTemp);
            }
            SetLocalInt(oStorage, sTemp+IntToString(iArrayIndex), bValue);
            GRSetDimSize(sName, sDimName, iSize, oStorage);
        }
    }
}

void GRFloatInsert(string sName, string sDimName, int iArrayIndex, float fValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_FLOAT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            iSize++;
            int i;
            float fTemp;
            string sTemp = GRGetFullDimName(sName, sDimName);
            for(i=iSize; i>iArrayIndex; i--) {
                fTemp = GRFloatGetValueAt(sName, sDimName, i-1, oStorage);
                SetLocalFloat(oStorage, sTemp+IntToString(i), fTemp);
            }
            SetLocalFloat(oStorage, sTemp+IntToString(iArrayIndex), fValue);
            GRSetDimSize(sName, sDimName, iSize, oStorage);
        }
    }
}

void GRObjectInsert(string sName, string sDimName, int iArrayIndex, object oObject, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_OBJECT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            iSize++;
            int i;
            object oTemp;
            string sTemp = GRGetFullDimName(sName, sDimName);
            for(i=iSize; i>iArrayIndex; i--) {
                oTemp = GRObjectGetValueAt(sName, sDimName, i-1, oStorage);
                SetLocalObject(oStorage, sTemp+IntToString(i), oTemp);
            }
            SetLocalObject(oStorage, sTemp+IntToString(iArrayIndex), oObject);
            GRSetDimSize(sName, sDimName, iSize, oStorage);
        }
    }
}

void GRLocationInsert(string sName, string sDimName, int iArrayIndex, location lLoc, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_LOCATION) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            iSize++;
            int i;
            location lTemp;
            string sTemp = GRGetFullDimName(sName, sDimName);
            for(i=iSize; i>iArrayIndex; i--) {
                lTemp = GRLocationGetValueAt(sName, sDimName, i-1, oStorage);
                SetLocalLocation(oStorage, sTemp+IntToString(i), lTemp);
            }
            SetLocalLocation(oStorage, sTemp+IntToString(iArrayIndex), lLoc);
            GRSetDimSize(sName, sDimName, iSize, oStorage);
        }
    }
}

void GRStringInsert(string sName, string sDimName, int iArrayIndex, string sValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_STRING) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            iSize++;
            int i;
            string sTempValue;
            string sTemp = GRGetFullDimName(sName, sDimName);
            for(i=iSize; i>iArrayIndex; i--) {
                sTempValue = GRStringGetValueAt(sName, sDimName, i-1, oStorage);
                SetLocalString(oStorage, sTemp+IntToString(i), sTempValue);
            }
            SetLocalString(oStorage, sTemp+IntToString(iArrayIndex), sValue);
            GRSetDimSize(sName, sDimName, iSize, oStorage);
        }
    }
}

void GRIntSetValueAt(string sName, string sDimName, int iArrayIndex, int iValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_INT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            SetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex), iValue);
        }
    }
}

void GRFloatSetValueAt(string sName, string sDimName, int iArrayIndex, float fValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_FLOAT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            SetLocalFloat(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex), fValue);
        }
    }
}

void GRBooleanSetValueAt(string sName, string sDimName, int iArrayIndex, int bValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_BOOLEAN) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            SetLocalInt(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex), bValue);
        }
    }
}

void GRObjectSetValueAt(string sName, string sDimName, int iArrayIndex, object oObject, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_OBJECT) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            SetLocalObject(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex), oObject);
        }
    }
}

void GRLocationSetValueAt(string sName, string sDimName, int iArrayIndex, location lLoc, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_LOCATION) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            SetLocalLocation(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex), lLoc);
        }
    }
}

void GRStringSetValueAt(string sName, string sDimName, int iArrayIndex, string sValue, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_STRING) {
        if(0<iArrayIndex && iArrayIndex<=iSize) {
            SetLocalString(oStorage, GRGetFullDimName(sName, sDimName)+IntToString(iArrayIndex), sValue);
        }
    }
}

void GRIntSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_INT) {
        if(0<iIndex1 && iIndex1<=iSize && 0<iIndex2 && iIndex2<=iSize && iIndex1!=iIndex2) {
            int iTemp1 = GRIntGetValueAt(sName, sDimName, iIndex1, oStorage);
            GRIntSetValueAt(sName, sDimName, iIndex1, GRIntGetValueAt(sName, sDimName, iIndex2, oStorage), oStorage);
            GRIntSetValueAt(sName, sDimName, iIndex2, iTemp1, oStorage);
        }
    }
}

void GRBooleanSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_BOOLEAN) {
        if(0<iIndex1 && iIndex1<=iSize && 0<iIndex2 && iIndex2<=iSize && iIndex1!=iIndex2) {
            int bTemp1 = GRBooleanGetValueAt(sName, sDimName, iIndex1, oStorage);
            GRIntSetValueAt(sName, sDimName, iIndex1, GRBooleanGetValueAt(sName, sDimName, iIndex2, oStorage), oStorage);
            GRIntSetValueAt(sName, sDimName, iIndex2, bTemp1, oStorage);
        }
    }
}

void GRFloatSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_FLOAT) {
        if(0<iIndex1 && iIndex1<=iSize && 0<iIndex2 && iIndex2<=iSize && iIndex1!=iIndex2) {
            float fTemp1 = GRFloatGetValueAt(sName, sDimName, iIndex1, oStorage);
            GRFloatSetValueAt(sName, sDimName, iIndex1, GRFloatGetValueAt(sName, sDimName, iIndex2, oStorage), oStorage);
            GRFloatSetValueAt(sName, sDimName, iIndex2, fTemp1, oStorage);
        }
    }
}

void GRObjectSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_OBJECT) {
        if(0<iIndex1 && iIndex1<=iSize && 0<iIndex2 && iIndex2<=iSize && iIndex1!=iIndex2) {
            object oTemp1 = GRObjectGetValueAt(sName, sDimName, iIndex1, oStorage);
            GRObjectSetValueAt(sName, sDimName, iIndex1, GRObjectGetValueAt(sName, sDimName, iIndex2, oStorage), oStorage);
            GRObjectSetValueAt(sName, sDimName, iIndex2, oTemp1, oStorage);
        }
    }
}

void GRLocationSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_LOCATION) {
        if(0<iIndex1 && iIndex1<=iSize && 0<iIndex2 && iIndex2<=iSize && iIndex1!=iIndex2) {
            location lTemp1 = GRLocationGetValueAt(sName, sDimName, iIndex1, oStorage);
            GRLocationSetValueAt(sName, sDimName, iIndex1, GRLocationGetValueAt(sName, sDimName, iIndex2, oStorage), oStorage);
            GRLocationSetValueAt(sName, sDimName, iIndex2, lTemp1, oStorage);
        }
    }
}

void GRStringSwap(string sName, string sDimName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iSize = GRGetDimSize(sName, sDimName, oStorage);
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sDimName, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_STRING) {
        if(0<iIndex1 && iIndex1<=iSize && 0<iIndex2 && iIndex2<=iSize && iIndex1!=iIndex2) {
            string sTemp1 = GRStringGetValueAt(sName, sDimName, iIndex1, oStorage);
            GRStringSetValueAt(sName, sDimName, iIndex1, GRStringGetValueAt(sName, sDimName, iIndex2, oStorage), oStorage);
            GRStringSetValueAt(sName, sDimName, iIndex2, sTemp1, oStorage);
        }
    }
}

void GRSwapAll(string sName, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);
    int i, iType;
    string sDimName;

    for(i=1; i<=iNumDimensions; i++) {
        iType = GRGetDimensionType(i, sName, oStorage);
        sDimName = GRGetDimensionName(i, sName, oStorage);
        switch(iType) {
            case VALUE_TYPE_INT:
                GRIntSwap(sName, sDimName, iIndex1, iIndex2, oStorage);
                break;
            case VALUE_TYPE_BOOLEAN:
                GRBooleanSwap(sName, sDimName, iIndex1, iIndex2, oStorage);
                break;
            case VALUE_TYPE_FLOAT:
                GRFloatSwap(sName, sDimName, iIndex1, iIndex2, oStorage);
                break;
            case VALUE_TYPE_OBJECT:
                GRObjectSwap(sName, sDimName, iIndex1, iIndex2, oStorage);
                break;
            case VALUE_TYPE_LOCATION:
                GRLocationSwap(sName, sDimName, iIndex1, iIndex2, oStorage);
                break;
            case VALUE_TYPE_STRING:
                GRStringSwap(sName, sDimName, iIndex1, iIndex2, oStorage);
                break;
        }
    }

}

//*:* This version of InsertionSort will sort multiple dimensions, but will only use
//*:* one dimension as the sort key - key must be int, float, or string
void GRInsertionSort(string sName, string sKey1, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);
    int i, j, k;
    int iTemp;
    float fTemp;
    string sTemp;
    int iType, iTempType;
    string sKeepValues = "KEEP_VALUES";

    iType = GRGetDimensionType(GRGetDimNumber(sName, sKey1, oStorage), sName, oStorage);

    // sort key must be of type int, float, or string
    if(iType==VALUE_TYPE_INT || iType==VALUE_TYPE_FLOAT || iType==VALUE_TYPE_STRING) {
        for(i=iIndex1+1; i<=iIndex2; i++) {
            // store all the "non-key" dimension values for position i
            if(iNumDimensions>1) {
                for(k=1; k<=iNumDimensions; k++) {
                string sDimName = GRGetDimensionName(k, sName, oStorage);
                if(sDimName!=sKey1) {
                    iTempType = GRGetDimensionType(k, sName, oStorage);
                    switch(iTempType) {
                        case VALUE_TYPE_INT:
                            SetLocalInt(oStorage, sKeepValues+IntToString(k), GRIntGetValueAt(sName, sDimName, i, oStorage));
                            break;
                        case VALUE_TYPE_BOOLEAN:
                            SetLocalInt(oStorage, sKeepValues+IntToString(k), GRBooleanGetValueAt(sName, sDimName, i, oStorage));
                            break;
                        case VALUE_TYPE_FLOAT:
                            SetLocalFloat(oStorage, sKeepValues+IntToString(k), GRFloatGetValueAt(sName, sDimName, i, oStorage));
                            break;
                        case VALUE_TYPE_OBJECT:
                            SetLocalObject(oStorage, sKeepValues+IntToString(k), GRObjectGetValueAt(sName, sDimName, i, oStorage));
                            break;
                        case VALUE_TYPE_LOCATION:
                            SetLocalLocation(oStorage, sKeepValues+IntToString(k), GRLocationGetValueAt(sName, sDimName, i, oStorage));
                            break;
                        case VALUE_TYPE_STRING:
                            SetLocalString(oStorage, sKeepValues+IntToString(k), GRStringGetValueAt(sName, sDimName, i, oStorage));
                            break;
                    }
                }
            }
            }
            // initialize j
            j = i-1;
            // do pass based on key dimension value type
            switch(iType) {
                case VALUE_TYPE_INT:
                    // get key dimension value at position i
                    iTemp = GRIntGetValueAt(sName, sKey1, i, oStorage);
                    while(j>=iIndex1 && GRIntGetValueAt(sName, sKey1, j, oStorage)>iTemp) {
                        // swap key dimension value
                        GRIntSetValueAt(sName, sKey1, j+1, GRIntGetValueAt(sName, sKey1, j, oStorage), oStorage);
                        // swap non-key dimension values
                        if(iNumDimensions>1) {
                            for(k=1; k<=iNumDimensions; k++) {
                                string sDimName = GRGetDimensionName(k, sName, oStorage);
                                if(sDimName!=sKey1) {
                                    iTempType = GRGetDimensionType(k, sName, oStorage);
                                    switch(iTempType) {
                                        case VALUE_TYPE_INT:
                                            GRIntSetValueAt(sName, sDimName, j+1, GRIntGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_BOOLEAN:
                                            GRBooleanSetValueAt(sName, sDimName, j+1, GRBooleanGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_FLOAT:
                                            GRFloatSetValueAt(sName, sDimName, j+1, GRFloatGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_OBJECT:
                                            GRObjectSetValueAt(sName, sDimName, j+1, GRObjectGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_LOCATION:
                                            GRLocationSetValueAt(sName, sDimName, j+1, GRLocationGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_STRING:
                                            GRStringSetValueAt(sName, sDimName, j+1, GRStringGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                    }
                                }
                            }
                        }
                        j--;
                    }
                    // replace the original value at new position
                    GRIntSetValueAt(sName, sKey1, j+1, iTemp);
                    break;
                case VALUE_TYPE_FLOAT:
                    fTemp = GRFloatGetValueAt(sName, sKey1, i, oStorage);
                    while(j>=iIndex1 && GRFloatGetValueAt(sName, sKey1, j, oStorage)>fTemp) {
                        GRFloatSetValueAt(sName, sKey1, j+1, GRFloatGetValueAt(sName, sKey1, j, oStorage), oStorage);
                        if(iNumDimensions>1) {
                            for(k=1; k<=iNumDimensions; k++) {
                                string sDimName = GRGetDimensionName(k, sName, oStorage);
                                if(sDimName!=sKey1) {
                                    iTempType = GRGetDimensionType(k, sName, oStorage);
                                    switch(iTempType) {
                                        case VALUE_TYPE_INT:
                                            GRIntSetValueAt(sName, sDimName, j+1, GRIntGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_BOOLEAN:
                                            GRBooleanSetValueAt(sName, sDimName, j+1, GRBooleanGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_FLOAT:
                                            GRFloatSetValueAt(sName, sDimName, j+1, GRFloatGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_OBJECT:
                                            GRObjectSetValueAt(sName, sDimName, j+1, GRObjectGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_LOCATION:
                                            GRLocationSetValueAt(sName, sDimName, j+1, GRLocationGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_STRING:
                                            GRStringSetValueAt(sName, sDimName, j+1, GRStringGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                    }
                                }
                            }
                        }
                        j--;
                    }
                    GRFloatSetValueAt(sName, sKey1, j+1, fTemp);
                    break;
                case VALUE_TYPE_STRING:
                    sTemp = GRStringGetValueAt(sName, sKey1, i, oStorage);
                    while(j>=iIndex1 && strcmp(GRStringGetValueAt(sName, sKey1, j, oStorage),sTemp)==1) {
                        GRStringSetValueAt(sName, sKey1, j+1, GRStringGetValueAt(sName, sKey1, j, oStorage), oStorage);
                        if(iNumDimensions>1) {
                            for(k=1; k<=iNumDimensions; k++) {
                                string sDimName = GRGetDimensionName(k, sName, oStorage);
                                if(sDimName!=sKey1) {
                                    iTempType = GRGetDimensionType(k, sName, oStorage);
                                    switch(iTempType) {
                                        case VALUE_TYPE_INT:
                                            GRIntSetValueAt(sName, sDimName, j+1, GRIntGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_BOOLEAN:
                                            GRBooleanSetValueAt(sName, sDimName, j+1, GRBooleanGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_FLOAT:
                                            GRFloatSetValueAt(sName, sDimName, j+1, GRFloatGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_OBJECT:
                                            GRObjectSetValueAt(sName, sDimName, j+1, GRObjectGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_LOCATION:
                                            GRLocationSetValueAt(sName, sDimName, j+1, GRLocationGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                        case VALUE_TYPE_STRING:
                                            GRStringSetValueAt(sName, sDimName, j+1, GRStringGetValueAt(sName, sDimName, j, oStorage), oStorage);
                                            break;
                                    }
                                }
                            }
                        }
                        j--;
                    }
                    GRStringSetValueAt(sName, sKey1, j+1, sTemp);
                    break;
            }
            // replace the other original values at new position
            if(iNumDimensions>1) {
                for(k=1; k<=iNumDimensions; k++) {
                    string sDimName = GRGetDimensionName(k, sName, oStorage);
                    if(sDimName!=sKey1) {
                        iTempType = GRGetDimensionType(k, sName, oStorage);
                        switch(iTempType) {
                            case VALUE_TYPE_INT:
                                GRIntSetValueAt(sName, sDimName, j+1, GetLocalInt(oStorage, sKeepValues+IntToString(k)), oStorage);
                                break;
                            case VALUE_TYPE_BOOLEAN:
                                GRBooleanSetValueAt(sName, sDimName, j+1, GetLocalInt(oStorage, sKeepValues+IntToString(k)), oStorage);
                                break;
                            case VALUE_TYPE_FLOAT:
                                GRFloatSetValueAt(sName, sDimName, j+1, GetLocalFloat(oStorage, sKeepValues+IntToString(k)), oStorage);
                                break;
                            case VALUE_TYPE_OBJECT:
                                GRObjectSetValueAt(sName, sDimName, j+1, GetLocalObject(oStorage, sKeepValues+IntToString(k)), oStorage);
                                break;
                            case VALUE_TYPE_LOCATION:
                                GRLocationSetValueAt(sName, sDimName, j+1, GetLocalLocation(oStorage, sKeepValues+IntToString(k)), oStorage);
                                break;
                            case VALUE_TYPE_STRING:
                                GRStringSetValueAt(sName, sDimName, j+1, GetLocalString(oStorage, sKeepValues+IntToString(k)), oStorage);
                                break;
                        }
                    }
                }
            }
        }
    }
}

//*:* This version of QuickSort will sort multiple dimensions, but will only use
//*:* one dimension as the sort key (no sorting by multiple keys)
int GRQSPartition(string sName, string sKey1, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sKey1, oStorage), sName, oStorage);
    int iNumDimensions = GRGetArrayDimensions(sName, oStorage);

    int i = iIndex1;
    int j = iIndex2+1;

    switch(iType) {
        case VALUE_TYPE_INT:
            int iPivot = GRIntGetValueAt(sName, sKey1, iIndex1, oStorage);
            do {
                do {
                    i++;
                } while(GRIntGetValueAt(sName, sKey1, i, oStorage)<iPivot && i<iIndex2);
                do {
                    j--;
                } while(GRIntGetValueAt(sName, sKey1, j, oStorage)>iPivot);
                GRSwapAll(sName, i, j, oStorage);
            } while(i<j);
            GRSwapAll(sName, i, j, oStorage);
            GRSwapAll(sName, iIndex1, j, oStorage);
            break;
        case VALUE_TYPE_FLOAT:
            float fPivot = GRFloatGetValueAt(sName, sKey1, iIndex1, oStorage);
            do {
                do {
                    i++;
                } while(GRFloatGetValueAt(sName, sKey1, i, oStorage)<fPivot && i<iIndex2);
                do {
                    j--;
                } while(GRFloatGetValueAt(sName, sKey1, j, oStorage)>fPivot);
                GRSwapAll(sName, i, j, oStorage);
            } while(i<j);
            GRSwapAll(sName, i, j, oStorage);
            GRSwapAll(sName, iIndex1, j, oStorage);
            break;
        case VALUE_TYPE_STRING:
            string sPivot = GRStringGetValueAt(sName, sKey1, iIndex1, oStorage);
            do {
                do {
                    i++;
                } while(strcmp(GRStringGetValueAt(sName, sKey1, i, oStorage),sPivot)==-1 && i<iIndex2);
                do {
                    j--;
                } while(strcmp(GRStringGetValueAt(sName, sKey1, j, oStorage),sPivot)==1);
                GRSwapAll(sName, i, j, oStorage);
            } while(i<j);
            GRSwapAll(sName, i, j, oStorage);
            GRSwapAll(sName, iIndex1, j, oStorage);
            break;
    }

    return j;
}

//*:* This version of QuickSort will sort multiple dimensions, but will only use
//*:* one dimension as the sort key (no sorting by multiple keys)
void GRQuickSort(string sName, string sKey1, int iIndex1, int iIndex2, object oStorage=OBJECT_SELF) {
    int iType = GRGetDimensionType(GRGetDimNumber(sName, sKey1, oStorage), sName, oStorage);

    if(iType==VALUE_TYPE_INT || iType==VALUE_TYPE_FLOAT || iType==VALUE_TYPE_STRING) {
        if(iIndex1<iIndex2) {
            if(iIndex2-iIndex1>3) {
                int iSplitPos = GRQSPartition(sName, sKey1, iIndex1, iIndex2, oStorage);
                GRQuickSort(sName, sKey1, iIndex1, iSplitPos - 1, oStorage);
                GRQuickSort(sName, sKey1, iSplitPos + 1, iIndex2, oStorage);
            } else {
                GRInsertionSort(sName, sKey1, iIndex1, iIndex2, oStorage);
            }
        }
    }
}