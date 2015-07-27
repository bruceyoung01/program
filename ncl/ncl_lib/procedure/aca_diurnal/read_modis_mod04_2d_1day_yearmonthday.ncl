; $ID: read_modis_mod04_2d_1day_yearmonthday.ncl V01 07/24/2015 11:28 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_modis_mod04_2d_1day_yearmonthday.ncl READS MODIS MOD04/MOY04 
;  DATA INTO ONE 2-D ARRAY, INCLUDING LATITUDE, LONGITUDE, AND mdata.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir          (a string):MODIS DATA DIRECTORY                     [   ]
;  (2 ) bv0          (a string):FILL VALUE FOR STRING ARRAY              [   ]
;  (3 ) filename          (1-D):ALL THE MODIS FILE NAMES                 [   ]
;  (4 ) variable     (a string):MODIS VARIABLE NAME TO READ              [   ]
;  (5 ) lat               (2-D):LATITUDE CORRESPONDING TO MODIS DATA     [   ]
;  (6 ) lon               (2-D):LONGITUDE CORRESPONDING TO MODIS DATA    [   ]
;  (7 ) mdata_qa_land     (2-D):QUALITY ASSRUANCE FOR MODIS LAND DATA    [   ]
;  (8 ) mdata_qa_ocean    (2-D):QUALITY ASSURANCE FOR MODIS OCEAN DATA   [   ]
;  (9 ) mdata             (2-D):MODIS DATA                               [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/24/2015)
;  (2 ) MODIFIED FROM read_modis_mod04_2d_1day.ncl BY REMOVE THE DAY INDEX, 
;       SINCE THE FILENAMES ARE SELECTED BY YEAR, MONTH, AND DAY, RATHER THAN 
;       FILENAME INDEX. (BRUCE, 07/27/2015)
;******************************************************************************

undef("read_modis_mod04_2d_1day_yearmonthday")
procedure read_modis_mod04_2d_1day_yearmonthday \
         (dir           :string,   bv0            :string,   \ ; INPUT
          year          :integer,                            \ ; INPUT
          filename      :string,   variable       :string,   \ ; INPUT
          lat           :float,    lon            :float,    \ ; OUTPUT
          mdata_qa_land :integer,  mdata_qa_ocean :integer,  \ ; OUTPUT
          mdata         :float)                                ; OUTPUT


begin

   syear     = sprinti("%4.4i", year)
;  GET FILE NAME INFO
   nfilename = num(.not.ismissing(filename))

   iloop = 0
;  DO FILE NAME LOOP IN ONE DAY
   do i = 0, nfilename-1
      print("NOW READING MODIS FILE : " + filename(i))
;  READ LATITUDE, LONGITUDE, AND mdata
      a                   = addfile(dir + syear + "/" + filename(i), "r")
      tmp_lat             = a->Latitude
      tmp_lon             = a->Longitude
;  SOMTIMES THE DIMENSION SIZE OF MODIS DATA VARIABLE IS VARIOUS,
;  WE NEED TO CHECK THE DIMENSION SIZE FIRST
;  FOR INSTANCE, MOD04_L2/MYD04_L2: Angstrom_Exponent_1_Ocean HAS 
;  VARIOUS DIMENSIONS
;  FOR   MYD04_L2.A2008183.1200.051.2009140003936.hdf HAS 3-D; 
;  WHILE MYD04_L2.A2008183.1335.006.2013348142302.hdf HAS 2-D.
      tmp                 = a->$variable$
      tmp_dim             = dimsizes(tmp)
      ntmp_dim            = dimsizes(tmp_dim)
      if (ntmp_dim .eq. 2) then
         tmp_mdata           = a->$variable$(:, :)
      else if (ntmp_dim .eq. 3) then
         tmp_mdata           = a->$variable$(0, :, :)
      end if
      end if
      tmp_mdata_qa_land   = a->Quality_Assurance_Land(:, :, 0)
      tmp_mdata_qa_ocean  = a->Quality_Assurance_Ocean(:, :, 0)

;  COLLECT ALL THE DATA INTO ONE 2-D ARRAY
      ntmp_lat = dimsizes(tmp_lat)
      np       = ntmp_lat(0)
      nl       = ntmp_lat(1)
      lat((np*iloop):(np*(iloop+1)-1), 0:nl-1)   = tmp_lat
      lon((np*iloop):(np*(iloop+1)-1), 0:nl-1)   = tmp_lon
      mdata_qa_land((np*iloop):(np*(iloop+1)-1), 0:nl-1)=  \
      doubletoint(tmp_mdata_qa_land*                       \
                  tmp_mdata_qa_land@scale_factor +         \
                  tmp_mdata_qa_land@add_offset)
      mdata_qa_ocean((np*iloop):(np*(iloop+1)-1), 0:nl-1)= \
      doubletoint(tmp_mdata_qa_ocean*                      \
                  tmp_mdata_qa_ocean@scale_factor +        \
                  tmp_mdata_qa_ocean@add_offset)
      mdata((np*iloop):(np*(iloop+1)-1), 0:nl-1)   =       \
      doubletofloat(tmp_mdata*tmp_mdata@scale_factor +     \
                    tmp_mdata@add_offset)
      delete([/tmp_lat, tmp_lon, tmp_dim, tmp, tmp_mdata,  \
               tmp_mdata_qa_land, tmp_mdata_qa_ocean/])
      iloop = iloop + 1
   end do

return
end
