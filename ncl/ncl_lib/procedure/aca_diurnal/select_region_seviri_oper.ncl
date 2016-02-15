;  $ID: select_region_seviri_oper.ncl V01 02/14/2016 23:03 ZHIFENG YANG EXP$
;
;******************************************************************************
;  PROCEDURE select_region_seviri_oper.ncl SELECTS DATA BASED ON THE LIMITED 
;  REGION LATITUDE AND LONGITUDE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) minlat    (a scalar): MINIMUM LATITUDE IN THE STUDY REGION        [DEG]
;  (2 ) maxlat    (a scalar): MAXIMUM LATITUDE IN THE STUDY REGION        [DEG]
;  (3 ) minlon    (a scalar): MINIMUM LONGITUDE IN THE STUDY REGION       [DEG]
;  (4 ) maxlon    (a scalar): MAXIMUM LONGITUDE IN THE STUDY REGION       [DEG]
;  (5 ) lat       (N-D)     : LATITUDE                                    [DEG]
;  (6 ) lon       (N-D)     : LONGITUDE                                   [DEG]
;  (7 ) data1     (N-D)     : DATA 1                                      [   ]
;  (8 ) data2     (N-D)     : DATA 2                                      [   ]
;  (9 ) sdata1    (N-D)     : SELECTED DATA 1                             [   ]
;  (10) sdata1    (N-D)     : SELECTED DATA 2                             [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY ZHIFENG YANG. (02/14/2016)
;******************************************************************************
;
undef("select_region_seviri_oper")
procedure select_region_seviri_oper \
          (minlat       :float, maxlat       :float, \ ;INPUT
           minlon       :float, maxlon       :float, \ ;INPUT
           lat          :float, lon          :float, \ ;INPUT
           data1        :float, data2        :float, \ ;INPUT
           sdata1       :float, sdata2       :float)   ;OUTPUT

begin
;  CONVERT DATA INTO ONE-DIMENSIONAL ARRAY
   oned_lat  = ndtooned(lat)
   oned_lon  = ndtooned(lon)
   oned_data1= ndtooned(data1)
   oned_data2= ndtooned(data2)

;  SELECT THE INDEX WITHIN THE STUDY REGION
   index = ind(oned_lat .ge. minlat       .and. \
               oned_lat .le. maxlat       .and. \
               oned_lon .ge. minlon       .and. \
               oned_lon .le. maxlon       .and. \
               .not.ismissing(oned_data1) .and. \
               .not.ismissing(oned_data2))

   if (.not.all(ismissing(index))) then
      nindex = dimsizes(index)
      print("TOTAL SELECTED PIXEL = " + nindex)
      sdata1(0:nindex-1) = oned_data1(index)
      sdata2(0:nindex-1) = oned_data2(index)
   end if

end
