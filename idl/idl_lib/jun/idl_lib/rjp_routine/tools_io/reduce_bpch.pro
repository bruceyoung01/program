
 pro reduce_bpch, filename, Lat=Lat, Lon=Lon, Lev=Lev, $
          outfilename=outfilename, tracers=tracers, category=category

 if n_elements(outfilename) eq 0 then outfilename = 'reduced.bpch'
 if n_elements(Lat)         eq 0 then Lat = [0.,80.]     ; Northen Hemisphere
 if n_elements(Lon)         eq 0 then Lon = [-150.,-50.] ; North America
 if n_elements(Lev)         eq 0 then Lev = [1.,20.]     ; Troposphere


   ctm_get_data, Datainfo, CATEGORY, file=filename, tracer=tracers

   First = 1L

   NewDATAinfo = shrink_datainfo( Datainfo, Lat=Lat, Lon=Lon, Lev=Lev, $
                 ThisFileInfo=ThisFileInfo )

   CTM_WRITEBPCH, NewDATAinfo, ThisFileInfo, filename=outfilename

 End

