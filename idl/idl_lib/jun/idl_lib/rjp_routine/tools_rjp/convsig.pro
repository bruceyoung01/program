       ikmm = 48
       pint = 0.01
       ptop = pint
       psfc = 1000.00
       ktrop=ikmm
       kstrat = 0
       sgint48 = [0.000000E+00, 1.768000E-05, 4.750000E-05, 9.200000E-05,$
           1.550000E-04, 2.450000E-04, 3.700000E-04, 5.400000E-04,$
           7.650000E-04, 1.060000E-03, 1.440000E-03, 1.920000E-03,$
           2.530000E-03, 3.300000E-03, 4.280000E-03, 5.500000E-03,$
           7.040000E-03, 8.975000E-03, 1.140500E-02, 1.448000E-02,$
           1.838000E-02, 2.333000E-02, 2.960000E-02, 3.754000E-02,$
           4.761000E-02, 6.035000E-02, 7.648000E-02, 9.690000E-02,$
           1.226800E-01, 1.550000E-01, 1.946400E-01, 2.419500E-01,$
           2.970500E-01, 3.595000E-01, 4.278000E-01, 5.000000E-01,$
           5.741000E-01, 6.476000E-01, 7.182000E-01, 7.830000E-01,$
           8.390000E-01, 8.840000E-01, 9.195000E-01, 9.468000E-01,$
           9.671000E-01, 9.815000E-01, 9.912000E-01, 9.970951E-01,$
           1.000000E+00]
        sgint48 = reverse(sgint48)
        sigma48 = (sgint48(0:ikmm-1)+sgint48(1:ikmm))*0.5

        prslay48 = sgint48*(psfc-pint) + pint 
        press48 = sigma48*(psfc-pint)+pint


       pint = 10. 
       ktrop=ikmm
       kstrat = 0 
       ptop = pint 
       sigma20 = [.993936,.971301,.929925,.874137,.807833,.734480,.657114,$
        .578390,.500500,.424750,.352000,.283750,.222750,.172150,$
        .132200,.10050,.073000,.049750,.029000,.009500] 

       sgint20=[1.000000,0.987871,0.954730,0.905120,0.843153,0.772512,0.696448,$
        0.617779,0.539000,0.462000,0.387500,0.316500,0.251000,0.194500,$
        0.149800,0.114600,0.085500,0.060500,0.039000,0.019000,0.00000] 

       ;Press and prslay are calculated ASSUMING psf = 1000! 
       ;Formula is sigma=(press-pint) /(psf-pint)
       ;           sgint=(prslay-pint)/(psf-pint)
       
       press20 = sigma20*(psfc-pint) + pint
       prslay20 = sgint20*(psfc-pint) + pint 


     ikmm = 25
     prslay25 = [1000.000, 997.095, 991.200, 981.500, 967.100, 946.801, 919.501, $
                  884.001, 839.002, 783.002, 718.203, 647.604, 574.104, 500.005, $    
                  427.806, 359.506, 297.057, 241.958, 202.555, 158.302, 123.454, $ 
                  94.6450, 69.8950, 48.6100, 28.8100, 10.0000]
    
     sgint25 = fltarr(ikmm+1)
     ptop = prslay25(ikmm)
     pint = 241.958
     psfc = prslay25(0)
 
     for ik = 0, ikmm do begin
      sgint25(ik) = (prslay25(ik)-pint)/(psfc-pint)
      if prslay25(ik) lt pint then sgint25(ik) = (prslay25(ik)-pint)/(pint-ptop)
     endfor

     sigma25 = (sgint25(0:ikmm-1)+sgint25(1:ikmm))*0.5
     dsig25  = (sgint25(0:ikmm-1)-sgint25(1:ikmm))
     press25 = fltarr(ikmm)
     for ik = 0, ikmm-1 do begin
      press25(ik) = sigma25(ik)*(psfc-pint)+pint
      if (sigma25(ik) lt 0.) then press25(ik) = sigma25(ik)*(pint-ptop)+pint
     endfor

set_plot, 'ps'
device, file='zcoord.eps',xsize=18,ysize=24,encapsulated=1
!p.charsize=1.5
!p.thick = 4.
!p.position=[0.20,0.02,0.95,0.95]
plot, [0,0], [0.,1000.], yrange=[1100.,0.01], ystyle=1, /ylog,  $
 ytitle='pressure(hpa)', title='Vertical coordinate used in UMD-CTMs',$
 xstyle=4

for i = 0, 48 do oplot, [0.1,0.3],[prslay48[i],prslay48[i]], line=1
for i = 0, 20 do oplot, [0.7,0.9],[prslay20[i],prslay20[i]], line=1
for i = 0, 25 do oplot, [0.4,0.6],[prslay25[i],prslay25[i]]
a = findgen(3)*0.1+0.4
b = replicate(pint,9)
oplot, a, b, psym=2

xyouts, 0.25, 0.55, 'SG-GCM[48]', /normal

xyouts, 0.73, 0.55, 'Uniform', /normal
xyouts, 0.73, 0.53, 'CTM (20)', /normal
;xyouts, 0.74, 0.83, '{pure sigma}', /normal

xyouts, 0.49, 0.55, 'Stretched', /normal
xyouts, 0.49, 0.53, 'CTM (25)',/normal

;xyouts, 0.49, 0.83, '{hybrid sigma',/normal
;xyouts, 0.49, 0.81, '-pressure}', /normal

;xyouts, 0.88, 0.27, 'pint', /normal
device, /close
set_plot,'X'

;...Test purpose

    pl20 = prslay20
    sg20 = fltarr(21)
    ptop = pl20(20)
    pint = 258.490
    psfc = prslay20(0)

     for ik = 0, 20 do begin
      sg20(ik) = (pl20(ik)-pint)/(psfc-pint)
      if pl20(ik) lt pint then sg20(ik) = (pl20(ik)-pint)/(pint-ptop)
     endfor


end

