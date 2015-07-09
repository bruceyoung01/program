; $ID: read_calipso_l2_vfm_sfc.ncl V01 02/07/2012 23:29 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_calipso_l2_vfm_sfc READ CALIPSO LEVEL 2 VFM DATA 
;  (CAL_LID_L2_VFM-ValStage1-V3-01), INCLUDING VERTICAL FEATURE MASK DATA,     
;  QUALITY FLAG, CLOUD LAYER FRACTION, SURFACE ELEVATION STATISTICS, LATITUDE, 
;  LONGITUDE AND SO ON.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dirh    (string) : DIRECTORY OF CALIPSO LEVEL 2 DATA              [---]
;  (2 ) filename(string) : ONE FILE NAME OF CALIPSO LEVEL 2 DATA          [---]
;  (3 ) bv1     (float)  : MISSING VALUE FOR FLOAT                        [---]
;  (4 ) minlat  (float)  : MINIMUM LATITUDE OF LIMITED REGION             [deg]
;  (5 ) maxlat  (float)  : MAXIMUM LATITUDE OF LIMITED REGION             [deg]
;  (6 ) minlon  (float)  : MINIMUM LONGITUDE OF LIMITED REGION            [deg]
;  (7 ) maxlon  (float)  : MAXIMUM LONGITUDE OF LIMITED REGION            [deg]
;  (8 ) dateh   (string) : CALIPSO DATE (FORMAT : YEAR-MONTH-DAY, 
;                          i.e. 2008-02-26)                               [---]
;  (9 ) timeh   (string) : CALIPSO TIME (FORMAT : TIME, 01)               [---]
;  (10) lathh   (float)  : CALIPSO LATITUDE FOR SELECTED GROUND TRACK BASED 
;                          ON THE LIMITED REGION                          [deg]
;  (11) lonhh   (float)  : CALIPSO LONGITUDE FOR SELECTED GROUND TRACK BASED
;                          ON THE LIMITED REGION                          [deg]
;  (12) ech     (float)  : CALIPSO AEROSOL EXTINCTION COEFFICIENT         [km-1]
;  (13) clfh1   (float)  : CALIPSO CLOUD FRACTION                         [---]
;  (14) aodh    (float)  : CALIPSO AOD FOR TOTAL COLUMN                   [---]
;  (15) sfch1   (float)  : CALIPSO SURFACE ELEVATION STATISTICS           [---]
;  (16) d_or_n  (string) : CALIPSO DAYTIME OR NIGHTTIME                   [---]
;  (17) indexh  (integer): SELECTED CALIPSO DATA INDEX IN LIMITED REGION  [---]
;  (18) ndimh   (integer): # OF SELECTED CALIPSO DATA INDEX IN LIMITED 
;                          REGION                                         [---]
;  (19) timeall (string) : CALIPSO TIME STRING (FORMAT : HOUR-MINUTE-SECOND,
;                          i.e. 01-01-01)                                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/07/2012)
;  (2 ) MODIFIED FROM read_calipso_l2_vfm.ncl. (04/25/2013)
;******************************************************************************

undef("read_calipso_l2_vfm_sfc")
procedure read_calipso_l2_vfm_sfc \
                         (dirh1     :string,  filename1 :string, \ ; INPUT
                          dirh      :string,  filename  :string, \ ; INPUT
                          bv0       :string,  bv1       :integer,\ ; INPUT
                          bv2       :float,                      \ ; INPUT
                          minlatn   :float,   maxlatn   :float,  \ ; INPUT
                          minlonn   :float,   maxlonn   :float,  \ ; INPUT
                          nprofile1 :integer,                    \ ; INPUT
                          npixel1   :integer, nblock1   :integer,\ ; INPUT
                          nprofile2 :integer,                    \ ; INPUT
                          npixel2   :integer, nblock2   :integer,\ ; INPUT
                          nprofile3 :integer,                    \ ; INPUT
                          npixel3   :integer, nblock3   :integer,\ ; INPUT
                          dateh     :string,  timeh     :string, \ ; OUTPUT
                          d_or_n    :string,  timeall   :string, \ ; OUTPUT
                          lath1     :float,   lonh1     :float,  \ ; OUTPUT
                          sfch1     :float,   vfmh1     :float,  \ ; OUTPUT
                          indexh1   :integer, ndimh1    :integer,\ ; OUTPUT
                          lath2     :float,   lonh2     :float,  \ ; OUTPUT
                          sfch2     :float,   vfmh2     :float,  \ ; OUTPUT
                          indexh2   :integer, ndimh2    :integer,\ ; OUTPUT
                          lath3     :float,   lonh3     :float,  \ ; OUTPUT
                          sfch3     :float,   vfmh3     :float,  \ ; OUTPUT
                          indexh3   :integer, ndimh3    :integer)  ; OUTPUT

