; $ID: filename_match_viirs.ncl V01 04/23/2012 10:55 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE filename_match_viirs READS NPP VIIRS EDR AEROSOL AND GEOLOCATION 
;  FILENAME AND MATCH THEM WITH EACH OTHER.
;  AEROSOL FILENAME:
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  GEOLOCATION FILENAME:
;  GAERO_npp_d20120201_t0909467_e0911109_b01362_c20120202145305252816_noaa_ops.h5
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/23/2012)
;******************************************************************************

undef("filename_match_viirs")
procedure filename_match_viirs (dir        :string,                     \ ; INPUT
                                vfname     :string, nvfname    :integer,\ ; INPUT
                                gfname     :string, ngfname    :integer,\ ; INPUT
                                new_vfname :string, new_gfname :string, \ ; OUTPUT
                                nvgfname   :integer)                      ; OUTPUT

begin

;  EXTRACT DATE, START TIME, AND END TIME OF EACH GRANULE AND CONVERT TO INTEGER
   vdate      = str_get_cols(vfname, 11, 8)
   vstart     = str_get_cols(vfname, 21, 7)
   vend       = str_get_cols(vfname, 30, 7)
   gdate      = str_get_cols(gfname, 11, 8)
   gstart     = str_get_cols(gfname, 21, 7)
   gend       = str_get_cols(gfname, 30, 7)

;  SELECT THE SAME FILES OF GEOLOCATION DEPENDING ON AEROSOL FILES
   j = 0
   do i = 0, nvfname-1
    index1 = ind(gdate  .eq. vdate(i)  .and. \
                 gstart .eq. vstart(i) .and. \
                 gend   .eq. vend(i))
    if(.not.all(ismissing(index1)))then
     new_gfname(j) = gfname(index1)
     j = j + 1
    end if
    delete(index1)
   end do

;  EXTRACT DATE, START TIME, AND END TIME FROM SELECTED GEOLOCATION FILES
   new_gdate      = str_get_cols(new_gfname, 11, 8)
   new_gstart     = str_get_cols(new_gfname, 21, 7)
   new_gend       = str_get_cols(new_gfname, 30, 7)

;  SELECT THE SAME FILES OF AEROSOL FILES DEPENDING ON SELECTED GEOLOCATION FILES
   l = 0
   do k = 0, j-1
    index2 = ind(vdate  .eq. new_gdate(k)  .and. \
                 vstart .eq. new_gstart(k) .and. \
                 vend   .eq. new_gend(k))
    if(.not.all(ismissing(index2)))then
     new_vfname(l) = vfname(index2)
     l = l + 1
    end if
    delete(index2)
   end do
   nvgfname = num(.not.ismissing(new_vfname))

return
end
