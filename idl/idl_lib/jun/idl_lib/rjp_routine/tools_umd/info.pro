; usage 
; I don't know

function info, file

if n_elements(file) eq 0 then return, 0

dd = '/data/eos3/stone/TOOLS/idl/'
openr, ilun, dd+file+'.pro', /get_lun

header = ''
while not eof(ilun) do begin
readf, ilun, header
header = strtrim(header,1)
if (strpos(header,';') eq 0) then print, header
endwhile

return, file
end
