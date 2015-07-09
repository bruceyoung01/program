! $id: matrix_inversion.f v1.0 2013/6/7
      SUBROUTINE MATRIX_INVERSION ( DO_RETRIEVAL, M, N, SY, SA, YWF, 
     &                              XAP, XOLD, YDIFF, 
     &                              X, SHAT, AK, CONTRI, OZDFS )
!
!******************************************************************************
! Routine MATRIX_INVERSION computes maximum a posteriori (MAP) solution
! for linear (or linearized non-linear) inverse problems.
! (xxu, 6/7/2013, aeronet project)
!
!  Arguments:
!  ============================================================================
!  ( 1) DO_RETRIEVAL (LOGICAL): Switch to turn on/off retrieval 
!  ( 2) M            (INTEGER): Number of observations
!  ( 3) N            (INTEGER): Number of parameters to be retrieved
!  ( 4) SY           (REAL*8 ): Observational error covariance matrix
!  ( 5) SA           (REAL*8 ): A priori error covariance matrix
!  ( 6) YWF          (REAL*8 ): Jacobian matrix
!  ( 7) XAP          (REAL*8 ): A priori state vector
!  ( 8) XOLD         (REAL*8 ): State vector obtained from last iteration 
!  ( 9) YDIFF        (REAL*8 ): Difference Y - F(x_a)
!  (10) X            (REAL*8 ): Retrieval of state vector in current iteration
!  (11) SHAT         (REAL*8 ): A posteriori error covariance matrix
!  (12) AK           (REAL*8 ): Averaging kernel matrix
!  (13) CONTRI       (REAL*8 ): Contribution/gain matrix
!  (14) OZDFS        (REAL*8 ): Degree of freedom for signal
!
!  Reference:
!  - Rodgers, (2000) Inverse Methods for Atmospheric Sounding: Theory
!     and Practice. Reprint on 2012 (all equations are from this book)
!****************************************************************************** 
!
      IMPLICIT NONE

      ! Arguments
      LOGICAL, INTENT(IN ) :: DO_RETRIEVAL
      INTEGER, INTENT(IN ) :: M, N
      REAL*8,  INTENT(IN ) :: SY(M,M), SA(N,N), YWF(M,N)
      REAL*8,  INTENT(IN ) :: XAP(N), XOLD(N), YDIFF(M)
      REAL*8,  INTENT(OUT) :: X(N), SHAT(N,N), AK(N,N), CONTRI(N,M)
      REAL*8,  INTENT(OUT) :: OZDFS

      ! Local Variables
      REAL*8               :: YWFT(N,M), SY_INV(M,M), SA_INV(N,N)
      REAL*8               :: SHAT_INV(N,N)
      REAL*8               :: FORCE(M)
      REAL*8               :: TMP_N_M(N,M), TMP_N_N(N,N)

      ! For calling SVD
      REAL*8               :: U(N,N), V(N,N), W(N)
      REAL*8               :: W_INV(N,N)

      LOGICAL              :: DEBUG = .TRUE.
      INTEGER              :: I

      WRITE(6, 100)     
 100  FORMAT( 2X, 'MATRIX_INVERSION: matrix inverion method' )

      ! Initialization
      SHAT   = 0d0
      AK     = 0d0
      CONTRI = 0d0 
      SY_INV = 0d0
      SA_INV = 0d0
      W_INV  = 0d0

      !================================================================
      ! Covariance of Posteriori error [Rodgers: eq.(3.31)] 
      !================================================================

      ! Calculate tranpose of weight function matrix
      YWFT = TRANSPOSE( YWF )
      
      ! Calculate inverse of observation error covariance matrix
      ! Now only apply diagonal matrices
      SY_INV = 0d0 
      DO I = 1, M
         SY_INV(I,I) = 1d0 / SY(I,I)
      ENDDO

      ! Calculate inverse of a priori error covariance matrix
      ! Now only apply diagonal matrices
      SA_INV = 0d0
      DO I = 1, N
         SA_INV(I,I) = 1d0 / SA(I,I)
      ENDDO

      ! Calculate inverse of optimization error covariance matrix
      ! [Rodgers: eq.(2.27)] 
      TMP_N_M  = MATMUL( YWFT, SY_INV )
      SHAT_INV = MATMUL( TMP_N_M, YWF ) + SA_INV

      ! Now solve optimization error covariance matrix with SVD
      ! SX^-1 = U W V^T
      U = SHAT_INV
      CALL SVDCMP(U, N, N, N, N, W, V )
     
      W_INV = 0d0
      DO I = 1, N
         W_INV(I,I) = 1.0 / W(I)
      ENDDO

      ! SX = V W^-1 U
      TMP_N_N = MATMUL( V, W_INV )
      SHAT = MATMUL( TMP_N_N, TRANSPOSE(U) )

      !================================================================
      ! Contrinution and Averaging kernel matrix
      !================================================================

      ! Contribution matrix [Rodgers: eq.(3.27)] 
      CONTRI = MATMUL( MATMUL(SHAT,YWFT), SY_INV )

      ! Averaging kernel matrix  [Rodgers: eq.(3.28)]
      AK = MATMUL( CONTRI, YWF )

      ! Degree of freedom
      OZDFS = 0D0
      DO I = 1, N
         OZDFS = OZDFS + AK(I,I)
      ENDDO

      !================================================================
      ! Update X with equation (5.9):
      ! X_i+1 = Xa + G [ Y - F(X_i) + K ( X_i - X_a ) ]
      !================================================================
      IF ( DO_RETRIEVAL ) THEN 

         ! FORCE: [ Y-F(X_i) + K( X_i - X_a ) ]
         FORCE = YDIFF + MATMUL( YWF, XOLD-XAP )

         ! New X: X_k+1 = X_a + G * FORCE
         X = XAP + MATMUL( CONTRI, FORCE )

      ENDIF

      IF ( DEBUG ) THEN

         WRITE(6, 110) 
         WRITE(6, 120) 
         DO I = 1, N
            WRITE(6,130) I, XAP(I), XOLD(I), X(I), 
     &                   SQRT(SHAT(I,I)), AK(I,I)
         ENDDO
         WRITE(6, 140) OZDFS 

      ENDIF

 110  FORMAT( 2X, ' - debug outputs ' )
 120  FORMAT( 2X, ' XAP, XOLD, XNEW, Err, AK ' )  
 130  FORMAT( 2X, I4, 1P3E10.2, 1P2E11.3 )
 140  FORMAT( 2X, ' - DFS = ', F8.3 )

      END SUBROUTINE MATRIX_INVERSION
