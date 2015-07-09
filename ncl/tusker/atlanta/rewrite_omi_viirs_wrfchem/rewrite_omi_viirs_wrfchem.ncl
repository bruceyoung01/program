;  $ID: rewrite_omi_viirs_wrfchem.ncl V01 11/06/2012 10:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM rewrite_omi_viirs_wrfchem READS OMI SURFACE REFLECTANCE DATA 
;  (HDF), VIIRS TOA REFLECTANCE, GEOMETRY DATA (HDF), AND WRFCHEM NC FILE, 
;  AND MATCH THEM WITH EACH OTHER, AND FINALLY REWRITES THE CORRESPONDING 
;  DATA INTO ONE TXT FILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (11/06/2012)
;******************************************************************************

;  LOAD LIBRARIES AND FUNCTIONS
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "../../ncl_lib/procedure/atlanta/WRFUserARW.ncl"
load "../../ncl_lib/procedure/atlanta/convert_viirs_time.ncl"
load "../../ncl_lib/procedure/atlanta/convert_wrfchem_time.ncl"
load "../../ncl_lib/procedure/atlanta/convert_met_em_time.ncl"



begin
;  OMI DATA DIRECTORY AND FILE NAME
   omi_dir          ="/work/jwang7/bruceyoung01/parallel/data/atlanta/omi/"
   omi_filename     = "OMI-Aura_L3-OMLER_2005m01-2009m12_v003-2010m0503t063707.he5.h5"

;  VIIRS DATA DIRECTORY AND FILE LIST
   viirs_dir        = "/work/jwang7/bruceyoung01/parallel/data/atlanta/viirs/viirs_all_band/"
   viirs_filelistgm = "GMTCO.list"
   viirs_filenamegm = asciiread(viirs_dir + viirs_filelistgm, -1, "string")
   nviirs_filenamegm= dimsizes(viirs_filenamegm)
   viirs_filelistm1 = "SVM01.list"
   viirs_filenamem1 = asciiread(viirs_dir + viirs_filelistm1, -1, "string")
   nviirs_filenamem1= dimsizes(viirs_filenamem1)
   viirs_filelistm2 = "SVM02.list"
   viirs_filenamem2 = asciiread(viirs_dir + viirs_filelistm2, -1, "string")
   nviirs_filenamem2= dimsizes(viirs_filenamem2)
   viirs_filelistm3 = "SVM03.list"
   viirs_filenamem3 = asciiread(viirs_dir + viirs_filelistm3, -1, "string")
   nviirs_filenamem3= dimsizes(viirs_filenamem3)
   viirs_filelistm4 = "SVM04.list"
   viirs_filenamem4 = asciiread(viirs_dir + viirs_filelistm4, -1, "string")
   nviirs_filenamem4= dimsizes(viirs_filenamem4)
   viirs_filelistm5 = "SVM05.list"
   viirs_filenamem5 = asciiread(viirs_dir + viirs_filelistm5, -1, "string")
   nviirs_filenamem5= dimsizes(viirs_filenamem5)
   viirs_filelistm6 = "SVM06.list"
   viirs_filenamem6 = asciiread(viirs_dir + viirs_filelistm6, -1, "string")
   nviirs_filenamem6= dimsizes(viirs_filenamem6)
   viirs_filelistm7 = "SVM07.list"
   viirs_filenamem7 = asciiread(viirs_dir + viirs_filelistm7, -1, "string")
   nviirs_filenamem7= dimsizes(viirs_filenamem7)
   viirs_filelistgi = "GITCO.list"
   viirs_filenamegi = asciiread(viirs_dir + viirs_filelistgi, -1, "string")
   nviirs_filenamegi= dimsizes(viirs_filenamegi)
   viirs_filelisti1 = "SVI01.list"
   viirs_filenamei1 = asciiread(viirs_dir + viirs_filelisti1, -1, "string")
   nviirs_filenamei1= dimsizes(viirs_filenamei1)
   viirs_filelisti2 = "SVI02.list"
   viirs_filenamei2 = asciiread(viirs_dir + viirs_filelisti2, -1, "string")
   nviirs_filenamei2= dimsizes(viirs_filenamei2)

