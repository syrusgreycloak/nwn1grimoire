//*:**************************************************************************
//*:*  GR_IN_ENERGY.NSS
//*:**************************************************************************
//*:*
//*:* Energy type-related functions
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
#include "GR_IC_ENERGY"
#include "GR_IC_SPELLS"

//*:**************************************************************************
//*:* Function Declarations
//*:**************************************************************************
int     GRGetEnergyBeamType(int iDamageType);
int     GRGetEnergyDamageType(int iDamageType, object oCaster=OBJECT_SELF);
int     GRGetEnergyExplodeType(int iDamageType, int iSpellID = -1);
int     GRGetEnergyIPDamageType(int iDamageType);
int     GRGetEnergyMirvType(int iDamageType);
int     GRGetEnergySaveType(int iDamageType);
int     GRGetEnergySpellType(int iDamageType);
int     GRGetEnergyVisualType(int iVisualEffect, int iDamageType);
//*** NWN2 SINGLE ***/ int  GRGetEnergyConeType(int iType, int iDamageType);
//*:**************************************************************************

//*:**************************************************************************
//*:* Function Definitions
//*:**************************************************************************

//*:**********************************************
//*:* GRGetEnergyBeamType
//*:**********************************************
//*:*
//*:* returns proper energy beam type
//*:* on damage type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetEnergyBeamType(int iDamageType) {
    int iBeamType;

    switch(iDamageType) {
        case DAMAGE_TYPE_ACID:
            /*** NWN1 SINGLE ***/ iBeamType = VFX_BEAM_BLACK;
            //*** NWN2 SINGLE ***/  iBeamType = VFX_BEAM_ACID;
            break;
        case DAMAGE_TYPE_COLD:
            /*** NWN1 SINGLE ***/ iBeamType = VFX_BEAM_COLD;
            //*** NWN2 SINGLE ***/ iBeamType = VFX_BEAM_ICE;
            break;
        case DAMAGE_TYPE_ELECTRICAL:
            iBeamType = VFX_BEAM_LIGHTNING;
            //*** NWN2 SINGLE ***/ if(GetSpellId()==SPELL_SHOCKING_GRASP) iBeamType = VFX_BEAM_SHOCKING_GRASP;
            break;
        case DAMAGE_TYPE_FIRE:
            switch(GetSpellId()) {
                case SPELL_FLAME_LASH:
                    iBeamType = VFX_BEAM_FIRE_LASH;
                    break;
                case SPELL_INFERNO:
                case SPELL_GR_AGANAZZARS_SCORCHER:
                case SPELL_GR_RESONATING_BOLT:
                    iBeamType = VFX_BEAM_FLAME; // 444
                    break;
                default:
                    iBeamType = VFX_BEAM_FIRE;
                    break;
            }
            break;
        case DAMAGE_TYPE_SONIC:
            /*** NWN1 SINGLE ***/ iBeamType = VFX_BEAM_ODD;
            //*** NWN2 SINGLE ***/ iBeamType = VFX_BEAM_SONIC;
            break;
    }

    return iBeamType;
}

//*:**********************************************
//*:* GRGetEnergyDamageType
//*:**********************************************
//*:*
//*:* Returns proper elemental damage type for caster
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetEnergyDamageType(int iDamageType, object oCaster=OBJECT_SELF) {

    object oCastItem = GetSpellCastItem();  // try to keep items from getting elemental substitution

    if(!GetIsObjectValid(oCastItem)) {
        if(GetObjectType(oCaster)!=OBJECT_TYPE_CREATURE) {
            return iDamageType;
        }

        if(GetMaster(oCaster)!=OBJECT_INVALID) {
            return iDamageType;
        }

        int iEleSubType = GetLocalInt(oCaster, ENERGY_SUBSTITUTION_TYPE);

        switch(iEleSubType) {
            case ENERGY_SUBSTITUTION_TYPE_ACID:
                iDamageType=DAMAGE_TYPE_ACID;
                break;
            case ENERGY_SUBSTITUTION_TYPE_COLD:
                iDamageType=DAMAGE_TYPE_COLD;
                break;
            case ENERGY_SUBSTITUTION_TYPE_ELECTRICITY:
                iDamageType=DAMAGE_TYPE_ELECTRICAL;
                break;
            case ENERGY_SUBSTITUTION_TYPE_FIRE:
                iDamageType=DAMAGE_TYPE_FIRE;
                break;
            case ENERGY_SUBSTITUTION_TYPE_SONIC:
                iDamageType=DAMAGE_TYPE_SONIC;
                break;
        }
    }

    return iDamageType;
}