begin
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

;  SPECIFY THE ACTUAL PROFILE FOR EACH BLOCK
   nprofile1a = 3
   nprofile2a = 5
   nprofile3a = 15

;  READ CALIPSO LEVEL2 VFM DATA
   print("START TIME : ")
   system("date")
   fh1       = addfile(dirh1 + filename1, "r")
   fh        = addfile(dirh  + filename,  "r")
   d_or_n    = str_get_cols(filename, 51, 51)
   sfch      = fh1->Surface_Elevation_Statistics
   lath      = fh->Latitude(:, 0)
   lonh      = fh->Longitude(:, 0)
   vfmh      = fh->Feature_Classification_Flags
   dimvfmh   = dimsizes(vfmh)
   npixel    = dimvfmh(0)
   nblock    = dimvfmh(1)
   dateh     = str_get_cols(filename, 31, 40)
   timeh     = str_get_cols(filename, 42, 43)
   timeall   = str_get_cols(filename, 42, 49)

;  DEFINE THREE ARRAYS FOR THREE LAYERS RESPECTIVELY
   svfmh1    = new((/npixel1, nblock1/), string,  bv0)
   svfmh2    = new((/npixel2, nblock2/), string,  bv0)
   svfmh3    = new((/npixel3, nblock3/), string,  bv0)

;  ASSIGN LATITUDE AND LONGITUDE TO DIFFERENT LAYER ARRAY
   do i = 0, npixel-1
    lath1(i*nprofile1:(i+1)*nprofile1-1) = lath(i)
    lonh1(i*nprofile1:(i+1)*nprofile1-1) = lonh(i)
    sfch1(i*nprofile1:(i+1)*nprofile1-1) = sfch(i, 0)
    lath2(i*nprofile2:(i+1)*nprofile2-1) = lath(i)
    lonh2(i*nprofile2:(i+1)*nprofile2-1) = lonh(i)
    sfch2(i*nprofile2:(i+1)*nprofile2-1) = sfch(i, 0)
    lath3(i*nprofile3:(i+1)*nprofile3-1) = lath(i)
    lonh3(i*nprofile3:(i+1)*nprofile3-1) = lonh(i)
    sfch3(i*nprofile3:(i+1)*nprofile3-1) = sfch(i, 0)
   end do

