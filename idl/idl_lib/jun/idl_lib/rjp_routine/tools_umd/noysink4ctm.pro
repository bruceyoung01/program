;+
; NAME:  noysink4ctm.pro
;   
; PURPOSE: loss rate (s-1) and lifetime (days) of noy is calculated as
;          a function of model level. 
;   
; CALLING SEQUENCE:  May be called with mainnoysink.pro 
;      
; INPUT KEYWORD PARAMETERS:
;  ikmm: number of vertical layers in CTM
;   
; OUTPUT KEYWORD PARAMETERS:
;  press: pressure on CTM levels
;  ht:    approximate height of CTM levels
;  lifetime1:  NOY lifetime (days) from AESA: Assessment (p. 72 of Friedl) 
;    note: They assume no loss at 200 hPa.  We assume 180 day lifetime. 
;  lifetime2:  NOY lifetime from Logan (1983?) (rainout only?)  
;  lifetime3: NOY lifetime  We use lifetime1 in lower
;    and mid-troposphere but shorten the lifetime in the upper troposphere
;    We justify this shortening because we assume no loss in the 
;    stratosphere. 
;  lifetime4: includes adjustment for settling of ice and scavenging
;      
; MODIFICATION HISTORY:  Initial version: 970918 
;    
;-
function noysink4ctm,ikmm=ikmm,lifetime1=lifetime1,press=press,ht=ht,$
 lifetime2=lifetime2,lifetime3=lifetime3,lifetime4land=lifetime4land,$
 lifetime4water=lifetime4water,losswater=losswater,lossice=lossice,$
 lifetime4ice=lifetime4ice

if n_elements(ikmm) eq 0 then ikmm = 26 

;Calculate pressure and height at model levels.     
press = grid(ikmm=ikmm,ht=ht,oned=1)  


;calculate lifetime using method of Logan. 
lifetime2 = 2.31e-6 * exp(1.6-0.4*ht) 
aa = where(ht lt 4.) & lifetime2(aa) = 2.31e-6
lifetime2 = 1./(86400.*lifetime2)
lossland = fltarr(ikmm) 
lifefit = [5.,5.,10.,18.,38.,180.]  
pp = [800.,600.,500.,400.,300.,200.] 

for ik = 0,ikmm-1 do begin
   case 1 of 
   (press(ik) gt pp(0)): lossland(ik) = lifefit(0)
   (press(ik) gt pp(1)): $
      begin                          
         wt = (press(ik) - pp(1))/(pp(0)-pp(1)) 
         lossland(ik) =  lifefit(0)*wt + (lifefit(1)*(1.-wt))   	      
      end 
   (press(ik) gt pp(2)): $
      begin                          
         wt = (press(ik) - pp(2))/(pp(1)-pp(2)) 
         lossland(ik) =  lifefit(1)*wt + (lifefit(2)*(1.-wt))   	      
      end 
   (press(ik) gt pp(3)): $
      begin                          
         wt = (press(ik) - pp(3))/(pp(2)-pp(3)) 
         lossland(ik) =  lifefit(2)*wt + (lifefit(3)*(1.-wt))   	      
      end 
   (press(ik) gt pp(4)): $
      begin                          
         wt = (press(ik) - pp(4))/(pp(3)-pp(4)) 
         lossland(ik) =  lifefit(3)*wt + (lifefit(4)*(1.-wt))   	      
      end 
   (press(ik) gt pp(5)): $
      begin                          
         wt = (press(ik) - pp(5))/(pp(4)-pp(5)) 
         lossland(ik) =  lifefit(4)*wt + (lifefit(5)*(1.-wt))   	      
      end 
   else: $
      begin                              
         lossland(ik) =  lifefit(5)  	      
      end 