;  WRFCHEM DATA DIRECTORY AND FILE LIST
   wrfchem_dir      = "/shared/aerosol/bruceyoung01/data/wrf_output/wrfout_atlanta/"
   wrfchem_filelist = "2012_wrfout_d02"
   wrfchem_filename = asciiread(wrfchem_dir + wrfchem_filelist, -1, "string")
   nwrfchem_filename= dimsizes(wrfchem_filename)

;  met_em DATA DIRECTORY AND FILE LIST
   met_em_dir       = "/work/jwang7/bruceyoung01/parallel/data/wrf_input/met_em/201207_09_atlanta/"
   met_em_filelist  = "2012_met_em_d02"
   met_em_filename  = asciiread(met_em_dir + met_em_filelist, -1, "string")
   nmet_em_filename = dimsizes(met_em_filename)

;  READ SURFACE REFLECTANCE FROM OMI
   omi_data         = addfile(omi_dir + omi_filename, "r")
   grpname          = "/HDFEOS/GRIDS/EarthSurfaceReflectanceClimatology/Data Fields"
   grp              = omi_data=>$grpname$
   olat             = grp->Latitude
   olon             = grp->Longitude
   orefl_raw        = grp->MonthlySurfaceReflectance
   orefl_scale      = orefl_raw@ScaleFactor
   orefl_offset     = orefl_raw@Offset
   orefl            = orefl_raw*orefl_scale + orefl_offset
   nodim            = dimsizes(orefl_raw)
   nomon            = nodim(0)
   nowav            = nodim(1)
   nolat            = nodim(2)
   nolon            = nodim(3)

;  MISSING VALUE
   bv1              = -9999
   bv2              = -9999.
   factor1          = 4
   factor2          = 2
;  SET UP TIME
   start_year       = 2012
   end_year         = 2012
   start_month      = 8
   end_month        = 8
   start_day        = 1
   end_day          = 1
   start_hour       = 0
   end_hour         = 23

;  SET UP STUDY REGION
   atlanta_lat= 33.76
   atlanta_lon= -84.4
;  2500: 0.192
;  15: 0.015
   limit      = 0.015
   npixel     = 15
   nlevel     = 27
   nspe_ov    = 20
   nspe_w     = 12
   minlat     = atlanta_lat - limit
   maxlat     = atlanta_lat + limit
   minlon     = atlanta_lon - limit
   maxlon     = atlanta_lon + limit

;  VERTICAL LAYER REQUIREMENT
   minlevel   = 0.0
   maxlevel   = 15.0
   nptslevel  = 16
   height_int = (maxlevel-minlevel)/(nptslevel-1)
   height     = fspan(minlevel+0.5, maxlevel-0.5, nptslevel-1)
   height_rev = fspan(maxlevel, minlevel, nptslevel)
   km_to_m    = 1000.0

;  IDEAL (UNIVERSAL) GAS CONSTANT(J/(mol.K))
   Na         = 6.022^23
   R          = 8.31447
   Msulf      = 96
   Mno3       = 62
   Mc         = 12

;  CONVERT CALENDAR DATE TO JULIAN DATE
   start_jd   = doubletoint(greg2jul(start_year, start_month, start_day, end_hour))
   end_jd     = doubletoint(greg2jul(end_year, end_month, end_day, end_hour))

;  GET ALL THE HOUR NEEDED
   nhour      = (end_jd - start_jd + 1)*24

