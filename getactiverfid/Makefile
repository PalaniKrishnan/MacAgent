CC = gcc
INCFLAG =    -I .  -I ../include
LDFLAGS = -lpcProxAPI -lstdc++

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	CXXFLAGS  = -L ../lib

else
#Linux
	LDFLAGS+= -lhidapi-hidraw
	
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CXXFLAGS  = -L ../../lib/64
	else
		CXXFLAGS  = -L ../../lib/32
	endif
endif

all: ./readercomm.cpp
	$(CC) $(CFLAG) $(INCFLAG)  -o  readercomm ./readercomm.cpp $(CXXFLAGS) $(LDFLAGS)
