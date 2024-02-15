CC = gcc
INCFLAG =    -I .  -I ../../include
LDFLAGS = -lpcProxAPI

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	CXXFLAGS  = -L ../../lib

else
#Linux
	LDFLAGS+= -lhidapi-hidraw
	
	UNAME_M := $(shell uname -m)
	ifeq ($(UNAME_M),$(filter $(UNAME_M),x86_64 aarch64))
		CXXFLAGS  = -L ../../lib/64
	else
		CXXFLAGS  = -L ../../lib/32
	endif
endif

all: ./readercomm.cpp
	$(CC) $(CFLAG) $(INCFLAG)  -o  readercomm ./readercomm.cpp $(CXXFLAGS) $(LDFLAGS)
