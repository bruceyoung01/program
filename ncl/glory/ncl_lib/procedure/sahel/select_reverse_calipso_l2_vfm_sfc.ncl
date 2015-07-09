;  $ID: select_reverse_calipso_l2_vfm_sfc.ncl V01 02/16/2012 10:32 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_reverse_calipso_l2_vfm_sfc SELECTS CALIPSO L2 DATA BASED 
;  ON THE LIMITED REGION AND REVERSE VERTICAL LEVEL WITH HORIZONTAL LAYER 
;  DIMENSION. (DATA : CAL_LID_L2_05kmAPro-Prov-V3-01)
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
;  (2 ) MODIFIED FROM select_reverse_calipso_l2.ncl. (04/22/2013)
;******************************************************************************

undef("select_reverse_calipso_l2_vfm_sfc")
procedure select_reverse_calipso_l2_vfm_sfc \
         (block   :integer, nblock  :integer,\; INPUT
          base    :float,   top     :float,  \; INPUT
          maxh    :float,   deltah  :float,  \; INPUT
          indexh  :integer, ndimh   :integer,\; INPUT
          inth    :integer, lathh   :float,  \; INPUT
          lonhh   :float,   sfch    :float,  \; INPUT
          vfmh    :float,                    \; INPUT
          d_or_n  :string,  bv2     :float,  \; INPUT
          sstart  :integer, send    :integer,\; OUTPUT
          rssfch  :float,   rsvfmh  :float)   ; OUTPUT


begin

;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

   sbase  = 0.5
   sstart = indexh(0)
   send   = indexh(ndimh-1)
   ssfch  = new((/ndimh/), float, bv2)
   svfmh  = new((/ndimh, inth/), float, bv2)
   slathh = new((/ndimh/), float, bv2)
   slonhh = new((/ndimh/), float, bv2)
   slathh = lathh(indexh(0:(ndimh-1)))
   slonhh = lonhh(indexh(0:(ndimh-1)))
;  CALCULATE THE REAL START # OF BLOCK IN THE CORRESPONDING HEIGHT CLASSIFICATION
   startb = floattoint(base/deltah)
   if (maxh .gt. base .and. \
       maxh .le. top) then
    ablock = floattoint((maxh-base)/deltah)
   else if (maxh .gt. top) then
    ablock = nblock
   end if
   end if
   underb = floattoint(sbase/deltah)
   endb   = startb+ablock-underb-1
   svfmh(:, startb:endb) = vfmh(sstart:send, nblock-underb-1:nblock-ablock)
   ssfch(:)              = sfch(sstart:send)

;  REVERSE EC ARRARY BETWEEN HEIGHT AND LATITUDE/LONGITUDE
   do j = 0, inth-1
    do k = 0, ndimh-1
     if( d_or_n .eq. "D" ) then
      rssfch(k)    = ssfch(ndimh-k-1)
      rsvfmh(j, k) = svfmh(ndimh-k-1, j)
     else if( d_or_n .eq. "N" ) then
      rssfch(k)    = ssfch(k)
      rsvfmh(j, k) = svfmh(k, j)
     end if
     end if
    end do
   end do
   delete(svfmh)
;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "select_reverse_calipso_l2_vfm.ncl", 0)

return
end