//*:**********************************************
//*:* GRGetEnergyExplodeType
//*:**********************************************
//*:*
//*:* Returns proper elemental FNF effect
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetEnergyExplodeType(int iDamageType, int iSpellID = -1) {

    int iExplodeType;

    if(iSpellID==-1) iSpellID = GetSpellId();

    switch(iDamageType) {
        case DAMAGE_TYPE_ACID:
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_ACID;
            //*** NWN2 SINGLE ***/ iExplodeType = VFX_HIT_AOE_ACID;
            break;
        case DAMAGE_TYPE_COLD:
            switch(iSpellID) {
                /*** NWN1 SPECIFIC ***/
                    case SPELL_FIRE_STORM:
                    case SPELL_ICE_STORM:
                    case SPELL_FLAME_STRIKE:
                        iExplodeType = VFX_FNF_ICESTORM;
                        break;
                /*** END NWN1 SPECIFIC ***/
                default:
                    /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_HOWL_MIND;
                    //*** NWN2 SINGLE ***/ iExplodeType = VFX_HIT_AOE_ICE;
                    break;
            }
            break;
        case DAMAGE_TYPE_ELECTRICAL:
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_ELECTRIC_EXPLOSION;
            //*** NWN2 SINGLE ***/ iExplodeType = VFX_HIT_AOE_LIGHTNING;
            break;
        case DAMAGE_TYPE_FIRE:
            switch(iSpellID) {
                case SPELL_FIREBALL:
                case SPELL_DELAYED_BLAST_FIREBALL:
                case SPELL_METEOR_SWARM:
                //case 600:  // Arcane Archer Imbue Arrow
                    iExplodeType = VFX_FNF_FIREBALL;
                    break;
                case SPELL_FIRE_STORM:
                case SPELL_FLAME_STRIKE:
                /*** NWN1 SINGLE ***/ case SPELL_ICE_STORM:
                    /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_FIRESTORM;
                    //*** NWN2 SINGLE ***/ iExplodeType = VFX_HIT_SPELL_FLAMESTRIKE;
                    break;
                    /*** END NWN1 SPECIFIC ***/
                default:
                    /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_GAS_EXPLOSION_FIRE;
                    //*** NWN2 SINGLE ***/ iExplodeType = VFX_HIT_AOE_FIRE;
                    break;
            }
            break;
        case DAMAGE_TYPE_SONIC:
            /*** NWN1 SINGLE ***/ iExplodeType = VFX_FNF_SOUND_BURST;
            //*** NWN2 SINGLE ***/ iExplodeType = VFX_HIT_AOE_SONIC;
            break;
    }

    return iExplodeType;
}

//*:**********************************************
//*:* GREnergyIPDamageType
//*:**********************************************
//*:*
//*:* Returns proper elemental damage type for caster
//*:* to add to a weapon type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 17, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetEnergyIPDamageType(int iDamageType) {

    switch(iDamageType) {
        case DAMAGE_TYPE_ACID:
            iDamageType = IP_CONST_DAMAGETYPE_ACID;
            break;
        case DAMAGE_TYPE_COLD:
            iDamageType = IP_CONST_DAMAGETYPE_COLD;
            break;
        case DAMAGE_TYPE_ELECTRICAL:
            iDamageType = IP_CONST_DAMAGETYPE_ELECTRICAL;
            break;
        case DAMAGE_TYPE_FIRE:
            iDamageType = IP_CONST_DAMAGETYPE_FIRE;
            break;
        case DAMAGE_TYPE_SONIC:
            iDamageType = IP_CONST_DAMAGETYPE_SONIC;
            break;
    }

    return iDamageType;
}

//*:**********************************************
//*:* GRGetEnergyBeamType
//*:**********************************************
//*:*
//*:* Returns proper elemental save type depending
//*:* on damage type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetEnergyMirvType(int iDamageType) {

    int iMirvType;

    switch(iDamageType) {
        case DAMAGE_TYPE_ACID:
            iMirvType = 245;
            break;
        case DAMAGE_TYPE_COLD:
            iMirvType = VFX_IMP_MIRV;
            break;
        case DAMAGE_TYPE_ELECTRICAL:
            iMirvType = VFX_IMP_MIRV_ELECTRIC;
            break;
        case DAMAGE_TYPE_FIRE:
            iMirvType = VFX_IMP_MIRV_FLAME;
            break;
        case DAMAGE_TYPE_SONIC:
            iMirvType = VFX_IMP_MIRV;
            break;
    }

    return iMirvType;
}