;  JUDGE WHETHER ALL THE VIIRS DATA HAVE THE SAME #
   if (nviirs_filenamegm .eq. nviirs_filenamegi .and. \
       nviirs_filenamegi .eq. nviirs_filenamem1 .and. \
       nviirs_filenamem1 .eq. nviirs_filenamem2 .and. \
       nviirs_filenamem2 .eq. nviirs_filenamem3 .and. \
       nviirs_filenamem3 .eq. nviirs_filenamem4 .and. \
       nviirs_filenamem4 .eq. nviirs_filenamem5 .and. \
       nviirs_filenamem5 .eq. nviirs_filenamem6 .and. \
       nviirs_filenamem6 .eq. nviirs_filenamei1 .and. \
       nviirs_filenamei1 .eq. nviirs_filenamei2) then
;   DECLARE ARRAY FOR PROCEDURE convert_viirs_time.ncl
    vyear  = new((/nviirs_filenamem1/), integer)
    vmonth = new((/nviirs_filenamem1/), integer)
    vday   = new((/nviirs_filenamem1/), integer)
    vhour  = new((/nviirs_filenamem1/), integer)

;   DECLARE ARRAY FOR PROCEDURE convert_wrfchem_time.ncl
    wyear  = new((/nwrfchem_filename/), integer)
    wmonth = new((/nwrfchem_filename/), integer)
    wday   = new((/nwrfchem_filename/), integer)
    whour  = new((/nwrfchem_filename/), integer)

;   DECLARE ARRAY FOR PROCEDURE convert_met_em_time.ncl
    myear  = new((/nmet_em_filename/), integer)
    mmonth = new((/nmet_em_filename/), integer)
    mday   = new((/nmet_em_filename/), integer)
    mhour  = new((/nmet_em_filename/), integer)

;   DECLARE ARRAY FOR WRITING THE DATA, INCLUDING OMI, VIIRS, AND WRFCHEM
;   DIMENSION IS AS FOLLOWING:
;   0 : TIME
;   1 : PIXEL
;   2 : SPECIES
    ov_data   = new((/nspe_ov, npixel/), float, bv2)
    outw_data = new((/nptslevel-1, nspe_w, npixel/), float, bv2)

;   CALL PROCEDURE convert_viirs_time.ncl TO GET TIME FROM VIIRS FILE NAME
    convert_viirs_time \
    (viirs_filenamem1, nviirs_filenamem1, vyear, vmonth, vday, vhour)

;   CALL PROCEDURE convert_wrfchem_time.ncl TO GET TIME FROM WRFCHEM FILE NAME
    convert_wrfchem_time \
    (wrfchem_filename, nwrfchem_filename, wyear, wmonth, wday, whour)

;   CALL PROCEDURE convert_met_em_time.ncl TO GET TIME FROM met_em FILE NAME
    convert_met_em_time \
    (met_em_filename, nmet_em_filename, myear, mmonth, mday, mhour)

;   DO THE TIME LOOP TO SELECT ALL CORRESPOND FILES
    do ijd = start_jd, end_jd
;   CONVERT JULIAN DAY TO CALENDAR
     idate  = jul2greg(ijd)
     iyear  = idate(0)
     imonth = idate(1)
     iday   = idate(2)
     itime  = 0
     print("NOW WORKING ON : " + iyear + "-" + imonth + "-" + \
           iday)
     do ihour = start_hour, end_hour
      vindex = ind(vyear  .eq. iyear  .and. \
                   vmonth .eq. imonth .and. \
                   vday   .eq. iday   .and. \
                   vhour  .eq. ihour)
      if (.not.all(ismissing(vindex))) then
       windex = ind(wyear  .eq. iyear  .and. \
                    wmonth .eq. imonth .and. \
                    wday   .eq. iday   .and. \
                    whour  .eq. ihour)
       mindex = ind(myear  .eq. iyear  .and. \
                    mmonth .eq. imonth .and. \
                    mday   .eq. iday   .and. \
                    mhour  .eq. ihour)

       if (.not.all(ismissing(windex)) .and. \
           .not.all(ismissing(mindex))) then
