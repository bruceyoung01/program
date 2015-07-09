;+
;PROGRAM:
;        grid.pro
;PURPOSE:
;        Define transport grid for GEOS DAS models
;COMMON BLOCKS:  
      
;DATE:
;        4 October 1994 (mcor and mass made 2 and 3-d) 
; 
;-
function grid,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,sigma=sigma,sgint=sgint,$
ht=ht,prslay=prslay,mass=mass,mcor=mcor,latcen=latcen,loncen=loncen,dp=dp,$
latedge=latedge,pint=pint,he=he,ptop=ptop,psf=psf,dy=dy,oned=oned,ktrop=ktrop,$
fac=fac,dsngrid=dsngrid,kstrat=kstrat,scaleht=scaleht,lonedge=lonedge,$
spress=spress,sprslay=sprslay,deltas=deltas,dd=dd 

if n_elements(dd) eq 0 then dd = '/data/eos1/allen/ctm/grid/'
case n_elements(dsngrid) of
0: begin
      dsngrid = 'hgrid14491.input_f77' 
      print,'dsngrid not specified: assume hgrid14491.input_f77
   end
else:
endcase 

if n_elements(scaleht) eq 0 then scaleht = 8.    

if n_elements(oned) eq 0 then oned = 0 
case oned of
1: begin
    ilmm = 1
    ijmm = 1 
   end 
else: loncen = rdgrid(dsn=dsngrid,dlonedge=lonedge,dlatcen=latcen,$
       dlatedge=latedge,ilmm=ilmm,ijmm=ijmm,dd=dd) 
endcase

if n_elements(ikmm) eq 0 then ikmm =  20
if n_elements(fac) eq 0 then fac = 1.e-15  
if n_elements(psf) eq 0 then begin psf = fltarr(ilmm,ijmm) & psf(*,*) = 1000. & end 
press = fltarr(ilmm,ijmm,ikmm) 
prslay = fltarr(ilmm,ijmm,ikmm+1)  

case ikmm of 
20: begin 
       pint = 10. 
       ktrop=ikmm
       kstrat = 0 
       ptop = pint 
       sigma = [.993936,.971301,.929925,.874137,.807833,.734480,.657114,$
        .578390,.500500,.424750,.352000,.283750,.222750,.172150,$
        .132200,.10050,.073000,.049750,.029000,.009500] 

       sgint=[1.000000,0.987871,0.954730,0.905120,0.843153,0.772512,0.696448,$
        0.617779,0.539000,0.462000,0.387500,0.316500,0.251000,0.194500,$
        0.149800,0.114600,0.085500,0.060500,0.039000,0.019000,0.00000] 

       ;Press and prslay are calculated ASSUMING psf = 1000! 
       ;Formula is sigma=(press-pint) /(psf-pint)
       ;           sgint=(prslay-pint)/(psf-pint)
       
       for ik=0,ikmm-1 do press(0,0,ik) = sigma(ik)*(psf(*,*)-pint) + pint
       for ik=0,ikmm do  prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint) + pint 
;       press = $ 
;       [9.94000E+02,9.71590E+02,9.30630E+02,8.75400E+02,8.09750E+02, $
;        7.37140E+02, 6.60540E+02,5.82610E+02, 5.05500E+02, 4.30500E+02,$ 
;        3.58480E+02, 2.90910E+02, 2.30520E+02,1.80430E+02,1.40880E+02, $
;        1.09050E+02, 8.22700E+01, 5.92500E+01, 3.87100E+01, 1.94100E+01]

;       prslay = [1000.,9.87990E+02,9.55180E+02,9.06070E+02,8.44720E+02,$
;        7.74790E+02,6.99480E+02,6.21600E+02,5.43610E+02,4.67380E+02,$
;        3.93630E+02,3.23340E+02,2.58490E+02,2.02560E+02,1.58300E+02,$
;        1.23450E+02,9.46500E+01,6.99000E+01,4.86100E+01, 2.88100E+01,$
;        1.00000E+01]
   end