endcase 			 
endfor 
lifetime1 = lossland 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lifefit = [5.,  5.,  10.,18.,  38.,49., 60.]
pp =     [800.,600.,500.,400.,300.,200.,100.] 
for ik = 0,ikmm-1 do begin
   case 1 of 
   (press(ik) gt pp(0)): lossland(ik) = lifefit(0)
   (press(ik) gt pp(1)): $
      begin                          
         wt = (press(ik) - pp(1))/(pp(0)-pp(1)) 
         lossland(ik) =  lifefit(0)*wt + (lifefit(1)*(1.-wt))   	      
      end 
   (press(ik) gt pp(2)): $
      begin                          
         wt = (press(ik) - pp(2))/(pp(1)-pp(2)) 
         lossland(ik) =  lifefit(1)*wt + (lifefit(2)*(1.-wt))   	      
      end 
   (press(ik) gt pp(3)): $
      begin                          
         wt = (press(ik) - pp(3))/(pp(2)-pp(3)) 
         lossland(ik) =  lifefit(2)*wt + (lifefit(3)*(1.-wt))   	      
      end 
   (press(ik) gt pp(4)): $
      begin                          
         wt = (press(ik) - pp(4))/(pp(3)-pp(4)) 
         lossland(ik) =  lifefit(3)*wt + (lifefit(4)*(1.-wt))   	      
      end 
   (press(ik) gt pp(5)): $
      begin                          
         wt = (press(ik) - pp(5))/(pp(4)-pp(5)) 
         lossland(ik) =  lifefit(4)*wt + (lifefit(5)*(1.-wt))   	      
      end 
   (press(ik) gt pp(6)): $
      begin                          
         wt = (press(ik) - pp(6))/(pp(5)-pp(6)) 
         lossland(ik) =  lifefit(5)*wt + (lifefit(6)*(1.-wt))   	      
      end 
   else: $
      begin                              
         lossland(ik) =  lifefit(6)  	      
      end 
endcase 			 
endfor 
lifetime3 = lossland 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lifefit = [5., 5., 5.,  10.,18.,  38.,49., 60.]
pp =     [1000., 800.,600.,500.,400.,300.,200.,100.] 
icefit =  [1.,    1.,  1., 0.74,0.77,0.80,0.85,0.90]
lifefit = lifefit * icefit 
for ik = 0,ikmm-1 do begin
   case 1 of 
   (press(ik) gt pp(0)): lossland(ik) = lifefit(0)
   (press(ik) gt pp(1)): $
      begin                          
         wt = (press(ik) - pp(1))/(pp(0)-pp(1)) 
         lossland(ik) =  lifefit(0)*wt + (lifefit(1)*(1.-wt))   	      
      end 
   (press(ik) gt pp(2)): $
      begin                          
         wt = (press(ik) - pp(2))/(pp(1)-pp(2)) 
         lossland(ik) =  lifefit(1)*wt + (lifefit(2)*(1.-wt))   	      
      end 
   (press(ik) gt pp(3)): $
      begin                          
         wt = (press(ik) - pp(3))/(pp(2)-pp(3)) 
         lossland(ik) =  lifefit(2)*wt + (lifefit(3)*(1.-wt))   	      
      end 
   (press(ik) gt pp(4)): $
      begin                          
         wt = (press(ik) - pp(4))/(pp(3)-pp(4)) 
         lossland(ik) =  lifefit(3)*wt + (lifefit(4)*(1.-wt))   	      
      end 
   (press(ik) gt pp(5)): $
      begin                          
         wt = (press(ik) - pp(5))/(pp(4)-pp(5)) 
         lossland(ik) =  lifefit(4)*wt + (lifefit(5)*(1.-wt))   	      
      end 
   (press(ik) gt pp(6)): $
      begin                          
         wt = (press(ik) - pp(6))/(pp(5)-pp(6)) 
         lossland(ik) =  lifefit(5)*wt + (lifefit(6)*(1.-wt))   	      
      end 
   (press(ik) gt pp(7)): $
      begin                          
         wt = (press(ik) - pp(7))/(pp(6)-pp(7)) 
         lossland(ik) =  lifefit(6)*wt + (lifefit(7)*(1.-wt))   	      
      end 
   else: $
      begin                              
         lossland(ik) =  lifefit(7)  	      
      end 
