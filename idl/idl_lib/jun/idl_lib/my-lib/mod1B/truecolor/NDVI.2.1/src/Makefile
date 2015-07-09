#==============================================================
# NDVI_EVI Make File
#
# Based on Makefile for Makefile for make_ndvi, modified by
#     A. Lunsford, 23 September 2003
#     G. Reichert, 26 June 2002
# Coded by C. Hoisington, Science Systems and Applications, Inc.
# 21 Sep 2001 Version 1.0
# 20 Mar 2003 modified by G. Reichert for use in velma "sandbox"
#             /raid/nppop/software/NDVI/NDVI.src/
#
#
# Note:
# 	Set enviroment variable HDFHOME to point to your local HDF4.1 
# 	installation.
#
#==============================================================


#------------------------------------------------------------------------------
# Modify:
#	HDFHOME (see above),
# 	COMPILER to be your local C compiler,
#	CFLAGS to add installation-specific compiler or loader flags,
#	LOCAL_LIB to add installation required libraries
#------------------------------------------------------------------------------

COMPILER  = gcc
CFLAGS    =  

HDFLIB = $(HDFHOME)/lib
HDFINC = $(HDFHOME)/include

LIB   = -L$(HDFLIB) -lmfhdf -ldf -ljpeg -lz -lm 
INC   = -I$(HDFINC)

all:	ndvi_evi.2.1 crefl.1.4

ndvi_evi.2.1: ndvi_evi.2.1.c
	$(COMPILER) $(CFLAGS) ndvi_evi.2.1.c -o ndvi_evi.2.1 ${INC} ${LIB} 

crefl.1.4: crefl.1.4.c
	$(COMPILER) $(CFLAGS) crefl.1.4.c  -o crefl.1.4  ${INC} ${LIB}

clean:
	rm -f *.o ndvi_evi.2.1 crefl.1.4
       