25: begin
     prslay25 = [1000.000, 997.095, 991.200, 981.500, 967.100, 946.801, 919.501, $
                  884.001, 839.002, 783.002, 718.203, 647.604, 574.104, 500.005, $    
                  427.806, 359.506, 297.057, 241.958, 202.555, 158.302, 123.454, $ 
                  94.6450, 69.8950, 48.6100, 28.8100, 10.0000]

     sgint = fltarr(ikmm+1)
     ptop = prslay25(ikmm)
     pint = 241.958
     psfc = prslay25(0)

     for ik = 0, ikmm do begin
      sgint(ik) = (prslay25(ik)-pint)/(psfc-pint)
      if prslay25(ik) lt pint then sgint(ik) = (prslay25(ik)-pint)/(pint-ptop)
     endfor

     sigma = (sgint(0:ikmm-1)+sgint(1:ikmm))*0.5

     for ik = 0, ikmm-1 do begin
      press(0,0,ik) = sigma(ik)*(psfc-pint)+pint
      if (sigma(ik) lt 0.) then press(0,0,ik) = sigma(ik)*(pint-ptop)+pint
     endfor

     prslay(0,0,*) = prslay25
    end
70: begin
       pint = 0.01 
       ptop = pint 
       ktrop=ikmm
       kstrat = 0 
       sgint=[0.00000    ,6.01635e-06,1.37082e-05,2.29524e-05,3.40184e-05,$
              4.80209e-05,6.59413e-05,8.86501e-05,0.000117785,0.000155016,$
              0.000202404,0.000262483,0.000338348,0.000433766,0.000553297,$
              0.000702439,0.000887780,0.00111801 ,0.00140307 ,0.00175490 ,$
              0.00218774 ,0.00271855 ,0.00336739 ,0.00415795 ,0.00511809 ,$
              0.00628039 ,0.00768288 ,0.00936969 ,0.0113918  ,0.0138081  ,$
              0.0166858  ,0.0201020  ,0.0241439  ,0.0289104  ,0.0345100  ,$
              0.0410763  ,0.0487200  ,0.0575737  ,0.0678111  ,0.0796365  ,$
              0.0932521  ,0.108878   ,0.126755   ,0.147130   ,0.170300   ,$
              0.196550   ,0.226250   ,0.259550   ,0.296280   ,0.336070   ,$
              0.378450   ,0.423030   ,0.469400   ,0.517035   ,0.565419   ,$
              0.613850   ,0.661599   ,0.707896   ,0.751944   ,0.792970   ,$
              0.830300   ,0.863570   ,0.892744   ,0.917900   ,0.939230   ,$
              0.957000   ,0.971500   ,0.982900   ,0.991400   ,0.997095   ,$
              1.00000]
        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
     end
46: begin
       pint = 1.0 
       ptop = pint 
       ktrop=ikmm 
       kstrat = 0
       sgint=[.000,9.4e-5,2.39e-4,4.49e-4,7.37e-4,1.121e-3,$
        1.616e-3,2.24e-3,3.011e-3,3.948e-3,5.072e-3,6.402e-3,7.96e-3,$
        9.7670e-3,1.1848e-2,1.4223e-2,1.6919e-2,$
        1.9958e-2,2.3367e-2,2.7422e-2,3.2162e-2,3.7692e-2,4.4128e-2,$
        5.1896e-2,6.1252e-2,7.2493e-2,8.5972e-2,0.102098,0.121347,$
        0.144267,0.171495,0.202593,0.237954,0.2780,0.325,0.38,0.44,$
        0.503,0.57,0.639,0.710,0.780,0.845,0.90512,0.95473,0.98787,1.]     
        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
     end
26: begin
       pint = 1.0 
       ptop = pint 
       ktrop= ikmm 
       kstrat = 0 
       sgint=[.000,      1.9958e-2, 3.7692e-2, 5.1896e-2, 6.1252e-2,$
              7.2493e-2, 8.5972e-2, 0.102098,  0.121347,  0.144267,$
	      0.171495,  0.202593,  0.237954,  0.2780,    0.325,$
	      0.38,      0.44,      0.503,     0.57,      0.639,$
	      0.710,     0.780,     0.845,     0.90512,   0.95473,$
	      0.98787,   1.]     
        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
     end