endcase 			 
endfor 
lifetime4land = lossland 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lifefit = [5., 5., 5.,  10.,18.,  38.,49., 60.]
pp =     [1000., 800.,600.,500.,400.,300.,200.,100.] 
icefit =  [1.,    1.,  1., 0.74,0.77,0.80,0.85,0.90]
lifefit = lifefit * icefit 
for ik = 0,ikmm-1 do begin
   case 1 of 
   (press(ik) gt pp(0)): lossland(ik) = lifefit(0)
   (press(ik) gt pp(1)): $
      begin                          
         wt = (press(ik) - pp(1))/(pp(0)-pp(1)) 
         lossland(ik) =  lifefit(0)*wt + (lifefit(1)*(1.-wt))   	      
      end 
   (press(ik) gt pp(2)): $
      begin                          
         wt = (press(ik) - pp(2))/(pp(1)-pp(2)) 
         lossland(ik) =  lifefit(1)*wt + (lifefit(2)*(1.-wt))   	      
      end 
   (press(ik) gt pp(3)): $
      begin                          
         wt = (press(ik) - pp(3))/(pp(2)-pp(3)) 
         lossland(ik) =  lifefit(2)*wt + (lifefit(3)*(1.-wt))   	      
      end 
   (press(ik) gt pp(4)): $
      begin                          
         wt = (press(ik) - pp(4))/(pp(3)-pp(4)) 
         lossland(ik) =  lifefit(3)*wt + (lifefit(4)*(1.-wt))   	      
      end 
   (press(ik) gt pp(5)): $
      begin                          
         wt = (press(ik) - pp(5))/(pp(4)-pp(5)) 
         lossland(ik) =  lifefit(4)*wt + (lifefit(5)*(1.-wt))   	      
      end 
   (press(ik) gt pp(6)): $
      begin                          
         wt = (press(ik) - pp(6))/(pp(5)-pp(6)) 
         lossland(ik) =  lifefit(5)*wt + (lifefit(6)*(1.-wt))   	      
      end 
   (press(ik) gt pp(7)): $
      begin                          
         wt = (press(ik) - pp(7))/(pp(6)-pp(7)) 
         lossland(ik) =  lifefit(6)*wt + (lifefit(7)*(1.-wt))   	      
      end 
   else: $
      begin                              
         lossland(ik) =  lifefit(7)  	      
      end 
endcase 			 
endfor 
lifetime4water = lossland 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lifefit = [5., 5., 5.,  10.,18.,  38.,49., 60.]
pp =     [1000., 800.,600.,500.,400.,300.,200.,100.] 
pp =     [1000., 800.,600.,500.,400.,300.,200.,100.] 
icefit =  [1.,    1.,  1., 0.74,0.77,0.80,0.85,0.90]
lifefit = lifefit * icefit 
for ik = 0,ikmm-1 do begin
   case 1 of 
   (press(ik) gt pp(0)): lossland(ik) = lifefit(0)
   (press(ik) gt pp(1)): $
      begin                          
         wt = (press(ik) - pp(1))/(pp(0)-pp(1)) 
         lossland(ik) =  lifefit(0)*wt + (lifefit(1)*(1.-wt))   	      
      end 
   (press(ik) gt pp(2)): $
      begin                          
         wt = (press(ik) - pp(2))/(pp(1)-pp(2)) 
         lossland(ik) =  lifefit(1)*wt + (lifefit(2)*(1.-wt))   	      
      end 
   (press(ik) gt pp(3)): $
      begin                          
         wt = (press(ik) - pp(3))/(pp(2)-pp(3)) 
         lossland(ik) =  lifefit(2)*wt + (lifefit(3)*(1.-wt))   	      
      end 
   (press(ik) gt pp(4)): $
      begin                          
         wt = (press(ik) - pp(4))/(pp(3)-pp(4)) 
         lossland(ik) =  lifefit(3)*wt + (lifefit(4)*(1.-wt))   	      
      end 
   (press(ik) gt pp(5)): $
      begin                          
         wt = (press(ik) - pp(5))/(pp(4)-pp(5)) 
         lossland(ik) =  lifefit(4)*wt + (lifefit(5)*(1.-wt))   	      
      end 
   (press(ik) gt pp(6)): $
      begin                          
         wt = (press(ik) - pp(6))/(pp(5)-pp(6)) 
         lossland(ik) =  lifefit(5)*wt + (lifefit(6)*(1.-wt))   	      
      end 
   (press(ik) gt pp(7)): $
      begin                          
         wt = (press(ik) - pp(7))/(pp(6)-pp(7)) 
         lossland(ik) =  lifefit(6)*wt + (lifefit(7)*(1.-wt))   	      
      end 
   else: $
      begin                              
         lossland(ik) =  lifefit(7)  	      
      end 
endcase 			 
endfor 
lifetime4ice = lossland 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lossland =  1./(lifetime4land  * 86400.)
losswater = 1./(lifetime4water * 86400.)
lossice =   1./(lifetime4ice   * 86400.)  

return,lossland 
end 

