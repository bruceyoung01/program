function interh, fdin, lon2, lat2, $
                       lon1, lat1 ; output grid

if n_elements(fdin) eq 0 then return, 0
if n_elements(lon1) eq 0 then return, 0
if n_elements(lat1) eq 0 then return, 0
if n_elements(lon2) eq 0 then return, 0
if n_elements(lat2) eq 0 then return, 0

;....THIS SUBROUTINE MAKES PROJECTION (INTERPOLATION) OF 3-D ARRAY FROM.
;....REGULAR LATITUDE-LONGITUDE SPHERICAL GRID TO IRREGULAR ONE.........
;....REGULAR GRID IS DEFINED BY THE ONE DIMENSIONAL ARRAYS..............
;....OF LONGITUDE AND LONGITUDE. ARRAYS STRINGS AND COLUMNS ARE.........
;....ALONG LONGITUDES AND LATITUDES. IRREGULAR GRID HAS IRREGULAR.......
;....DISTRIBUTED NODES AND IS DEFINED BY 2-D ARRAYS OF LONGITUDE........
;....AND LATITUDE. ROTATED GRID LOOKS LIKE IRREGULAR IN OLD SYSTEM......

;....IF RESULTING DOMAIN IS LARGER THAN ORIGINAL- BOUNDARY VALUES.......
;....ARE EXTRAPOLATED...................................................
;....J INDEX IS CHANGING :
;........................  FROM 1 TO JM-1 FOR P AND U GRIDS ............
;........................  FROM 1 TO JM   FOR V GRID, SO AS ............
;........................  FOR J=1 AND J=JM V IS SUPPOUSED TO BE 0 .....
;........................  OR JUST MERIDIONAL FLUXES ...................
;....ALL DATA AND GRID ARRAYS MUST BE DEFINED FROM 1:JM AND 1:IM .......
;....VERTICAL DIMENSIONS LM MUST BE SAME FOR BOTH INPUT AND OUTPUT......
;....FOR 2-D ARRAYS LM=1................................................
;....OUTPUT ARRAY IS ALWAYS DEFINED AS IRREGULAR BY 2-D ARRAYS..........
;....OF LATITUDES AND LONGITUDES........................................
;....SO IN BOTH ROTATED AND NON ROTATED CASES WE USE 'NO' OR 'ON' ARRAYS
;....WHICH ARE QUASIIRREGULAR IN NONROTATED CASE, BUT STILL ARE DEFINED.
;....IN TRANSFRM SUBROUTINE.............................................
;.......................................................................
;....GEORGIY L. STENCHIKOV   10/10 1994.................................
;....ROKJIN J. PARK 10/29 2000..modified in IDL.........................
;....DEPARTMENT OF METEOROLOGY UNIVERSITY OF MARYLAND...................

dim = size(fdin,/dim)
im2 = dim(0) & jm2 = dim(1) ; Input dimension on regular grid

lonst = fltarr(im2+4)
fdinst = fltarr(im2+4,jm2)

lonst(0:1) = lon2(im2-2:im2-1)-360.
lonst(2:im2+1) = lon2
lonst(im2+2:im2+3) = lon2(0:1)+360.

fdinst(0:1,*) = fdin(im2-2:im2-1,*)
fdinst(2:im2+1,*) = fdin
fdinst(im2+2:im2+3,*) = fdin(0:1,*)


dim = size(lon1)
if dim(0) ne 2 then begin
   print, 'OUPUT grid should be 2 dimensions'
   return, 0
endif
im1 = dim(1) & jm1 = dim(2) ; Output dimension on regular/irregular grid
fdout = fltarr(im1,jm1)

 for j = 0, jm1-1 do begin
 for i = 0, im1-1 do begin
 
  ip = locate(lon1(i,j), lonst, cof=xcof)
  jp = locate(lat1(i,j), lat2, cof=ycof)

  fdout(i,j) = fdinst(ip  ,jp  )*(1.-xcof)*(1.-ycof) $
             + fdinst(ip+1,jp  )*  xcof   *(1.-ycof) $
             + fdinst(ip+1,jp+1)*  xcof   *   ycof   $
             + fdinst(ip  ,jp+1)*(1.-xcof)*   ycof
 end
 end


return, fdout
end
