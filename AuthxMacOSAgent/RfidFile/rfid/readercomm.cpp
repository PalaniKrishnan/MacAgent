// rf IDEAS, Inc. Proprietary and Confidential
// Copyright © 2023 rf IDEAS, Inc. as an unpublished work.
// All Rights Reserved

#include <stdlib.h>
#include <string.h>
#include "pcProxAPI.h"
#include <stdio.h>

#define PRXDEVTYP_USB 0

void showHelpText()
{
	printf("\nUsage: readercomm [options]\n\n");
	printf("--enumerate\t\t list all the connected rfidea's readers\n");
	printf("--sdk-version\t\t give the sdk version\n");
	printf("--help\t\t         print this help\n");
	printf("--getid\t\t         give raw data of card which being read\n");
	printf("--getESN\t         read the ESN from the reader\n");
	printf("--get-actid\t         give active card data(to stop execution press Ctrl+C)\n");
}

void listAllConnectedRFIDevice()
{
	short i, getDevCnt;
	SetDevTypeSrch(PRXDEVTYP_USB);
	if (usbConnect() == 0)
	{
		printf("\nReader not connected\n");
		return;
	}
	getDevCnt = GetDevCnt();
	printf("\nPartNumber\t\tVid:Pid\t\t\t\tLUID\n\n");
	for (i = 0; i < getDevCnt; i++)
	{
		SetActDev(i);
		unsigned short luid = GetLUID();
		printf("%s\t\t%s\t\t%d", getPartNumberString(), GetVidPidVendorName(), luid);
		printf("\n");
	}
	USBDisconnect();
}

void printLibVersion()
{
	short m, n, d;
	GetLibVersion(&m, &n, &d);
	printf("\nSDK Version : %02d.%02d.%d\n", m, n, d);
}

void printActiveId()
{
	SetDevTypeSrch(PRXDEVTYP_USB);
	if (usbConnect() == 0)
	{
		printf("\nReader not connected\n");
		return;
	}
#ifdef _WIN32
	Sleep(250);
	BYTE buf[32];
#else
	usleep(250000);
	unsigned char buf[32];
#endif
	memset(buf, 0, sizeof(buf));
	short bits = GetActiveID32(buf, 32);
	int num;
	if (bits == 0)
	{
		printf("\nNo id found, Please put card on the reader and ");
		printf("make sure it must be configured with the card placed on it.\n");
	}
	else
	{
		int bytes_to_read = (bits + 7) / 8;
		if (bytes_to_read < 8){
			bytes_to_read = 8;
		}
		printf("\n%d Bits : ", bits);
		for (int i = bytes_to_read - 1; i >= 0; i--)
		{
			num = buf[i];
			printf("%02X ", buf[i]);
		}
		printf("\n");
	}
	USBDisconnect();
}

void getEsn()
{
	SetDevTypeSrch(PRXDEVTYP_USB);
	if (usbConnect() == 0)
	{
		printf("\nReader not connected\n");
		return;
	}
	const char* ESN = getESN();
	if (ESN != NULL)
	{
		printf("\nESN: %s\n", ESN);
	}
	else
	{
		printf("\nReader does not support ESN functionality\n");
	}
	USBDisconnect();
}

void getActiveID()
{
	SetDevTypeSrch(PRXDEVTYP_USB);
	if (usbConnect() == 0)
	{
		printf("\nReader not connected\n");
		return;
	}
	int prevNbits = 0;
	while (1)
	{
		#ifdef _WIN32
		Sleep(750);
		BYTE buf[8];
		#else
		usleep(750000);
		unsigned char buf[8];
		#endif
		int nBits = GetActiveID(buf, 8);
		if (nBits != prevNbits)
		{
			prevNbits = nBits;
			if (nBits == 0)
			{
				printf("Card removed\n");
				#ifdef _WIN32
				Sleep(250);
				#else
				usleep(250000);
				#endif
			}
			else
			{
				printf("Card ID: %d bits ", nBits);
				for (int index = 7; index >= 0; index--)
				{
					printf("%02X ", buf[index]);
				}
				printf("\n");
			}
		}
	}
}

int main(int argc, char* argv[])
{
	if (argc == 1)
	{
		showHelpText();
	}

	else if (strcmp(argv[1], "--enumerate") == 0)
	{
		listAllConnectedRFIDevice();
	}

	else if (strcmp(argv[1], "--sdk-version") == 0)
	{
		printLibVersion();
	}

	else if (strcmp(argv[1], "--getid") == 0)
	{
		printActiveId();
	}

	else if (strcmp(argv[1], "--getESN") == 0)
	{
		getEsn();
	}

	else if (strcmp(argv[1], "--get-actid") == 0)
	{
		getActiveID();
	}

	else if (strcmp(argv[1], "--help") == 0)
	{
		showHelpText();
	}

	else
	{
		printf("\nWrong argument passed\n");
		showHelpText();
	}
	return 0;
}

// Copyright © rf IDEAS, Inc. Proprietary and confidential.
// EOF