;   WRFCHEM DATA
        w_data      = addfile(wrfchem_dir + wrfchem_filename(windex) + ".nc", "r")
        wlat        = w_data->XLAT(0, :, :)
        wlon        = w_data->XLONG(0, :, :)
        wu          = w_data->U(0, :, :, :)
        wv          = w_data->V(0, :, :, :)
        ww          = w_data->W(0, :, :, :)
        wt          = w_data->T(0, :, :, :)
        wps         = w_data->PSFC(0, :, :)
        wpm25       = w_data->PM2_5_DRY(0, :, :, :)
        wpm10       = w_data->PM10(0, :, :, :)
        wso2        = w_data->so2(0, :, :, :)
        wsulf       = w_data->sulf(0, :, :, :)
        wnh3        = w_data->nh3(0, :, :, :)
        wn2o5       = w_data->n2o5(0, :, :, :)
        wno3        = w_data->no3(0, :, :, :)
        wso4ai      = w_data->so4ai(0, :, :, :)
        wso4aj      = w_data->so4aj(0, :, :, :)
        wno3ai      = w_data->no3ai(0, :, :, :)
        wno3aj      = w_data->no3aj(0, :, :, :)
        weci        = w_data->eci(0, :, :, :)
        wecj        = w_data->ecj(0, :, :, :)
        worgaro1j   = w_data->orgaro1j(0, :, :, :)
        worgaro1i   = w_data->orgaro1i(0, :, :, :)
        worgaro2j   = w_data->orgaro2j(0, :, :, :)
        worgaro2i   = w_data->orgaro2i(0, :, :, :)
        worgalk1j   = w_data->orgalk1j(0, :, :, :)
        worgalk1i   = w_data->orgalk1i(0, :, :, :)
        worgba1j    = w_data->orgba1j(0, :, :, :)
        worgba1i    = w_data->orgba1i(0, :, :, :)
        worgba2j    = w_data->orgba2j(0, :, :, :)
        worgba2i    = w_data->orgba2i(0, :, :, :)
        worgba3j    = w_data->orgba3j(0, :, :, :)
        worgba3i    = w_data->orgba3i(0, :, :, :)
        worgba4j    = w_data->orgba4j(0, :, :, :)
        worgba4i    = w_data->orgba4i(0, :, :, :)
        worgpaj     = w_data->orgpaj(0, :, :, :)
        worgpai     = w_data->orgpai(0, :, :, :)
        alt         = w_data->ALT(0, :, :, :)
        wz          = getvar(w_data, "z", 0)
        nwdim       = dimsizes(wpm25)
        nwlevel     = nwdim(0)
        nwlat       = nwdim(1)
        nwlon       = nwdim(2)
        alt         = 1/alt
        wsulf       = wso4ai + wso4aj
        wno3        = wno3ai + wno3aj
        weci        = weci + wecj
        worgaro1j   = worgaro1j + worgaro1i + worgaro2j + worgaro2i + \
                      worgalk1j + worgalk1i + worgba1j  + worgba1i  + \
                      worgba2j  + worgba2i  + worgba3j  + worgba3i  + \
                      worgba4j  + worgba4i  + worgpaj   + worgpai

;   met_em DATA
        m_data      = addfile(met_em_dir + met_em_filename(mindex) + ".nc", "r")
        mpres       = m_data->PRES(0, :, :, :)
        mt          = m_data->TT(0, :, :, :)
        mrh         = m_data->RH(0, :, :, :)
        mz          = m_data->GHT(0, :, :, :)

;   DECLARE NEW ARRAY FOR INTERPOLATED VARIABLES
        new_wpm25     = new((/nptslevel-1, nwlat, nwlon/), float)
        new_wpm10     = new((/nptslevel-1, nwlat, nwlon/), float)
        new_wsulf     = new((/nptslevel-1, nwlat, nwlon/), float)
        new_wno3      = new((/nptslevel-1, nwlat, nwlon/), float)
        new_weci      = new((/nptslevel-1, nwlat, nwlon/), float)
        new_woc       = new((/nptslevel-1, nwlat, nwlon/), float)
        new_wec       = new((/nptslevel-1, nwlat, nwlon/), float)
        new_airden    = new((/nptslevel-1, nwlat, nwlon/), float)
        new_airnden   = new((/nptslevel-1, nwlat, nwlon/), float)
        new_mpres     = new((/nptslevel-1, nwlat, nwlon/), float)
        new_mt        = new((/nptslevel-1, nwlat, nwlon/), float)
        new_mrh       = new((/nptslevel-1, nwlat, nwlon/), float)

