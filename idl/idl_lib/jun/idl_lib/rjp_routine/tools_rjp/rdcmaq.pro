function rdcmaq,file,fdname,name_dim=name_dim,size_dim=size_dim

if n_elements(file) eq 0 then return, 0
if n_elements(fdname) eq 0 then fdname = ''
 fid   = ncdf_open(file)
 info  = ncdf_inquire(fid)
 ndims = info.ndims
 nvars = info.nvars

 Name_dim = strarr(ndims)
 Size_dim = intarr(ndims)

 for i = 0, ndims-1 do begin
  ncdf_diminq,fid,i,Name,Size
  Name_dim(i) = Name
  Size_dim(i) = Size
;  print, Name_dim(i), Size_dim(i)
 end

 fdname = strupcase(fdname)
 for i = 0, nvars-1 do begin
  fdinfo = ncdf_varinq(fid,i)
  if (fdname eq '') then begin
    help, fdinfo, /stru
    wait, 2
  end
  gasname = fdinfo.name
  gasname = strupcase(gasname)
  if ( gasname eq fdname ) then begin
   ncdf_varget, fid, i, fd
   goto, jump
  endif
 end
 return, 0

 jump : ncdf_close, fid

return, fd
end

