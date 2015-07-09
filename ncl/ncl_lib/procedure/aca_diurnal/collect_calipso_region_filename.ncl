;  $ID: collect_calipso_region_filename.ncl V01 06/16/2015 11:53 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM collect_calipso_region_filename COLLECTS ALL THE CALIPSO DATA IN THE 
;  STUDY REGION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) cdir   (a string) :CALIPSO DATA DIRECTORY                         [   ]
;  (2 ) scfilename  (1-D) :CALIPSO FILE NAMES IN A DAY                    [   ]
;  (3 ) siyear (a string) :YEAR IN WHICH CALIPSO DATA ARE                 [   ]
;  (4 ) minlat   (scalar) :MINIMUM LATITUDE OF STUDY REGION               [DEG]
;  (5 ) maxlat   (scalar) :MAXIMUM LATITUDE OF STUDY REGION               [DEG]
;  (6 ) minlon   (scalar) :MINIMUM LONGITUDE OF STUDY REGION              [DEG]
;  (7 ) maxlon   (scalar) :MAXIMUM LONGITUDE OF STUDY REGION              [DEG]
;  (8 ) scfilename_region (1-D) :FILE NAMES IN THE STUDY REGION           [   ]
;  (9 ) logic_scfilename_region (a logical) :CHECK WHETHER FILE NAMES EXIST[  ]
;  (10) nctrack_real (scalar) :THE NUMBER OF EXISTING FILE NAMES          [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/16/2015)
;******************************************************************************

undef("collect_calipso_region_filename")
procedure collect_calipso_region_filename \
          (cdir             :string, scfilename             :string,  \;INPUT
           siyear           :string,                                  \;INPUT
           minlat           :float,  maxlat                 :float,   \;INPUT
           minlon           :float,  maxlon                 :float,   \;INPUT
           scfilename_region:string, logic_scfilename_region:logical, \;OUTPUT
           nctrack_real     :integer)                                  ;OUTPUT

begin

;  READ CALIPSO VARIABLES FROM FILENAME
            ncfilename = dimsizes(ind(.not.ismissing(scfilename)))
            ictrack    = 0
            do icfilename = 0, ncfilename-1
               a    = addfile(cdir + siyear + "/" + scfilename(icfilename), "r")
               clat = a->Latitude
               clon = a->Longitude
;  CHECK WHETHER THE CALIPSO IN THE STUDY REGION
               index = ind(clat(:, 1) .ge. minlat .and. \
                           clat(:, 1) .le. maxlat .and. \
                           clon(:, 1) .ge. minlon .and. \
                           clon(:, 1) .le. maxlon)
               if (all(ismissing(index))) then
                  delete([/index/])
               else
                  scfilename_region(ictrack) = scfilename(icfilename)
                  print("Selected track : " + scfilename(icfilename))
                  logic_scfilename_region = True
                  ictrack = ictrack + 1
                  delete([/index/])
               end if
; GET THE TOTAL NUMBER OF SELECTED FILE NAMES IF EXISTING
               nctrack_real = dimsizes(ind(.not.ismissing(scfilename_region)))
            end do
return
end
