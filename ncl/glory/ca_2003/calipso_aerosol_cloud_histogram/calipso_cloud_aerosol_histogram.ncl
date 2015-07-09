; $ID calipso_cloud_aerosol.ncl, V01 12/01/2011 12:56 BRUCE EXP$
;
;******************************************************************************
; PROGRAM calipso_cloud_aerosol IS TO COLLECT THE FOLLOWING FOUR SITUATIONS 
; ON HOW TO DISTINGUISH CLOUD AND AEROSOL FROM CALIPSO LEVEL 2 DATA(
; CAL_LID_L2_05kmAPro-Prov-V3-01)
; (1 ) FROM TOP TO BOTTOM : NA-AEROSOL-CLOUD-NA
; (2 ) FROM TOP TO BOTTOM : NA-CLOUD-AEROSOL-CLOUD-NA
; (3 ) FROM TOP TO BOTTOM : NA-CLOUD-AEROSOL-CLOUD-AEROSOL-NA
; (4 ) OTHERS
;
; NOTES:
; =============================================================================
; (1 ) ORIGINALLY WRITTEN BY BRUCE. (12/01/2011)
;******************************************************************************
;
; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"

begin

; SET UP THE PLOT WORKSTATION
; type     = "x11"
  type     = "pdf"
  plot_name= "1plt_calipso_cloud_aerosol_histogram"
  wks      = gsn_open_wks(type, plot_name)
  gsn_define_colormap(wks, "BlAqGrYeOrReVi200")

; DEFINE UNIVERSAL SYMBOLS AND CONSTANTS
  nfv = "No_FillValue"
  str = "string"

; READ THE CALIPSO LEVEL 2 DATA : CAL_LID_L2_05kmAPro-Prov-V3-01
  cdir     = "/home/bruce/sshfs/pfw/satellite/CALIPSO/sahel/2008/CAL_LID_L2_05kmAPro-Prov-V3-01/"
  cfilelist= "CAL_LID_L2_05kmAPro-Prov-V3-01"
  cname    = asciiread(cdir+cfilelist, -1, str)
  ncname   = dimsizes(cname)

; DEFINE BAD VALUE
  bv1    = -599.94
  bv2    = -9997.
  n_layer= 399
; SEAS : 20N~10S, 95E~125E
; SAHEL: 35N~15S, 25W~30E
  maxlat =  10.0
  minlat = -10.0
  maxlon =  30.0
  minlon = -25.0

  nttype0 = 0 ; NA
  nttype1 = 0 ; NA-AEROSOL-NA
  nttype2 = 0 ; NA-AEROSOL-CLOUD-NA
  nttype3 = 0 ; NA-CLOUD-NA
  nttype4 = 0 ; NA-CLOUD-AEROSOL-NA
  nttype5 = 0 ; NA-CLOUD-AEROSOL-CLOUD-NA
  nttype6 = 0 ; NA-CLOUD-AEROSOL-CLOUD-AEROSOL-NA

; CALIPSO DATA LOOP
  do i = 0, ncname-1
   cdata = addfile(cdir+cname(i), "r")
   clat  = cdata->Latitude
   clon  = cdata->Longitude
   cec   = cdata->Extinction_Coefficient_532
   cclf  = cdata->Cloud_Layer_Fraction
   ndim  = dimsizes(clat)
   time  = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)
   dateh = str_get_cols(cname(i), 31, 40)
   timeh = str_get_cols(cname(i), 42, 43)
   print("WORKING ON : "+time)
   system("date")

; DEFINE DAYTIME OR NIGHTTIME FOR CALIPSO
   dornh = str_get_cols(cname(i), 51, 51)
   if(dornh .eq. "D")then
    dntime= " Daytime "
   else
    dntime= " Nighttime "
   end if

; SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION
   nclat  = new((/ndim(0)/), float, bv2)
   nclon  = new((/ndim(0)/), float, bv2)
   ncec   = new((/ndim(0), n_layer/), float, bv1)
   ncclf  = new((/ndim(0), n_layer/), float, bv1)
   nclat  = clat(:,0)
   nclon  = clon(:,0)
   ncec   = cec(:,:)
   ncclf  = cclf(:,:)
   index  = ind(nclat .gt. minlat .and. nclat .lt. maxlat .and. \
                nclon .gt. minlon .and. nclon .lt. maxlon)
   if (dimsizes(index) .gt. 1 .and. .not.all(ismissing(index))) then
   nnclat = nclat(index)
   nnclon = nclon(index)
   nncec  = ncec(index,:)
   nncclf = ncclf(index,:)
   nndim  = dimsizes(nnclat)
   nncclfec= new((/nndim(0), n_layer/), float, bv1)

; MERGE AEROSOL AND CLOUND FEATURE MASK INTO ONE ARRAY
   do j = 0, nndim(0)-1
    do k = 0, n_layer-1
     if (nncec(j,k) .ge. 0.0) then
      nncec(j,k) = 1.0
     end if
     if (nncclf(j,k) .ge. 0.0) then
      nncclf(j,k) = 2.0
     end if
    end do ; END OF J LOOP
   end do ; END OF K LOOP

   nncclfec = nncec + nncclf
   do j = 0, nndim(0)-1
    do k = 0, n_layer-1
     if (.not.ismissing(nncclfec(j,k)) .and. nncclfec(j,k) .eq. 3.0) then
      nncclfec(j,k) = bv2
     end if 
    end do ; END OF J LOOP
   end do ; END OF K LOOP

; COUNT THE NUMBER OF DIFFERENT CONDITIONS
   ntype0 = 0 ; NA
   ntype1 = 0 ; NA-AEROSOL-NA
   ntype2 = 0 ; NA-AEROSOL-CLOUD-NA
   ntype3 = 0 ; NA-CLOUD-NA
   ntype4 = 0 ; NA-CLOUD-AEROSOL-NA
   ntype5 = 0 ; NA-CLOUD-AEROSOL-CLOUD-NA
   ntype6 = 0 ; NA-CLOUD-AEROSOL-CLOUD-AEROSOL-NA
   do j = 0, nndim(0)-1
    type0 = 0
    type1 = 0
    type2 = 0
    type3 = 0
    type4 = 0
    type5 = 0
    type6 = 0
    do k = 0, n_layer-1
; JUDGE TYPE1
     if (.not.ismissing(nncclfec(j,k)) .and. nncclfec(j,k) .lt. 1.0) then
      type1 = 1
     end if
; JUDGE TYPE2
     if (.not.ismissing(nncclfec(j,k)) .and. nncclfec(j,k) .gt. 1.0 .and. type1 .eq. 1) then
      type2 = 1
     end if
; JUDGE TYPE3
     if (.not.ismissing(nncclfec(j,k)) .and. nncclfec(j,k) .gt. 1.0) then
      type3 = 1
     end if
; JUDGE TYPE4
     if (.not.ismissing(nncclfec(j,k)) .and. nncclfec(j,k) .lt. 1.0 .and. type3 .eq. 1) then
      type4 = 1
     end if
; JUDGE TYPE5
     if (.not.ismissing(nncclfec(j,k)) .and. nncclfec(j,k) .gt. 1.0 .and. type4 .eq. 1) then
      type5 = 1
     end if
; JUDGE TYPE6
     if (.not.ismissing(nncclfec(j,k)) .and. nncclfec(j,k) .lt. 1.0 .and. type5 .eq. 1) then
      type6 = 1
     end if
    end do
; COUNT THE NUMBER OF TYPE1
    if (type1 .eq. 1 .and. type2 .eq. 0) then
     ntype1 = ntype1 + 1
    end if
; COUNT THE NUMBER OF TYPE2
    if (type1 .eq. 1 .and. type2 .eq. 1) then
     ntype2 = ntype2 + 1
    end if
