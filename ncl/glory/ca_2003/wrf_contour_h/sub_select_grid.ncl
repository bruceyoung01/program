; $ID: sub_select_grid.ncl V01 11/18/2011 13:18 BRUCE EXP $
     procedure sub_select_grid(wdir1, wdir2, cdir1, cdir2, \
                               wfilename1, wfilename2, cfilename1, cfilename2,\
                                )
;
;******************************************************************************
;  SUBROUTINE sub_select_grid IS USED TO SELECT WRFCHEM DATA FROM THE SAME PATH
;  WAY AS CALIPSO(BOTH CAL_LID_L2_05kmAPro-Prov-V3-01 AND 
;                      CAL_LID_L2_VFM-ValStage1-V3-01)
;
;  NOTES:
;  ============================================================================
;  (1 ): ORIGINALLY WRITTEN BY BRUCE. (11/18/2011)
;
;******************************************************************************
local j, k
begin

; PRINT OUT WHEN THE PROGRAM START TO RUN
  print("START TIME : ")
  system("date")

;-----------------CALIPSO DATA 1-------------------------------------
; READ THE FIRST CALIPSO HDF DATA
  fh1       = addfile( dirh1 + nameh1, "r" )
; JUDGE IT IS DAY TIME OR NIGHT TIME
  d_or_n    = str_get_cols(nameh1, 51, 51)\
  ech532    = fh1->Extinction_Coefficient_532
  clfh      = fh1->Cloud_Layer_Fraction
  aodh532   = fh1->Column_Optical_Depth_Aerosols_532
  sfch      = fh1->Surface_Elevation_Statistics
  qch532    = fh1->Extinction_QC_Flag_532
  lath      = fh1->Latitude
  lonh      = fh1->Longitude
  dimlath   = dimsizes(lath)
  dimlonh   = dimsizes(lonh)
  dimech532 = dimsizes(ec532h)
  nlevelh   = dimech532(1)
  dateh     = str_get_cols(nameh1, 31, 40)
  timeh     = str_get_cols(nameh1, 42, 43)
  timeall   = str_get_cols(nameh1, 42, 49)
  clfh1     = new(( /dimech532(0), dimech532(1)/ ), float, bv1)
  sfch1     = new(( /dimech532(0)/ ), float, bv1)
  clfh1     = clfh
  sfch1     = sfch(:, 2)

; QUALIFY THE QUALITY OF EXTINCTION COEFFICIENT
  qch2      = qch(:, :, 0)
  oneqch2   = ndtooned(qch2)
  nqch2     = dimsizes(qch2)
  qch2ind   = ind_resolve(ind(oneqch2 .ne. 0.0 .and. \
                              oneqch2 .ne. 1.0 .and. \
                              oneqch2 .ne. 2.0 .and. \
                              oneqch2 .ne. 16.), nqch2)
  dimqch2   = dimsizes(qch2ind)
  qcnpts    = dimqch2(0)
  ndimqc    = dimqch2(1)
  do j = 0, qcnpts - 1
   ech( qch2ind(j, 0), qch2ind(j, 1) ) = bv1
  end do
  delete(qch2)
  delete(oneqch2)
  delete(qch2ind)

; ASSIGN ARRAY TO A NEW VALUE
  do j = 0, dimech(1) - 1
   do k = 0, dimech(0) - 1
    if ( clfh1(k, j) .le. 0.0 ) then
     clfh1(k, j) = bv1
    else
     clfh1(k, j) = 0.0 - clfh1(k, j)
    end if
   end do
  end do

; ASSIGN 1 NEW DIMENSIONAL ARRAY FOR LATITUDE AND LONGITUDE OF CALIPSO
  lathh     = lath(:, 0)
  lonhh     = lonh(:, 0)

;---------------------------WRFCHEM DATA 1---------------------------
; READ WRFCHEM DATA 1
  index     = ind()
