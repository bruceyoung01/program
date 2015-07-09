      SUBROUTINE INTERH  (    !HORIZONTAL INTERPOLATION OF THE FIELD

     *                   LM                !COMMON VERTICAL DIMENSION
     *,                  KM1,IM1,JM1,LON1,LAT1,DAT1 !OUTPUT VARIABLES
     *,                  KM2,IM2,JM2,LON2,LAT2,DAT2 !INPUT VARIABLES
CGLS**** KM1 MUST BE LARGER OR EQUAL TO KM2*********************************
     *,                  REG2REG    !TRUE IF INTERPOLATS FROM REGULAR
     *                   )          !INTO REGULAR GRID

CDIR$ BOUNDS

CGLS****THIS SUBROUTINE MAKES PROJECTION (INTERPOLATION) OF 3-D ARRAY FROM*
CGLS****REGULAR LATITUDE-LONGITUDE SPHERICAL GRID TO IRREGULAR ONE*********
CGLS****REGULAR GRID IS DEFINED BY THE ONE DIMENSIONAL ARRAYS**************
CGLS****OF LONGITUDE AND LONGITUDE. ARRAYS STRINGS AND COLUMNS ARE*********
CGLS****ALONG LONGITUDES AND LATITUDES. IRREGULAR GRID HAS IRREGULAR*******
CGLS****DISTRIBUTED NODES AND IS DEFINED BY 2-D ARRAYS OF LONGITUDE********
CGLS****AND LATITUDE. ROTATED GRID LOOKS LIKE IRREGULAR IN OLD SYSTEM******

CGLS****IF RESULTING DOMAIN IS LARGER THAN ORIGINAL- BOUNDARY VALUES*******
CGLS****ARE EXTRAPOLATED***************************************************
CGLS****J INDEX IS CHANGING :
CGLS************************  FROM 1 TO JM-1 FOR P AND U GRIDS ************
CGLS************************  FROM 1 TO JM   FOR V GRID, SO AS ************
CGLS************************  FOR J=1 AND J=JM V IS SUPPOUSED TO BE 0 *****
CGLS************************  OR JUST MERIDIONAL FLUXES *******************
CGLS****ALL DATA AND GRID ARRAYS MUST BE DEFINED FROM 1:JM AND 1:IM *******
CGLS****VERTICAL DIMENSIONS LM MUST BE SAME FOR BOTH INPUT AND OUTPUT******
CGLS****FOR 2-D ARRAYS LM=1************************************************
CGLS****OUTPUT ARRAY IS ALWAYS DEFINED AS IRREGULAR BY 2-D ARRAYS**********
CGLS****OF LATITUDES AND LONGITUDES****************************************
CGLS****SO IN BOTH ROTATED AND NON ROTATED CASES WE USE 'NO' OR 'ON' ARRAYS
CGLS****WHICH ARE QUASIIRREGULAR IN NONROTATED CASE, BUT STILL ARE DEFINED*
CGLS****IN TRANSFRM SUBROUTINE*********************************************
CGLS***********************************************************************
CGLS****GEORGIY L. STENCHIKOV   10/10 1994*********************************
CGLS****DEPARTMENT OF METEOROLOGY UNIVERSITY OF MARYLAND*******************
C
C
C     LM - VERTICAL DIMENSION OF ALL INPUT AND OUTPUT ARRAYS

C     IM2, JM2, LON2, LAT2, DAT2 - INPUT DATA ON REGULAR GRID
C     LON2, LAT2 - 1-D ARRAYS - NODES, WHERE DAT2 IS LOCATED

C     IM1, JM1, LON1, LAT1, DAT1 - RESULTING ARRAYS ON REGULAR/IRREGULAR GRID
C     LON1, LAT1 - 2-D ARRAYS - NODES, WHERE DAT1 IS LOCATED
C

      IMPLICIT NONE

      REAL ONE
      REAL TWO
      REAL HALF
      REAL FOURTH
      REAL ZERO
      REAL PI

      PARAMETER (ONE=1.0)
      PARAMETER (TWO=2.0)
      PARAMETER (ZERO=0.0)
      PARAMETER (HALF=0.5)
      PARAMETER (FOURTH=0.25)
      PARAMETER (PI=3.1415926535898)

CGLS****INPUT/OUTPUT PARAMETRS**********************************************

      INTEGER IM1, JM1, IM2, JM2, LM, KM, KM1, KM2
      REAL    LON1(IM1,JM1), LAT1(IM1,JM1), DAT1(IM1,JM1,LM,KM1)
      REAL    LON2(IM2), LAT2(JM2), DAT2(IM2,JM2,LM,KM2)
      LOGICAL REG2REG