;  SELECT THE TRACK IN THE STUDY REGION
   indexh  = ind(lath  .ge. minlatn .and. lath  .le. maxlatn .and. \
                 lonh  .ge. minlonn .and. lonh  .le. maxlonn)
   ndimh   = dimsizes(indexh)
   indexha = ind(lath1 .ge. minlatn .and. lath1 .le. maxlatn .and. \
                 lonh1 .ge. minlonn .and. lonh1 .le. maxlonn)
   ndimh1  = dimsizes(indexha)
   indexh1(0: (ndimh1-1)) = indexha 
   indexhb = ind(lath2 .ge. minlatn .and. lath2 .le. maxlatn .and. \
                 lonh2 .ge. minlonn .and. lonh2 .le. maxlonn)
   ndimh2  = dimsizes(indexhb)
   indexh2(0: (ndimh2-1)) = indexhb 
   indexhc = ind(lath3 .ge. minlatn .and. lath3 .le. maxlatn .and. \
                 lonh3 .ge. minlonn .and. lonh3 .le. maxlonn)
   ndimh3  = dimsizes(indexhc)
   indexh3(0: (ndimh3-1)) = indexhc

   print("Total Selected Pixels = " + ndimh)
   do i = 0, ndimh-1
    m = i + 1
    print("Now processing Pixel = " + m + " Of " + ndimh)
    do j = 0, nprofile1-1
     stmp1 = new((/nblock1/), string,  bv0)
     do j1 = 0, nblock1-1
      tmp       = getbitsone(vfmh(indexh(i), nblock1*j+j1))
      stmp1(j1) = str_concat(tostring(tmp(0, :)))
      delete([/tmp/])
     end do
     svfmh1((indexh(i)*nprofile1+j):(indexh(i)*nprofile1+j), :) = (/stmp1/)
    end do
    do k = 0, nprofile2-1
     stmp2 = new((/nblock2/), string,  bv0)
     do k1 = 0, nblock2-1
      tmp       = getbitsone(vfmh(indexh(i), nprofile1a*nblock1+nblock2*k+k1))
      stmp2(k1) = str_concat(tostring(tmp(0, :)))
      delete([/tmp/])
     end do
     svfmh2((indexh(i)*nprofile2+k):(indexh(i)*nprofile2+k), :) = (/stmp2/)
    end do
    do l = 0, nprofile3-1
     stmp3 = new((/nblock3/), string,  bv0)
     do l1 = 0, nblock3-1
      tmp1      = vfmh(indexh(i), nprofile1a*nblock1+nprofile2a*nblock2+nblock3*l+l1)
      tmp2      = getbitsone(tmp1)
      stmp3(l1) = str_concat(tostring(tmp2(0, :)))
      delete([/tmp1, tmp2/])
     end do
     svfmh3((indexh(i)*nprofile3+l):(indexh(i)*nprofile3+l), :) = (/stmp3/)
    end do
   end do

   oned_svfmh1 = ndtooned(svfmh1)
   oned_svfmh2 = ndtooned(svfmh2)
   oned_svfmh3 = ndtooned(svfmh3)
   ndim_svfmh1 = dimsizes(svfmh1)
   ndim_svfmh2 = dimsizes(svfmh2)
   ndim_svfmh3 = dimsizes(svfmh3)

;  EXTRACT FEATURE TYPE (BITS 1-3) AND FEATURE SUBTYPE (BITS 10-12)
   svfmh1_ft   = str_get_cols(oned_svfmh1, 13, 15)
   svfmh1_fst  = str_get_cols(oned_svfmh1, 4,   6)
   svfmh1_tqa  = str_get_cols(oned_svfmh1, 3,   3)
   svfmh2_ft   = str_get_cols(oned_svfmh2, 13, 15)
   svfmh2_fst  = str_get_cols(oned_svfmh2, 4,   6)
   svfmh2_tqa  = str_get_cols(oned_svfmh2, 3,   3)
   svfmh3_ft   = str_get_cols(oned_svfmh3, 13, 15)
   svfmh3_fst  = str_get_cols(oned_svfmh3, 4,   6)
   svfmh3_tqa  = str_get_cols(oned_svfmh3, 3,   3)
;  print(oned_svfmh3 + "==" + svfmh3_tqa + "==" + svfmh3_fst + "==" + svfmh3_ft)

;  GET INDEX FOR DIFFERENT AEROSOL SUBTYPE
;  FOR TOP LAYER
   print("-------------------------------------------------")
   print("Start to Process Block #1")
   system("date")
;  0 : NOT DETERMINED
   index1_nda   = ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "000" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_nda)))
    index1_nd   = ind_resolve(index1_nda, ndim_svfmh1)
    nd = dimsizes(index1_nda)
    do i = 0, nd-1
     vfmh1(index1_nd(i, 0), index1_nd(i, 1))      = 0
    end do
    delete([/index1_nd/])
   end if
;  1 : CLEAN MARINE
   index1_cma   = ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "001" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_cma)))
    index1_cm   = ind_resolve(index1_cma, ndim_svfmh1) 
    nd = dimsizes(index1_cma)
    do i = 0, nd-1
     vfmh1(index1_cm(i, 0), index1_cm(i, 1))      = 1
    end do
    delete([/index1_cm/])
   end if
