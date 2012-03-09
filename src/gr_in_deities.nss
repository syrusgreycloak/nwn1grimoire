//*:**************************************************************************
//*:*  GR_IN_DEITIES.NSS
//*:**************************************************************************
//*:*
//*:* Deity-related functions
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2004
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************

//*:**************************************************************************
//*:* Include following files
//*:**************************************************************************
#include "GR_IC_DEITIES"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int     GRGetDeityAlignGoodEvil(int iDeityConst);
int     GRGetDeityAlignLawChaos(int iDeityConst);
int     GRGetDeity(object oCaster = OBJECT_SELF);
void    GRSetDeityValue(object oTarget, int iDeityConst);
void    GRSetPCDeity(object oPC);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetDeityAlignGoodEvil
//*:**********************************************
//*:*
//*:* Returns the Good/Evil alignment part of the
//*:* specified deity
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 3, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetDeityAlignGoodEvil(int iDeityConst) {

    switch(iDeityConst) {
        case DEITY_CORELLON_LARETHIAN:
        case DEITY_KORD:
        case DEITY_LLIIRA:
        case DEITY_LURUE:
        case DEITY_SELUNE:
        case DEITY_SHARESS:
        case DEITY_SUNE:
        case DEITY_TYMORA:
        case DEITY_VALKUR:
        case DEITY_ANHUR:
        case DEITY_NEPHTHYS:
        case DEITY_EILISTRAEE:
        case DEITY_DUGMAREN_BRIGHTMANTLE:
        case DEITY_HAELA_BRIGHTAXE:
        case DEITY_SHARINDLAR:
        case DEITY_THARD_HARR:
        case DEITY_AERDRIE_FAENYA:
        case DEITY_ANGHARRADH:
        case DEITY_DEEP_SASHELAS:
        case DEITY_HANALI_CELANIL:
        case DEITY_LABELAS_ENORETH:
        case DEITY_RILLIFANE_RALLATHIL:
        case DEITY_SEHANINE_MOONBOW:
        case DEITY_SOLONOR_THELANDIRA:
        case DEITY_HEIRONEOUS:
        case DEITY_MORADIN:
        case DEITY_YONDALLA:
        case DEITY_ILMATER:
        case DEITY_NOBANION:
        case DEITY_TORM:
        case DEITY_TYR:
        case DEITY_HORUS_RE:
        case DEITY_OSIRIS:
        case DEITY_BERRONAR_TRUESILVER:
        case DEITY_CLANGEDDIN_SILVERBEARD:
        case DEITY_GORM_GULTHYN:
        case DEITY_GAERDAL_IRONHAND:
        case DEITY_ARVOREEN:
        case DEITY_CYRROLLALEE:
        case DEITY_EHLONNA:
        case DEITY_GARL_GLITTERGOLD:
        case DEITY_PELOR:
        case DEITY_CHAUNTEA:
        case DEITY_DENEIR:
        case DEITY_ELDATH:
        case DEITY_GWAERON_WINDSTROM:
        case DEITY_LATHANDER:
        case DEITY_MIELIKKI:
        case DEITY_MILIL:
        case DEITY_MYSTRA:
        case DEITY_SHIALLIA:
        case DEITY_HATHOR:
        case DEITY_ISIS:
        case DEITY_MARTHAMMOR_DUIN:
        case DEITY_BAERVAN_WILDWANDERER:
        case DEITY_BARAVAR_CLOAKSHADOW:
        case DEITY_FLANDAL_STEELSKIN:
        case DEITY_SEGOJAN_EARTHCALLER:
            return ALIGNMENT_GOOD;
            break;
        case DEITY_ERYTHNUL:
        case DEITY_GRUUMSH:
        case DEITY_BESHABA:
        case DEITY_CYRIC:
        case DEITY_MALAR:
        case DEITY_TALONA:
        case DEITY_TALOS:
        case DEITY_UMBERLEE:
        case DEITY_GHAUNADAUR:
        case DEITY_KIARANSALEE:
        case DEITY_LOLTH:
        case DEITY_SELVETARM:
        case DEITY_VHAERAUN:
        case DEITY_URDLEN:
        case DEITY_BAHGTRU:
        case DEITY_SHARGAAS:
        case DEITY_HEXTOR:
        case DEITY_BANE:
        case DEITY_GARGAUTH:
        case DEITY_LOVIATAR:
        case DEITY_TIAMAT:
        case DEITY_SET:
        case DEITY_DEEP_DUERRA:
        case DEITY_LADUGUER:
        case DEITY_NERULL:
        case DEITY_VECNA:
        case DEITY_AURIL:
        case DEITY_MASK:
        case DEITY_SHAR:
        case DEITY_VELSHAROON:
        case DEITY_SEBEK:
        case DEITY_ABBATHOR:
        case DEITY_ILNEVAL:
        case DEITY_LUTHIC:
        case DEITY_YURTRUS:
            return ALIGNMENT_EVIL;
            break;
    }
    return ALIGNMENT_NEUTRAL;
}

