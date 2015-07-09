type = 'dc8' ;'dc8'/'p3b'


if (type eq 'p3b') then begin
   starter = 4
   ender =  24
   maxalt = 8
endif

if (type eq 'dc8') then begin
   starter = 4
   ender = 20
   maxalt = 12
endif

for i=starter, ender do begin
   if (i le 9) then begin
      file = type+'_0'+string(i, format='(i1)')+'.dat'
   endif else begin
      file = type+'_'+string(i, format='(i2)')+'.dat'
   endelse
   print,  file
  
   openr, 1, file
   line = ''
   readf, 1, line
   names = strsplit(line, ' ', /extract)
   if (i eq 4) then begin
      data = fltarr(10000, n_elements(names))
      counter = 0
   endif
   while not eof(1) do begin
      readf, 1, line
      xline = float(strsplit(line, ' ', /extract))
      data(counter, *) = xline
      counter = counter+1
   endwhile
   close, 1
endfor
data = data(0:(counter-1), *)
;goto,  skip
if (type eq 'dc8') then begin
gspec = ['geos_Ox', 'geos_CO', 'geos_C2H6', 'geos_C3H8', $
         'geos_CH2O', 'geos_CH2O', $
         'geos_H2O2', 'geos_PAN', 'geos_ALD2', 'geos_ALD2', $
         'geos_ACET', 'geos_ACET']
gcorr = [1e9, 1e9, 0.5e12, 0.333e12, 1e12, 1e12, 1e12, 1e12, 1e12, 0.5e12, 0.5e12, 0.3333e12, 0.3333e12]
mspec = ['O3', 'CO', 'Ethane', 'Propane', 'CH2O_fa', 'CH2O_hb', $
         'H2O2', 'PAN', 'ALD2_ap', 'ALD2_sh', 'ACET_ap', $
         'ACET_sh']
endif 

if (type eq 'p3b') then begin
   gspec = ['geos_Ox', 'geos_CO', $
            'geos_C2H6', 'geos_C3H8', $
            'geos_PAN', 'geos_NOx', $
            'NOy']
        
   gcorr = [1e9, 1e9, 0.5e12, 0.333e12, 1e12, 1e12, 1e12, 1e12, 1e12, 1e12, 1e12, 1e12, 1e12]
   mspec = ['O3', 'CO', $
            'Ethane', 'Propane', $
            'PAN', 'NOx', $
            'NOy']
endif

