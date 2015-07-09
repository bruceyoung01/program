!  $ID: READ_FLAMBE.F V01 07/01/2013 08:36 BRUCE EXP$
!
!******************************************************************************
!  SUBROUTINE READ_FLAMBE READS FLAMBE SMOKE EMISSION.
!
!  VARIABLES:
!  ============================================================================
!  (1 ) 
!
!  NOTES:
!  ============================================================================
!  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/01/2013)
!******************************************************************************
!
      SUBROUTINE READ_FLAMBE
     &           (IYEAR, IMONTH, IDAY, START_HOUR, END_HOUR, 
     &            FLAT, FLON, FAREA, FLUX)

      ! FORCE ALL VARIABLES TO BE DECLARED EXPLICITLY
      IMPLICIT NONE

      ! PARAMETER
      INTEGER, PARAMETER       :: MAXL    = 50000
      REAL*8,  PARAMETER       :: HRTOSED = 3600.

      ! ARGUMENTS
      CHARACTER (LEN = 255)    :: FLAMBEDIR
      INTEGER                  :: IYEAR, IMONTH, IDAY
      INTEGER                  :: START_HOUR, END_HOUR
      REAL, DIMENSION(MAXL)    :: FLAT, FLON, FAREA, FLUX

      ! LOCAL VARIABLES
      CHARACTER (LEN = 255)    :: CTIME, DIR, SUF, INPTF
      INTEGER                  :: I, ILINE, NL, IPF, IHR, HHMM
      INTEGER                  :: X1, Y1
      INTEGER                  :: IBOT, ITOP
      REAL                     :: X, Y
      REAL*8                   :: ZDIF, FRC

      ! VARIABLES FOR FLAMBE EMISSION BEFORE 2003
      CHARACTER (LEN = 255)    :: NOUSE
      REAL                     :: TMPLAT1, TMPLON1, TMPLAT2, TMPLON2
      REAL                     :: TMPAREA, TMPFLUX
      INTEGER                  :: SAT, TMPPOSE

      ! VAIRBALES FOR FLAMBE EMISSION AFTER 2004
      INTEGER                  :: INMIN, INMID, INMAX, HALF
      INTEGER*8                :: STAMP
      REAL                     :: CARBON
      REAL                     :: TMP1, TMP2, TMP3

      ! DO HOUR LOOP TO READ FLAMBE DATA
      DO IHR = START_HOUR, END_HOUR
       HHMM = IHR-1
       HHMM = INT(HHMM*100)
       WRITE(CTIME, 110) IYEAR, IMONTH, IDAY, HHMM
110    FORMAT(I4.4I2.2I2.2I4.4)

      !========================================================================
      ! READS FLAMBE EMISSION BEFORE 2003
      !========================================================================

       IF (IYEAR .LE. 2003) THEN
        DIR = FLAMBEDIR(1: LEN_TRIM(FLAMBEDIR))//'good'
     &        CTIME(1: 4)//'smoke_goes_'
        INPTF = DIR(1: LEN_TRIM(DIR))//CTIME(1: LEN_TRIM(CTIME))
        OPEN(1, FILE = INPTF, STATUS = 'OLD')
        DO ILINE = 1, MAXL
         TMPLAT1 = 0.0
         TMPLON1 = 0.0
         TMPLAT2 = 0.0
         TMPLON2 = 0.0
         SAT     = 0
         TMPAREA = 0.0
         TMPPLUX = 0.0
         TMPOSE  = 0.0
         READ(1, *, END = 100) TMPLAT1, TMPLON1, TMPLAT2, TMPLON2, 
     &                         SAT, TMPAREA, TMPFLUX, TMPPOSE, NOUSE
         FLAT(ILINE)  = TMPLAT1
         FLON(ILINE)  = TMPLON1
         FAREA(ILINE) = TMPAREA
         FLUX(ILINE)  = TMPFLUX
        ENDDO
100    CONTINUE
       CLOSE(1)
       ENDIF

      !========================================================================
      ! READS FLAMBE EMISSION AFTER 2004
      !========================================================================

       IF (IYEAR .GE. 2004) THEN
        SUF = '.dat'
        DIR = FLAMBEDIR(1: LEN_TRIM(FLAMBEDIR))//
              CTIME(1: 4)//'/'//CTIME(1: 6)//
     &        '/flambe_arctas_'
        INPTF = DIR(1: LEN_TRIM(DIR))//CTIME(1: LEN_TRIM(CTIME))//
     &          SUF(1: LEN_TRIM(SUF))
        OPEN(1, FILE = INPTF, STATUS = 'OLD')
        DO ILINE = 1, MAXL
         STAMP   = 0
         TMPLAT1 = 0.0
         TMPLON1 = 0.0
         INMIN   = 0
         INMID   = 0
         INMAX   = 0
         SAT     = 0
         TMPAREA = 0.0
         TMPFLUX = 0.0
         HALF    = 0
         CARBON  = 0.0
         TMP1    = 0.0
         TMP2    = 0.0
         TMP3    = 0.0
         READ(1, *, END = 200) STAMP, TMPLON1, TMPLAT1, INMIN, INMID, 
     &                         INMAX, SAT, TMPAREA, TMPFLUX, HALF, 
     &                         CARBON, TMP1, TMP2, TMP3
         FLAT(ILINE)  = TMPLAT1
         FLON(ILINE)  = TMPLON1
         FAREA(ILINE) = TMPAREA
         FLUX(ILINE)  = TMPFLUX
        ENDDO
200     CONTINUE
        CLOSE(1)
       ENDIF

       END SUBROUTINE READ_FLAMBE
