;  $ID: nc_merge_2file.ncl V01 09/13/2012 10:04 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM nc_merge_2file READS AND MERGE WRFCHEM OUTPUT .nc FILES, WITH 
;  SELECTED VARIABLES
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/13/2012)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv1       = -9999.
   bv2       = -9999
   nfv       = "No_FillValue"
   str       = "string"

;  READ WRFCHEM OUTPUT NC FILE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn      = "/mnt/sdc/wrfout_sahel_85_smoke_650/wrfout/"
   filelistn = "2008_wrfout_d01"
   namen     = asciiread(dirn+filelistn, -1, str)
   nfnamen   = dimsizes(namen)
   daten     = new((/nfnamen/), string, nfv)
   timen     = new((/nfnamen/), string, nfv)

   dirn2     = "/mnt/sdc/wrfout_sahel_85_smoke_dust_650/"
   filelistn2= "2008_wrfout_d01"
   namen2    = asciiread(dirn2+filelistn2, -1, str)
   datestrlen= 19
   daten     = new((/nfnamen/), string, nfv)
   diro      = "./"

;  READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
   do i = 0, nfnamen-1
    daten(i)     = str_get_cols(namen(i), 11, 29)
   end do 

;  READ VARIABLES AND WRITE TO A NEW .nc FILE
   do i = 0, nfnamen-1
    fn       = addfile(dirn + namen(i), "r")
    fn2      = addfile(dirn2 +namen2(i), "r")
    time     = fn->Times
    print("NOW WORKING ON : " + time)
    pm25n    = fn->PM2_5_DRY
    lat      = fn->XLAT
    lon      = fn->XLONG
    u        = fn->U
    v        = fn->V
    w        = fn->W
    hgt      = fn->HGT
    t        = fn->T
    p        = fn->P
    ph       = fn->PH
    pb       = fn->PB
    phb      = fn->PHB
    dust1    = fn2->DUST_1
    dust2    = fn2->DUST_2
    dust3    = fn2->DUST_3
    pm25nd   = fn2->PM2_5_DRY
    pm25nd   = dust1 + dust2 + dust3
    ndim     = dimsizes(pm25n)
    nlevel   = ndim(1)
    nlat     = ndim(2)
    nlon     = ndim(3)

;   OPEN AND WRITE OUTPUT FILE
    fileo    = namen(i)
    system("/bin/rm -f " + diro + fileo)
    fout     = addfile(fileo, "c")
;   EXPLICITLY DECLARE FILE DEFINITION MODE. IMPROVE EFFICIENCY
    setfileoption(fout, "DefineMode", True)
;   CREATE GLOBAL ATTRIBUTES OF THE FILE
    fAtt              = True
    fAtt@TITLE        = "OUTPUT FROM WRF V3.3 MODEL"
    fAtt@START_DATE   = "2008-02-01_00:00:00"
    fAtt@SIMULATION_START_DATE = "2008-02-01_00:00:00"
    fAtt@DX = 85000.
    fAtt@DY = 85000.
    fAtt@GRIDTYPE = "C" 
    fAtt@DIFF_OPT = 1 
    fAtt@KM_OPT = 4 
    fAtt@DAMP_OPT = 0 
    fAtt@DAMPCOEF = 0.2
    fAtt@KHDIF = 0.
    fAtt@KVDIF = 0.
    fAtt@MP_PHYSICS = 2 
    fAtt@RA_LW_PHYSICS = 1 
    fAtt@RA_SW_PHYSICS = 2 
    fAtt@SF_SFCLAY_PHYSICS = 1 
    fAtt@SF_SURFACE_PHYSICS = 2 
    fAtt@BL_PBL_PHYSICS = 1 
    fAtt@CU_PHYSICS = 1 
    fAtt@SURFACE_INPUT_SOURCE = 1 
    fAtt@SST_UPDATE = 0 
    fAtt@GRID_FDDA = 0 
    fAtt@GFDDA_INTERVAL_M = 0 
    fAtt@GFDDA_END_H = 0 
    fAtt@GRID_SFDDA = 0 
    fAtt@SGFDDA_INTERVAL_M = 0 
    fAtt@SGFDDA_END_H = 0 
    fAtt@SF_URBAN_PHYSICS = 0 
    fAtt@FEEDBACK = 1 
    fAtt@SMOOTH_OPTION = 0 
    fAtt@SWRAD_SCAT = 1.
    fAtt@W_DAMPING = 0 
    fAtt@MOIST_ADV_OPT = 1 
    fAtt@SCALAR_ADV_OPT = 1 
    fAtt@TKE_ADV_OPT = 1 
    fAtt@DIFF_6TH_OPT = 0 
    fAtt@DIFF_6TH_FACTOR = 0.12
    fAtt@OBS_NUDGE_OPT = 0 
    fAtt@GRID_ID = 1 
    fAtt@PARENT_ID = 0 
    fAtt@I_PARENT_START = 1 
    fAtt@J_PARENT_START = 1 
    fAtt@PARENT_GRID_RATIO = 1 
    fAtt@DT = 180.
    fAtt@CEN_LAT = 10.11407 
    fAtt@CEN_LON = 11.69699 
    fAtt@TRUELAT1 = 10.114 
    fAtt@TRUELAT2 = 10.114
    fAtt@MOAD_CEN_LAT = 10.11407
    fAtt@STAND_LON = 11.697
    fAtt@POLE_LAT = 90.
    fAtt@POLE_LON = 0.
    fAtt@GMT = 0.
    fAtt@JULYR = 2008 
    fAtt@JULDAY = 14 
    fAtt@MAP_PROJ = 1 
    fAtt@MMINLU = "USGS" 
    fAtt@NUM_LAND_CAT = 24 
    fAtt@ISWATER = 16 
    fAtt@ISLAKE = -1 
    fAtt@ISICE = 24 
    fAtt@ISURBAN = 1 
    fAtt@ISOILWATER = 14 
    fileattdef(fout, fAtt)

