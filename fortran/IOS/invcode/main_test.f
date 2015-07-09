      PROGRAM MAIN_TEST

      LOGICAL, PARAMETER :: DO_RETRIEVAL = .TRUE.
      INTEGER, PARAMETER :: M = 1, N = 1
      REAL*8    :: SY(M,M), SA(N,N), YWF(M,N) 
      REAL*8    :: XAP(N), XOLD(N), YDIFF(M)
      REAL*8    :: X(N), SHAT(N,N), AK(N,N), CONTRI(N,M)
      REAL*8    :: OZDFS


      SY(1,1)   = 1D0
      SA(1,1)   = 1D0
      YWF(1,1)  = 2D0
      XAP(1)    = 2D0
      XOLD(1)   = 2D0
      YDIFF(1)  = 1D0
      
      CALL MATRIX_INVERSION ( DO_RETRIEVAL, M, N, SY, SA, YWF,
     &                        XAP, XOLD, YDIFF,
     &                        X, SHAT, AK, CONTRI, OZDFS )

      WRITE(6,*) 'SHAT   = ', SHAT(1,1)
      WRITE(6,*) 'CONTRI = ', CONTRI(1,1)
      WRITE(6,*) 'AK     = ', AK(1,1)
      WRITE(6,*) 'OZDFS  = ', OZDFS
      IF ( DO_RETRIEVAL ) WRITE(6,*) ' Retrieval = ', X

      END PROGRAM MAIN_TEST
