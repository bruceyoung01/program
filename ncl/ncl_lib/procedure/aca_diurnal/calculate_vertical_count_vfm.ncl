;  ID: calculate_vertical_count_vfm.ncl V01 11/21/2015 15:21 ZHIFENG YANG EXP$
;
;******************************************************************************
;  PROCEDURE calculate_vertical_count_vfm.ncl INCLUDES THE FOLLOWING STEPS:
;  (1 ) SELECTS THE PARTS OF TRACK IN THE STUDY REGION;
;  (2 ) PARTITIONS THE VERTICAL PROFILE INTO VARIOUS PARTS;
;  (3 ) FILTERS THE DATA WITH VARIOUS FLAGS, SUCH AS 
;        A) FEATURE TYPE (BITS: 1-3);
;        B) FEATURE TYPE QA (4-5);
;        C) ICE/WATER PHASE (6-7);
;        D) ICE/WATER PHASE QA (8-9);
;        E) FEATURE SUBTYPE (10-12);
;        F) CLOUD/AEROSOL/PSC TYPE QA (13);
;        G) HORIZONTAL AVERAGING REQUIRED FOR DETECTION (14-16).
;  (4 ) COUNTS THE NUMBER OF AEROSOL AND CLOUD IN EACH LAYER 
;
;  TABLE: Profile Spatial Resolution 
;  Altitude Region Vertical
;  Base (km) 	Top (km) Resolution(meters) Horizontal Resolution(meters) \
;  Profiles per 5km Samples per Profile
;  -0.5 	8.2 	30 	333 	15 	290
;   8.2 	20.2 	60 	1000 	5 	200
;  20.2 	30.1 	180 	1667 	3 	55
;  Total 					545
;
;  VARIABLES:
;  ============================================================================
;  (1 ) minlat (scalar):MINIMUM LATITUDE                                  [DEG]
;  (2 ) maxlat (scalar):MAXIMUM LATITUDE                                  [DEG]
;  (3 ) minlon (scalar):MINIMUM LONGITUDE                                 [DEG]
;  (4 ) maxlon (scalar):MAXIMUM LONGITUDE                                 [DEG]
;  (5 ) lat       (1-D):CALIPSO GROUND TRACK LATITUDE                     [DEG]
;  (6 ) lon       (1-D):CALIPSO GROUND TRACK LONGITUDE                    [DEG]
;  (7 ) dnf       (1-D):DAY OR NIGHT FLAG                                 [   ]
;  (8 ) lwm       (1-D):LAND OR WATER MASK                                [   ]
;  (9 ) fcf       (2-D):FEATURE CLASSIFICATION FLAG                       [   ]
;  (10) ninterval (scalar):LAYER NUMBER OF THE FIRST LAYER WITH 30m RESOLUTION
;  (11) sday_or_night (string):REQUIRED DAY OR NIGHT TIME                 [   ]
;  (12) land_or_water (integer):REQUIRED LAND OR WATER MASK               [   ]
;  (13) count_aerosol (integer):TOTAL NUMBER OF AEROSOL DETECTION IN EACH LAYER
;  (14) count_cloud   (integer):TOTAL NUMBER OF CLOUD DETECTION IN EACH LAYER
;  (15) count_ac      (integer):TOTAL NUMBER OF AEROSOL AND CLOUD DETECTION 
;                               IN EACH LAYER
;
;  NOTES:
;  ============================================================================
;  (1 ) INITIALLY WRITTEN BY ZHIFENG YANG. (11/21/2015)
;  (2 ) LAND-WATER MASK:
;       0 = shallow ocean
;       1 = land
;       2 = coastlines
;       3 = shallow inland water
;       4 = intermittent water
;       5 = deep inland water
;       6 = continental ocean
;       7 = deep ocean
;  (3 ) FOR MORE INFORMATION ABOUT THE CALIPSO PRODUCT, PLEASE REFER TO 
;       http://www-calipso.larc.nasa.gov/resources/calipso_users_guide/data_summaries/vfm/index.php
;******************************************************************************