//*:**********************************************
//*:* GRGetEnergySaveType
//*:**********************************************
//*:*
//*:* Returns proper elemental save type depending
//*:* on damage type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetEnergySaveType(int iDamageType) {

    int iSaveType=0;

    switch(iDamageType) {
        case DAMAGE_TYPE_ACID:
            iSaveType=SAVING_THROW_TYPE_ACID;
            break;
        case DAMAGE_TYPE_COLD:
            iSaveType=SAVING_THROW_TYPE_COLD;
            break;
        case DAMAGE_TYPE_ELECTRICAL:
            iSaveType=SAVING_THROW_TYPE_ELECTRICITY;
            break;
        case DAMAGE_TYPE_FIRE:
            iSaveType=SAVING_THROW_TYPE_FIRE;
            break;
        case DAMAGE_TYPE_SONIC:
            iSaveType=SAVING_THROW_TYPE_SONIC;
            break;
    }

    return iSaveType;
}

//*:**********************************************
//*:* GRGetEnergySpellType
//*:**********************************************
//*:*
//*:* Returns proper elemental spell type depending
//*:* on damage type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
//*:* Updated On: February 12, 2007
//*:**********************************************
int GRGetEnergySpellType(int iDamageType) {

    int iSpellType=0;

    switch(iDamageType) {
        case DAMAGE_TYPE_ACID:
            iSpellType=SPELL_TYPE_ACID;
            break;
        case DAMAGE_TYPE_COLD:
            iSpellType=SPELL_TYPE_COLD;
            break;
        case DAMAGE_TYPE_ELECTRICAL:
            iSpellType=SPELL_TYPE_ELECTRICITY;
            break;
        case DAMAGE_TYPE_FIRE:
            iSpellType=SPELL_TYPE_FIRE;
            break;
        case DAMAGE_TYPE_SONIC:
            iSpellType=SPELL_TYPE_SONIC;
            break;
    }

    return iSpellType;
}

//*:**********************************************
//*:* GRGetEnergyVisualType
//*:**********************************************
//*:*
//*:* Returns proper elemental visual depending
//*:* on damage type
//*:*
//*:**********************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: March 9, 2005
//*:**********************************************
int GRGetEnergyVisualType(int iVisualEffect, int iDamageType) {

    switch(iVisualEffect) {
        case VFX_COM_HIT_ACID:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_COM_HIT_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_COM_HIT_FROST;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_COM_HIT_ELECTRICAL;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_COM_HIT_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_COM_HIT_SONIC;
                    break;
            }
            break;
        case VFX_COM_HIT_FROST:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_COM_HIT_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_COM_HIT_FROST;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_COM_HIT_ELECTRICAL;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_COM_HIT_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_COM_HIT_SONIC;
                    break;
            }
            break;
        case VFX_COM_HIT_ELECTRICAL:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_COM_HIT_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_COM_HIT_FROST;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_COM_HIT_ELECTRICAL;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_COM_HIT_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_COM_HIT_SONIC;
                    break;
            }
            break;
        case VFX_COM_HIT_FIRE:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_COM_HIT_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_COM_HIT_FROST;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_COM_HIT_ELECTRICAL;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_COM_HIT_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_COM_HIT_SONIC;
                    break;
            }
            break;
        case VFX_COM_HIT_SONIC:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_COM_HIT_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_COM_HIT_FROST;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_COM_HIT_ELECTRICAL;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_COM_HIT_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_COM_HIT_SONIC;
                    break;
            }
            break;
        case VFX_IMP_ACID_L:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_L;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_L;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_M;
                    break;
                case DAMAGE_TYPE_SONIC:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_SONIC;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_IMP_FROST_L:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_L;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_L;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_M;
                    break;
                case DAMAGE_TYPE_SONIC:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_SONIC;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        /*** NWN1 SINGLE ***/ case VFX_IMP_LIGHTNING_M:
        //*** NWN2 SINGLE ***/ case 916: // VFX_SPELL_HIT_CALL_LIGHTNING
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_POLYMORPH;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_HEALING_X;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_LIGHTNING_M;
                    //*** NWN2 SINGLE ***/ iVisualEffect = 916; // VFX_SPELL_HIT_CALL_LIGHTNING
                    break;
                case DAMAGE_TYPE_FIRE:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_DIVINE_STRIKE_FIRE;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_FLAMESTRIKE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_IMP_HARM;
                    break;
            }
            break;
        /*** NWN1 SINGLE ***/ case VFX_IMP_DIVINE_STRIKE_FIRE:
        //*** NWN2 SINGLE ***/ case VFX_HIT_SPELL_FLAMESTRIKE:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_POLYMORPH;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_HEALING_X;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_LIGHTNING_M;
                    //*** NWN2 SINGLE ***/ iVisualEffect = 916; // VFX_SPELL_HIT_CALL_LIGHTNING
                    break;
                case DAMAGE_TYPE_FIRE:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_DIVINE_STRIKE_FIRE;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_FLAMESTRIKE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_IMP_HARM;
                    break;
            }
            break;
        case VFX_IMP_FLAME_M:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_L;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_L;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_M;
                    break;
                case DAMAGE_TYPE_SONIC:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_SONIC;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_IMP_ACID_S:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_S;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_S;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_S;
                    break;
                case DAMAGE_TYPE_SONIC:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_SONIC;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_IMP_FROST_S:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_S;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_S;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_S;
                    break;
                case DAMAGE_TYPE_SONIC:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_SONIC;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_IMP_LIGHTNING_S:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_S;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_S;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_S;
                    break;
                case DAMAGE_TYPE_SONIC:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_SONIC;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_IMP_FLAME_S:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_S;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_S;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_S;
                    break;
                case DAMAGE_TYPE_SONIC:
                    /*** NWN1 SINGLE ***/ iVisualEffect=VFX_IMP_SONIC;
                    //*** NWN2 SINGLE ***/ iVisualEffect = VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        /*** NWN1 SPECIFIC ***/
        case VFX_IMP_SONIC:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_IMP_ACID_S;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_IMP_FROST_S;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_IMP_LIGHTNING_S;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_IMP_FLAME_S;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_IMP_SONIC;
                    break;
            }
            break;
        /*** END NWN1 SPECIFIC ***/
        /*** NWN2 SPECIFIC ***
        case VFX_HIT_SPELL_ACID:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_HIT_SPELL_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_HIT_SPELL_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_HIT_SPELL_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_HIT_SPELL_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_HIT_SPELL_ICE:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_HIT_SPELL_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_HIT_SPELL_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_HIT_SPELL_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_HIT_SPELL_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_HIT_SPELL_LIGHTNING:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_HIT_SPELL_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_HIT_SPELL_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_HIT_SPELL_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_HIT_SPELL_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_HIT_SPELL_FIRE:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_HIT_SPELL_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_HIT_SPELL_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_HIT_SPELL_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_HIT_SPELL_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        case VFX_HIT_SPELL_SONIC:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iVisualEffect=VFX_HIT_SPELL_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iVisualEffect=VFX_HIT_SPELL_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iVisualEffect=VFX_HIT_SPELL_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iVisualEffect=VFX_HIT_SPELL_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iVisualEffect=VFX_HIT_SPELL_SONIC;
                    break;
            }
            break;
        /*** END NWN2 SPECIFIC ***/
    }

    return iVisualEffect;
}

