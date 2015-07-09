function aave, fdin, lon2b, lat2b, $
                     lon1b, lat1b

if n_elements(fdin) eq 0 then return, 0
if n_elements(lon1b) eq 0 then return, 0
if n_elements(lat1b) eq 0 then return, 0
if n_elements(lon2b) eq 0 then return, 0
if n_elements(lat2b) eq 0 then return, 0

dim = size(fdin)
im2 = dim(1) & jm2 = dim(2) ; Input dimension on regular grid

 case dim(0) of 
      2 : LM = 1
      3 : LM = dim(3)
   else : return, 0
 end

 lonst  = [lon2b(im2-5:im2-1)-360.,lon2b,lon2b(1:5)+360.]
 fdinst = [fdin(im2-5:im2-1,*),fdin,fdin(0:4,*)]

dim = size(lon1b)
if dim(0) ne 2 then begin
   print, 'OUPUT grid should be 2 dimensions'
   return, 0
endif
im1 = dim(1)-1 & jm1 = dim(2)-1 ; Output dimension on regular/irregular grid
fdout = fltarr(im1,jm1)

 for j = 0, jm1-1 do begin
 for i = 0, im1-1 do begin
  ip1 = locate(lon1b(i,j),   lon2b, cof=xcof1)
  ip2 = locate(lon1b(i+1,j), lon2b, cof=xcof2)

  jp1 = locate(lat1b(i,j),   lat2b, cof=ycof1)
  jp2 = locate(lat1b(i,j+1), lat2b, cof=ycof2)

  nx = ip2(0)-ip1(0)+1 & ny = jp2(0)-jp1(0)+1
  XX = replicate(1.,nx) & YY = replicate(1.,ny)
  XX(0) = 1.-xcof1 & XX(nx-1) = xcof2
  YY(0) = 1.-ycof1 & YY(ny-1) = ycof2

  sum = 0.
  for jj = jp1(0), jp2(0) do begin
  for ii = ip1(0), ip2(0) do begin
      weight = XX(ii-ip1)*YY(jj-jp1)
      sum = sum + weight * fdin(ii,jj)
  end
  end
  
  fdout(i,j) = sum
 end
 end

 return, fdout
 end
