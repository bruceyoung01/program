pro read_sondes_4lev_mozaic, name, sonde, std_sonde

 sonde=fltarr(12,4)
 std_sonde=fltarr(12,4)


openr, usta, name, /get_lun 
line=''
; Read in means and stds

; Skip first 4 lines
for i=0,3 do begin
    readf,usta,line, $
    format='(a30)'
    ;print, line
endfor

means=fltarr(26,12)
stdev=fltarr(26,12)


; Now read monthly means

for i=0,25 do begin
    readf,usta,pres, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, $
    format='(f6.2,3x,12(f5.2,1x))'
    means[i,0]=m1
    means[i,1]=m2
    means[i,2]=m3
    means[i,3]=m4
    means[i,4]=m5
    means[i,5]=m6
    means[i,6]=m7
    means[i,7]=m8
    means[i,8]=m9
    means[i,9]=m10
    means[i,10]=m11
    means[i,11]=m12
endfor

for i=0,11 do begin
	sonde[i,0]=means[1,i]
	sonde[i,1]=means[4,i]
	sonde[i,2]=means[9,i]
        sonde[i,3]=means[15,i]
endfor

;print, sonde

; Skip more lines
for i=0,27 do begin
    readf,usta,line, $
    format='(a30)'
endfor

; Now read monthly stds
for i=0,25 do begin
    readf,usta,pres, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, $
    format='(f6.2,3x,12(f5.2,1x))'
    stdev[i,0]=s1
    stdev[i,1]=s2
    stdev[i,2]=s3
    stdev[i,3]=s4
    stdev[i,4]=s5
    stdev[i,5]=s6
    stdev[i,6]=s7
    stdev[i,7]=s8
    stdev[i,8]=s9
    stdev[i,9]=s10
    stdev[i,10]=s11
    stdev[i,11]=s12
endfor


for i=0,11 do begin
	std_sonde[i,0]=stdev[1,i]
	std_sonde[i,1]=stdev[3,i]
	std_sonde[i,2]=stdev[9,i]
        std_sonde[i,3]=stdev[15,i]
endfor

;print, std_sonde

 close,/all

return
end
