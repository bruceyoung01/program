;  $ID: write_viirs_epa_site_4hr_point.ncl V01 02/18/2013 22:30 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM write_viirs_epa_site_4hr_point WRITE THE SELECTED VIIRS PIXELS AND 
;  EPA SITES INFO INTO AN ASCII FILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/18/2013)
;  (2 ) MODIFIED FROM write_viirs_epa_site_4hr.ncl BY ADDING SELECTED PIXEL 
;       RADIANCE. (01/28/2014)
;******************************************************************************
undef("write_viirs_epa_site_4hr_point")
procedure write_viirs_epa_site_4hr_point \
          (groupname :string,  site_id        :string,  \ ; INPUT
           site_lat  :float,   site_lon       :float,   \ ; INPUT
           date      :integer,                          \ ; INPUT
           pnlat     :float,   pnlon          :float,   \ ; INPUT
           sza       :float,   saa            :float,   \ ; INPUT
           mp        :float,   lza            :float,   \ ; INPUT
           laa       :float,   pm             :float,   \ ; INPUT
           rad       :float)                              ; INPUT

begin
;  SPECIFY HEADER
   header1 = (/"year, month, day, hour, latitude, longitude, SatelliteZenithAngle,"      + \
               "SatelliteAzimuthAngle, Moonphase, LunarZenithAngle, LunarAzimuthAngle,"  + \
               "PM2.5A, PM2.5B, PM2.5C, PM2,5D"/)
   header2 = (/"radiance1, radiance2, radiance3, radiance4, radiance5, radiance6, "    + \
               "radiance7, radiance8, radiance9, radiance10, radiance11, radiance12, " + \
               "radiance13, radiance14, radiance15, radiance16"/)
   header3 = (/"latitude1, latitude2, latitude3, latitude4, latitude5, latitude6, "    + \
               "latitude7, latitude8, latitude9, latitude10, latitude11, latitude12, " + \
               "latitude13, latitude14, latitude15, latitude16"/)
   header4 = (/"longitude1, longitude2, longitude3, longitude4, longitude5, longitude6, "    + \
               "longitude7, longitude8, longitude9, longitude10, longitude11, longitude12, " + \
               "longitude13, longitude14, longitude15, longitude16"/)
;  COMBINE ARRAY TO THE LIST
   hlist1 = [/header1/]
   hlist2 = [/header2/]
   hlist3 = [/header3/]
   hlist4 = [/header4/]

   alist1 = [/date(0, :), date(1, :), date(2, :), date(3, :), site_lat, site_lon, \
              sza, saa, mp, lza, laa, pm(0, :), pm(1, :), pm(2, :), pm(3, :)/]
   alist2 = [/rad(0, :), rad(1, :), rad(2, :), rad(3, :), rad(4, :), rad(5, :),  \
              rad(6, :), rad(7, :), rad(8, :), rad(9, :), rad(10, :), rad(11, :),\
              rad(12, :), rad(13, :), rad(14, :), rad(15, :)/]
   alist3 = [/pnlat(0, :), pnlat(1, :), pnlat(2, :), pnlat(3, :), pnlat(4, :), pnlat(5, :),  \
              pnlat(6, :), pnlat(7, :), pnlat(8, :), pnlat(9, :), pnlat(10, :), pnlat(11, :),\
              pnlat(12, :), pnlat(13, :), pnlat(14, :), pnlat(15, :)/]
   alist4 = [/pnlon(0, :), pnlon(1, :), pnlon(2, :), pnlon(3, :), pnlon(4, :), pnlon(5, :),  \
              pnlon(6, :), pnlon(7, :), pnlon(8, :), pnlon(9, :), pnlon(10, :), pnlon(11, :),\
              pnlon(12, :), pnlon(13, :), pnlon(14, :), pnlon(15, :)/]

   afmt1  = "%4i, %02i, %02i, %02i, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, " + \
            "%15.7f, %15.7f, %15.7f"
   afmt2  = "%15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, "    + \
            "%15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f"
   afmt3  = "%15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, "    + \
            "%15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f"
   afmt4  = "%15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f, "    + \
            "%15.7f, %15.7f, %15.7f, %15.7f, %15.7f, %15.7f"

   write_table(groupname + site_id + "_1.txt", "w", hlist1, "%s")
   write_table(groupname + site_id + "_1.txt", "a", alist1, afmt1)
   write_table(groupname + site_id + "_2.txt", "w", hlist2, "%s")
   write_table(groupname + site_id + "_2.txt", "a", alist2, afmt2)
   write_table(groupname + site_id + "_3.txt", "w", hlist3, "%s")
   write_table(groupname + site_id + "_3.txt", "a", alist3, afmt3)
   write_table(groupname + site_id + "_4.txt", "w", hlist4, "%s")
   write_table(groupname + site_id + "_4.txt", "a", alist4, afmt4)

end
