//*:**************************************************************************
//*:*  GR_IC_DOMAINS.NSS
//*:**************************************************************************
//*:*
//*:* Domain constants for use in functions
//*:*
//*:**************************************************************************
//*:* Created By: Karl Nickels (Syrus Greycloak)
//*:* Created On: November 8, 2004
//*:**************************************************************************
//*:* Updated On: February 12, 2007
//*:**************************************************************************
#include "GR_IC_FEATS"

//*:**********************************************
//*:* Domain constants - same as FEAT_xxx_DOMAIN_POWER
//*:**********************************************
const int   DOMAIN_WAR          = FEAT_WAR_DOMAIN_POWER;
const int   DOMAIN_STRENGTH     = FEAT_STRENGTH_DOMAIN_POWER;
const int   DOMAIN_PROTECTION   = FEAT_PROTECTION_DOMAIN_POWER;
const int   DOMAIN_LUCK         = FEAT_LUCK_DOMAIN_POWER;
const int   DOMAIN_DEATH        = FEAT_DEATH_DOMAIN_POWER;
const int   DOMAIN_AIR          = FEAT_AIR_DOMAIN_POWER;
const int   DOMAIN_ANIMAL       = FEAT_ANIMAL_DOMAIN_POWER;
const int   DOMAIN_DESTRUCTION  = FEAT_DESTRUCTION_DOMAIN_POWER;
const int   DOMAIN_EARTH        = FEAT_EARTH_DOMAIN_POWER;
const int   DOMAIN_EVIL         = FEAT_EVIL_DOMAIN_POWER;
const int   DOMAIN_FIRE         = FEAT_FIRE_DOMAIN_POWER;
const int   DOMAIN_GOOD         = FEAT_GOOD_DOMAIN_POWER;
const int   DOMAIN_HEALING      = FEAT_HEALING_DOMAIN_POWER;
const int   DOMAIN_KNOWLEDGE    = FEAT_KNOWLEDGE_DOMAIN_POWER;
const int   DOMAIN_MAGIC        = FEAT_MAGIC_DOMAIN_POWER;
const int   DOMAIN_PLANT        = FEAT_PLANT_DOMAIN_POWER;
const int   DOMAIN_SUN          = FEAT_SUN_DOMAIN_POWER;
const int   DOMAIN_TRAVEL       = FEAT_TRAVEL_DOMAIN_POWER;
const int   DOMAIN_TRICKERY     = FEAT_TRICKERY_DOMAIN_POWER;
const int   DOMAIN_WATER        = FEAT_WATER_DOMAIN_POWER;
    //*:**********************************************
    //*:* custom domains - be sure to update when
    //*:* updating the custom feat constants
    //*:**********************************************
const int   DOMAIN_ORC          = FEAT_ORC_DOMAIN_POWER;
const int   DOMAIN_CHARM        = FEAT_CHARM_DOMAIN_POWER;
const int   DOMAIN_CHAOS        = FEAT_CHAOS_DOMAIN_POWER;
const int   DOMAIN_LAW          = FEAT_LAW_DOMAIN_POWER;
const int   DOMAIN_SLIME        = FEAT_SLIME_DOMAIN_POWER;
const int   DOMAIN_DARKNESS     = FEAT_DARKNESS_DOMAIN_POWER;
const int   DOMAIN_DROW         = FEAT_DROW_DOMAIN_POWER;
const int   DOMAIN_DWARF        = FEAT_DWARF_DOMAIN_POWER;
const int   DOMAIN_UNDEATH      = FEAT_UNDEATH_DOMAIN_POWER;
const int   DOMAIN_HALFLING     = FEAT_HALFLING_DOMAIN_POWER;
const int   DOMAIN_HATRED       = FEAT_HATRED_DOMAIN_POWER;
const int   DOMAIN_TYRANNY      = FEAT_TYRANNY_DOMAIN_POWER;
const int   DOMAIN_ILLUSION     = FEAT_ILLUSION_DOMAIN_POWER;
const int   DOMAIN_SUMMONER     = FEAT_SUMMONER_DOMAIN_POWER;
const int   DOMAIN_BESTIAL      = FEAT_BESTIAL_DOMAIN_POWER;