;   INTERPOLATE THE RAW DATA TO THE NEW HEIGHT LEVEL
        do ih = 0, nptslevel-2
         new_wpm25(ih, :, :)  = wrf_user_intrp3d(wpm25,      wz, "h", height(ih)*km_to_m, 0., False)
         new_wpm10(ih, :, :)  = wrf_user_intrp3d(wpm10,      wz, "h", height(ih)*km_to_m, 0., False)
         new_wsulf(ih, :, :)  = wrf_user_intrp3d(wsulf,      wz, "h", height(ih)*km_to_m, 0., False)
         new_wno3(ih, :, :)   = wrf_user_intrp3d(wno3,       wz, "h", height(ih)*km_to_m, 0., False)
         new_wec(ih, :, :)    = wrf_user_intrp3d(weci,       wz, "h", height(ih)*km_to_m, 0., False)
         new_woc(ih, :, :)    = wrf_user_intrp3d(worgaro1j,  wz, "h", height(ih)*km_to_m, 0., False)
         new_airden(ih, :, :) = wrf_user_intrp3d(alt,        wz, "h", height(ih)*km_to_m, 0., False)
         new_mpres(ih, :, :)  = wrf_user_intrp3d(mpres,      mz, "h", height(ih)*km_to_m, 0., False)
         new_mt(ih, :, :)     = wrf_user_intrp3d(mt,         mz, "h", height(ih)*km_to_m, 0., False)
         new_mrh(ih, :, :)    = wrf_user_intrp3d(mrh,        mz, "h", height(ih)*km_to_m, 0., False)
        end do

;   CONVERT MIXING RATIO TO CONCENTRATION
        do ih = 0, nptslevel-2
         do ilat = 0, nwlat-1
          do ilon = 0, nwlon-1
;          new_wsulf(ih, ilat, ilon)   = new_mpres(ih, ilat, ilon)*new_wsulf(ih, ilat, ilon)*Msulf/(R*new_mt(ih, ilat, ilon))
;          new_wno3(ih, ilat, ilon)    = new_mpres(ih, ilat, ilon)*new_wno3(ih, ilat, ilon)*Mno3/(R*new_mt(ih, ilat, ilon))
           new_wsulf(ih, ilat, ilon)   = new_wsulf(ih, ilat, ilon)/new_airden(ih, ilat, ilon)
           new_wno3(ih, ilat, ilon)    = new_wno3(ih, ilat, ilon)/new_airden(ih, ilat, ilon)
           new_wec(ih, ilat, ilon)     = new_wec(ih, ilat, ilon)/new_airden(ih, ilat, ilon)
           new_woc(ih, ilat, ilon)     = new_woc(ih, ilat, ilon)/new_airden(ih, ilat, ilon)
           new_airnden(ih, ilat, ilon) = new_mpres(ih, ilat, ilon)*Na/(R*new_mt(ih, ilat, ilon))
           new_airden(ih, ilat, ilon)  = new_airden(ih, ilat, ilon)*height(ih)
          end do ; ilon
         end do ; ilat
        end do ; ih

        n_vindex = dimsizes(vindex)
        ipixel   = 0
        do igranule = 0, n_vindex-1
