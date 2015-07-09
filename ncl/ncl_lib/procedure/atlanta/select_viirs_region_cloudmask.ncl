;  $ID: select_viirs_region_cloudmask.ncl V01 02/24/2013 11:27 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_viirs_region_cloudmask SELECTS THE VIIRS DATA IN A 
;  SPECIFIC REGION LIMITATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/24/2013)
;******************************************************************************
undef("select_viirs_region_cloudmask")
procedure select_viirs_region_cloudmask \
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
   index1     = ind(oned_lat   .ge. minlat .and. \
                    oned_lat   .le. maxlat .and. \
                    oned_lon   .ge. minlon .and. \
                    oned_lon   .le. maxlon)
   if (.not.all(ismissing(index1))) then
    nindex1            = dimsizes(index1)
    print("TOTAL PIXEL : " + nindex1)
    slat(0:nindex1-1)  = oned_lat(index1)
    slon(0:nindex1-1)  = oned_lon(index1)
    data2(0:nindex1-1) = oned_data1(index1)
    dataa              = floattoint(data2)
    datab              = ndectobin(dataa)
    sdatab             = tostring(datab)
    sdatac             = str_get_cols(sdatab, 0, 1)
    index2 = ind(sdatac .eq. "11" .or. \
                 sdatac .eq. "10")
    if (.not.all(ismissing(index2))) then
     data2(index2) = 0
print(dataa(index2(0)))
print(datab(index2(0)))
print(sdatac(index2(0)))
    end if
    delete([/index2/])
    index2 = ind(sdatac .eq. "00" .or. \
                 sdatac .eq. "01")
    if (.not.all(ismissing(index2))) then
     data2(index2) = 1
    end if
    delete([/index2/])
   end if
   delete([/index1/])
end