/*** NWN2 SPECIFIC ***
int GRGetEnergyConeType(int iType, int iDamageType) {

    int iResult = iType;

    switch(iType) {
        case VFX_DUR_CONE_ACID:
            switch(iDamageType) {
                case DAMAGE_TYPE_COLD:
                    iResult = VFX_DUR_CONE_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iResult = VFX_DUR_CONE_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iResult = VFX_DUR_CONE_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iResult = VFX_DUR_CONE_SONIC;
                    break;
            }
            break;
        case VFX_DUR_CONE_ICE:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iResult = VFX_DUR_CONE_ACID;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iResult = VFX_DUR_CONE_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iResult = VFX_DUR_CONE_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iResult = VFX_DUR_CONE_SONIC;
                    break;
            }
            break;
        case VFX_DUR_CONE_LIGHTNING:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iResult = VFX_DUR_CONE_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iResult = VFX_DUR_CONE_ICE;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iResult = VFX_DUR_CONE_FIRE;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iResult = VFX_DUR_CONE_SONIC;
                    break;
            }
            break;
        case VFX_DUR_CONE_FIRE:
        case VFX_DUR_BURNING_HANDS:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iResult = VFX_DUR_CONE_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iResult = VFX_DUR_CONE_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iResult = VFX_DUR_CONE_LIGHTNING;
                    break;
                case DAMAGE_TYPE_SONIC:
                    iResult = VFX_DUR_CONE_SONIC;
                    break;
            }
            break;
        case VFX_DUR_CONE_SONIC:
            switch(iDamageType) {
                case DAMAGE_TYPE_ACID:
                    iResult = VFX_DUR_CONE_ACID;
                    break;
                case DAMAGE_TYPE_COLD:
                    iResult = VFX_DUR_CONE_ICE;
                    break;
                case DAMAGE_TYPE_ELECTRICAL:
                    iResult = VFX_DUR_CONE_LIGHTNING;
                    break;
                case DAMAGE_TYPE_FIRE:
                    iResult = VFX_DUR_CONE_FIRE;
                    break;
            }
            break;
    }

    return iResult;
}
/*** END NWN2 SPECIFIC ***/
//*:**************************************************************************
//*:**************************************************************************