;   READ VIIRS DATA
;   M-BAND
         viirs_gm   = addfile(viirs_dir + viirs_filenamegm(vindex(igranule)), "r")
         vlatgm     = viirs_gm->Latitude
         vlongm     = viirs_gm->Longitude
         vszagm     = viirs_gm->SolarZenithAngle
         vsaagm     = viirs_gm->SolarAzimuthAngle
         vvzagm     = viirs_gm->SatelliteZenithAngle
         vvaagm     = viirs_gm->SatelliteAzimuthAngle
         vraz       = viirs_gm->SatelliteAzimuthAngle
         viirs_m1   = addfile(viirs_dir + viirs_filenamem1(vindex(igranule)), "r")
         vreflm1_raw= viirs_m1->Reflectance
         vreflm1_fac= viirs_m1->ReflectanceFactors
         vreflm1    = vreflm1_raw*vreflm1_fac(0) + vreflm1_fac(1)
         viirs_m2   = addfile(viirs_dir + viirs_filenamem2(vindex(igranule)), "r")
         vreflm2_raw= viirs_m2->Reflectance
         vreflm2_fac= viirs_m2->ReflectanceFactors
         vreflm2    = vreflm2_raw*vreflm2_fac(0) + vreflm2_fac(1)
         viirs_m3   = addfile(viirs_dir + viirs_filenamem3(vindex(igranule)), "r")
         vreflm3_raw= viirs_m3->Reflectance
         vreflm3_fac= viirs_m3->ReflectanceFactors
         vreflm3    = vreflm3_raw*vreflm3_fac(0) + vreflm3_fac(1)
         viirs_m4   = addfile(viirs_dir + viirs_filenamem4(vindex(igranule)), "r")
         vreflm4_raw= viirs_m4->Reflectance
         vreflm4_fac= viirs_m4->ReflectanceFactors
         vreflm4    = vreflm4_raw*vreflm4_fac(0) + vreflm4_fac(1)
         viirs_m5   = addfile(viirs_dir + viirs_filenamem5(vindex(igranule)), "r")
         vreflm5_raw= viirs_m5->Reflectance
         vreflm5_fac= viirs_m5->ReflectanceFactors
         vreflm5    = vreflm5_raw*vreflm5_fac(0) + vreflm5_fac(1)
         viirs_m6   = addfile(viirs_dir + viirs_filenamem6(vindex(igranule)), "r")
         vreflm6_raw= viirs_m6->Reflectance
         vreflm6_fac= viirs_m6->ReflectanceFactors
         vreflm6    = vreflm6_raw*vreflm6_fac(0) + vreflm6_fac(1)
;  I-BAND
         viirs_gi   = addfile(viirs_dir + viirs_filenamegi(vindex(igranule)), "r")
         vlatgi     = viirs_gi->Latitude
         vlongi     = viirs_gi->Longitude
         vszagi     = viirs_gi->SolarZenithAngle
         vsaagi     = viirs_gi->SolarAzimuthAngle
         vvzagi     = viirs_gi->SatelliteZenithAngle
         vvaagi     = viirs_gi->SatelliteAzimuthAngle
         viirs_i1   = addfile(viirs_dir + viirs_filenamei1(vindex(igranule)), "r")
         vrefli1_raw= viirs_i1->Reflectance
         vrefli1_fac= viirs_i1->ReflectanceFactors
         vrefli1    = vrefli1_raw*vrefli1_fac(0) + vrefli1_fac(1)
         viirs_i2   = addfile(viirs_dir + viirs_filenamei2(vindex(igranule)), "r")
         vrefli2_raw= viirs_i2->Reflectance
         vrefli2_fac= viirs_i2->ReflectanceFactors
         vrefli2    = vrefli2_raw*vrefli2_fac(0) + vrefli2_fac(1)

;  CALCULATE RELATIVE AZIMUTH ANGLE
         vmdim = dimsizes(vraz)
         do inp = 0, vmdim(0)-1
          do inl = 0, vmdim(0)-1
           if(vsaagm(inp,inl) .lt. 0.) then
            vsaagm(inp,inl) = 360.+ vsaagm(inp,inl)
           end if
           if(vvaagm(inp,inl) .lt. 0.) then
            vvaagm(inp,inl) = 360.+ vvaagm(inp,inl)
           end if
           vraz(inp,inl)  = abs(vsaagm(inp,inl)-vvaagm(inp,inl))
           if(vraz(inp,inl) .gt. 180.0) then
            vraz(inp,inl)=360.-vraz(inp,inl)
           end if
          end do
         end do