//*:**********************************************
//*:* DOMAINS 2DA CONSTANTS - points into sg_domains.2da
//*:**********************************************
const int DOMAIN_2DA_INVALID = -1;
const int DOMAIN_2DA_AIR    =   0   ;
const int DOMAIN_2DA_ANIMAL =   1   ;
const int DOMAIN_2DA_CHAOS  =   2   ;
const int DOMAIN_2DA_DEATH  =   3   ;
const int DOMAIN_2DA_DESTRUCTION    =   4   ;
const int DOMAIN_2DA_EARTH  =   5   ;
const int DOMAIN_2DA_EVIL   =   6   ;
const int DOMAIN_2DA_FIRE   =   7   ;
const int DOMAIN_2DA_GOOD   =   8   ;
const int DOMAIN_2DA_HEALING    =   9   ;
const int DOMAIN_2DA_KNOWLEDGE  =   10  ;
const int DOMAIN_2DA_LAW    =   11  ;
const int DOMAIN_2DA_LUCK   =   12  ;
const int DOMAIN_2DA_MAGIC  =   13  ;
const int DOMAIN_2DA_PLANT  =   14  ;
const int DOMAIN_2DA_PROTECTION =   15  ;
const int DOMAIN_2DA_STRENGTH   =   16  ;
const int DOMAIN_2DA_SUN    =   17  ;
const int DOMAIN_2DA_TRAVEL =   18  ;
const int DOMAIN_2DA_TRICKERY   =   19  ;
const int DOMAIN_2DA_WAR    =   20  ;
const int DOMAIN_2DA_WATER  =   21  ;
//_Vile_Darkness    =   22  ;
const int DOMAIN_2DA_BESTIAL    =   23  ;
//  const int DOMAIN_2DA_DEMONIC    =   24  ;
//  const int DOMAIN_2DA_DIABOLIC   =   25  ;
//  const int DOMAIN_2DA_PAIN   =   26  ;
//_Exalted_Deeds    =   27  ;
//  const int DOMAIN_2DA_CELESTIAL  =   28  ;
//  const int DOMAIN_2DA_ENDURANCE  =   29  ;
//  const int DOMAIN_2DA_FEY    =   30  ;
//  const int DOMAIN_2DA_HERALD =   31  ;
//  const int DOMAIN_2DA_JOY    =   32  ;
//  const int DOMAIN_2DA_PLEASURE   =   33  ;
//  const int DOMAIN_2DA_WRATH_BOED =   34  ;
//_Frostburn    =   35  ;
//  const int DOMAIN_2DA_WINTER =   36  ;
//_RoD  =   37  ;
//  const int DOMAIN_2DA_CITY   =   38  ;
//  const int DOMAIN_2DA_DESTINY    =   39  ;
//_RotW =   40  ;
//  const int DOMAIN_2DA_SKY    =   41  ;
//_Sandstorm    =   42  ;
//  const int DOMAIN_2DA_REPOSE =   43  ;
//  const int DOMAIN_2DA_SAND   =   44  ;
//  const int DOMAIN_2DA_SUMMER =   45  ;
//  const int DOMAIN_2DA_THIRST =   46  ;
//_Libris_Mortis    =   47  ;
//  const int DOMAIN_2DA_CORRUPTION =   48  ;
//  const int DOMAIN_2DA_VILE_DARKNESS  =   49  ;
//_Stormwrack   =   50  ;
//  const int DOMAIN_2DA_BLACKWATER =   51  ;
//  const int DOMAIN_2DA_SEAFOLK    =   52  ;
//_Heroes_of_Horror =   53  ;
//  const int DOMAIN_2DA_SPITE  =   54  ;
//_Spell_Compendium =   55  ;
//  const int DOMAIN_2DA_BALANCE    =   56  ;
//  const int DOMAIN_2DA_CAVERN =   57  ;
//  const int DOMAIN_2DA_CELERITY   =   58  ;
const int DOMAIN_2DA_CHARM  =   59  ;
//  const int DOMAIN_2DA_COLD   =   60  ;
//  const int DOMAIN_2DA_COMMUNITY  =   61  ;
//  const int DOMAIN_2DA_COMPETITION    =   62  ;
//  const int DOMAIN_2DA_COURAGE    =   63  ;
//  const int DOMAIN_2DA_CRAFT  =   64  ;
//  const int DOMAIN_2DA_CREATION   =   65  ;
const int DOMAIN_2DA_DARKNESS   =   66  ;
//  const int DOMAIN_2DA_DEATHBOUND =   67  ;
//  const int DOMAIN_2DA_DOMINATION =   68  ;
//  const int DOMAIN_2DA_DRAGON =   69  ;
//  const int DOMAIN_2DA_DREAM  =   70  ;
const int DOMAIN_2DA_DROW   =   71  ;
const int DOMAIN_2DA_DWARF  =   72  ;
//  const int DOMAIN_2DA_ELF    =   73  ;
//  const int DOMAIN_2DA_ENVY   =   74  ;
//  const int DOMAIN_2DA_FAMILY =   75  ;
//  const int DOMAIN_2DA_FATE   =   76  ;
//  const int DOMAIN_2DA_FORCE  =   77  ;
//  const int DOMAIN_2DA_GLORY  =   78  ;
//  const int DOMAIN_2DA_GLUTTONY   =   79  ;
//  const int DOMAIN_2DA_GNOME  =   80  ;
//  const int DOMAIN_2DA_GREED  =   81  ;
const int DOMAIN_2DA_HALFLING   =   82  ;
const int DOMAIN_2DA_HATRED =   83  ;
//  const int DOMAIN_2DA_HUNGER =   84  ;
const int DOMAIN_2DA_ILLUSION   =   85  ;
//  const int DOMAIN_2DA_INQUISITION    =   86  ;
//  const int DOMAIN_2DA_LIBERATION =   87  ;
//  const int DOMAIN_2DA_LUST   =   88  ;
//  const int DOMAIN_2DA_MADNESS    =   89  ;
//  const int DOMAIN_2DA_MENTALISM  =   90  ;
//  const int DOMAIN_2DA_METAL  =   91  ;
//  const int DOMAIN_2DA_MIND   =   92  ;
//  const int DOMAIN_2DA_MOON   =   93  ;
//  const int DOMAIN_2DA_MYSTICISM_GOOD =   94  ;
//  const int DOMAIN_2DA_MYSTICISM_EVIL =   95  ;
//  const int DOMAIN_2DA_NOBILITY   =   96  ;
//  const int DOMAIN_2DA_OCEAN  =   97  ;
//  const int DOMAIN_2DA_ORACLE =   98  ;
const int DOMAIN_2DA_ORC    =   99  ;
//  const int DOMAIN_2DA_PACT   =   100 ;
//  const int DOMAIN_2DA_PESTILENCE =   101 ;
//  const int DOMAIN_2DA_PLANNING   =   102 ;
//  const int DOMAIN_2DA_PORTAL =   103 ;
//  const int DOMAIN_2DA_PRIDE  =   104 ;
//  const int DOMAIN_2DA_PURIFICATION   =   105 ;
//  const int DOMAIN_2DA_RENEWAL    =   106 ;
//  const int DOMAIN_2DA_RETRIBUTION    =   107 ;
//  const int DOMAIN_2DA_RUNE   =   108 ;
//  const int DOMAIN_2DA_SCALYKIND  =   109 ;
const int DOMAIN_2DA_SLIME  =   110 ;
//  const int DOMAIN_2DA_SLOTH  =   111 ;
//  const int DOMAIN_2DA_SPELL  =   112 ;
//  const int DOMAIN_2DA_SPIDER =   113 ;
//  const int DOMAIN_2DA_STORM  =   114 ;
//  const int DOMAIN_2DA_SUFFERING  =   115 ;
const int DOMAIN_2DA_SUMMONER   =   116 ;
//  const int DOMAIN_2DA_TIME   =   117 ;
//  const int DOMAIN_2DA_TRADE  =   118 ;
const int DOMAIN_2DA_TYRANNY    =   119 ;
const int DOMAIN_2DA_UNDEATH    =   120 ;
//  const int DOMAIN_2DA_WEALTH =   121 ;
//  const int DOMAIN_2DA_WINDSTORM  =   122 ;
//  const int DOMAIN_2DA_WRATH  =   123 ;
//_Dragonlance  =   124 ;
//  const int DOMAIN_2DA_ALTERATION =   125 ;
//  const int DOMAIN_2DA_FORGE  =   126 ;
//  const int DOMAIN_2DA_INSIGHT    =   127 ;
//  const int DOMAIN_2DA_LIBERATION_DL  =   128 ;
//  const int DOMAIN_2DA_MEDITATION =   129 ;
//  const int DOMAIN_2DA_NECROMANCY =   130 ;
//  const int DOMAIN_2DA_PASSION    =   131 ;
//  const int DOMAIN_2DA_RESTORATION    =   132 ;
//  const int DOMAIN_2DA_TREACHERY  =   133 ;
//_Oriental_Adventures  =   134 ;
//  const int DOMAIN_2DA_ANCESTOR   =   135 ;
//  const int DOMAIN_2DA_FLAME  =   136 ;
//  const int DOMAIN_2DA_FURY   =   137 ;
//  const int DOMAIN_2DA_GRAVE  =   138 ;
//  const int DOMAIN_2DA_GUARDIAN   =   139 ;
//  const int DOMAIN_2DA_HERO   =   140 ;


