
;get the 'variable string' info in the TRACE-P merged (Sept 2001) data 
;hyl, 09/16/2001

pro read_varstr, file, NV, varstr

OpenR, unit, file, /get_lun

FNAME=''        &    PI=''       &     SUMMARY=''   
EXPEDITION=''   &    DATES=''    &     NF= ''

readf, unit, NH
readf, unit, FNAME
readf, unit, PI
readf, unit, SUMMARY
readf, unit, EXPEDITION
readf, unit, DATES
readf, unit, NF
readf, unit, NV   &  NV=fix(Nv)         ;# of variables
readf, unit, NC   			;# of comments 
readf, unit, DT   			;Dataset Type
readf, unit, DAP  			;Data Averaging Period
readf, unit, DSF  			;Data Sampling Frequency (Hertz)

;print, 'NH,DATES,NF,NV, NC,DT,DAP,DSF = ', NH,DATES,NF,NV, NC,DT,DAP,DSF

;get the variable string in Line 13 --> Line 13+NV-1

charline = ''
varstr = StrArr(NV)
for i = 0, NV-1 do begin
 readf, unit, charline
 headstr = StrTrim ( StrSplit ( StrTrim(charline,2), ',', /extract ), 2 )
;help, headstr       ;array[8] or array[12]
; print, string(i+1)+'th header string=', headstr
 varstr(i) = headstr(0)
endfor

;help, varstr 
;print, 'variable string= ', varstr
close, unit
free_lun,  unit
end
