openw,jjj,'../output/emission.144x91.b8501.e8512.dat_xdr',/xdr,/get
openw,ilun,'../output/emission.txt', /get

ilmm=144
ijmm=91
inter = 0

for i = 1, 12 do begin

 emis_builder, i, ilmm=ilmm, ijmm=ijmm, inter=inter, $
    NOx=NOx,CO=CO,ISOP=ISOP,C2H6=C2H6,C3H8=C3H8,C2H4=C2H4,C3H6=C3H6,CH3COCH3=CH3COCH3

 writeu,jjj,NOx
 writeu,jjj,CO
 writeu,jjj,ISOP
 writeu,jjj,C2H6
 writeu,jjj,C3H8
 writeu,jjj,C2H4
 writeu,jjj,C3H6
 writeu,jjj,CH3COCH3

 print, i

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 wco = 28.01 & wn = 14.007 & wc = 12.011
;
;...ISOP = ISOP * 380./502. ; Modified by [380/502] according to Spivakovski et al
 printf, ilun, ' '
 printf, ilun, ' Emission for the month of ', i
 printf, ilun, total(CO)*wco/1.e12, 'CO [Tg CO/mon]', format='(f8.3,A25)'
 printf, ilun, total(NOx)*wn/1.e12, 'NOx [Tg N/mon]', format='(f8.3,A25)'
 printf, ilun, total(ISOP)*5.*wc/1.e12, 'ISOP [Tg C/mon]', format='(f8.3,A25)'
 printf, ilun, total(C2H6)*2.*wc/1.e12, 'Ethane [Tg C/mon]', format='(f8.3,A25)'
 printf, ilun, total(C3H8)*3.*wc/1.e12, 'Propane [Tg C/mon]', format='(f8.3,A25)'
 printf, ilun, total(C2H4)*2.*wc/1.e12, 'Ethene [Tg C/mon]', format='(f8.3,A25)'
 printf, ilun, total(C3H6)*3.*wc/1.e12, 'Propene [Tg C/mon]', format='(f8.3,A25)'
 printf, ilun, total(CH3COCH3)*3.*wc/1.e12, 'Acetone [Tg C/mon]', format='(f8.3,A25)'

end

free_lun,jjj
free_lun,ilun

end
