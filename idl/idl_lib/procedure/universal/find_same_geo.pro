;
; $ID: find_same_geo.pro 
; Xiaoguang XU
; 11/30/09
;

; determine the image array with same geolocation
;

  PRO find_same_geo, center_lat, $
       flat,flon,np,nl,          $
       min_dis=min_dis,          $
       idx_min=idx_min

; INPUTS & OUTPUTS
; ================
;   center_lat      --> center lat to determine the location
;   flat,flon,np,nl --> geolocation
;

  lon1 = flon[67,*]
  lat1 = flat[67,*]
  lon2 = lon1
  lat2 = lon1*0.0 + center_lat  

  dist_lat = distance(lon1,lat1,lon2,lat2)  
  min_dis  = min(dist_lat,idx_min)
  idx_min = idx_min
  
  ;outdat = indat[0:np-1,idx_min-150:idx_min+150]
  ;new_flat = flat[0:np-1,idx_min-150:idx_min+150]
  ;new_flon = flon[0:np-1,idx_min-150:idx_min+150]  


; end of routine

  return
  end

