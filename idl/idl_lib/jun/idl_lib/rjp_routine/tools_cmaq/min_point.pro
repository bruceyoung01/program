pro min_point, fd, pt

 if n_elements(fd) eq 0 then return

 dim = size(fd,/dim)
 ilmm = dim(0)
 ijmm = dim(1)

 minvalue = min(fd)

 for j = 0, ijmm-1 do begin
 for i = 0, ilmm-1 do begin
  if (fd(i,j) eq minvalue) then begin
     ip = i
     jp = j
  endif
 endfor
 endfor

 pt = {ipt:ip,jpt:jp}

end