usersym, sin(indgen(30)*2.*!pi/30.), cos(indgen(30)*2.*!pi/30.),/fill
galt = where(names eq 'alt')
mo3 = where(names eq 'O3')
mco = where(names eq 'CO')
erase
!p.multi = [0, maxalt/4, 2, 0, 0]
for i=0, n_elements(gspec)-1 do begin
;for i=0, 0 do begin
   print,  mspec(i),  gspec(i)
   !p.multi(0) = 0
   if (mspec(i) ne 'NOx' and mspec(i) ne 'NOy') then begin
      k_g = where(gspec(i) eq names)
      k_m = where(mspec(i) eq names)

      for ki=0, maxalt/2.-1 do begin
         k = where(data(*, k_g) ge 0. and data(*, k_m) ge 0. $
                   and data(*, mo3) le 150. and $
                   data(*,galt) ge ki*2. and data(*, galt) le (ki+1)*2.)
         
         print,  ki*2,  (ki+1)*2.
         print,  n_elements(k)
         kp = where(data(k, k_g(0)) ge 1e-3)
         
         if (kp(0) ne -1) then begin
            data(k(kp), k_g(0)) =  data(k(kp), k_g(0))/1e9
         endif
         
         
         x =  alog10(reform(data(k, k_m(0)), 1, n_elements(k)))
         
         y =  alog10(data(k, k_g(0))*gcorr(i))
         weights = x*0.+1.
         result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
         plot,  data(k, k_m(0)),  data(k, k_g(0))*gcorr(i),  psym=8,  symsize=0.5, ystyle=1,xstyle=1, $
            title=type+' '+$
            mspec(i)+' R^2 ='+string(R(0)^2, format='(f4.2)')+$
            ' '+string(ki*2, format='(i2)')+'-'+$
            string((ki+1)*2, format='(i2)')+'km',  /xlog,  /ylog, $
            xtitle='Measured',  ytitle='Modeled'
         print,  mspec(i),  result,  r
         oplot,  [1e-10, 1e10], [1e-10, 1e10]
         oplot,  [1e-10, 1e10], [1.5e-10, 1.5e10]
         oplot,  [1e-10, 1e10], [0.667e-10, 0.667e10]
         oplot,  10^x,  10^yfit,  thick=3
      endfor

      array = fltarr(maxalt*100, 4)
      counter = 0
      for ki=0., maxalt-1, 0.01 do begin
         k = where(data(*, k_g) ge 0. and data(*, k_m) ge 0. $
                   and data(*, mo3) le 150. and $
                  data(*,galt) ge (ki-1.) and data(*, galt) le (ki+1))
         
         
         kp = where(data(k, k_g(0)) ge 1e-3)
         
         if (kp(0) ne -1) then begin
            data(k(kp), k_g(0)) =  data(k(kp), k_g(0))/1e9
         endif
         
         
         x =  alog10(reform(data(k, k_m(0)), 1, n_elements(k)))
         
         y =  alog10(data(k, k_g(0))*gcorr(i))
         weights = x*0.+1.
         result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
     
         
         array(counter, 0) = median(10^x/10^y)
         array(counter, 1) = result
         array(counter, 2) = r^2
         array(counter, 3) = n_elements(x)
         counter = counter+1
      endfor
      plot,  array(0:(counter-1), 0), indgen(counter-1)*0.01,  yrange=[0, maxalt], $
         title='Median ratio (Measured/Modeled) '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 1), indgen(counter-1)*0.01,$
         title='Gradient '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 2), indgen(counter-1)*0.01,$
         title='R^2 '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 3), indgen(counter-1)*0.01,$
         title='Number of points '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
   endif 

   if (mspec(i) eq 'NOx') then begin
      print,  'here'
      k_g = where(gspec(i) eq names)
      k_m1 = where(names eq 'NO')
      k_m2 = where(names eq 'NO2')
      for ki=0, maxalt/2.-1 do begin
         k = where(data(*, k_g) ge 0. and $
                   data(*, k_m1) ge 0. and $
                   data(*, k_m2) ge 0. and $
                   data(*, mo3) le 150. and $
                   data(*, galt) ge ki*2 and $
                   data(*, galt) le (ki+1)*2.)
         
         x =  alog10(reform(data(k, k_m1(0))+data(k, k_m2(0)), $
                            1, n_elements(k)))
         
         y =  alog10(data(k, k_g(0))*gcorr(i))
         weights = x*0.+1.
         result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
         plot,  data(k, k_m1(0))+data(k, k_m2(0)),  data(k, k_g(0))*gcorr(i),  psym=8,  symsize=0.5, $
            title=mspec(i)+string(median(10^x/10^y)),  /xlog,  /ylog
         print,  mspec(i),  result,  r
         oplot,  [1e-10, 1e10], [1e-10, 1e10]
         oplot,  [1e-10, 1e10], [1.5e-10, 1.5e10]
         oplot,  [1e-10, 1e10], [0.667e-10, 0.667e10]
         oplot,  10^x,  10^yfit,  thick=3
      endfor

      array = fltarr(maxalt*100, 4)
      counter = 0
      for ki=0., maxalt-1, 0.01 do begin
         
         k = where(data(*, k_g) ge 0. and $
                   data(*, k_m1) ge 0. and $
                   data(*, k_m2) ge 0. and $
                   data(*, mo3) le 150. and $
                   data(*,galt) ge (ki-1.) and $
                   data(*, galt) le (ki+1))
         
         
         kp = where(data(k, k_g(0)) ge 1e-3)
         
         if (kp(0) ne -1) then begin
            data(k(kp), k_g(0)) =  data(k(kp), k_g(0))/1e9
         endif
         
         x =  alog10(reform(data(k, k_m1(0))+data(k, k_m2(0)), $
                            1, n_elements(k)))
         
         
         y =  alog10(data(k, k_g(0))*gcorr(i))
         weights = x*0.+1.
         result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
     
         
         array(counter, 0) = median(10^x/10^y)
         array(counter, 1) = result
         array(counter, 2) = r^2
         array(counter, 3) = n_elements(x)
         counter = counter+1
      endfor
      plot,  array(0:(counter-1), 0), indgen(counter-1)*0.01,  yrange=[0, maxalt], $
         title='Median ratio (Measured/Modeled) '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 1), indgen(counter-1)*0.01,$
         title='Gradient '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 2), indgen(counter-1)*0.01,$
         title='R^2 '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 3), indgen(counter-1)*0.01,$
         title='Number of points '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
   endif
   
   if (mspec(i) eq 'NOy') then begin
      k_g1 = where(names eq 'geos_NOx')
      k_g2 = where(names eq 'geos_PAN')
      k_g3 = where(names eq 'geos_HNO3')
      k_g4 = where(names eq 'geos_PMN')
      k_g5 = where(names eq 'geos_PPN')
      k_g6 = where(names eq 'geos_R4N2')
      k_g7 = where(names eq 'geos_HNO4')
      k_g8 = where(names eq 'geos_N2O5')

      kp = where(data(k, k_g1(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g1(0)) =  data(k(kp), k_g1(0))/1e9
      endif
      
      kp = where(data(k, k_g2(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g2(0)) =  data(k(kp), k_g2(0))/1e9
      endif

      kp = where(data(k, k_g3(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g3(0)) =  data(k(kp), k_g3(0))/1e9
      endif

      kp = where(data(k, k_g4(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g4(0)) =  data(k(kp), k_g4(0))/1e9
      endif

      kp = where(data(k, k_g5(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g5(0)) =  data(k(kp), k_g5(0))/1e9
      endif

      kp = where(data(k, k_g6(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g6(0)) =  data(k(kp), k_g6(0))/1e9
      endif

      kp = where(data(k, k_g7(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g7(0)) =  data(k(kp), k_g7(0))/1e9
      endif

      kp = where(data(k, k_g8(0)) ge 1e-3)      
      if (kp(0) ne -1) then begin
         data(k(kp), k_g8(0)) =  data(k(kp), k_g8(0))/1e9
      endif     

      k_m = where(names eq 'NOy')
      NOy = data(*, k_g1)+data(*, k_g2)+data(*, k_g3)+$
         data(*, k_g4)+data(*, k_g5)+data(*, k_g6)+$
         data(*, k_g7)+data(*, k_g8)*2.

      for ki=0, maxalt/2.-1 do begin

         k = where(NOy ge 0. and $
                   data(*, k_m) ge 0. and $
                   data(*, mo3) le 150. and $
                   data(*, galt) ge ki*2 and $
                   data(*, galt) le (ki+1)*2.)

   
      
      x =  alog10(reform(data(k, k_m(0)), 1, n_elements(k)))
      y =  alog10(NOy(k)*gcorr(i))
      
      weights = x*0+1.
      result = regress(  x, y, weights,  yfit, Const, Sigma, $
                         Ftest, R, Rmul, $
                         Chisq, Status, /RELATIVE_WEIGHT)
      
      plot,  data(k, k_m(0)),  $
         NOy*gcorr(i),  psym=8,  symsize=0.5, $
         title=mspec(i)+' R^2 ='+string(R(0)^2, format='(f4.2)'),$
         /xlog,  /ylog
   
      print,  mspec(i),  result,  r
      oplot,  [1e-10, 1e10], [1e-10, 1e10]
      oplot,  [1e-10, 1e10], [1.5e-10, 1.5e10]
      oplot,  [1e-10, 1e10], [0.667e-10, 0.667e10]
      oplot,  10^x,  10^yfit,  thick=3
      endfor

      array = fltarr(maxalt*100, 4)
      counter = 0
      for ki=0., maxalt-1, 0.01 do begin
         
         k = where(NOy ge 0. and $
                   data(*, k_m) ge 0. and $
                   data(*, mo3) le 150. and $
                   data(*,galt) ge (ki-1.) and $
                   data(*, galt) le (ki+1) and $
                   data(*, mco) ge 100.)
         

         
         x =  alog10(reform(data(k, k_m(0)), $
                            1, n_elements(k)))
         
         y =  alog10(NOy(k)*gcorr(i))
        
         weights = x*0.+1.
         result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
     
         
         array(counter, 0) = median(10^x/10^y)
         array(counter, 1) = result
         array(counter, 2) = r^2
         array(counter, 3) = n_elements(x)
         counter = counter+1
      endfor
      plot,  array(0:(counter-1), 0), indgen(counter-1)*0.01,  yrange=[0, maxalt], $
         title='Median ratio (Measured/Modeled) '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 1), indgen(counter-1)*0.01,$
         title='Gradient '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 2), indgen(counter-1)*0.01,$
         title='R^2 '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
      plot,  array(0:(counter-1), 3), indgen(counter-1)*0.01,$
         title='Number of points '+mspec(i),  ytitle='Altitude (km)', $
         charsize=1
   endif
   
endfor


;skip:
!p.multi(0) = 0
m_CO = where(names eq 'CO')
m_O3 = where(names eq 'O3')
m_NOy = where(names eq 'NOy')
g_CO = where(names eq 'geos_CO')
g_O3 = where(names eq 'geos_Ox')
galt = where(names eq 'alt')

for i=0, (maxalt/2)-1 do begin

   k = where(data(*, m_CO) ge 0. and data(*, m_o3) ge 0. and $
             data(*, galt) ge (i*2) and data(*, galt) le (i+1)*2. and $
             data(*, m_CO) le 1000. and data(*, g_CO) le 1000e-9)

 
   plot,  data(k, m_CO(0)),  data(k, m_O3(0)),  psym=8,  yrange=[0, 100], $
      xrange=[0, 500],  xtitle='CO',  ytitle='O3', $
      title=string(i*2)+'-'+string((i+1)*2)+' km'

   x =  reform(data(k, m_CO(0)), 1, n_elements(k)) 
   y =  data(k, m_O3(0))
        
   weights = x*0.+1.
   result2 = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)      
   oplot,  x, yfit,  thick=4
   
   oplot,  data(k, g_CO(0))*1e9,  data(k, g_O3(0))*1e9,  psym=8,  $
      color=50,  symsize=0.75

   x =  reform(data(k, g_CO(0))*1e9, 1, n_elements(k)) 
   y =  data(k, g_O3(0))*1e9
        
   weights = x*0.+1.
   result2 = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)      
   oplot,  x, yfit,  color=50,  thick=4
endfor

counter = 0
array = fltarr(maxalt*100, 6)
for i=0., maxalt, 0.01 do begin
   k = where(data(*, m_CO) ge 0. and data(*, m_o3) ge 0. and $
             data(*, galt) ge (i-1) and data(*, galt) le (i+1) and $
             data(*, m_CO) le 1000)
;   plot,  data(k, m_NOy(0)),  data(k, m_O3(0)),  psym=8,  yrange=[0, 100], $
;      xrange=[10, 5000],  xtitle='NOy',  ytitle='O3',  /xlog
;   oplot,  NOy(k)*1e12,  data(k, g_O3(0))*1e9,  psym=8,  $
;      color=55,  symsize=0.75

   x =  reform(data(k, m_CO(0)), 1, n_elements(k))    
   y =  data(k, m_O3(0))
        
   weights = x*0.+1.
   result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
   
   array(counter, 0) = result
   array(counter, 1) = r ^2
   array(counter, 4) = sigma

  ; oplot,  10^x,  yfit,  thick=4,  color=0

   x =  reform(data(k, g_CO(0))*1e9, 1, n_elements(k)) 
   y =  data(k, g_O3(0))*1e9
        
   weights = x*0.+1.
   result2 = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
   

   array(counter, 2) = result2
   array(counter, 3) = r2 ^2
   array(counter, 5) = sigma
 ;  oplot,  10^x,  yfit,  thick=4,  color=55
 ;  print,  result(0),result2(0), r, r2
   counter = counter+1
endfor
plot,  array(*, 0),indgen(counter-1)*0.01,  xrange=[0, 0.4], $
   ytitle='Altitude',  xtitle='O3/CO slope'
oplot,  array(*, 0)+array(*, 4), indgen(counter-1)*0.01
oplot,   array(*, 0)-array(*, 4), indgen(counter-1)*0.01
oplot,  array(*, 2), indgen(counter-1)*0.01,  color=50
oplot,  array(*, 2)+array(*, 5), indgen(counter-1)*0.01,  color=50
oplot,   array(*, 2)-array(*, 5), indgen(counter-1)*0.01,  color=50
plot,  array(*, 1), indgen(counter-1)*0.01, $
   ytitle='Altitude',  xtitle='O3/CO R!e2!n',  xrange=[0, 1]
oplot,  array(*, 3), indgen(counter-1)*0.01,  color=50

!p.multi(0) = 0
if (type eq 'p3b') then begin
   for i=0, maxalt/2-1 do begin
      k = where(data(*, m_NOy) ge 0. and data(*, m_o3) ge 0. and $
                data(*, galt) ge (i*2) and data(*, galt) le (i+1)*2. and $
                data(*, m_CO) ge 000)
      plot,  data(k, m_NOy(0)),  data(k, m_O3(0)),  psym=8,  yrange=[0, 100], $
         xrange=[10, 5000],  xtitle='NOy',  ytitle='O3',  /xlog
      oplot,  NOy(k)*1e12,  data(k, g_O3(0))*1e9,  psym=8,  $
         color=55,  symsize=0.75
      
      x =  reform(alog10(data(k, m_NOy(0))), 1, n_elements(k))     
      y =  data(k, m_O3(0))
      
      weights = x*0.+1.
      result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                         Chisq, Status, /RELATIVE_WEIGHT)
      
      oplot,  10^x,  yfit,  thick=4,  color=0
      
      x =  reform(alog10(NOy(k)*1e12), 1, n_elements(k)) 
      y =  data(k, g_O3(0))*1e9
      
      weights = x*0.+1.
      result2 = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                          Chisq, Status, /RELATIVE_WEIGHT)
      
      oplot,  10^x,  yfit,  thick=4,  color=55
      print,  result(0),result2(0), r, r2
   endfor
   
   counter = 0
   array = fltarr(maxalt*100, 6)
   for i=0., maxalt, 0.01 do begin
      k = where(data(*, m_NOy) ge 0. and data(*, m_o3) ge 0. and $
                data(*, galt) ge (i-1) and data(*, galt) le (i+1) and $
                data(*, m_CO) ge 000)
;   plot,  data(k, m_NOy(0)),  data(k, m_O3(0)),  psym=8,  yrange=[0, 100], $
;      xrange=[10, 5000],  xtitle='NOy',  ytitle='O3',  /xlog
;   oplot,  NOy(k)*1e12,  data(k, g_O3(0))*1e9,  psym=8,  $
;      color=55,  symsize=0.75
      
      x =  reform(alog10(data(k, m_NOy(0))), 1, n_elements(k))     
      y =  data(k, m_O3(0))
      
      weights = x*0.+1.
      result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R, Rmul, $
                         Chisq, Status, /RELATIVE_WEIGHT)
      
      array(counter, 0) = result
      array(counter, 1) = r ^2
      array(counter, 4) = sigma
      
                                ; oplot,  10^x,  yfit,  thick=4,  color=0
      
      x =  reform(alog10(NOy(k)*1e12), 1, n_elements(k)) 
      y =  data(k, g_O3(0))*1e9
      
      weights = x*0.+1.
      result2 = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                          Chisq, Status, /RELATIVE_WEIGHT)
      
      
      array(counter, 2) = result2
      array(counter, 3) = r2 ^2
      array(counter, 5) = sigma
                                ;  oplot,  10^x,  yfit,  thick=4,  color=55
                                ;  print,  result(0),result2(0), r, r2
      counter = counter+1
   endfor
   plot,  array(*, 0),indgen(counter-1)*0.01,  xrange=[0, 100], $
      ytitle='Altitude',  xtitle='O3/NOy slope'
   oplot,  array(*, 0)+array(*, 4), indgen(counter-1)*0.01
   oplot,   array(*, 0)-array(*, 4), indgen(counter-1)*0.01
   oplot,  array(*, 2), indgen(counter-1)*0.01,  color=50
   oplot,  array(*, 2)+array(*, 5), indgen(counter-1)*0.01,  color=50
   oplot,   array(*, 2)-array(*, 5), indgen(counter-1)*0.01,  color=50
   plot,  array(*, 1), indgen(counter-1)*0.01, $
      ytitle='Altitude',  xtitle='O3/NOy R!e2!n',  xrange=[0, 1]
   oplot,  array(*, 3), indgen(counter-1)*0.01,  color=50
skip:
endif

m_c2h6 = where(names eq 'Ethane')
m_c3h8 = where(names eq 'Propane')
m_alt = where(names eq 'alt')

g_c2h6 = where(names eq 'geos_C2H6')
g_c3h8 = where(names eq 'geos_C3H8')
!p.multi(0) = 0
for ip=0, maxalt/2-1 do begin
   k = where(data(*, m_c2h6) ge 0 and data(*, m_c3h8) ge 0. and $
             data(*, m_alt) ge ip*2. and data(*, m_alt) le (ip+1)*2.)
   plot,  data(k, m_c2h6(0)),  data(k, m_c3h8(0)),  psym=8, $
      xtitle='C2H6', ytitle='C3H8',  /xlog,  /ylog, $
      title=string(ip*2)+'-'+string((ip+1)*2.)+' km'
   x = reform( data(k, m_c2h6(0)), 1, n_elements(k))
   y = data(k, m_c3h8(0))

   x = alog(x)
   y = alog(y)
   weights = x*0.+1.
   result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
   oplot,  exp(x), exp(yfit),  thick=4

   print,  'meas', result


   oplot,  data(k, g_c2h6(0))*1e12/2.,  data(k, g_c3h8(0))*1e12/3.,$
      psym=8,  color=50, symsize=0.4
   x = reform( data(k, g_c2h6(0))*1e12/2., 1, n_elements(k))
   y = data(k, g_c3h8(0))*1e12/3.

   x = alog(x)
   y = alog(y)
   weights = x*0.+1.
   result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                            Chisq, Status, /RELATIVE_WEIGHT)
   print,  'model', result

   oplot,  exp(x), exp(yfit),  thick=4, color=50
endfor

counter = 0
array = fltarr(maxalt*100, 6)
for ip=0., maxalt, 0.01 do begin
   k = where(data(*, m_c2h6) ge 0 and data(*, m_c3h8) ge 0. and $
             data(*, m_alt) ge (ip-1.) and data(*, m_alt) le (ip+1.))

   x = reform( data(k, m_c2h6(0)), 1, n_elements(k))
   y = data(k, m_c3h8(0))
   
   x = alog(x)
   y = alog(y)
   weights = x*0.+1.
   result = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                      Chisq, Status, /RELATIVE_WEIGHT)
   array(counter, 0) = result
   array(counter, 2) = R2^2
   array(counter, 4) = const
   x = reform( data(k, g_c2h6(0)), 1, n_elements(k))*1e12/2.
   y = data(k, g_c3h8(0))*1e12/3.
   
   x = alog(x)
   y = alog(y)
   weights = x*0.+1.
   result2 = regress(  x, y, weights,  yfit, Const, Sigma, Ftest, R2, Rmul, $
                      Chisq, Status, /RELATIVE_WEIGHT)
   print,  result(0),  result2(0)
   array(counter, 1) = result2
   array(counter, 3) = R2^2
   array(counter, 5) = const
   counter = counter+1
endfor
plot,  array(*, 0), indgen(counter-1)*0.01, thick=4,  xrange=[1, 3], $
   ytitle='Altitude',  xtitle='Gradient ln[C3H8]/ln[C2H6]'
oplot,  array(*, 1), indgen(counter-1)*0.01, thick=4,  color=50

plot,  array(*, 2), indgen(counter-1)*0.01, thick=4,  xrange=[0.5, 1.0], $
   ytitle='Altitude',  xtitle='R^2 ln[C3H8]/ln[C2H6]'
oplot,  array(*, 3), indgen(counter-1)*0.01, thick=4,  color=50

plot,  exp(array(*, 4)), indgen(counter-1)*0.01, thick=4, $
   ytitle='Altitude',  xtitle='Constant'
oplot,  exp(array(*, 5)), indgen(counter-1)*0.01, thick=4,  color=50

device,  /close
end