undef("calculate_vertical_count_vfm")
procedure calculate_vertical_count_vfm \
          (minlat         :float,   maxlat       :float,   \ ;INPUT
           minlon         :float,   maxlon       :float,   \ ;INPUT
           lat            :float,   lon          :float,   \ ;INPUT
           tpoint_aerosol :integer, tpoint_cloud :integer, \ ;INPUT
           dnf            :integer, lwm          :integer, \ ;INPUT
           fcf            :numeric, ninterval    :integer, \ ;INPUT
           sday_or_night  :string,  land_or_water:integer, \ ;INPUT
           count_aerosol  :integer, count_cloud  :integer, \ ;OUTPUT
           count_ac       :integer)                          ;OUTPUT

begin

;  CONVERT THE sday_or_night FROM STRING TO INTEGER
   if (sday_or_night .eq. "D") then
      day_or_night = 0
   else
      day_or_night = 1
   end if

;  THE LOWEST LAYER INFO
   dim       = dimsizes(fcf)
   nvertical = dim(0)
   point     = 1165

;  TRUNCATE THE GROUND TRACK ONLY FOR THE STUDY REGION
   index = ind(lat .ge. minlat .and. \
               lat .le. maxlat .and. \
               lon .ge. minlon .and. \
               lon .le. maxlon)
;print("a0" + index)
;  IF THE TRACK IS IN THE STUDY REGION, CONTINUE TO PROCESS
   if (.not.all(ismissing(index))) then
;print("a1")
      nindex = dimsizes(index)
;  DO THE SELECTED GROUND TRACK POINTS LOOP
      do iindex = 0, nindex-1
;print("a2" + iindex)
;  FOR DAY TIME OR NIGHT TIME
         if (dnf(index(iindex)) .eq. day_or_night) then
;print("a3")
;  FOR LAND WATER MASK
            if (lwm(index(iindex)) .eq. land_or_water) then
;print("a4")
;  DO THE VERTICAL POINTS LOOP
               do ipoint = nvertical-1, point, ninterval
                  do ispoint = 0, ninterval-1
                     spoint      = ipoint - ispoint
;print("a9" + spoint)
;  CONVERT INTEGER TO BIT
                     fcf_bit     = getbitsone(fcf(index(iindex), spoint))
                     tmp_fcf_bit = flt2string(byte2flt(fcf_bit(0, :)))
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  CONVERT BIT TO INTEGER
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  TYPE
;print("a5" + tmp_fcf_bit(0:2))
                     type        = bintoint(str_concat(tmp_fcf_bit(0:2)))
;print("a6" + type)
;printVarSummary(type)
;  TYPE QA
                     type_qa     = bintoint(str_concat(tmp_fcf_bit(3:4)))
;  ICE/WATER PHASE
                     iwp         = bintoint(str_concat(tmp_fcf_bit(5:6)))
;  ICE/WATER PHASE QA
                     iwp_qa      = bintoint(str_concat(tmp_fcf_bit(7:8)))
;  SUBTYPE
                     subtype     = bintoint(str_concat(tmp_fcf_bit(9:11)))
;  SUBTYPE QA
                     subtype_qa  = bintoint(str_concat(tmp_fcf_bit(12)))
;  HORIZONTAL AVERAGE
                     ha          = bintoint(str_concat(tmp_fcf_bit(13:15)))
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  COUNT THE NUMBER SATISFYING THE FOLLOWING CRITERIA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  AERSOL
                     if (type   .eq. 3 .and. \
                        type_qa .eq. 2 .or.  \
                        type_qa .eq. 3) then
                        count_aerosol(ispoint) = count_aerosol(ispoint) + 1
print("aerosol = " + ispoint + "  " + count_aerosol(ispoint))
;  CLOUD
                     else if (type   .eq. 2 .and. \
                             type_qa .eq. 2 .or.  \
                             type_qa .eq. 3) then
                        count_cloud(ispoint) = count_cloud(ispoint) + 1
print("cloud = " + ispoint + "  " + count_cloud(ispoint))
                     end if
                     end if
                  end do ;ispoint
print("a7")
               end do ;ipoint
print("a8")
            end if ;lwm(index(iindex))
         end if ;dnf(index(iindex))
      end do ;iindex
   end if ;.not.all(ismissing(index))




return
end