28: begin
        ktrop = 7 
        kstrat = 21 
        ikmm = ktrop + kstrat
        prslay0 = [1000.00, 843.304, 707.036, 595.789, 494.923, $
          393.598, 308.007, 247.462, 204.531, 174.100, 150.415, $
          130.000, 108.628, 93.8084, 82.3165, 72.4290, 62.3167, $
          51.4364, 38.3119, 26.1016, 17.7828, 12.1153, 8.25404, $
          5.62341, 3.83119, 2.61016, 1.77828, 1.00000, .430576] 

        ptop = prslay0(ikmm) 
        pint = prslay0(ktrop) 
	     
        press0 = fltarr(ikmm) & sigma = fltarr(ikmm) & sgint = fltarr(ikmm+1) 	    
       
        for ik=0,ikmm-1 do begin	  
           press0(ik) = 1000.*(prslay0(ik+1)*prslay0(ik)*1.e-6)^0.5 
        endfor 
        for ik=0,ktrop-1 do begin	  
           sigma(ik) = (press0(ik)-pint)/(prslay0(0)-pint)
        endfor 
        for ik=0,ktrop do begin	  
           sgint(ik) = (prslay0(ik)-pint)/(prslay0(0)-pint) 
        endfor 

        for ik=ktrop,ikmm-1 do begin
           sigma(ik) = (press0(ik)-pint)/(pint-ptop)
           sgint(ik) = (prslay0(ik)-pint)/(pint-ptop)
        endfor  

        ik=ikmm   
        sgint(ik) = (prslay0(ik)-pint)/(pint-ptop)	       

        press = fltarr(ilmm,ijmm,ikmm) & prslay = fltarr(ilmm,ijmm,ikmm+1) 
        for ik=0,ktrop-1 do begin
           press(0,0,ik) = sigma(ik)*(psf-pint)+pint
           prslay(0,0,ik) = sgint(ik)*(psf-pint)+pint 
        endfor 
        for ik=ktrop,ikmm-1 do begin
           press(*,*,ik) = press0(ik)
           prslay(*,*,ik) = prslay0(ik)
        endfor
        ik = ikmm
        prslay(*,*,ik) = prslay0(ik) 
     end 

