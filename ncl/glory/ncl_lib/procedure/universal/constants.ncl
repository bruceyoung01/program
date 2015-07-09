; $ID: constants.ncl V01 01/17/2012 16:29 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE contants IS USED TO INITIALIZE THE FREQUENTLY-USED CONSTATNTS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv1     (integer): BAD VALUE FOR INTEGER                        [---]
;  (2 ) bv2     (float)  : BAD VALUE FOR FLOAT                          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/17/2012)
;******************************************************************************

undef("constants")
procedure constants(bv1    :integer, \ ; OUTPUT
                    bv2    :float,   \ ; OUTPUT)

begin

;  BAD VALUE FOR INTEGER
   bv1 = -999
;  BAD VALUE FOR FLOAT
   bv2 = -999.0

return
end
