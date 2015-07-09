; $ID: read_wrfchem_data.ncl V01 06/19/2012 10:23 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_wrfchem_data.ncl READS WRFCHEM DATA DEPENDING ON FILE NAMES 
;  LIST, OUTPUT TIME, LATITUDE, LONGITUDE, AND DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/19/2012)
;******************************************************************************

undef("read_wrfchem_data")
procedure read_wrfchem_data \
          (wdir      :string,  sfile    :string,  \ ; INPUT
           wtime     :character,                  \ ; OUTPUT
           wlat      :float,   wlon     :float,   \ ; OUTPUT
           data1     :float,   data2    :float)     ; OUTPUT

begin
;  READ WRFCHEM OUTPUT
   files = systemfunc("ls " + wdir + sfile)
   a     = addfiles(files, "r")
   delete(files)
   ListSetType(a, "join")

   wtime      = a[:]->Times(:,0,:)
   data1      = a[:]->TAUAER2(:, 0, :, :, :)
   data1@lat2d= a[:]->XLAT(:, 0, :, :)
   data1@lon2d= a[:]->XLONG(:, 0, :, :)
   data2      = a[:]->TAUAER3(:, 0, :, :, :)
   data2@lat2d= a[:]->XLAT(:, 0, :, :)
   data2@lon2d= a[:]->XLONG(:, 0, :, :)
   wlat       = a[:]->XLAT(0, 0, :, :)
   wlon       = a[:]->XLONG(0, 0, :, :)

end
