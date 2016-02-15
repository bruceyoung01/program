;  $ID: joint_histogram_modis_mod08_m3.ncl V01 02/10/2016 18:07 ZHIFENG YANG EXP$
;
;******************************************************************************
;  PROGRAM joint_histogram_modis_mod08_m3.ncl READS MODIS MOD08_M3/MYD08_M3 
;  DATA. THE PARAMETERS FROM THE DATA ARE:
;  (1 ). Cloud_Optical_Thickness_Liquid_JHisto_vs_Pressure
;  MODIS MOD08_M3/MYD08_M3 DATA PRODUCT FILE NAME:
;  MYD08_M3.A2013001.006.2014272180603.hdf
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) SETUP INFO FOR THE MODIS DATA, SUCH AS DIRECTORY, FILENAME AND VARIABLE 
;       NAME;
;  (2 ) DO YEAR, MONTH LOOP TO READ MODIS FILE NAME;
;  (3 ) PLOT MONTHLY AVERAGED COT VS CTP;
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (02/11/2016)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/function/int2string.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_modis_mod08_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_histogram_terra_cot_ctp_hist.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/joint_histogram_modis_mod08_m3/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_joint_histogram_modis_mod08_m3_Aqua_v02")
   gsn_define_colormap(wks,"MPL_gist_yarg")

;  DATA DIRECTORY
   wdir       = "/home/vy57456/zzbatmos_common/Data/MODIS/6/MYD08_M3/"
   filelist   = "filelist"
   sate       = "Aqua"
;==============================================================================
;  SETUP MISSING VALUES; STUDY REGION, AND PAPRAMETERS
;==============================================================================
;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.
   zero1      = 0
   zero2      = 0.0

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)
;  SWITCH FOR BACKGROUND MAP
   switch_pg  = True

;  ARRARY INDEX FOR THE STUDY REGION
   lat_start  = 80
   lat_end    = 119
   lon_start1 = 0
   lon_end1   = 19
   lon_start2 = 340
   lon_end2   = 359

;  SET UP THE START TIME AND END TIME
   start_year = 2013
   end_year   = 2014
   start_month= 7
   end_month  = 9
   start_day  = 1

;  DEFINE THE BIN BOUNDARIES
   COT_boundary = (/0.0, 2.0, 4.0, 6.0, 8.0, 10.0, 15.0, \
                   20.0, 30.0, 40.0, 50.0, 100.0, 150.0/)
   CTP_boundary = (/50.0, 250.0, 300.0, 350.0, 400.0,    \
                   450.0, 500.0, 550.0, 600.0, 700.0,    \
                   800.0, 900.0, 1000.0, 1100.0/)

   nCOT_boundary = dimsizes(COT_boundary)
   nCTP_boundary = dimsizes(CTP_boundary)

;  READ THE FILE DEPENDING ON THE YEAR, MONTH
;  DO YEAR LOOP
      cot_ctp_avg_norm_yearly = new((/nCTP_boundary-1, nCOT_boundary-1/), float, bv2)
      cot_ctp_avg_norm_yearly = 0.0
      ncount_yearly           = 0

   do iyear = start_year, end_year
      siyear  = sprinti("%0.4i", iyear)
      swdir   = wdir + siyear + "/"

;  DO MONTH LOOP
      do imonth = start_month, end_month
         simonth = sprinti("%0.2i", imonth)
         stime   = siyear + "-" + simonth
         print("Now Processing : " + stime)

         sfilename      = new((/1/), string)
         logic_filename = True
;  CONVERT iyear AND imonth INTO NUMBER OF DAY IN THE YEAR
         select_modis_mod08_filename                 \
         (swdir, filelist, iyear, imonth, start_day, \
         sfilename, logic_filename)

         if (.not.logic_filename) then
            print("NO DATA ON : " + stime)
            continue
         end if

;  READ PARAMETERS FROM THE MODIS HDF FILE
         a = addfile(swdir + sfilename + ".hdf", "r")
         cot_ctp = a->Cloud_Optical_Thickness_Liquid_JHisto_vs_Pressure

;  CALCULATE THE REGIONAL AVERAGE IN THE STUDY REGION
         cot_ctp_avg              = \
         (dim_avg_n_Wrap(cot_ctp(:, :, lat_start:lat_end, lon_start1:lon_end1), (/2, 3/)) + \
          dim_avg_n_Wrap(cot_ctp(:, :, lat_start:lat_end, lon_start2:lon_end2), (/2, 3/)))/2
         cot_ctp_avg_norm_monthly = 100*cot_ctp_avg/sum(cot_ctp_avg)
         cot_ctp_avg_norm_yearly  = cot_ctp_avg_norm_yearly + cot_ctp_avg_norm_monthly
         ncount_yearly            = ncount_yearly + 1

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT AND WRITE MONTHLY
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         stime_monthly = siyear + "_" + simonth
;  CALL SUBROUTINE plot_histogram_terra_cot_ctp_hist.ncl TO PLOT JOINT HISTOGRAM OF 
;  COT AND CTP
         plot_histogram_terra_cot_ctp_hist \
         (wks, COT_boundary, CTP_boundary, \
         cot_ctp_avg_norm_monthly, stime)

         if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
            polygon_map                           \
            (wks, minlat, maxlat, minlon, maxlon, \
            lat_pg, lon_pg)
         end if

;  WRITE JOINT HISTOGRAM INTO A TEXT FILE
         option        = True
         option@row    = False
         option@tspace = 0
         option@fout   = plot_dir + sate + "_" + "Monthly_" + stime_monthly + ".txt"
         write_matrix(cot_ctp_avg_norm_monthly, "12f10.5", option)

      end do ;imonth

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT AND WRITE YEARLY
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
      cot_ctp_avg_norm_yearly = cot_ctp_avg_norm_yearly/ncount_yearly
      stime_yearly            = siyear
;  CALL SUBROUTINE plot_histogram_terra_cot_ctp_hist.ncl TO PLOT JOINT HISTOGRAM OF 
;  COT AND CTP
      plot_histogram_terra_cot_ctp_hist \
      (wks, COT_boundary, CTP_boundary, \
      cot_ctp_avg_norm_yearly, stime)

      if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
         polygon_map                           \
         (wks, minlat, maxlat, minlon, maxlon, \
         lat_pg, lon_pg)
      end if

;  WRITE JOINT HISTOGRAM INTO A TEXT FILE
      option        = True
      option@row    = False
      option@tspace = 0
      option@fout   = plot_dir + sate + "_" + "Yearly_" + stime_yearly + ".txt"
      write_matrix(cot_ctp_avg_norm_yearly, "12f10.5", option)

   end do ;iyear

end
