;  $ID: collect_calipso_region_dn_filename.ncl V01 06/16/2015 11:53 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM collect_calipso_region_dn_filename COLLECTS ALL THE CALIPSO DATA IN THE 
;  STUDY REGION FOR DAY TIME OR NIGHT TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) cdir   (a string) :CALIPSO DATA DIRECTORY                         [   ]
;  (2 ) scfilename  (1-D) :CALIPSO FILE NAMES IN A DAY                    [   ]
;  (3 ) siyear (a string) :YEAR IN WHICH CALIPSO DATA ARE                 [   ]
;  (4 ) sday_or_night (a string):DAY OR NIGHT                             [   ]
;  (5 ) minlat   (scalar) :MINIMUM LATITUDE OF STUDY REGION               [DEG]
;  (6 ) maxlat   (scalar) :MAXIMUM LATITUDE OF STUDY REGION               [DEG]
;  (7 ) minlon   (scalar) :MINIMUM LONGITUDE OF STUDY REGION              [DEG]
;  (8 ) maxlon   (scalar) :MAXIMUM LONGITUDE OF STUDY REGION              [DEG]
;  (9 ) scfilename_region (1-D) :FILE NAMES IN THE STUDY REGION           [   ]
;  (10) logic_scfilename_region (a logical) :CHECK WHETHER FILE NAMES EXIST[  ]
;  (11) nctrack_real (scalar) :THE NUMBER OF EXISTING FILE NAMES          [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/16/2015)
;******************************************************************************

undef("collect_calipso_region_dn_filename")
procedure collect_calipso_region_dn_filename \
          (cdir             :string, scfilename             :string,  \;INPUT
           siyear           :string, sday_or_night          :string,  \;INPUT
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
               if (isdefined("clat") .and. isdefined("clon")) then
                  delete([/clat, clon/])
               end if
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
                  cday_or_night = str_get_cols(scfilename(icfilename), -5, -5)
                  if (sday_or_night .eq. cday_or_night) then
                     scfilename_region(ictrack) = scfilename(icfilename)
                     print("Selected track : " + scfilename(icfilename))
                     logic_scfilename_region = True
                     ictrack = ictrack + 1
                  end if
                  delete([/index/])
               end if
; GET THE TOTAL NUMBER OF SELECTED FILE NAMES IF EXISTING
               nctrack_real = dimsizes(ind(.not.ismissing(scfilename_region)))
            end do
return
end
