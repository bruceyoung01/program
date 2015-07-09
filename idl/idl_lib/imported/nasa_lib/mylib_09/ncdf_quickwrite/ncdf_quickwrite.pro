print,'-------------------------'
if n_elements(ncfields) ne 1 then stop,'NCFIELDS not set'
print,'Writing fields: ',NCFIELDS

ncdf_quickwrite_helper1,ncfields,__ncdf,'__ncdf'
if __ncdf.ncommands eq -1 then stop

for __loop=0,__ncdf.ncommands-1 do $
  if not execute((*__ncdf.commands)[__loop]) then stop

ncdf_quickwrite_helper2,ncfile,__ncdf,'__ncdf'
if __ncdf.ncommands eq -1 then stop

for __loop=0,__ncdf.ncommands-1 do $
  if not execute((*__ncdf.commands)[__loop]) then stop

ncdf_quickwrite_helper3,__ncdf

print,'Written to ',NCFILE
print,'-------------------------'