//  const int DOMAIN_2DA_****   =   141 ;
//  const int DOMAIN_2DA_****   =   142 ;
//  const int DOMAIN_2DA_ABYSS1 =   143 ;
//  const int DOMAIN_2DA_ABYSS2 =   144 ;
//  const int DOMAIN_2DA_ARBOREA1   =   145 ;
//  const int DOMAIN_2DA_ARBOREA2   =   146 ;
//  const int DOMAIN_2DA_BAATOR1    =   147 ;
//  const int DOMAIN_2DA_BAATOR2    =   148 ;
//  const int DOMAIN_2DA_CELESTIA1  =   149 ;
//  const int DOMAIN_2DA_CELESTIA2  =   150 ;
//  const int DOMAIN_2DA_ELYSIUM1   =   151 ;
//  const int DOMAIN_2DA_ELYSIUM2   =   152 ;
//  const int DOMAIN_2DA_HADES1 =   153 ;
//  const int DOMAIN_2DA_HADES2 =   154 ;
//  const int DOMAIN_2DA_LIMBO1 =   155 ;
//  const int DOMAIN_2DA_LIMBO2 =   156 ;
//  const int DOMAIN_2DA_MECHANUS1  =   157 ;
//  const int DOMAIN_2DA_MECHANUS2  =   158 ;
