; $ID: fix_int_n.pro V01 06/24/2012 16:33 BRUCE EXP$
;
;******************************************************************************
;  FUNCTION fix_int_n CONVERTS FLOAT TO INTEGER WITH THE FOLLOWING RULES.
;  (1 ) IF 0.0<X<1.0, THEN fix_int_n(X) = 1
;  (2 ) IF 0.0=<X-fix(X)<0.5, THEN fix_int_n(X) = fix(X)
;  (3 ) IF 0.5=<X-fix(X)<1.0, THEN fix_int_n(X) = fix(X) + 1
;  (4 ) IF -1.0<X<0.0, THEN fix_int_n(X) = -1
;  (5 ) IF -0.5<X-fix(X)=<0.0, THEN fix_int_n(X) = fix(X)
;  (6 ) IF -1.0<X-fix(X)=<-0.5, THEN fix_int_n(X) = fix(X) - 1
;
;  VARIABLES:
;  ============================================================================
;  (1 ) X     (FLOAT) : INPUT FLOAT DATA                                 [---]
;  (2 ) Y     (FLOAT) : OUTPUT FLOAT DATA                                [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/24/2012)
;******************************************************************************

   FUNCTION fix_int_n, x

;  FIND THE DIMENSION OF X
   DIM  = SIZE(X, /DIMENSIONS)
   NDIM = SIZE(X, /N_DIMENSIONS)
   Y    = FLTARR(DIM)

;  X IS POSITIVE
   IND1    = WHERE(X GT 0.0 AND X LT 1.0, NCOUNT1)
   IF (NCOUNT1 GT 0) THEN BEGIN
    Y(IND1) = FIX(X(IND1)) + 1
   ENDIF
   IND2    = WHERE(X GE 1.0 AND X-FIX(X) GE 0.0 AND X-FIX(X) LT 0.5, NCOUNT2)
   IF (NCOUNT2 GT 0) THEN BEGIN
    Y(IND2) = FIX(X(IND2))
   ENDIF
   IND3    = WHERE(X GT 1.0 AND X-FIX(X) GE 0.5 AND X-FIX(X) LT 1.0, NCOUNT3)
   IF (NCOUNT3 GT 0) THEN BEGIN
    Y(IND3) = FIX(X(IND3)) + 1
   ENDIF

;  X IS NEGATIVE
   IND4    = WHERE(X GT -1.0 AND X LT 0.0, NCOUNT4)
   IF (NCOUNT4 GT 0) THEN BEGIN
    Y(IND4) = FIX(X(IND4)) - 1
   ENDIF
   IND5    = WHERE(X LE -1.0 AND X-FIX(X) LE 0.0 AND X-FIX(X) GT -0.5, NCOUNT5)
   IF (NCOUNT5 GT 0) THEN BEGIN
    Y(IND5) = FIX(X(IND5))
   ENDIF
   IND6    = WHERE(X LT -1.0 AND X-FIX(X) LE -0.5 AND X-FIX(X) GT -1.0, NCOUNT6)
   IF (NCOUNT6 GT 0) THEN BEGIN
    Y(IND6) = FIX(X(IND6)) - 1
   ENDIF

   RETURN, Y

   END
