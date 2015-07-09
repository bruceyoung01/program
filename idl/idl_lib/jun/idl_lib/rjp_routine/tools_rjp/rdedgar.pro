;+
;PROGRAM:
;        rdedgar.pro
;PURPOSE:
;        read edgarv2.0 emission inventories. 
;COMMENTS:
;        Unit of inventory(kg/yr) is converted to (g/cm2/yr)
      
;DATE:
;        April, 29, 1999 
; 
;-
function rdedgar, file=file

if n_elements(file) eq 0 then return, 0

n = size(file,/n_elements)

a = 6.371220e8 ; Earth's radius in cm
ilmm = 360 & ijmm = 180

lat = fltarr(ijmm) & lon = fltarr(ilmm)
dat = fltarr(ilmm,ijmm)
out = dat 

if (n eq 1 ) then begin
  if(file(0) eq '') then return, out
end 

area = sfcarea(ilmm=ilmm,ijmm=ijmm,grid_type='C')

for jj = 0 , n-1 do begin

openr, ilun, file(jj), /get_lun
header = ''

for k = 0, 11 do begin
 readf, ilun, header 
 print, header
end

while(not eof(ilun)) do begin
 readf, ilun, I , J , c
 I = fix(I) + 180 
 J = fix(J) + 90
 dat(I,J) = 1000.* c ; Convert from kg/yr to g/yr
end

 out = out + dat
 print, jj, min(dat),max(dat),total(dat)
 dat(*,*) = 0.
 free_lun, ilun
end

 print, jj-1,min(out),max(out),total(out)

 return, out  ;/area  return the conc in g/yr
end
