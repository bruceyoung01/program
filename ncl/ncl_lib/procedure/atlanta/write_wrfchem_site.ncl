;  $ID: write_wrfchem_site.ncl V01 06/13/2013 10:11 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM write_wrfchem_site WRITES THE SELECTED WRFCHEM DATA INTO AN ASCII 
;  FILE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/13/2013)
;  (2 ) MODIFIED FROM write_viirs_epa_site.ncl. (06/13/2013)
;  (3 ) ADD tau400/tau600/pm25. (07/18/2013)
;******************************************************************************
undef("write_wrfchem_site")
procedure write_wrfchem_site \
          (site_id   :string,                           \ ; INPUT
           year      :integer,   month        :integer, \ ; INPUT
           day       :integer,   hour         :integer, \ ; INPUT
           rh        :float,     u            :float,   \ ; INPUT
           v         :float,     pblh         :float,   \ ; INPUT
           psfc      :float,     tau400       :float,   \ ; INPUT
           tau600    :float,     pm25         :float)     ; INPUT

begin
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

;  SPECIFY HEADER
   header1 = (/"year, month, day, hour(UTC), Relative_Humidity, U(m/s), V(m/s), PBL_Height(m), Surface_Pressure(pa), TAU(400nm), TAU(600nm), PM2.5"/)
;  COMBINE ARRAY TO THE LIST
   hlist1 = [/header1/]

   alist1 = [/year, month, day, hour, rh, u, v, pblh, psfc, tau400, tau600, pm25/]

   afmt1  = "%4i, %02i, %02i, %02i, %7.2f, %7.2f, %7.2f, %7.2f, %9.2f, %7.2f, %7.2f, %7.2f"

   write_table(site_id + "_2012.txt", "w", hlist1, "%s")
   write_table(site_id + "_2012.txt", "a", alist1, afmt1)
;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "write_wrfchem_site.ncl", 0)

end
