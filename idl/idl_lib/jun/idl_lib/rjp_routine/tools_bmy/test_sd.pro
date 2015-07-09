pro test_sd, FileName

   ; HDF file -- created by bmy
   InFile = '~/S/myhdf.19970701.000000.hdf'
   
   ; Open HDF file
   fId = HDF_SD_Start( Expand_Path( InFile ), /Read )

   ; Get LON, LAT, JNO2, NOx
   Lon  = HDF_GetSD( fId, 'LON' )
   Lat  = HDF_GetSD( fId, 'LAT' )
   JNO2 = HDF_GetSD( fId, 'JV-MAP-$::JNO2' )
   NOx  = HDF_GetSD( fId, 'IJ-AVG-$::NOx' )

   Multipanel, 2
   
   ; Plot JNO2 at surface
   TvMap, JNO2[*,*,0], Lon, Lat, $
      /CBar, /Sample, Div=3, /Grid, /Contin, /Countries, /Coasts, Title='JNO2'

   ; Plot NOx at surface
   TvMap, NOx[*,*,0], Lon, Lat, $
      /CBar, /Sample, Div=3, /Grid, /Contin, /Countries, /Coasts, Title='NOx'

   ; Close HDF file
   HDF_SD_End, fId

   ; Quit
   return
end
