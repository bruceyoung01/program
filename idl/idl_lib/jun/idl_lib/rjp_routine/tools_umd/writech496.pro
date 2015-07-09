;Latitudinal distribution of ch4 for 1993 (Dlugokencky et. al, 1994) in ppm
; 1993 values  for 10 degree intervals, -90 to 90 (19 values total) 
ch4 = fltarr(19) 
ch4(0:6) = replicate(1666,7) 
ch4(7) = 1670. & ch4(8) = 1677. & ch4(9) = 1695.
ch4(10) = 1730. & ch4(11) = 1736. & ch4(12) = 1770. & ch4(13) = 1794. 
ch4(14) = 1790. & ch4(15) = 1796 & ch4(16) = 1808. & ch4(17) = 1800. 
ch4(18) = 1800. 

;interpolate to 91 points
latcen =  18. * findgen(91) / (2.*45.)
ch4int= interpolate(ch4,latcen,/grid)
latcen = -90. + findgen(91)*2.
plot,latcen,ch4int,xrange=[-90.,90.],xstyle=1,xticks=6,$
title='[CH4] 1993, 1996',xtitle='latitude',$
ytitle='ppb',yrange=[1500.,1850.]

;calculate ch4 thru 1996. Assume annual increase of 5.5 ppb/yr
;Shipham  et al., 1998
ch4new=ch4int+16.5
oplot,latcen,ch4new


ch4s=fltarr(91,5) & fd=fltarr(91,12)  & ch4z=fltarr(91,26)
fd1=fltarr(91) & ijmm=91
; in stratosphere use values from Mark Jacobson (obtained from Guy Brasseur)
; at 122, 55, 25, 11.5 mb
ch4s(0,0)=ch4new
ch4s(0,1)=ch4new*0.8824
ch4s(0,2)=ch4new*0.7647 
ch4s(0,3)=ch4new*0.5529
ch4s(0,4)=ch4new*0.3941

;interpolate in stratosphere to model layers (convert to height first)
pp1=[221.053,122,55,25,11.5]
pp2=[221.053,187.857,158.723,133.674,$
     112.611,94.9410,80.1533,67.8056,57.5174,45.7492,$
     29.7962,10.9690]
htin  = -8 * alog(pp1 * .001)
htout = -8 * alog(pp2 * .001)
print,htout

for j=0,ijmm-1 do begin
     fdin=reform(ch4s(j,*))
     fdout=interp(htin,fdin,htout)
     for k=0,11 do fd(j,k)=fdout(k)
endfor 

openw,lunout,'methane',/f77_unformatted,/get_lun

;keep [ch4] constant within troposphere (up to layer w/ pressure=221 mb) 
for i=0,13 do begin
   fd1=fd(*,0)
;   writeu,lunout,fd(*,0)
endfor
;write out strat  interpolated values calculated above
for i=0,11 do begin
   fd1=fd(*,i)
;   writeu,lunout,fd1    
endfor

free_lun,lunout
stop
end
