function aave, fdin, lonin, latin, $
                     lonot, latot

;fdin is the input field to be interpolated
; Also all grid must be at the edge (not center)
;lonin and latin are input grid (1-D grid)
;lonot and latot are output grid (2-D grid)

if n_elements(fdin) eq 0 then return, 0
if n_elements(lonot) eq 0 then return, 0
if n_elements(latot) eq 0 then return, 0
if n_elements(lonin) eq 0 then return, 0
if n_elements(latin) eq 0 then return, 0

dim = size(fdin)
im2 = dim(1) & jm2 = dim(2) ; Input dimension on regular grid

 case dim(0) of 
      2 : LM = 1
      3 : LM = dim(3)
   else : return, 0
 end

; stretching input grid and field
 fdinst = [fdin(im2-7:im2-1,*),fdin,fdin(0:6,*)]
 lonst  = [lonin(im2-7:im2-1)-360.,lonin,lonin(1:7)+360.]

dim = size(lonot)
if dim(0) ne 2 then begin
   print, 'OUPUT grid should be 2 dimensions'
   return, 0
endif
im1 = dim(1)-1 & jm1 = dim(2)-1 ; Output dimension on regular/irregular grid
fdout = fltarr(im1,jm1)

 for j = 0, jm1-1 do begin
 for i = 0, im1-1 do begin
  ip1 = locate(lonot(i,j),   lonst, cof=xcof1)
  ip2 = locate(lonot(i+1,j), lonst, cof=xcof2)

  jp1 = locate(latot(i,j),   latin, cof=ycof1)
  jp2 = locate(latot(i,j+1), latin, cof=ycof2)

  nx = ip2(0)-ip1(0)+1 & ny = jp2(0)-jp1(0)+1
  XX = replicate(1.,nx) & YY = replicate(1.,ny)
  XX(0) = 1.-xcof1 & XX(nx-1) = xcof2
  YY(0) = 1.-ycof1 & YY(ny-1) = ycof2

  if (nx eq 1) then XX(0) = xcof2 - xcof1
  if (ny eq 1) then YY(0) = ycof2 - ycof1

  sum = 0.
  for jj = jp1(0), jp2(0) do begin
  for ii = ip1(0), ip2(0) do begin
     if (XX(ii-ip1(0)) lt 0. or YY(jj-jp1(0)) lt 0.) then begin
         print, 'Weight cannot be negative',XX(ii-ip1(0)),YY(jj-jp1(0))
         stop
     endif
      weight = XX(ii-ip1(0))*YY(jj-jp1(0))
      sum = sum + weight * fdinst(ii,jj)
  end
  end
  
  fdout(i,j) = sum
 end
 end

 return, fdout
 end
