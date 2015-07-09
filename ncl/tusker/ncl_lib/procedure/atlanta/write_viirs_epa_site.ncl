;  $ID: write_viirs_epa_site.ncl V01 02/18/2013 22:30 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM write_viirs_epa_site WRITE THE SELECTED VIIRS PIXELS AND EPA SITES 
;  INFO INTO AN ASCII FILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/18/2013)
;******************************************************************************
undef("write_viirs_epa_site")
procedure write_viirs_epa_site \
          (site_id   :string,                           \ ; INPUT
           site_lat  :float,   site_lon       :float,   \ ; INPUT
           date      :integer,                          \ ; INPUT
           sza       :float,   saa            :float,   \ ; INPUT
           mp        :float,   lza            :float,   \ ; INPUT
           laa       :float,   pm             :float,   \ ; INPUT
           rad       :float)                              ; INPUT

begin
;  SPECIFY HEADER
   header1 = (/"year, month, day, hour, latitude, longitude, SatelliteZenithAngle,"      + \
               "SatelliteAzimuthAngle, Moonphase, LunarZenithAngle, LunarAzimuthAngle,"  + \
               "PM2.5A, PM2.5B"/)
   header2 = (/"radiance1, radiance2, radiance3, radiance4, radiance5, radiance6, "    + \
               "radiance7, radiance8, radiance9, radiance10, radiance11, radiance12, " + \
               "radiance13, radiance14, radiance15, radiance16"/)
   header3 = (/"radiance17, radiance18, radiance19, radiance20, radiance21, " + \
               "radiance22, radiance23, radiance24, radiance25"/)
   header4 = (/"radiance26, radiance27, radiance28, radiance29, radiance30, radiance31, " + \
               "radiance32, radiance33, radiance34, radiance35, radiance36, radiance37, " + \
               "radiance38, radiance39, radiance40, radiance41"/)
   header5 = (/"radiance42, radiance43, radiance44, radiance45, radiance46, radiance47, " + \
               "radiance48, radiance49, radiance50, radiance51, radiance52, radiance53, " + \
               "radiance54, radiance55, radiance56, radiance57"/)
   header6 = (/"radiance58, radiance59, radiance60, radiance61, radiance62, radiance63, " + \
               "radiance64, radiance65, radiance66, radiance67, radiance68, radiance69, " + \
               "radiance70, radiance71, radiance72, radiance73"/)
   header7 = (/"radiance74, radiance75, radiance76, radiance77, radiance78, radiance79, " + \
               "radiance80, radiance81"/)
;  COMBINE ARRAY TO THE LIST
   hlist1 = [/header1/]
   hlist2 = [/header2/]
   hlist3 = [/header3/]
   hlist4 = [/header4/]
   hlist5 = [/header5/]
   hlist6 = [/header6/]
   hlist7 = [/header7/]

   alist1 = [/date(:, 0), date(:, 1), date(:, 2), date(:, 3), site_lat, site_lon, \
              sza, saa, mp, lza, laa, pm(:,0), pm(:,1)/]
   alist2 = [/rad(:,0), rad(:,1), rad(:,2), rad(:,3), rad(:,4), rad(:,5),  \
              rad(:,6), rad(:,7), rad(:,8), rad(:,9), rad(:,10), rad(:,11),\
              rad(:,12), rad(:,13), rad(:,14), rad(:,15)/]
   alist3 = [/rad(:,16), rad(:,17), rad(:,18), rad(:,19), rad(:,20), rad(:,21), \
              rad(:,22), rad(:,23), rad(:,24)/]
   alist4 = [/rad(:,25), rad(:,26), rad(:,27), rad(:,28), rad(:,29), rad(:,30),  \
              rad(:,31), rad(:,32), rad(:,33), rad(:,34), rad(:,35), rad(:,36),\
              rad(:,37), rad(:,38), rad(:,39), rad(:,40)/]
   alist5 = [/rad(:,41), rad(:,42), rad(:,43), rad(:,44), rad(:,45), rad(:,46),  \
              rad(:,47), rad(:,48), rad(:,49), rad(:,50), rad(:,51), rad(:,52),\
              rad(:,53), rad(:,54), rad(:,55), rad(:,56)/]
   alist6 = [/rad(:,57), rad(:,58), rad(:,59), rad(:,60), rad(:,61), rad(:,62),  \
              rad(:,63), rad(:,64), rad(:,65), rad(:,66), rad(:,67), rad(:,68),\
              rad(:,69), rad(:,70), rad(:,71), rad(:,72)/]
   alist7 = [/rad(:,73), rad(:,74), rad(:,75), rad(:,76), rad(:,77), rad(:,78),  \
              rad(:,79), rad(:,80)/]

   afmt1  = "%4i, %02i, %02i, %02i, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f, %7.2f"
   afmt2  = "%8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, "+ \
            "%8.3e, %8.3e, %8.3e, %8.3e"
   afmt3  = "%8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e"
   afmt4  = "%8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, "+ \
            "%8.3e, %8.3e, %8.3e, %8.3e"
   afmt5  = "%8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, "+ \
            "%8.3e, %8.3e, %8.3e, %8.3e"
   afmt6  = "%8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, "+ \
            "%8.3e, %8.3e, %8.3e, %8.3e"
   afmt7  = "%8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e, %8.3e"

   write_table(site_id + "_1.txt", "w", hlist1, "%s")
   write_table(site_id + "_1.txt", "a", alist1, afmt1)
   write_table(site_id + "_2.txt", "w", hlist2, "%s")
   write_table(site_id + "_2.txt", "a", alist2, afmt2)
   write_table(site_id + "_3.txt", "w", hlist3, "%s")
   write_table(site_id + "_3.txt", "a", alist3, afmt3)
   write_table(site_id + "_4.txt", "w", hlist4, "%s")
   write_table(site_id + "_4.txt", "a", alist4, afmt4)
   write_table(site_id + "_5.txt", "w", hlist5, "%s")
   write_table(site_id + "_5.txt", "a", alist5, afmt5)
   write_table(site_id + "_6.txt", "w", hlist6, "%s")
   write_table(site_id + "_6.txt", "a", alist6, afmt6)
   write_table(site_id + "_7.txt", "w", hlist7, "%s")
   write_table(site_id + "_7.txt", "a", alist7, afmt7)

end
