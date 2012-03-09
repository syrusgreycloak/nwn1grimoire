/*
Filename:           h2_biowaredb_c
System:             core  (bioware database persistence)
Author:             Edward Beck (0100010)
Date Created:       Aug. 28, 2005
Summary:
HCR2 core external database function user-configuration script.
This script should be consumed by h2_persistence_c as an include directive, if
the builder desires to use the Bioware database as their means of campaign database storage.

Revision Info should only be included for post-release revisions.
-----------------
Revision Date:
Revision Author:
Revision Summary:

*/

//A user defined constant that specifies the name of the campaign associated
//with external database variable storage. This value will be used whenever
//any of the h2_Get\SetExternal functions are called and the campaign name is not specified.
const string H2_DEFAULT_CAMPAIGN_NAME = "H2_TESTMODULE";

void h2_InitializeDatabase()
{
    return;
}

float h2_GetExternalFloat(string sVarName, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    return GetCampaignFloat(sCampaignName, sVarName, oPlayer);
}

int h2_GetExternalInt(string sVarName, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    return GetCampaignInt(sCampaignName, sVarName, oPlayer);
}

location h2_GetExternalLocation(string sVarName, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    return GetCampaignLocation(sCampaignName, sVarName, oPlayer);
}

string h2_GetExternalString(string sVarName, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    return GetCampaignString(sCampaignName, sVarName, oPlayer);
}

vector h2_GetExternalVector(string sVarName, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    return GetCampaignVector(sCampaignName, sVarName, oPlayer);
}

object h2_GetExternalObject(string sVarName, location locLocation, object oOwner = OBJECT_INVALID, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    return RetrieveCampaignObject(sCampaignName, sVarName, locLocation, oOwner, oPlayer);
}

void h2_DeleteExternalVariable(string sVarName, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    DeleteCampaignVariable(sCampaignName, sVarName, oPlayer);
}

void h2_SetExternalFloat(string sVarName, float flFloat, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    SetCampaignFloat(sCampaignName, sVarName, flFloat, oPlayer);
}

void h2_SetExternalInt(string sVarName, int nInt, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    SetCampaignInt(sCampaignName, sVarName, nInt, oPlayer);
}

void h2_SetExternalLocation(string sVarName, location locLocation, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    SetCampaignLocation(sCampaignName, sVarName, locLocation, oPlayer);
}

void h2_SetExternalString(string sVarName, string sString, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    SetCampaignString(sCampaignName, sVarName, sString, oPlayer);
}

void h2_SetExternalVector(string sVarName, vector vVector, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    SetCampaignVector(sCampaignName, sVarName, vVector, oPlayer);
}

int h2_SetExternalObject(string sVarName, object oObject, object oPlayer=OBJECT_INVALID, string sCampaignName=H2_DEFAULT_CAMPAIGN_NAME)
{
    int bSuccess = StoreCampaignObject(sCampaignName, sVarName, oObject, oPlayer);
    if (!bSuccess)
        WriteTimestampedLogEntry("StoreCampaignObject failed on object " + GetResRef(oObject) + " to variable " + sVarName);
    return bSuccess;
}
