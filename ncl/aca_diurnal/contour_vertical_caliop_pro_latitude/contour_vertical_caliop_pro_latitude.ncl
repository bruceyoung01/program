;  $ID: contour_vertical_caliop_pro_latitude.ncl V01 08/12/2015 15:33 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_vertical_caliop_pro_latitude.ncl READS CALIOP PROFILE DATA, 
;  REGRIDS TO GRIDDED DATA ALONG HORIZONS, AND PLOTS THE REGRIDDED DATA AS 
;  VERTICAL CONTOUR.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO LATITUDE LOOP WITH INTERVAL OF 4 DEGREE;
;  (2 ) DO HOUR, YEAR, MONTH, AND DAY LOOP;
;  (3 ) COLLECT ALL THE CALIOP FILE NAME ON THIS DAY;