48: begin
       pint = 0.01
       ptop = pint
       ktrop=ikmm
       kstrat = 0 
       sgint = [0.000000E+00, 1.768000E-05, 4.750000E-05, 9.200000E-05,$
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
        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
      end 
30: begin
       pint = 0.01
       ptop = pint
       ktrop=ikmm
       kstrat = 0 
       sgint = [1.0, $
           9.97095E-01,9.91200E-01,9.81500E-01,9.67100E-01,9.46800E-01, $
          9.19500E-01,8.84000E-01,8.39000E-01,7.83000E-01,7.18200E-01, $
          6.47600E-01,5.74100E-01,5.00000E-01,4.27800E-01,3.59500E-01, $
          2.97050E-01,2.41950E-01,1.94640E-01,1.55000E-01,1.22680E-01, $
          9.69000E-02,7.64800E-02,6.03500E-02,4.76100E-02,3.75400E-02, $
          2.96000E-02,1.83800E-02,8.97500E-03,1.06000E-03,0.00000E+00]
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
      end 
36: begin
       pint = 0.01
       ptop = pint
       ktrop=ikmm
       kstrat = 0 
       sgint = [0.0E+00, 3.259000E-05, 1.235000E-04, 3.075000E-04,$
           6.525000E-04, 1.250000E-03, 2.225000E-03, 3.790000E-03,$
	   6.270000E-03, 1.019000E-02, 1.643000E-02, 2.646500E-02,$
	   4.257500E-02, 6.035000E-02, 7.648000E-02, 9.690000E-02,$
           1.226800E-01, 1.550000E-01, 1.946400E-01, 2.419500E-01,$
           2.970500E-01, 3.595000E-01, 4.278000E-01, 5.000000E-01,$
           5.741000E-01, 6.476000E-01, 7.182000E-01, 7.830000E-01,$
           8.390000E-01, 8.840000E-01, 9.195000E-01, 9.468000E-01,$
           9.671000E-01, 9.815000E-01, 9.912000E-01, 9.970951E-01,$
           1.000000E+00]
        sgint = reverse(sgint) 
        sigma = fltarr(ikmm) 
        for ik=0,ikmm-1 do sigma(ik) = (sgint(ik)+sgint(ik+1))*0.5
        for ik=0,ikmm-1 do press(0,0,ik)  = sigma(ik)*(psf(*,*)-pint)+pint
        for ik=0,ikmm   do prslay(0,0,ik) = sgint(ik)*(psf(*,*)-pint)+pint 
      end 
35: begin
        ktrop = 17 
        kstrat = 18 
        ikmm = ktrop + kstrat
        prslay0 = $
        [1.000000e+03, 9.970952e+02, 9.912001e+02, 9.815002e+02, 9.671003e+02, $
         9.468005e+02, 9.195008e+02, 8.840012e+02, 8.390016e+02, 7.830021e+02, $
         7.182028e+02, 6.476035e+02, 5.741043e+02, 5.000050e+02, 4.278057e+02, $
         3.595064e+02, 2.970570e+02, 2.419576e+02, 1.946480e+02, 1.550084e+02, $
         1.226888e+02, 9.690903e+01, 7.648923e+01, 6.035939e+01, 4.761952e+01, $
         3.754962e+01, 2.781744e+01, 1.935912e+01, 1.265640e+01, 7.773055e+00, $
         4.484663e+00, 2.430661e+00, 1.237587e+00, 5.919479e-01, 1.019991e-01, $
         1.000000e-02]
 
        ptop = prslay0(ikmm) 
        pint = prslay0(ktrop) 
	     
        press0 = fltarr(ikmm) & sigma = fltarr(ikmm) & sgint = fltarr(ikmm+1) 	    
       
        for ik=0,ikmm-1 do begin	  
           press0(ik) = 1000.*(prslay0(ik+1)*prslay0(ik)*1.e-6)^0.5 
        endfor 
        for ik=0,ktrop-1 do begin	  
           sigma(ik) = (press0(ik)-pint)/(prslay0(0)-pint)
        endfor 
        for ik=0,ktrop do begin	  
           sgint(ik) = (prslay0(ik)-pint)/(prslay0(0)-pint) 
        endfor 

        for ik=ktrop,ikmm-1 do begin
           sigma(ik) = (press0(ik)-pint)/(pint-ptop)
           sgint(ik) = (prslay0(ik)-pint)/(pint-ptop)
        endfor  

        ik=ikmm   
        sgint(ik) = (prslay0(ik)-pint)/(pint-ptop)	       

        press = fltarr(ilmm,ijmm,ikmm) & prslay = fltarr(ilmm,ijmm,ikmm+1) 
        for ik=0,ktrop-1 do begin
           press(0,0,ik) = sigma(ik)*(psf-pint)+pint
           prslay(0,0,ik) = sgint(ik)*(psf-pint)+pint 
        endfor 
        for ik=ktrop,ikmm-1 do begin
           press(*,*,ik) = press0(ik)
           prslay(*,*,ik) = prslay0(ik)
        endfor
        ik = ikmm
        prslay(*,*,ik) = prslay0(ik) 
     end 
else: begin
       print,'Please respecify ikmm'
       stop
      end 
endcase

ht = -scaleht * alog(press*0.001)    
he = -scaleht * alog(prslay*.001) 

dp = prslay - shift(prslay,0,0,-1) 
dp = dp(*,*,0:ikmm-1) 


mcor = setmcor(dlatedge=latedge,dlonedge=lonedge,fac=fac) 

g = 9.8 & mass=fltarr(ilmm,ijmm,ikmm) 
for k=0,ikmm-1 do begin
for j=0,ijmm-1 do begin
   mass(0,j,k) = 100.*mcor(*,j)*dp(*,j,k)/g
endfor
endfor 

case oned of 
1: begin
    press = reform(press(0,0,*)) & prslay = reform(prslay(0,0,*))
    mass = reform(mass(0,0,*))   & dp = reform(dp(0,0,*))
    ht = reform(ht(0,0,*))       & he = reform(he(0,0,*))
    spress = format(press,sformat='f7.2') 
    sprslay = format(prslay,sformat='f7.2') 
   end
else:
endcase 

deltas = sgint - shift(sgint,-1)
deltas = deltas(0:ikmm-1)

return,press  
end 