;  2 : DUST
   index1_dusta = ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "010" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_dusta)))
    index1_dust = ind_resolve(index1_dusta, ndim_svfmh1) 
    nd = dimsizes(index1_dusta)
    do i = 0, nd-1
     vfmh1(index1_dust(i, 0), index1_dust(i, 1))  = 2
    end do
    delete([/index1_dust/])
   end if
;  3 : POLLUTED CONTINENTAL
   index1_pca   = ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "011" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_pca)))
    index1_pc   = ind_resolve(index1_pca, ndim_svfmh1) 
    nd = dimsizes(index1_pca)
    do i = 0, nd-1
     vfmh1(index1_pc(i, 0), index1_pc(i, 1))      = 3
    end do
    delete([/index1_pc/])
   end if
;  4 : CLEAN CONTINENTAL
   index1_cca   = ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "100" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_cca)))
    index1_cc   = ind_resolve(index1_cca, ndim_svfmh1) 
    nd = dimsizes(index1_cca)
    do i = 0, nd-1
     vfmh1(index1_cc(i, 0), index1_cc(i, 1))      = 4
    end do
    delete([/index1_cc/])
   end if
;  5 : POLLUTED DUST
   index1_pda   = ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "101" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_pda)))
    index1_pd   = ind_resolve(index1_pda, ndim_svfmh1) 
    nd = dimsizes(index1_pda)
    do i = 0, nd-1
     vfmh1(index1_pd(i, 0), index1_pd(i, 1))      = 5
    end do
    delete([/index1_pda/])
   end if
;  6 : SMOKE
   index1_smokea= ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "110" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_smokea)))
    index1_smoke= ind_resolve(index1_smokea, ndim_svfmh1) 
    nd = dimsizes(index1_smokea)
    do i = 0, nd-1
     vfmh1(index1_smoke(i, 0), index1_smoke(i, 1))= 6
    end do
    delete([/index1_smoke/])
   end if
;  7 : OTHER
   index1_othera= ind(svfmh1_ft  .eq. "011" .and. \
                      svfmh1_fst .eq. "111" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_othera)))
    index1_other= ind_resolve(index1_othera, ndim_svfmh1) 
    nd = dimsizes(index1_othera)
    do i = 0, nd-1
     vfmh1(index1_other(i, 0), index1_other(i, 1))= 7
    end do
    delete([/index1_other/])
   end if
;  8 : CLOUD
   index1_clouda= ind(svfmh1_ft  .eq. "010" .and. \
                      svfmh1_tqa .eq. "1")
   if (.not.all(ismissing(index1_clouda)))
    index1_cloud= ind_resolve(index1_clouda, ndim_svfmh1)
    nd = dimsizes(index1_clouda)
    do i = 0, nd-1
     vfmh1(index1_cloud(i, 0), index1_cloud(i, 1))= 8
    end do
    delete([/index1_cloud/])
   end if
;  _FillValue : NAN
   index1_nana  = ind(svfmh1_ft  .ne. "011" .and. \
                      svfmh1_ft  .ne. "010")
   if (.not.all(ismissing(index1_nana)))
    index1_nan  = ind_resolve(index1_nana, ndim_svfmh1)
    nd = dimsizes(index1_nana)
    do i = 0, nd-1
     vfmh1(index1_nan(i, 0), index1_nan(i, 1))    = bv1
    end do
    delete([/index1_nan/])
   end if

;  FOR THE MIDDLE LAYER
   print("-------------------------------------------------")
   print("Start to Process Block #2")
   system("date")
;  0 : NOT DETERMINED
   index2_nda   = ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "000" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_nda)))
    index2_nd   = ind_resolve(index2_nda, ndim_svfmh2)
    nd = dimsizes(index2_nda)
    do i = 0, nd-1
     vfmh2(index2_nd(i, 0), index2_nd(i, 1))      = 0
    end do
    delete([/index2_nd/])
   end if
;  1 : CLEAN MARINE
   index2_cma   = ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "001" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_cma)))
    index2_cm   = ind_resolve(index2_cma, ndim_svfmh2)
    nd = dimsizes(index2_cma)
    do i = 0, nd-1
     vfmh2(index2_cm(i, 0), index2_cm(i, 1))      = 1
    end do
    delete([/index2_cm/])
   end if
