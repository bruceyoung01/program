; $ID: read_wrf_modis.ncl V01 08/13/2012 09:49 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_wrf_modis READS SELECTED WRF-CHEM DATA BASED ON MODIS DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/13/2012)
;******************************************************************************

undef("read_wrf_modis")
procedure read_wrf_modis \
          (wdir          :string,   wfilename :string,  \ ; INPUT
           wstartinx     :integer,  wendinx   :integer, \ ; INPUT
           wlat          :float,    wlon      :float,   \ ; INPUT
           avg_data1     :float,    avg_data2 :float)     ; OUTPUT

begin
;  READ SELECTED WRF-CHEM DATA
   a     = addfiles(wdir + wfilename(wstartinx:wendinx) + ".nc", "r")
   ListSetType(a, "join")

   wtime      = a[:]->Times(:,0,:)
   data1      = a[:]->TAUAER2(:, 0, :, :, :)
   data1@lat2d= a[:]->XLAT(:, 0, :, :)
   data1@lon2d= a[:]->XLONG(:, 0, :, :)
   avg_data1  = dim_avg_n_Wrap(dim_sum_n_Wrap(data1, 1), 0)
   data2      = a[:]->TAUAER3(:, 0, :, :, :)
   data2@lat2d= a[:]->XLAT(:, 0, :, :)
   data2@lon2d= a[:]->XLONG(:, 0, :, :)
   avg_data2  = dim_avg_n_Wrap(dim_sum_n_Wrap(data2, 1), 0)
   data3      = a[:]->U(:, 0, :, :, :)
   data3@lat2d= a[:]->XLAT(:, 0, :, :)
   data3@lon2d= a[:]->XLONG(:, 0, :, :)
   avg_data3  = dim_avg_n_Wrap(dim_sum_n_Wrap(data3, 1), 0)
   data4      = a[:]->V(:, 0, :, :, :)
   data4@lat2d= a[:]->XLAT(:, 0, :, :)
   data4@lon2d= a[:]->XLONG(:, 0, :, :)
   avg_data4  = dim_avg_n_Wrap(dim_sum_n_Wrap(data4, 1), 0)
   wlat       = a[:]->XLAT(0, 0, :, :)
   wlon       = a[:]->XLONG(0, 0, :, :)

return
end
