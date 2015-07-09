function retrieve, file

format = '(A12,I6,12F7.3)'

openr, il, file, /get

hd = ' '
readf, il, hd

yymm = 1L
conc = fltarr(12)
west = fltarr(12, 12)
east = west
for d = 0, 11 do begin
  readf, il, hd
  readf, il, hd, yymm, conc, format=format
  west[d,*] = conc
  readf, il, hd, yymm, conc, format=format
  east[d,*] = conc
end

free_lun, il

return, {west:west, east:east}

end

;==================================

file ='usconc_std_1x1.txt'
std = retrieve(file)

file ='usconc_noasia_1x1.txt'
noasia = retrieve(file)


end