//*:**********************************************
//*:* GRGetDeityAlignLawChaos
//*:**********************************************
//*:*
//*:* Returns the Law/Chaos alignment part of the
//*:* specified deity
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: August 3, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetDeityAlignLawChaos(int iDeityConst) {

    switch(iDeityConst) {
        case DEITY_HEIRONEOUS:
        case DEITY_MORADIN:
        case DEITY_YONDALLA:
        case DEITY_WEE_JAS:
        case DEITY_ST_CUTHBERT:
        case DEITY_HEXTOR:
        case DEITY_AZUTH:
        case DEITY_BANE:
        case DEITY_GARGAUTH:
        case DEITY_HELM:
        case DEITY_HOAR:
        case DEITY_ILMATER:
        case DEITY_JERGAL:
        case DEITY_KELEMVOR:
        case DEITY_LOVIATAR:
        case DEITY_NOBANION:
        case DEITY_RED_KNIGHT:
        case DEITY_SAVRAS:
        case DEITY_SIAMORPHE:
        case DEITY_TIAMAT:
        case DEITY_TORM:
        case DEITY_TYR:
        case DEITY_ULUTIU:
        case DEITY_HORUS_RE:
        case DEITY_OSIRIS:
        case DEITY_SET:
        case DEITY_BERRONAR_TRUESILVER:
        case DEITY_CLANGEDDIN_SILVERBEARD:
        case DEITY_DEEP_DUERRA:
        case DEITY_GORM_GULTHYN:
        case DEITY_LADUGUER:
        case DEITY_GAERDAL_IRONHAND:
        case DEITY_ARVOREEN:
        case DEITY_CYRROLLALEE:
        case DEITY_UROGALAN:
            return ALIGNMENT_LAWFUL;
            break;
        case DEITY_CORELLON_LARETHIAN:
        case DEITY_KORD:
        case DEITY_OLIDAMMARA:
        case DEITY_ERYTHNUL:
        case DEITY_GRUUMSH:
        case DEITY_BESHABA:
        case DEITY_CYRIC:
        case DEITY_FINDER_WYVERNSPUR:
        case DEITY_GARAGOS:
        case DEITY_LLIIRA:
        case DEITY_LURUE:
        case DEITY_MALAR:
        case DEITY_SELUNE:
        case DEITY_SHARESS:
        case DEITY_SHAUNDAKUL:
        case DEITY_SUNE:
        case DEITY_TALONA:
        case DEITY_TALOS:
        case DEITY_TEMPUS:
        case DEITY_TYMORA:
        case DEITY_UMBERLEE:
        case DEITY_UTHGAR:
        case DEITY_VALKUR:
        case DEITY_ANHUR:
        case DEITY_NEPHTHYS:
        case DEITY_EILISTRAEE:
        case DEITY_GHAUNADAUR:
        case DEITY_KIARANSALEE:
        case DEITY_LOLTH:
        case DEITY_SELVETARM:
        case DEITY_VHAERAUN:
        case DEITY_DUGMAREN_BRIGHTMANTLE:
        case DEITY_HAELA_BRIGHTAXE:
        case DEITY_SHARINDLAR:
        case DEITY_THARD_HARR:
        case DEITY_AERDRIE_FAENYA:
        case DEITY_ANGHARRADH:
        case DEITY_DEEP_SASHELAS:
        case DEITY_EREVAN_ILESERE:
        case DEITY_FENMAREL_MESTARINE:
        case DEITY_HANALI_CELANIL:
        case DEITY_LABELAS_ENORETH:
        case DEITY_RILLIFANE_RALLATHIL:
        case DEITY_SEHANINE_MOONBOW:
        case DEITY_SHEVARASH:
        case DEITY_SOLONOR_THELANDIRA:
        case DEITY_URDLEN:
        case DEITY_BAHGTRU:
        case DEITY_SHARGAAS:
            return ALIGNMENT_CHAOTIC;
            break;
    }
    return ALIGNMENT_NEUTRAL;
}

