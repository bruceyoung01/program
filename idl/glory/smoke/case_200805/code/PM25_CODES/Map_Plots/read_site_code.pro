;
;  $ID: read_site_code.pro
;
;  Read EPA-AQS site info:
;    state code, county code, site ID, and lon, lat

   PRO read_site_code, NSITE, STATE_CODE, COUNTY_CODE, SITE_ID,$
                       SITE_LAT, SITE_LON

;  site code file: "Site_code.txt"

   file_site_code = '/fs1/EPA/EPAAIRS/Site_code.txt'

   readcol, file_site_code, STATE_CODE, COUNTY_CODE,SITE_ID, $
            SITE_LAT, SITE_LON,  $
            FORMAT = 'I, I, I, F, F', skipline = 1

   NSITE = N_ELEMENTS(STATE_CODE)

   RETURN

   END
