; $ID: plot_correlation.ncl V01 01/11/2012 10:57 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_correlation IS USED TO PLOT THE CORRELATION BETWEEN COLUMNS 
;  OF ONE ARRAY.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks        (graphic) : WORK STATION                             [---]
;  (2 ) sitename   (string)  : AEROENT SITE NAME                        [---]
;  (3 ) data1      (float)   : SELECTED AERONET AOD ARRAY               [---]
;  (4 ) data2      (float)   : SELECTED WRFCHEM OUTPUT                  [---]
;  (5 ) sitem      (integer) : SELECTED AOD IN WHICH COLUMN             [---]
;  (6 ) nfiles     (integer) : # OF ALL THE WRFCHEM OUTPUT FILES        [---]
;  (7 ) mpplot     (graphic) : MAP PLOT WITH SITE POINT                 [---]
;  (8 ) awplot     (graphic) : CORRELATION PLOT                         [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/11/2012)
;******************************************************************************

undef("plot_correlation")
procedure plot_correlation(wks    :graphic, sitename:string,  \ ; INPUT
                           data1  :float,   data2   :float,   \ ; INPUT
                           sitem  :integer, nfiles  :integer, \ ; INPUT
                           mpplot :graphic,                   \ ; INPUT
                           awplot :graphic)                     ; OUTPUT


begin

;  DEFINE LOCAL ARRAY
   dim   = dimsizes(data2)
   data  = new((/2, dim/), float)
   tdata = new((/2, dim/), float)

;  SET RESOURCES FOR SCATTER PLOT
   res                   = True
   res@tiMainString      = "PM2.5 VS AOD    " + sitename
   res@xyDashPatterns    = 1
   res@xyMarkLineModes   = (/"Markers","Lines"/)
   res@xyMarkers         = 16
   res@xyMarkerSizes     = 6
   res@xyLineColors      = "Blue"
   res@xyLineThicknesses = (/1,2/)
   res@trXMaxF           = 2
   res@trXMinF           = 0
   res@trYMaxF           = 1
   res@trYMinF           = 0

;  SET TITLE RESOURCES
   res@tiYAxisString = "WRF/CHEM AOD (600nm)"
   res@tiXAxisString = "AERONET AOD (675nm)"

;  CALCULATE CORRELATION
   data(0,:) = data1(:, sitem)
   data(1,:) = data2
   avgdata1  = avg(data1(:, sitem))
   avgdata2  = avg(data2)
   stddata1  = dim_stddev_n(data1(:, sitem), 0)
   stddata2  = dim_stddev_n(data2, 0)
   data!0    = "AERONET"
   data!1    = "WRFCHEM"
   ecr       = esccr(data1(:, sitem),data2,0)
   prob      = rtest(ecr,nfiles,0)
   rc        = regline(data1(:, sitem),data2)
   cor       = correlation(data1(:, sitem), data2)
   tdata(0,:)= data2
   tdata(1,:)= rc*(data1(:, sitem)-rc@xave) + rc@yave

;  SET UP TEXT RESOURCES
   tres               = True
   tres@txFontHeightF = 0.015
   gsn_text_ndc(wks,"y = ", 0.23, 0.77, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.27, 0.77, tres)
   gsn_text_ndc(wks,"x + ", 0.32, 0.77, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc@yave-rc*rc@xave), 0.36, 0.77, tres)
   gsn_text_ndc(wks,"R = ", 0.23, 0.75, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.27, 0.75, tres)
   gsn_text_ndc(wks,"N = ", 0.23, 0.73,tres)
   gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.27, 0.73,tres)
   gsn_text_ndc(wks,"AEORNET : ", 0.268, 0.71,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", avgdata1), 0.35, 0.71,tres)
   gsn_text_ndc(wks,"~F34~1", 0.38, 0.71,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", stddata1), 0.42, 0.71,tres)
   gsn_text_ndc(wks,"WRFCHEM: ", 0.27, 0.69,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", avgdata2), 0.35, 0.69,tres)
   gsn_text_ndc(wks,"~F34~1", 0.38, 0.69,tres)
   gsn_text_ndc(wks,sprintf("%5.2f", stddata2), 0.42, 0.69,tres)
   draw(mpplot)
   awplot = gsn_csm_xy(wks, data1(:, sitem), tdata, res)
   overlay(mpplot, awplot)
   delete(res)
   delete(tres)
return
end
