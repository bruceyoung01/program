; $ID: select_reverse_calipso_l2.ncl V01 02/16/2012 10:32 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_reverse_calipso_l2 SELECTS CALIPSO L2 DATA BASED ON THE 
;  LIMITED REGION AND REVERSE VERTICAL LEVEL WITH HORIZONTAL LAYER DIMENSION.
;  (DATA : CAL_LID_L2_05kmAPro-Prov-V3-01)
;
;  VARIABLES:
;  ============================================================================
;  (1 ) indexh (integer): SELECTED CALIPSO DATA INDEX IN LIMITED REGION  [---]
;  (2 ) ndimh  (integer): # OF SELECTED CALIPSO DATA INDEX IN LIMITED 
;                         REGION                                         [---]
;  (3 ) inth   (integer): # OF VERTICAL LELVELS                          [---]
;  (4 ) lathh  (float)  : CALIPSO LATITUDE FOR SELECTED GROUND TRACK BASED 
;                         ON THE LIMITED REGION                          [deg]
;  (5 ) lonhh  (float)  : CALIPSO LONGITUDE FOR SELECTED GROUND TRACK BASED
;                         ON THE LIMITED REGION                          [deg]
;  (6 ) nlevelh(integer): ORIGINAL VERTICAL LEVELS OF CALISPO DATA(399)  [---]
;  (7 ) ech    (float)  : CALIPSO AEROSOL EXTINCTION COEFFICIENT         [km-1]
;  (8 ) clfh1  (float)  : CALIPSO CLOUD FRACTION                         [---]
;  (9 ) aodh   (float)  : CALIPSO AOD FOR TOTAL COLUMN                   [---]
;  (10) sfch1  (float)  : CALIPSO SURFACE ELEVATION STATISTICS           [---]
;  (11) d_or_n (string) : CALIPSO DAYTIME OR NIGHTTIME                   [---]
;  (12) bv1    (float)  : MISSING VALUE FOR FLOAT                        [---]
;  (13) sstart (integer): START INDEX OF CALIPSO GROUND TRACK FOR LIMITED
;                         REGION                                         [---]
;  (14) send   (integer): END INDEX OF CALIPSO GROUND TRACK FOR LIMITED
;                         REGION                                         [---]
;  (15) rsech  (float)  : SELECTED AEROSOL EXTINCTION COEFFICIENT        [km-1]
;  (16) rsclfh (float)  : SELECTED CLOUD FRACTION                        [---]
;  (17) rssfch (float)  : SELECTED SURFACE ELEVATION STATISTICS          [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/16/2012)
;
;******************************************************************************

undef("select_reverse_calipso_l2")
procedure select_reverse_calipso_l2(indexh  :integer, ndimh   :integer,\; INPUT
                                    inth    :integer, lathh   :float,  \; INPUT
                                    lonhh   :float,   nlevelh :integer,\; INPUT
                                    ech     :float,   clfh1   :float,  \; INPUT
                                    aodh    :float,   sfch1   :float,  \; INPUT
                                    d_or_n  :string,  bv1     :float,  \; INPUT
                                    sstart  :integer, send    :integer,\; OUTPUT
                                    rsech   :float,   rsclfh  :float,  \; OUTPUT
                                    rssfch  :float)                     ; OUTPUT


begin

   sstart = indexh(0)
   send   = indexh(ndimh-1)
   sech   = new((/ndimh, inth/), float, bv1)
   sclfh  = new((/ndimh, inth/), float, bv1)
   slathh = new((/ndimh/), float, bv1)
   slonhh = new((/ndimh/), float, bv1)
   saodh  = new((/ndimh/), float, bv1)
   ssfch  = new((/ndimh/), float, bv1)
   slathh = lathh(indexh(0:(ndimh-1)))
   slonhh = lonhh(indexh(0:(ndimh-1)))
   sech   = ech(sstart:send,(nlevelh-9):(nlevelh-inth-8))
   sclfh  = clfh1(sstart:send,(nlevelh-9):(nlevelh-inth-8))
   saodh  = aodh(sstart:send)
   ssfch  = sfch1(sstart:send)
   
;  REVERSE EC ARRARY BETWEEN HEIGHT AND LATITUDE/LONGITUDE
   do j = 0, inth-1
    do k = 0, ndimh-1
     if( .not.ismissing(sech(k,j)).and. sech(k,j) .gt. -1.0  \
         .and. sech(k,j) .lt. 0.0)then
      sech(k,j) = 0.0
     end if
     if( d_or_n .eq. "D" ) then
;     rsech(j, k) = sech(ndimh-k-1, j)
;     rsclfh(j,k) = sclfh(ndimh-k-1, j)
;     rssfch(k)   = ssfch(ndimh-k-1)
      rsech(j, k) = sech(k, j)
      rsclfh(j,k) = sclfh(k, j)
      rssfch(k)   = ssfch(k)
     end if
     if( d_or_n .eq. "N" ) then
      rsech(j, k) = sech(k, j)
      rsclfh(j,k) = sclfh(k, j)
      rssfch(k)   = ssfch(k)
     end if
    end do
   end do
   delete(sech)
return
end
