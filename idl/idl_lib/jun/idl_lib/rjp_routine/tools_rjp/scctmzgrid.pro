     ikmm = 25
     prslay25 = [10., 28.81, 48.61, 69.895, 94.645, $
             123.454, 158.302, 202.555, 258.490, 323.335, $
         393.625,    467.380,    543.610,    621.601,    699.484, $
         774.787,    844.721,    875.39563,  906.06880,  922.42360, $
         938.80315,  955.18270,  966.11923,  977.05576,  987.99229, $
        1000.000]
    
     sgint25 = fltarr(ikmm+1)
     ptop = prslay25(0)
     psfc = prslay25(ikmm)
 
     for ik = 0, ikmm do begin
      sgint25(ik) = (prslay25(ik)-ptop)/(psfc-ptop)
     endfor

     sigma25 = (sgint25(0:ikmm-1)+sgint25(1:ikmm))*0.5
     dsig25  = (sgint25(0:ikmm-1)-sgint25(1:ikmm))
     press25 = fltarr(ikmm)
     for ik = 0, ikmm-1 do begin
      press25(ik) = sigma25(ik)*(psfc-ptop)+ptop
      if (sigma25(ik) lt 0.) then press25(ik) = sigma25(ik)*(ptop-ptop)+ptop
     endfor

 set_plot, 'ps'
 device, file='zscctm.eps',xoffset=1.5,yoffset=1.5,xsize=18,ysize=24,/encapsul
 !p.charsize=1.5
 !p.thick = 4.
 plot, [0.3,0.7], [1000.,1000.], yrange=[1000.,10.], ystyle=5, ytitle='pressure(hpa)',  $
 title='Vertical layers of SCCTM', xstyle=4, line=1, xrange=[0.2,0.8]

 for i = 0, 25 do oplot, [0.3,0.7],[prslay25[i],prslay25[i]], line=1
 oplot, [0.3,0.7],[prslay25[23],prslay25[23]],line=0
 oplot, [0.3,0.7],[prslay25[22],prslay25[22]],line=0
 oplot, [0.3,0.7],[prslay25[20],prslay25[20]],line=0
 oplot, [0.3,0.7],[prslay25[19],prslay25[19]],line=0
 oplot, [0.3,0.7],[prslay25[17],prslay25[17]],line=0

 for i = 0, 25 do xyouts, 0.22, prslay25[i],  $
 strmid(strtrim(prslay25[i],1),0,5)+'['+strmid(strtrim(sgint25[i],1),0,5)+']', $
  charsize=0.6
 xyouts, 0.22, 1015., 'pressure[sigma]', charsize=0.6

device, /close
set_plot,'X'



end