//*:**********************************************
//*:* GRGetDeity
//*:**********************************************
//*:*
//*:*    Gets a local variable on a cleric/divine caster
//*:*    denoting the deity of the caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 13, 2007
//*:**********************************************
int GRGetDeity(object oCaster = OBJECT_SELF) {

    return GetLocalInt(oCaster, "MY_DEITY");
}

//*:**********************************************
//*:* GRSetDeityValue
//*:**********************************************
//*:*
//*:*    Sets a local variable on a cleric/divine caster
//*:*    denoting the deity of the caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRSetDeityValue(object oTarget, int iDeityConst) {
    SetLocalInt(oTarget,"MY_DEITY", iDeityConst);
}

//*:**********************************************
//*:* GRSetPCDeity
//*:**********************************************
//*:*
//*:* Sets a local variable on a cleric/divine caster
//*:* denoting the deity of the caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: June 10, 2004
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
void GRSetPCDeity(object oPC) {

    string sDeity=GetStringUpperCase(GetDeity(oPC));
    int iDeity=GetLocalInt(oPC,"MY_DEITY");

    if(!iDeity) {
        if(sDeity=="") {
            iDeity=DEITY_NONE;
        } else if(sDeity=="HEIRONEOUS") {
            iDeity=DEITY_HEIRONEOUS;
        } else if(sDeity=="MORADIN") {
            iDeity=DEITY_MORADIN;
        } else if(sDeity=="YONDALLA") {
            iDeity=DEITY_YONDALLA;
        } else if(sDeity=="EHLONNA") {
            iDeity=DEITY_EHLONNA;
        } else if(sDeity=="GARL GLITTERGOLD") {
            iDeity=DEITY_GARL_GLITTERGOLD;
        } else if(sDeity=="CORELLON" || sDeity=="CORELLON LARETHIAN") {
                iDeity=DEITY_CORELLON_LARETHIAN;
        } else if(sDeity=="GRUUMSH") {
            iDeity=DEITY_GRUUMSH;
        } else if(sDeity=="EILISTRAEE") {
            iDeity=DEITY_EILISTRAEE;
        } else if(sDeity=="KIARANSALEE") {
            iDeity=DEITY_KIARANSALEE;
        } else if(sDeity=="LOLTH") {
            iDeity=DEITY_LOLTH;
        } else if(sDeity=="CLANGEDDIN" || sDeity=="CLANGEDDIN SILVERBEARD" || sDeity=="SILVERBEARD") {
            iDeity=DEITY_CLANGEDDIN_SILVERBEARD;
        } else if(sDeity=="EREVAN" || sDeity=="EREVAN ILESERE") {
            iDeity=DEITY_EREVAN_ILESERE;
        } else if(sDeity=="SOLONOR" || sDeity=="SOLONOR THELANDIRA" || sDeity=="SOLONOR THELANDRIA") {
            iDeity=DEITY_SOLONOR_THELANDIRA;
        } else if(sDeity=="AKADI") {
            iDeity=DEITY_AKADI;
        } else if(sDeity=="AURIL") {
            iDeity=DEITY_AURIL;
        } else if(sDeity=="AZUTH") {
            iDeity=DEITY_AZUTH;
        } else if(sDeity=="BANE") {
            iDeity=DEITY_BANE;
        } else if(sDeity=="BESHABA") {
            iDeity=DEITY_BESHABA;
        } else if(sDeity=="CHAUNTEA") {
            iDeity=DEITY_CHAUNTEA;
        } else if(sDeity=="CYRIC") {
            iDeity=DEITY_CYRIC;
        } else if(sDeity=="DENEIR") {
            iDeity=DEITY_DENEIR;
        } else if(sDeity=="ELDATH") {
            iDeity=DEITY_ELDATH;
        } else if(sDeity=="FINDER" || sDeity=="FINDER WYVERNSPUR") {
            iDeity=DEITY_FINDER_WYVERNSPUR;
        } else if(sDeity=="GARAGOS") {
            iDeity=DEITY_GARAGOS;
        } else if(sDeity=="GARGAUTH") {
            iDeity=DEITY_GARGAUTH;
        } else if(sDeity=="GOND" || sDeity=="GOND WONDERBRINGER" || sDeity=="THE WONDERBRINGER") {
            iDeity=DEITY_GOND;
        } else if(sDeity=="GRUMBAR") {
            iDeity=DEITY_GRUMBAR;
        } else if(sDeity=="GWAERON" || sDeity=="GWAERON WINDSTROM") {
            iDeity=DEITY_GWAERON_WINDSTROM;
        } else if(sDeity=="HELM") {
            iDeity=DEITY_HELM;
        } else if(sDeity=="HOAR") {
            iDeity=DEITY_HOAR;
        } else if(sDeity=="ILMATER") {
            iDeity=DEITY_ILMATER;
        } else if(sDeity=="ISTISHIA") {
            iDeity=DEITY_ISHTISHIA;
        } else if(sDeity=="JERGAL") {
            iDeity=DEITY_JERGAL;
        } else if(sDeity=="KELEMVOR") {
            iDeity=DEITY_KELEMVOR;
        } else if(sDeity=="KOSSUTH") {
            iDeity=DEITY_KOSSUTH;
        } else if(sDeity=="LATHANDER") {
            iDeity=DEITY_LATHANDER;
        } else if(sDeity=="LLIIRA") {
            iDeity=DEITY_LLIIRA;
        } else if(sDeity=="LOVIATAR") {
            iDeity=DEITY_LOVIATAR;
        } else if(sDeity=="LURUE") {
            iDeity=DEITY_LURUE;
        } else if(sDeity=="MALAR") {
            iDeity=DEITY_MALAR;
        } else if(sDeity=="MASK") {
            iDeity=DEITY_MASK;
        } else if(sDeity=="MIELIKKI") {
            iDeity=DEITY_MIELIKKI;
        } else if(sDeity=="MILIL") {
            iDeity=DEITY_MILIL;
        } else if(sDeity=="MYSTRA" || sDeity=="MIDNIGHT") {
            iDeity=DEITY_MYSTRA;
        } else if(sDeity=="NOBANION") {
            iDeity=DEITY_NOBANION;
        } else if(sDeity=="OGHMA") {
            iDeity=DEITY_OGHMA;
        } else if(sDeity=="RED KNIGHT" || sDeity=="THE RED KNIGHT") {
            iDeity=DEITY_RED_KNIGHT;
        } else if(sDeity=="SAVRAS") {
            iDeity=DEITY_SAVRAS;
        } else if(sDeity=="SELUNE") {
            iDeity=DEITY_SELUNE;
        } else if(sDeity=="SHAR") {
            iDeity=DEITY_SHAR;
        } else if(sDeity=="SHARESS") {
            iDeity=DEITY_SHARESS;
        } else if(sDeity=="SHAUNDAKUL") {
            iDeity=DEITY_SHAUNDAKUL;
        } else if(sDeity=="SHIALLIA") {
            iDeity=DEITY_SHIALLIA;
        } else if(sDeity=="SIAMORPHE") {
            iDeity=DEITY_SIAMORPHE;
        } else if(sDeity=="SILVANUS") {
            iDeity=DEITY_SILVANUS;
        } else if(sDeity=="SUNE") {
            iDeity=DEITY_SUNE;
        } else if(sDeity=="TALONA") {
            iDeity=DEITY_TALONA;
        } else if(sDeity=="TALOS") {
            iDeity=DEITY_TALOS;
        } else if(sDeity=="TEMPUS") {
            iDeity=DEITY_TEMPUS;
        } else if(sDeity=="TIAMAT") {
            iDeity=DEITY_TIAMAT;
        } else if(sDeity=="TORM") {
            iDeity=DEITY_TORM;
        } else if(sDeity=="TYMORA") {
            iDeity=DEITY_TYMORA;
        } else if(sDeity=="TYR") {
            iDeity=DEITY_TYR;
        } else if(sDeity=="UBTAO") {
            iDeity=DEITY_UBTAO;
        } else if(sDeity=="ULUTIU") {
            iDeity=DEITY_ULUTIU;
        } else if(sDeity=="UMBERLEE") {
            iDeity=DEITY_UMBERLEE;
        } else if(sDeity=="UTHGAR") {
            iDeity=DEITY_UTHGAR;
        } else if(sDeity=="VALKUR") {
            iDeity=DEITY_VALKUR;
        } else if(sDeity=="VELSHAROON") {
            iDeity=DEITY_VELSHAROON;
        } else if(sDeity=="WAUKEEN") {
            iDeity=DEITY_WAUKEEN;
        } else if(sDeity=="ISIS") {
            iDeity=DEITY_ISIS;
        } else if(sDeity=="OSIRIS") {
            iDeity=DEITY_OSIRIS;
        } else if(sDeity=="SET") {
            iDeity=DEITY_SET;
        } else if(sDeity=="PELOR") {
            iDeity=DEITY_PELOR;
        } else if(sDeity=="KORD") {
            iDeity=DEITY_KORD;
        } else if(sDeity=="WEE JAS") {
            iDeity=DEITY_WEE_JAS;
        } else if(sDeity=="ST. CUTHBERT" || sDeity=="ST CUTHBERT") {
                iDeity=DEITY_ST_CUTHBERT;
        } else if(sDeity=="BOCCOB") {
            iDeity=DEITY_BOCCOB;
        } else if(sDeity=="FHARLANGHN") {
            iDeity=DEITY_FHARLANGHN;
        } else if(sDeity=="OBAD-HAI" || sDeity=="OBAD HAI") {
            iDeity=DEITY_OBAD_HAI;
        } else if(sDeity=="OLIDAMMARA") {
            iDeity=DEITY_OLIDAMMARA;
        } else if(sDeity=="HEXTOR") {
            iDeity=DEITY_HEXTOR;
        } else if(sDeity=="NERULL") {
            iDeity=DEITY_NERULL;
        } else if(sDeity=="VECNA") {
            iDeity=DEITY_VECNA;
        } else if(sDeity=="ERYTHNUL") {
            iDeity=DEITY_ERYTHNUL;
        } else if(sDeity=="ANHUR") {
            iDeity=DEITY_ANHUR;
        } else if(sDeity=="GEB") {
            iDeity=DEITY_GEB;
        } else if(sDeity=="HATHOR") {
            iDeity=DEITY_HATHOR;
        } else if(sDeity=="HORUS-RE" || sDeity=="HORUS RE") {
            iDeity=DEITY_HORUS_RE;
        } else if(sDeity=="NEPHTHYS") {
            iDeity=DEITY_NEPHTHYS;
        } else if(sDeity=="SEBEK") {
            iDeity=DEITY_SEBEK;
        } else if(sDeity=="THOTH") {
            iDeity=DEITY_THOTH;
        } else if(sDeity=="GHAUNADAUR") {
            iDeity=DEITY_GHAUNADAUR;
        } else if(sDeity=="SELVETARM") {
            iDeity=DEITY_SELVETARM;
        } else if(sDeity=="VHAERAUN") {
            iDeity=DEITY_VHAERAUN;
        } else if(sDeity=="ABBATHOR") {
            iDeity=DEITY_ABBATHOR;
        } else if(sDeity=="BERRONAR" || sDeity=="BERRONAR TRUESILVER") {
            iDeity=DEITY_BERRONAR_TRUESILVER;
        } else if(sDeity=="DEEP DUERRA" || sDeity=="DUERRA") {
            iDeity=DEITY_DEEP_DUERRA;
        } else if(sDeity=="DUGMAERN" || sDeity=="DUGMAREN BRIGHTMANTLE") {
            iDeity=DEITY_DUGMAREN_BRIGHTMANTLE;
        } else if(sDeity=="DUMATHOIN") {
            iDeity=DEITY_DUMATHOIN;
        } else if(sDeity=="GORM" || sDeity=="GORM GULTHYN") {
            iDeity=DEITY_GORM_GULTHYN;
        } else if(sDeity=="HAELA" || sDeity=="HAELA BRIGHTAXE") {
            iDeity=DEITY_HAELA_BRIGHTAXE;
        } else if(sDeity=="LADUGUER") {
            iDeity=DEITY_LADUGUER;
        } else if(sDeity=="MARTHAMMOR DUIN") {
            iDeity=DEITY_MARTHAMMOR_DUIN;
        } else if(sDeity=="SHARINDLAR") {
            iDeity=DEITY_SHARINDLAR;
        } else if(sDeity=="THARD HARR") {
            iDeity=DEITY_THARD_HARR;
        } else if(sDeity=="VERGADAIN") {
            iDeity=DEITY_VERGADAIN;
        } else if(sDeity=="AERDRIE FAENYA") {
            iDeity=DEITY_AERDRIE_FAENYA;
        } else if(sDeity=="ANGHARRADH") {
            iDeity=DEITY_ANGHARRADH;
        } else if(sDeity=="DEEP SASHELAS" || sDeity=="SASHELAS") {
            iDeity=DEITY_DEEP_SASHELAS;
        } else if(sDeity=="FENMAREL MESTARINE") {
            iDeity=DEITY_FENMAREL_MESTARINE;
        } else if(sDeity=="HANALI CELANIL") {
            iDeity=DEITY_HANALI_CELANIL;
        } else if(sDeity=="LABELAS" || sDeity=="LABELAS ENORETH") {
            iDeity=DEITY_LABELAS_ENORETH;
        } else if(sDeity=="RILLIFANE" || sDeity=="RILLIFANE RALLATHIL") {
            iDeity=DEITY_RILLIFANE_RALLATHIL;
        } else if(sDeity=="SEHANINE" || sDeity=="SEHANINE MOONBOW") {
            iDeity=DEITY_SEHANINE_MOONBOW;
        } else if(sDeity=="SHEVARASH") {
            iDeity=DEITY_SHEVARASH;
        } else if(sDeity=="BAERVAN WILDWANDERER") {
            iDeity=DEITY_BAERVAN_WILDWANDERER;
        } else if(sDeity=="BARAVAR CLOAKSHADOW") {
            iDeity=DEITY_BARAVAR_CLOAKSHADOW;
        } else if(sDeity=="CALLARDURAN SMOOTHHANDS") {
            iDeity=DEITY_CALLARDURAN_SMOOTHHANDS;
        } else if(sDeity=="FLANDAL STEELSKIN") {
            iDeity=DEITY_FLANDAL_STEELSKIN;
        } else if(sDeity=="GAERDAL IRONHAND") {
            iDeity=DEITY_GAERDAL_IRONHAND;
        } else if(sDeity=="SEGOJAN EARTHCALLER") {
            iDeity=DEITY_SEGOJAN_EARTHCALLER;
        } else if(sDeity=="URDLEN") {
            iDeity=DEITY_URDLEN;
        } else if(sDeity=="BAHGTRU") {
            iDeity=DEITY_BAHGTRU;
        } else if(sDeity=="ILNEVAL") {
            iDeity=DEITY_ILNEVAL;
        } else if(sDeity=="LUTHIC") {
            iDeity=DEITY_LUTHIC;
        } else if(sDeity=="SHARGAAS") {
            iDeity=DEITY_SHARGAAS;
        } else if(sDeity=="YURTRUS") {
            iDeity=DEITY_YURTRUS;
        }

        SetLocalInt(oPC,"MY_DEITY", iDeity);
    }
}

//*:**************************************************************************
//*:**************************************************************************
