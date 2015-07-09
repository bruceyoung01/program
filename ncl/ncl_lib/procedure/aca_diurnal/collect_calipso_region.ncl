;  $ID: collect_calipso_region.ncl V01 06/16/2015 11:53 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM collect_calipso_region COLLECTS ALL THE CALIPSO DATA IN THE STUDY 
;  REGION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) cdir   (a string) :CALIPSO DATA DIRECTORY                         [   ]
;  (2 ) scfilename  (1-D) :CALIPSO FILE NAMES IN A DAY                    [   ]
;  (3 ) siyear (a string) :YEAR IN WHICH CALIPSO DATA ARE                 [   ]
;  (4 ) minlat   (scalar) :MINIMUM LATITUDE OF STUDY REGION               [   ]
;  (5 ) maxlat   (scalar) :MAXIMUM LATITUDE OF STUDY REGION               [   ]
;  (6 ) minlon   (scalar) :MINIMUM LONGITUDE OF STUDY REGION              [   ]
;  (7 ) maxlon   (scalar) :MAXIMUM LONGITUDE OF STUDY REGION              [   ]
;  (8 ) tclat       (2-D) :ALL THE LATITUDE OF CALIPSO GROUND TRACK IN THE 
;                          STUDY REGION                                   [   ]
;  (9 ) tclon       (2-D) :ALL THE LONGITUDE OF CALIPSO GROUND TRACK IN THE 
;                          STUDY REGION                                   [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/16/2015)
;******************************************************************************

undef("collect_calipso_region")
procedure collect_calipso_region \
          (cdir         :string,  scfilename     :string,  \ ;INPUT
           siyear       :string,                           \ ;INPUT
           minlat       :float,   maxlat         :float,   \ ;INPUT
           minlon       :float,   maxlon         :float,   \ ;INPUT
           tclat        :float,   tclon          :float)     ;OUTPUT

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
                  ndim_clat = dimsizes(clat)
                  nclat     = ndim_clat(0)
                  tclat(0:nclat-1, ictrack) = clat(:, 1)
                  tclon(0:nclat-1, ictrack) = clon(:, 1)
                  print("Selected track : " + scfilename(icfilename))
                  ictrack = ictrack + 1
                  delete([/index/])
               end if

            end do
return
end