;  2 : DUST
   index2_dusta = ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "010" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_dusta)))
    index2_dust = ind_resolve(index2_dusta, ndim_svfmh2)
    nd = dimsizes(index2_dusta)
    do i = 0, nd-1
     vfmh2(index2_dust(i, 0), index2_dust(i, 1))  = 2
    end do
    delete([/index2_dust/])
   end if
;  3 : POLLUTED CONTINENTAL
   index2_pca   = ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "011" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_pca)))
    index2_pc   = ind_resolve(index2_pca, ndim_svfmh2)
    nd = dimsizes(index2_pca)
    do i = 0, nd-1
     vfmh2(index2_pc(i, 0), index2_pc(i, 1))      = 3
    end do
    delete([/index2_pc/])
   end if
;  4 : CLEAN CONTINENTAL
   index2_cca   = ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "100" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_cca)))
    index2_cc   = ind_resolve(index2_cca, ndim_svfmh2)
    nd = dimsizes(index2_cca)
    do i = 0, nd-1
     vfmh2(index2_cc(i, 0), index2_cc(i, 1))      = 4
    end do
    delete([/index2_cc/])
   end if
;  5 : POLLUTED DUST
   index2_pda   = ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "101" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_pda)))
    index2_pd   = ind_resolve(index2_pda, ndim_svfmh2)
    nd = dimsizes(index2_pda)
    do i = 0, nd-1
     vfmh2(index2_pd(i, 0), index2_pd(i, 1))      = 5
    end do
    delete([/index2_pd/])
   end if
;  6 : SMOKE
   index2_smokea= ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "110" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_smokea)))
    index2_smoke= ind_resolve(index2_smokea, ndim_svfmh2)
    nd = dimsizes(index2_smokea)
    do i = 0, nd-1
     vfmh2(index2_smoke(i, 0), index2_smoke(i, 1))= 6
    end do
    delete([/index2_smoke/])
   end if
;  7 : OTHER
   index2_othera= ind(svfmh2_ft  .eq. "011" .and. \
                      svfmh2_fst .eq. "111" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_othera)))
    index2_other= ind_resolve(index2_othera, ndim_svfmh2)
    nd = dimsizes(index2_othera)
    do i = 0, nd-1
     vfmh2(index2_other(i, 0), index2_other(i, 1))= 7
    end do
    delete([/index2_other/])
   end if
;  8 : CLOUD
   index2_clouda= ind(svfmh2_ft  .eq. "010" .and. \
                      svfmh2_tqa .eq. "1")
   if (.not.all(ismissing(index2_clouda)))
    index2_cloud= ind_resolve(index2_clouda, ndim_svfmh2)
    nd = dimsizes(index2_clouda)
    do i = 0, nd-1
     vfmh2(index2_cloud(i, 0), index2_cloud(i, 1))= 8
    end do
    delete([/index2_cloud/])
   end if
;  _FillValue : NAN
   index2_nana  = ind(svfmh2_ft  .ne. "011" .and. \
                      svfmh2_ft  .ne. "010")
   if (.not.all(ismissing(index2_nana)))
    index2_nan  = ind_resolve(index2_nana, ndim_svfmh2)
    nd = dimsizes(index2_nana)
    do i = 0, nd-1
     vfmh2(index2_nan(i, 0), index2_nan(i, 1))    = bv1
    end do
    delete([/index2_nan/])
   end if

;  FOR THE BOTTOM LAYER
   print("-------------------------------------------------")
   print("Start to Process Block #3")
   system("date")
;  0 : NOT DETERMINED
   index3_nda   = ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "000" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_nda)))
    index3_nd   = ind_resolve(index3_nda, ndim_svfmh3)
    nd = dimsizes(index3_nda)
    do i = 0, nd-1
     vfmh3(index3_nd(i, 0), index3_nd(i, 1))      = 0
    end do
    delete([/index3_nd/])
   end if
;  1 : CLEAN MARINE
   index3_cma   = ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "001" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_cma)))
    index3_cm   = ind_resolve(index3_cma, ndim_svfmh3)
    nd = dimsizes(index3_cma)
    do i = 0, nd-1
     vfmh3(index3_cm(i, 0), index3_cm(i, 1))      = 1
    end do
    delete([/index3_cm/])
   end if
