pro pick_point, fd, var, pt

 if n_elements(fd)  eq 0 then return
 if n_elements(var) eq 0 then return

 results = size(fd)
 ndim = results(0)
 
 point = where(var eq fd)
 if point(0) eq -1 then begin
  print, 'There is no value'
  stop
 endif
 if n_elements(point) gt 1 then begin
  print, 'There are more than 2 points'
  print, fd(point)
  stop
 endif

 case ndim of 
  1 : pt = {ipt:point}
  2 : begin
      ilmm = results(1)
      jp = point/ilmm
      ip = point mod ilmm
      pt = {ipt:ip,jpt:jp}
      end
  3 : begin
      ilmm = results(1)
      ijmm = results(2)
      kp = point/(ilmm*ijmm)
      jp = (point mod (ilmm*ijmm))/ilmm
      ip = (point mod (ilmm*ijmm)) mod ilmm
      pt = {ipt:ip,jpt:jp,kpt:kp}
      end
 else : print, 'no values'
 endcase

end