;   PREDEFINE DIMENSIONS
    dimNames = (/"Time", "DateStrLen", "west_east", "south_north",    \
                 "bottom_top", "bottom_top_stag", "soil_layers_stag", \
                 "west_east_stag", "force_layers", "south_north_stag",\
                 "dust_erosion_dimension", "emissions_zdim"/)
    dimSizes = (/1,      datestrlen,   nlon,        nlat,  \
                 nlevel, 28, 4, 100, 8, 74, 3, 19/)
    dimUnlim = (/False,    False,        False,       False, \
                 False, False, False, False, False, False, False, False/)
    filedimdef(fout, dimNames, dimSizes, dimUnlim)

;   PREDEFINE THE DIMENSIONALITY OF THE VARIABLES TO BE WRITTEN OUT
    filevardef(fout, "Times", typeof(time),   getvardims(time))
    filevardef(fout, "XLAT",  typeof(lat),    getvardims(lat))
    filevardef(fout, "XLONG", typeof(lon),    getvardims(lon))
    filevardef(fout, "U",     typeof(u),      getvardims(u))
    filevardef(fout, "V",     typeof(v),      getvardims(v))
    filevardef(fout, "W",     typeof(w),      getvardims(w))
    filevardef(fout, "HGT",   typeof(hgt),    getvardims(hgt))
    filevardef(fout, "T",     typeof(t),      getvardims(t))
    filevardef(fout, "P",     typeof(p),      getvardims(p))
    filevardef(fout, "PH",    typeof(ph),     getvardims(ph))
    filevardef(fout, "PB",    typeof(pb),     getvardims(pb))
    filevardef(fout, "PHB",   typeof(phb),    getvardims(phb))
    filevardef(fout, "Smoke", typeof(pm25n),  getvardims(pm25n))
    filevardef(fout, "Dust",  typeof(pm25nd), getvardims(pm25nd))

;   COPY ATTRIBUTES ASSOCIATED WITH EACH VARIABLES TO THE FILE
    filevarattdef(fout, "Times",  time)
    filevarattdef(fout, "XLAT",  lat)
    filevarattdef(fout, "XLONG", lon)
    filevarattdef(fout, "U",     u)
    filevarattdef(fout, "V",     v)
    filevarattdef(fout, "W",     w)
    filevarattdef(fout, "HGT",   hgt)
    filevarattdef(fout, "T",     t)
    filevarattdef(fout, "P",     p)
    filevarattdef(fout, "PH",    ph)
    filevarattdef(fout, "PHB",   phb)
    filevarattdef(fout, "PB",    pb)
    filevarattdef(fout, "Smoke", pm25n)
    filevarattdef(fout, "Dust",  pm25nd)

;   EXPLICITLY EXIT FILE DENIFITION MODE
    setfileoption(fout, "DefineMode", False)

;   OUTPUT ONLY THE DATA VALUE
    fout->Times   = (/time/)
    fout->XLAT    = (/lat/)
    fout->XLONG   = (/lon/)
    fout->U       = (/u/)
    fout->V       = (/v/)
    fout->W       = (/w/)
    fout->HGT     = (/hgt/)
    fout->T       = (/t/)
    fout->P       = (/p/)
    fout->PH      = (/ph/)
    fout->PB      = (/pb/)
    fout->PHB     = (/phb/)
    fout->Smoke   = (/pm25n/)
    fout->Dust    = (/pm25nd/)
   end do

end
