 function aqs_specinfo

 Openr, il, 'spec_map.txt', /get

 a = 'x'
 i = 0L
 id= 0L
 na= 'x'

 while (not eof(il)) do begin
    readf, il, i, a, format='(I5,1x,a29)'
    id = [id, i]
    na = [na, strtrim(a,2)]
 end
 free_lun, il

 return, {specid:id[1:*],name:na[1:*]}
 
 end
 
