//
//  pcProx.cpp
//  AuthxMacOSAgent
//
//  Created by Admin on 03.01.2023.
//

#include "pcProx.h"

#include <string>
using namespace std;

#include "./include/pcProxAPI.h"


#define PRXDEVTYP_USB 0

int convert(char num[]) {
    int len = strlen(num);
    int base = 1;
    int temp = 0;
    for (int i = len - 1; i >= 0; i--) {
        if (num[i] >= '0' && num[i] <= '9') {
            temp += (num[i] - 48) * base;
            base = base * 16;
        }
        else if (num[i] >= 'A' && num[i] <= 'F') {
            temp += (num[i] - 55) * base;
            base = base * 16;
        }
    }
    return temp;
}

int GetActiveRFID()
{
    SetDevTypeSrch(PRXDEVTYP_USB);
    if (usbConnect() == 0)
    {
        //printf("\nReader not connected\n");
        return 1001;
    }

    usleep(250000);
    unsigned char buf[32];

    memset(buf, 0, sizeof(buf));
    short bits = GetActiveID32(buf, 32);
    int num;
    int nData=0;
    
    if (bits == 0)
    {
        //printf("\nNo id found, Please put card on the reader and ");
        //printf("make sure it must be configured with the card placed on it.\n");
        
        return 0;
    }
    else
    {
        int bytes_to_read = (bits + 7) / 8;
        if (bytes_to_read < 8){
            bytes_to_read = 8;
        }
       
        printf("\n%d Bits : ", bits);
        std::string s = "";
                //if (DEVELOPING) PrintLn("\n%d Bits : ", bits);
                char sHexData[255];
                for (int i = bytes_to_read - 1; i >= 0; i--)
                {
                    num = buf[i];

                    sprintf(sHexData, "%02X", buf[i]);
                    s += sHexData;
                    //printf("%02X ", buf[i]);
                }

                if (s.length() > 0)
                    nData = convert((char*)s.c_str());
    }
    USBDisconnect();
    return nData;
}