CGLS****LOCAL PARAMETERS****************************************************

      INTEGER I,J,L,K, I1,I2,I3,J1,J2,J3
      REAL    X1,Y1,Y2,Y3,X2,X3,DX,DY, D22,D23,D33,D32

      KM = MIN0(KM1, KM2)

      DO  I=1,IM1        !LOOP ON THE RESULTING IRREGULAR GRID
      DO  J=1,JM1

         IF (REG2REG) THEN
            X1 = LON1(I,1)
            Y1 = LAT1(J,1)  !REGULAR TO REGULAR GRID
         ELSE
            X1 = LON1(I,J)
            Y1 = LAT1(I,J)  !REGULAR TO IRREGULAR GRID
         ENDIF

CGLS****SEARCH IN LATITUDE DIRECTION***************************************
CGLS****J INDEX IS CHANGING :
CGLS************************  FROM 1 TO JM-1 FOR P AND U GRIDS ************
CGLS************************  FROM 1 TO JM   FOR V GRID, SO AS ************
CGLS************************  FOR J=1 AND J=JM V IS SUPPOUSED TO BE 0 *****
CGLS************************  OR JUST MERIDIONAL FLUXES *******************
CGLS****ALL DATA AND GRID ARRAYS MUST BE DEFINED FROM 1 TO JM OR IM *******

         J1 = 1
         IF (Y1.LE.LAT2(1)) THEN  !EXTRAPOLATION TO < LAT2 REGION
            J2 = J1
            J3 = J1
            Y2 = LAT2(J2)
            Y3 = LAT2(J3)            !J3=2 AND DY=Y3-Y2 GIVE EXTRAPOLATION
            DY = 1.
            GO TO 3
         ENDIF
2        CONTINUE
         J2 = J1
         J3 = J1+1
         Y2 = LAT2(J2)
         Y3 = LAT2(J3)
         DY = Y3-Y2
         IF ((Y1.LT.Y3).AND.(Y1.GE.Y2))  GO TO 3
         J1 = J1+1
         IF (J1.GE.JM2) THEN      !EXTRAPOLATION > LAT2 REGION
             J2 = JM2
             J3 = JM2
             Y2 = LAT2(J2)
             Y3 = LAT2(J3)      !J3=JM2-1 AND DY=Y3-Y2 GIVE EXTRAPOLATION
             DY = 1.
             GO TO 3
         ENDIF
         GO TO 2 
3        CONTINUE

CGLS****SEARCH IN LONGITUDE DIRECTION*************************************
CGLS****I INDEX IS ALWAYS CHANGING FROM 1 TO IM***************************
CGLS****IF N>1 WE HAVE NOT PERIODICAL DOMAIN IN LONGITUDE AND CAN ********
CGLS****DO ALL LIKE FOR LATITUDES*****************************************
CGLS****NOW ALL REALIZED ONLY FOR N=1, BUT IS POSSIBLE TO DO UNIVERSAL****
CGLS****WE SUPPOSE THAT LON1, LON2 START FROM -PI AND FINISH AT PI********
CGLS****IT IS ALSO NOT UNIVERSAL******************************************

CGLS****   IF N=1 USE THIS ALGORITHM. IF N#1 REALIZE NONPERIODIC ONE   ***

         I1 = 1       !LONGITUDINAL GRID ALWAYS STARTS FROM 1 AND FINISH ON IM
         IF (X1.LE.LON2(1)) THEN   !ENUMERATION IS BROKEN AT -PI/PI POINT
            I2 = IM2
            I3 = 1
            X2 = LON2(I2)-TWO*PI   !INTERPOLATION BETWEEN LAST AND FIRST POINTS
            X3 = LON2(I3)          !X1<0. AND X1<LON2(1)
            DX = X3 - X2
            GO TO 5
         ENDIF

 4       CONTINUE
         I2 = I1
         I3 = I1+1
         X2 = LON2(I2)             !REGULAR INTERNAL CASE
         X3 = LON2(I3)
         DX = X3 - X2
         IF ((X1.LT.X3).AND.(X1.GE.X2)) GO TO 5
         I1  = I1+1
         IF (I1.GE.IM2) THEN        !INTERPOLATION BETWEEN LAST AND FIRST POINTS
            I2 = IM2                !X1>O. AND X1>LON2(IM2)
            I3 = 1
            X2 = LON2(I2)
            X3 = LON2(I3)+TWO*PI
            DX = X3 - X2
            GO TO 5
         ENDIF
         GO TO 4

 5       CONTINUE             !BILINEAR INTERPOLATION INTO LON1(I),LAT1(J) NODE

         DO  K=1,KM
         DO  L=1,LM

            D22 = DAT2(I2,J2,L,K)
            D23 = DAT2(I2,J3,L,K)
            D32 = DAT2(I3,J2,L,K)
            D33 = DAT2(I3,J3,L,K)

            DAT1(I,J,L,K)=D22+(D23-D22)*(Y1-Y2)/DY+(D32-D22)*(X1-X2)/DX
     *                 +(D33+D22-D32-D23)*(Y1-Y2)*(X1-X2)/DY/DX
         ENDDO       !LOOP ON L
         ENDDO       !LOOP ON K

      ENDDO       !LOOP ON J
      ENDDO       !LOOP ON I


      RETURN
      END
        
