; ===========================================
; conLev_1.ncl
;
; Concepts illustrated:
;   - Setting contour levels using a min/max contour level and a spacing
;   - Reordering an array
;   - Using a blue-white-red color map
;   - Adding gray to an existing color map
;   - Zooming in on a particular area on a cylindrical equidistant map
;
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin
  f      = addfile ("b003_TS_200-299.nc", "r")
  x      = f->TS(43,:,:)       ;Grab 43rd timestep (=year 243)

  x = x-273.15

  wks = gsn_open_wks("ps","conLev_1")
  gsn_define_colormap(wks,"BlWhRe")	     ; use the BlWhRe colormap (instead of default colormap)
  color1 = NhlNewColor(wks,0.75,0.75,0.75)   ; add a lighter gray to the color map

  res           = True
  res@mpFillOn = True			  ; turn on the map filling resource
  res@mpFillColors = (/ -1,-1,103,-1/)	  ; color the continents gray
  res@mpMinLatF = -70.			  ; set the minimum latitude = -70.
  res@mpMaxLatF = 70.			  ; set the maximum latitude = 70.

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -5.			; set the minimum contour level
  res@cnMaxLevelValF  = 30.			; set the maximum contour level
  res@cnLevelSpacingF = 5.			; set the interval between contours
  plot = gsn_csm_contour_map_ce(wks,x,res)    
end     