; COUNT THE NUMBER OF TYPE3
    if (type3 .eq. 1 .and. type4 .eq. 0) then
     ntype3 = ntype3 + 1
    end if
; COUNT THE NUMBER OF TYPE4
    if (type3 .eq. 1 .and. type4 .eq. 1 .and. type5 .eq. 0) then
     ntype4 = ntype4 + 1
    end if
; COUNT THE NUMBER OF TYPE5
    if (type3 .eq. 1 .and. type5 .eq. 1 .and. type6 .eq. 0) then
     ntype5 = ntype5 + 1
    end if
; COUNT THE NUMBER OF TYPE6
    if (type3 .eq. 1 .and. type6 .eq. 1) then
     ntype6 = ntype6 + 1
    end if
    if (type1 .eq. 0 .and.\
        type2 .eq. 0 .and.\
        type3 .eq. 0 .and.\
        type4 .eq. 0 .and.\
        type5 .eq. 0 .and.\
        type6 .eq. 0 ) then
     ntype0 = ntype0 + 1
    end if
   end do
   nttype0 = nttype0 + ntype0
   nttype1 = nttype1 + ntype1
   nttype2 = nttype2 + ntype2
   nttype3 = nttype3 + ntype3
   nttype4 = nttype4 + ntype4
   nttype5 = nttype5 + ntype5
   nttype6 = nttype6 + ntype6
   delete(nnclat)
   delete(nnclon)
   delete(nncec)
   delete(nncclf)
   delete(nncclfec)
   end if
   delete(clat)
   delete(clon)
   delete(cec)
   delete(cclf)
   delete(nclat)
   delete(nclon)
   delete(ncec)
   delete(ncclf)
   delete(index)
   end do ; END OF I LOOP
   tnttype  = int2flt(nttype0+nttype1+nttype2+nttype3+nttype5)
   fnttype0 = nttype0/tnttype
   fnttype1 = nttype1/tnttype
   fnttype2 = nttype2/tnttype
   fnttype3 = nttype3/tnttype
   fnttype4 = nttype4/tnttype
   fnttype5 = nttype5/tnttype
   fnttype6 = nttype6/tnttype
   npts     = 7
   fnttype  = new((/npts/), float, bv2)
;  fnttype  = (/fnttype0,fnttype1,fnttype2,fnttype3,fnttype4,fnttype5,fnttype6/)*100
;  fnttype  = (/3.6, 54.1, 2.8, 1.4, 36.3, 1.2, 0.6/)
;  find     = ind(fnttype .lt. 1.0)
;  fnttype(find) = 0.1
   xlabel   = (/"N", "NAN", "NACN", "NCN", "NCAN", "NCACN", "NCACA"/)

; PLOT THE HISTOGRAM
   bres                       = True
   bres@gsnDraw               = True
   bres@gsnFrame              = True
   bres@gsnXYBarChart         = True
   bres@gsnXYBarChartBarWidth = 0.3
   bres@trXMinF               = 0.0
   bres@trXMaxF               = 8
   bres@trYMinF               = 0.1
   bres@trYMaxF               = 110
   bres@trYAxisType           = "LogAxis"
   bres@tiXAxisString         = "Category"
   bres@tiYAxisString         = "Frequency(%)"
   bres@tiMainString          = "2008 Frequency"
   bres@tmXBMode              = "Explicit"
   bres@tmXBValues            = ispan(1, npts, 1)
   bres@tmXBLabels            = xlabel
   bres@tmXBMajorThicknessF   = 0.5
   bres@tmYLMajorThicknessF   = 0.5
   bres@gsnXYBarChartColors   = (/"black"/)
   bres@gsnXYBarChartPatterns = 6
; SET INITIAL WIDTH AND HEIGHT
   bres@vpHeightF             = 0.4
   bres@vpWidthF              = 0.8
   bres@vpXF                  = 0.15
   bres@vpYF                  = 0.7
   plot1 = gsn_csm_xy(wks, fspan(0.98, npts-0.02, npts), fnttype, bres)
   system("date")

end
