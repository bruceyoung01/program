;  $ID: select_viirs_region.ncl V01 02/24/2013 11:27 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_viirs_region SELECTS THE VIIRS DATA IN A SPECIFIC REGION 
;  LIMITATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/24/2013)
;******************************************************************************
undef("select_viirs_region")
procedure select_viirs_region \
         (minlat      :float,      maxlat       :float, \; INPUT
          minlon      :float,      maxlon       :float, \; INPUT
          lat         :float,      lon          :float, \; INPUT
          data1       :float,                           \; INPUT
          slat        :float,      slon         :float, \; INPUT
          data2       :float)                            ; OUTPUT

begin
   oned_lat   = ndtooned(lat)
   oned_lon   = ndtooned(lon)
   oned_data1 = ndtooned(data1)
   index1     = ind(oned_lat .ge. minlat .and. \
                    oned_lat .le. maxlat .and. \
                    oned_lon .ge. minlon .and. \
                    oned_lon .le. maxlon)
   if (.not.all(ismissing(index1))) then
    nindex1            = dimsizes(index1)
    print("TOTAL PIXEL : " + nindex1)
    slat(0:nindex1-1)  = oned_lat(index1)
    slon(0:nindex1-1)  = oned_lon(index1)
    data2(0:nindex1-1) = oned_data1(index1)
   end if
   delete([/index1/])
end