;  SELECT THE PIXEL IN THE STUDY REGION
;  M-BAND
         oned_vlatgm = ndtooned(vlatgm)
         oned_vlongm = ndtooned(vlongm)
         gmindex = ind(oned_vlatgm .ge. minlat .and. \
                       oned_vlatgm .le. maxlat .and. \
                       oned_vlongm .ge. minlon .and. \
                       oned_vlongm .le. maxlon)
         if (.not.all(ismissing(gmindex)) .and. \
             ipixel .lt. npixel) then
          print(iyear + "-" + imonth + "-" + iday + "-" + ihour + ":00:00")
          print("# of selected pixel for granule " + igranule + " : " + dimsizes(gmindex))
          gmindex2  = ind_resolve(gmindex, dimsizes(vlatgm))
          n_gmindex = dimsizes(gmindex)
          do igmindex = 0, n_gmindex-1
           ; ASSIGN VIIRS DATA TO ALL DATA ARRAY
           system("date")
           print("Processing pixel  :  " + igmindex + " of " + n_gmindex)
           if (ipixel + igmindex .lt. npixel) then
            ov_data(0, (ipixel + igmindex)) = \
            vlatgm(gmindex2(igmindex, 0), gmindex2(igmindex, 1))
            ov_data(1, (ipixel + igmindex)) = \
            vlongm(gmindex2(igmindex, 0), gmindex2(igmindex, 1))
            ov_data(2, (ipixel + igmindex)) = \
            vszagm(gmindex2(igmindex, 0), gmindex2(igmindex, 1))
            ov_data(3, (ipixel + igmindex)) = \
            vsaagm(gmindex2(igmindex, 0), gmindex2(igmindex, 1))
            ov_data(4, (ipixel + igmindex)) = \
            vvzagm(gmindex2(igmindex, 0), gmindex2(igmindex, 1))
            ov_data(5, (ipixel + igmindex)) = \
            vvaagm(gmindex2(igmindex, 0), gmindex2(igmindex, 1))
            ov_data(6, (ipixel + igmindex)) = \
            vraz  (gmindex2(igmindex, 0), gmindex2(igmindex, 1))
            ov_data(7, (ipixel + igmindex)) = \
            (/vreflm1(gmindex2(igmindex, 0), gmindex2(igmindex, 1))/)
            ov_data(8, (ipixel + igmindex)) = \
            (/vreflm2(gmindex2(igmindex, 0), gmindex2(igmindex, 1))/)
            ov_data(9, (ipixel + igmindex)) = \
            (/vreflm3(gmindex2(igmindex, 0), gmindex2(igmindex, 1))/)
            ov_data(10, (ipixel + igmindex)) = \
            (/vreflm4(gmindex2(igmindex, 0), gmindex2(igmindex, 1))/)
            ov_data(11, (ipixel + igmindex)) = \
            (/vreflm5(gmindex2(igmindex, 0), gmindex2(igmindex, 1))/)
            ov_data(12, (ipixel + igmindex)) = \
            (/vreflm6(gmindex2(igmindex, 0), gmindex2(igmindex, 1))/)
            ov_data(13, (ipixel + igmindex)) = \
            (/vrefli1(2*gmindex2(igmindex, 0), 2*gmindex2(igmindex, 1))/)
            ov_data(14, (ipixel + igmindex)) = \
            (/vrefli2(2*gmindex2(igmindex, 0), 2*gmindex2(igmindex, 1))/)


            ; SELECT OMI GRID BOX DEPENDING ON VIIRS DATA
            do iolat = 0, nolat-2
             do iolon = 0, nolon-2
              if (vlatgm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .ge. olat(iolat)   .and. \
                  vlatgm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .le. olat(iolat+1) .and. \
                  vlongm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .ge. olon(iolon)   .and. \
                  vlongm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .ge. olon(iolon+1)) then
               ov_data(15, (ipixel + igmindex)) = (/orefl(imonth-1, 10, iolat, iolon)/)
               ov_data(16, (ipixel + igmindex)) = (/orefl(imonth-1, 11, iolat, iolon)/)
               ov_data(17, (ipixel + igmindex)) = (/orefl(imonth-1, 15, iolat, iolon)/)
               ov_data(18, (ipixel + igmindex)) = (/orefl(imonth-1, 16, iolat, iolon)/)
               ov_data(19, (ipixel + igmindex)) = (/orefl(imonth-1, 20, iolat, iolon)/)
              end if
             end do ; iolat
            end do ; iolon
            ; SELECT WRFCHEM GRID BOX BASED ON VIIRS DATA
            do iwlat = 0, nwlat-2
             do iwlon = 0, nwlon-2
              if (vlatgm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .ge. wlat(iwlat, iwlon)   .and. \
                  vlatgm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .le. wlat(iwlat+1, iwlon) .and. \
                  vlongm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .ge. wlon(iwlat, iwlon)   .and. \
                  vlongm(gmindex2(igmindex, 0), gmindex2(igmindex, 1)) .ge. wlon(iwlat, iwlon+1)) then
               outw_data(:, 0,  (ipixel + igmindex)) = (/wps(iwlat, iwlon)/)
               outw_data(:, 1,  (ipixel + igmindex)) = (/new_mpres(:, iwlat, iwlon)/)
               outw_data(:, 2,  (ipixel + igmindex)) = (/new_mt(:, iwlat, iwlon)/)
               outw_data(:, 3,  (ipixel + igmindex)) = (/new_mrh(:, iwlat, iwlon)/)
               outw_data(:, 4,  (ipixel + igmindex)) = (/new_airnden(:, iwlat, iwlon)/)
               outw_data(:, 5,  (ipixel + igmindex)) = (/new_airden(:, iwlat, iwlon)/)
               outw_data(:, 6,  (ipixel + igmindex)) = (/height_int/)
               outw_data(:, 7,  (ipixel + igmindex)) = (/new_wpm25(:, iwlat, iwlon)/)
               outw_data(:, 8,  (ipixel + igmindex)) = (/new_wpm10(:, iwlat, iwlon)/)
               outw_data(:, 9,  (ipixel + igmindex)) = ((/new_wsulf(:, iwlat, iwlon)/) + (/new_wno3(:, iwlat, iwlon)/))*factor1
               outw_data(:, 10, (ipixel + igmindex)) = ((/new_wec(:, iwlat, iwlon)/))*factor2
               outw_data(:, 11, (ipixel + igmindex)) = ((/new_woc(:, iwlat, iwlon)/))*factor2
;              outw_data(:, 12, (ipixel + igmindex)) = (/height_rev/)
              end if
             end do ; END OF iwlon
            end do ; END OF iwlat
           end if
          end do ; END OF igmindex
          ipixel = ipixel + n_gmindex
          delete([/gmindex2/])
         end if
         delete([/gmindex/])
        end do ; END OF igranule
        print("TOTAL SELECTED PIXEL : " + ipixel)
        print("STARTING TO WRITE ASCII DATA")
        ov_output = "OMI_VIIRS_" + str_get_cols(wrfchem_filename(windex), 11, 23) + ".txt"
        w_output  = "WRFCHEM_"   + str_get_cols(wrfchem_filename(windex), 11, 23) + ".txt"
        asciiwrite(ov_output, ov_data)
        asciiwrite(w_output,  outw_data)
        print(outw_data(:, 9,  :))
        print(outw_data(:, 10,  :))
        print(outw_data(:, 11,  :))
       end if
       delete([/windex/])
      end if
      delete([/vindex/])
     end do ; END OF ihour
     itime = itime + 1
    end do ; END OF ijd

   else
    print("VIIRS data files do not match !!!")
   end if

end
