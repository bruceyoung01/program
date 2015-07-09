; $ID: pixel_to_grid_degree.ncl V01 05/06/2012 22:09 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE pixel_to_grid_degree CONVERTS PIXEL DATA (NON-GRID) TO GRID DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv1        (scalar): BAD VALUE OF INTEGER                         [---]
;  (2 ) bv2        (scalar): BAD VALUE OF FLOAT                           [---]
;  (3 ) gclat         (2-D): LATITUDE IN EACH GRID BOX                    [DEG]
;  (4 ) gclon         (2-D): LONGITUDE IN EACH GRID BOX                   [DEG]
;  (5 ) lat_grid_size (scalar):GRID SIZE OF LATITUDE                      [DEG]
;  (6 ) lon_grid_size (scalar):GRID SIZE OF LONGITUDE                     [DEG]
;  (7 ) flat          (N-D): LATITUDE OF PIXEL DATA                       [DEG]
;  (8 ) flon          (N-D): LONGITUDE OF PIXEL DATA                      [DEG]
;  (9 ) minpixel   (scalar): THRESHOLD OF MINIMUM # OF PIXELS IN EACH GRID[---]
;  (10) pdat          (2-D): PIXEL DATA                                   [---]
;  (11) gdat          (2-D): GRID DATA                                    [---]
;  (12) pcon          (2-D): # OF PIXELS IN EACH GRID                     [---]
;  (13) stdd          (2-D): STANDARD DEVIATION OF PIXEL DATA IN EACH GRID[---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/06/2012)
;******************************************************************************

undef("pixel_to_grid_degree")
procedure pixel_to_grid_degree \
          (bv1           :integer, bv2           :float,  \ ; INPUT
           gclat         :float,   gclon         :float,  \ ; INPUT
           lat_grid_size :float,   lon_grid_size :float,  \ ; INPUT
           flat          :float,   flon          :float,  \ ; INPUT
           minpixel      :integer, pdat          :numeric,\ ; INPUT
           gdat          :numeric, pcon          :integer,\ ; OUTPUT
           stdd          :float)                            ; OUTPUT

begin
;  CALCULATE THE HALF MAGNITUDE OF GRID BOX
   dim   = dimsizes(gclat)
   nlgc  = dim(0)
   npgc  = dim(1)
   dx    = lon_grid_size/2.
   dy    = lat_grid_size/2.

;  JUDGE THE DIMENSION SIZE OF flat, flon, AND pdat
   ndim  = dimsizes(flat)
   nndim = dimsizes(ndim)

   if(nndim .eq. 2)then
;  DO GRID # LOOP
    do j = 0, nlgc-1
     do i = 0, npgc-1
      oned_pdat2 = ndtooned(pdat)
      oned_flat2 = ndtooned(flat)
      oned_flon2 = ndtooned(flon)
      index2 = ind(oned_flat2 .ge. gclat(i, j)-dy .and. \
                   oned_flat2 .le. gclat(i, j)+dy .and. \
                   oned_flon2 .ge. gclon(i, j)-dx .and. \
                   oned_flon2 .le. gclon(i, j)+dx)
      if(.not.all(ismissing(index2)))then
       if(.not.all(ismissing(oned_pdat2(index2))))then
        pcon(i, j) = num(.not.ismissing(index2))
        if(pcon(i, j) .ge. minpixel)then
         gdat(i, j) = avg(oned_pdat2(index2))
         stdd(i, j) = stddev(oned_pdat2(index2))
;if (.not.ismissing(gdat(i, j))) then
;   print("gdat(" + i + ", " + j + ") = " + gdat(i, j))
;   print("gclat(" + i + ", " + j + ") = " + gclat(i, j))
;   print("gclon(" + i + ", " + j + ") = " + gclon(i, j))
;end if
        end if
       end if
      else
       pcon(i, j) = bv1
       gdat(i, j) = bv2
       stdd(i, j) = bv2
      end if
      delete(index2)
     end do
    end do
   else if(nndim .eq. 3)then
    do k = 0, ndim(2)-1
    print("NOW WORKING ON DAY  :" + k + " OF " + ndim(2))
     do j = 0, nlgc-1
      do i = 0, npgc-1
       oned_pdat3 = ndtooned(pdat(:, :, k))
       oned_flat3 = ndtooned(flat(:, :, k))
       oned_flon3 = ndtooned(flon(:, :, k))
       index3 = ind(oned_flat3 .ge. gclat(i, j)-dy .and. \
                    oned_flat3 .le. gclat(i, j)+dy .and. \
                    oned_flon3 .ge. gclon(i, j)-dx .and. \
                    oned_flon3 .le. gclon(i, j)+dx)
       if(.not.all(ismissing(index3)))then
        if(.not.all(ismissing(oned_pdat3(index3))))then
         pcon(i, j, k) = num(.not.ismissing(index3))
         if(pcon(i, j, k) .ge. minpixel)then
          gdat(i, j, k) = avg(oned_pdat3(index3))
          stdd(i, j, k) = stddev(oned_pdat3(index3))
         end if
        end if
       else
        pcon(i, j, k) = bv1
        gdat(i, j, k) = bv2
        stdd(i, j, k) = bv2
       end if
       delete(index3)
      end do
     end do
    end do
   end if
   end if
return
end
