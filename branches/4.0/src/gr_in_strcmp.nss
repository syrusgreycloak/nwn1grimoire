int ConvertChar(string chr) {
    int iValue = 0;

    if(chr==" ") iValue = 0;
    else if(chr=="A") iValue = 1;
    else if(chr=="B") iValue = 2;
    else if(chr=="C") iValue = 3;
    else if(chr=="D") iValue = 4;
    else if(chr=="E") iValue = 5;
    else if(chr=="F") iValue = 6;
    else if(chr=="G") iValue = 7;
    else if(chr=="H") iValue = 8;
    else if(chr=="I") iValue = 9;
    else if(chr=="J") iValue = 10;
    else if(chr=="K") iValue = 11;
    else if(chr=="L") iValue = 12;
    else if(chr=="M") iValue = 13;
    else if(chr=="N") iValue = 14;
    else if(chr=="O") iValue = 15;
    else if(chr=="P") iValue = 16;
    else if(chr=="Q") iValue = 17;
    else if(chr=="R") iValue = 18;
    else if(chr=="S") iValue = 19;
    else if(chr=="T") iValue = 20;
    else if(chr=="U") iValue = 21;
    else if(chr=="V") iValue = 22;
    else if(chr=="W") iValue = 23;
    else if(chr=="X") iValue = 24;
    else if(chr=="Y") iValue = 25;
    else if(chr=="Z") iValue = 26;
    else if(chr=="a") iValue = 27;
    else if(chr=="b") iValue = 28;
    else if(chr=="c") iValue = 29;
    else if(chr=="d") iValue = 30;
    else if(chr=="e") iValue = 31;
    else if(chr=="f") iValue = 32;
    else if(chr=="g") iValue = 33;
    else if(chr=="h") iValue = 34;
    else if(chr=="i") iValue = 35;
    else if(chr=="j") iValue = 36;
    else if(chr=="k") iValue = 37;
    else if(chr=="l") iValue = 38;
    else if(chr=="m") iValue = 39;
    else if(chr=="n") iValue = 40;
    else if(chr=="o") iValue = 41;
    else if(chr=="p") iValue = 42;
    else if(chr=="q") iValue = 43;
    else if(chr=="r") iValue = 44;
    else if(chr=="s") iValue = 45;
    else if(chr=="t") iValue = 46;
    else if(chr=="u") iValue = 47;
    else if(chr=="v") iValue = 48;
    else if(chr=="w") iValue = 49;
    else if(chr=="x") iValue = 50;
    else if(chr=="y") iValue = 51;
    else if(chr=="z") iValue = 52;

    return iValue;
}

int strcmp(string string1, string string2, int bIgnoreCase = FALSE) {
    int i, j;
    int iResult = 0;

    int iStr1Len = GetStringLength(string1);
    int iStr2Len = GetStringLength(string2);

    if(bIgnoreCase) {
        string1 = GetStringLowerCase(string1);
        string2 = GetStringLowerCase(string2);
    }

    int iLen;

    if(iStr1Len<iStr2Len) {
        iLen = iStr1Len;
    } else {
        iLen = iStr2Len;
    }

    for(i=0; i<iLen && iResult==0; i++) {
        int c1 = ConvertChar(GetSubString(string1, i, 1));
        int c2 = ConvertChar(GetSubString(string2, i, 1));
        if(c1<c2) {
            iResult = -1;
        } else if(c2<c1) {
            iResult = 1;
        }
    }

    return iResult;
}