;  2 : DUST
   index3_dusta = ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "010" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_dusta)))
    index3_dust = ind_resolve(index3_dusta, ndim_svfmh3)
    nd = dimsizes(index3_dusta)
    do i = 0, nd-1
     vfmh3(index3_dust(i, 0), index3_dust(i, 1))   = 2
    end do
    delete([/index3_dust/])
   end if
;  3 : POLLUTED CONTINENTAL
   index3_pca   = ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "011" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_pca)))
    index3_pc   = ind_resolve(index3_pca, ndim_svfmh3)
    nd = dimsizes(index3_pca)
    do i = 0, nd-1
     vfmh3(index3_pc(i, 0), index3_pc(i, 1))      = 3
    end do
    delete([/index3_pc/])
   end if
;  4 : CLEAN CONTINENTAL
   index3_cca   = ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "100" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_cca)))
    index3_cc   = ind_resolve(index3_cca, ndim_svfmh3)
    nd = dimsizes(index3_cca)
    do i = 0, nd-1
     vfmh3(index3_cc(i, 0), index3_cc(i, 1))      = 4
    end do
    delete([/index3_cc/])
   end if
;  5 : POLLUTED DUST
   index3_pda   = ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "101" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_pda)))
    index3_pd   = ind_resolve(index3_pda, ndim_svfmh3)
    nd = dimsizes(index3_pda)
    do i = 0, nd-1
     vfmh3(index3_pd(i, 0), index3_pd(i, 1))      = 5
    end do
    delete([/index3_pd/])
   end if
;  6 : SMOKE
   index3_smokea= ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "110" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_smokea)))
    index3_smoke= ind_resolve(index3_smokea, ndim_svfmh3)
    nd = dimsizes(index3_smokea)
    do i = 0, nd-1
     vfmh3(index3_smoke(i, 0), index3_smoke(i, 1))= 6
    end do
    delete([/index3_smoke/])
   end if
;  7 : OTHER
   index3_othera= ind(svfmh3_ft  .eq. "011" .and. \
                      svfmh3_fst .eq. "111" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_othera)))
    index3_other= ind_resolve(index3_othera, ndim_svfmh3)
    nd = dimsizes(index3_othera)
    do i = 0, nd-1
     vfmh3(index3_other(i, 0), index3_other(i, 1))= 7
    end do
    delete([/index3_other/])
   end if
;  8 : CLOUD
   index3_clouda= ind(svfmh3_ft  .eq. "010" .and. \
                      svfmh3_tqa .eq. "1")
   if (.not.all(ismissing(index3_clouda)))
    index3_cloud= ind_resolve(index3_clouda, ndim_svfmh3)
    nd = dimsizes(index3_clouda)
    do i = 0, nd-1
     vfmh3(index3_cloud(i, 0), index3_cloud(i, 1))= 8
    end do
    delete([/index3_cloud/])
   end if
;  _FillValue : NAN
   index3_nana  = ind(svfmh3_ft  .ne. "011" .and. \
                      svfmh3_ft  .ne. "010")
   if (.not.all(ismissing(index3_nana)))
    index3_nan  = ind_resolve(index3_nana, ndim_svfmh3)
    nd = dimsizes(index3_nana)
    do i = 0, nd-1
     vfmh3(index3_nan(i, 0), index3_nan(i, 1))    = bv1
    end do
    delete([/index3_nan/])
   end if

   print("-------------------------------------------------")
   print("Finish to Process Block #1-3")
   system("date")

   delete([/indexh, indexha, indexhb, indexhc/])
   delete([/index1_nda, index1_cma, index1_dusta, index1_pca, index1_cca, \
            index1_pda, index1_smokea, index1_othera, index1_clouda, index1_nana, \
            index2_nda, index2_cma, index2_dusta, index2_pca, index2_cca, \
            index2_pda, index2_smokea, index2_othera, index2_clouda, index2_nana, \
            index3_nda, index3_cma, index3_dusta, index3_pca, index3_cca, \
            index3_pda, index3_smokea, index3_othera, index3_clouda, index3_nana/])

;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "read_calipso_l2_vfm.ncl", 0)

return
end
