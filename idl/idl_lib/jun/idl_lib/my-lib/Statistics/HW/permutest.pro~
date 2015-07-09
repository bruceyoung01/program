FUNCTION PERMUTEST,A,B, TD
;+
; NAME:  
;	PERMUTEST
; PURPOSE: 
;	Apply Fisher's Permutation Test for the equality of the means of two
;	samples. This method is non-parametric and exact--and slow.
;
; CALLING SEQUENCE:
;	asl = PERMUTEST( sample1, sample2, [ TD] )
; INPUT:	
;	SAMPLE1, SAMPLE2 = vectors containing samples A and B
;
; OUTPUT:
;	ASL - PERMUTEST returns the Achieved Significance Level, or the 
;	probability the two distributions are the same. A fraction 0. to 1.0.
;
; OPTIONAL OUTPUT: 
;	TD = the distribution of the difference of the means
; NOTE: 
;	This is a SLOW routine. It may not be appropriate for large (~N > 1000) 
;	samples, depending on the user's patience and the speed of his machine.
; REVISION HISTORY:
;	H.T. Freudenreich, HSTX, 2/1/95
;-

NLOOP = 1000  ; draw a thousand samples

M=N_ELEMENTS(A)  &  N=N_ELEMENTS(B)
MN=M+N

IF MN GT 32767 THEN BEGIN
  PRINT,' PERMUTEST: Too much data! Maximum = 32767 values, total'
  RETURN,0.
ENDIF

C=[A,B]

; Get the random number seed:  
SEED=SYSTIME(1)*2.+1.

M_INDICES=INTARR(M)
TD=FLTARR(NLOOP)
FOR I=0,NLOOP-1 DO BEGIN
; Select M numbers at random from the combined vector, repeating none.

  ORDER=INDGEN(MN)
  INDICES=ORDER

  FOR K = 0, M-1 DO BEGIN
    O=ORDER(WHERE( ORDER GE 0, NLEFT ))
    J=RANDOMU(SEED,1)*NLEFT
    INDX=O(J)
    M_INDICES(K) = FIX(INDX)
    ORDER( INDX ) = -1
  ENDFOR
  A1=C(M_INDICES)
; The remaining elements go into B1:
  INDICES(M_INDICES)=-1
  B1=C(WHERE(INDICES GE 0))
  
; Now perform the test:
  TD(I) = AVG(A1) - AVG(B1)
ENDFOR

; Compare the actual difference of means to the distribution.
T0=AVG(A)-AVG(B)
Q=WHERE( ABS(TD) GT ABS(T0), NPTS )
CONF=FLOAT(NPTS)/FLOAT(NLOOP)
PCONF=CONF*100.
PRINT,'The distribution means are the same at a confidence level of ',PCONF,'%'

RETURN,CONF
END
