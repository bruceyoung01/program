; $ID: pixel_to_grid_degree.ncl V01 05/06/2012 22:09 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE pixel_to_grid_degree CONVERTS PIXEL DATA (NON-GRID) TO GRID DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv1       (integer): BAD VALUE OF INTEGER                         [---]
;  (2 ) bv2       (float)  : BAD VALUE OF FLOAT                           [---]
;  (3 ) gclat     (float)  : LATITUDE IN EACH GRID BOX (2-D)              [deg]
;  (4 ) gclon     (float)  : LONGITUDE IN EACH GRID BOX (2-D)             [deg]
;  (5 ) npgc      (integer): # OF LATITUDE GRID                           [---]
;  (6 ) nlgc      (integer): # OF LONGITUDE GRID                          [---]
;  (7 ) flat      (float)  : LATITUDE OF PIXEL DATA (2-D)                 [deg]
;  (8 ) flon      (float)  : LONGITUDE OF PIXEL DATA (2-D)                [deg]
;  (9 ) np        (integer): # OF PIXELS OF GRANULE WIDTH                 [---]
;  (10) nl        (integer): # OF PIXELS OF GRANULE LENGTH                [---]
;  (11) minpixel  (integer): THRESHOLD OF MINIMUM # OF PIXELS IN EACH GRID[---]
;  (12) pdat      (float)  : PIXEL DATA                                   [---]
;  (13) gdat      (float)  : GRID DATA                                    [---]
;  (14) pcon      (float)  : # OF PIXELS IN EACH GRID                     [---]
;  (15) stdd      (float)  : STANDARD DEVIATION OF PIXEL DATA IN EACH GRID[---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/06/2012)
;******************************************************************************

undef("pixel_to_grid_degree")
procedure pixel_to_grid_degree \
                        (bv1      :integer, bv2      :float,  \ ; INPUT
                         gclat    :float,   gclon    :float,  \ ; INPUT
                         npgc     :integer, nlgc     :integer,\ ; INPUT
                         flat     :float,   flon     :float,  \ ; INPUT
                         np       :integer, nl       :integer,\ ; INPUT
                         minpixel :integer, pdat     :float,  \ ; INPUT
                         gdat     :float,   pcon     :integer,\ ; OUTPUT
                         stdd     :float)                       ; OUTPUT

begin
;  CALCULATE THE HALF MAGNITUDE OF GRID BOX
   dx = (gclon(1, 0) - gclon(0, 0))/2.
   dy = (gclat(0, 1) - gclat(0, 0))/2.

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
      if(dx .ge. 0.0 .and. dy .ge. 0.0)then
       index2 = ind(oned_flat2 .ge. gclat(i, j)-dy .and. \
                    oned_flat2 .le. gclat(i, j)+dy .and. \
                    oned_flon2 .ge. gclon(i, j)-dx .and. \
                    oned_flon2 .le. gclon(i, j)+dx)
      else if(dx .le. 0.0 .and. dy .ge. 0.0)then
       index2 = ind(oned_flat2 .ge. gclat(i, j)-dy .and. \
                    oned_flat2 .le. gclat(i, j)+dy .and. \
                    oned_flon2 .le. gclon(i, j)-dx .and. \
                    oned_flon2 .ge. gclon(i, j)+dx)
      else if(dx .ge. 0.0 .and. dy .le. 0.0)then
       index2 = ind(oned_flat2 .le. gclat(i, j)-dy .and. \
                    oned_flat2 .ge. gclat(i, j)+dy .and. \
                    oned_flon2 .ge. gclon(i, j)-dx .and. \
                    oned_flon2 .le. gclon(i, j)+dx)
      else if(dx .le. 0.0 .and. dy .le. 0.0)then
       index2 = ind(oned_flat2 .le. gclat(i, j)-dy .and. \
                    oned_flat2 .ge. gclat(i, j)+dy .and. \
                    oned_flon2 .le. gclon(i, j)-dx .and. \
                    oned_flon2 .ge. gclon(i, j)+dx)
      end if
      end if
      end if
      end if
      if(.not.all(ismissing(index2)))then
       if(.not.all(ismissing(oned_pdat2(index2))))then
        pcon(i, j) = num(.not.ismissing(index2))
        if(pcon(i, j) .ge. minpixel)then
         gdat(i, j) = avg(oned_pdat2(index2))
         stdd(i, j) = stddev(oned_pdat2(index2))
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
      if(dx .ge. 0.0 .and. dy .ge. 0.0)then
       index3 = ind(oned_flat3 .ge. gclat(i, j)-dy .and. \
                    oned_flat3 .le. gclat(i, j)+dy .and. \
                    oned_flon3 .ge. gclon(i, j)-dx .and. \
                    oned_flon3 .le. gclon(i, j)+dx)
      else if(dx .le. 0.0 .and. dy .ge. 0.0)then
       index3 = ind(oned_flat3 .ge. gclat(i, j)-dy .and. \
                    oned_flat3 .le. gclat(i, j)+dy .and. \
                    oned_flon3 .le. gclon(i, j)-dx .and. \
                    oned_flon3 .ge. gclon(i, j)+dx)
      else if(dx .ge. 0.0 .and. dy .le. 0.0)then
       index3 = ind(oned_flat3 .le. gclat(i, j)-dy .and. \
                    oned_flat3 .ge. gclat(i, j)+dy .and. \
                    oned_flon3 .ge. gclon(i, j)-dx .and. \
                    oned_flon3 .le. gclon(i, j)+dx)
      else if(dx .le. 0.0 .and. dy .le. 0.0)then
       index3 = ind(oned_flat3 .le. gclat(i, j)-dy .and. \
                    oned_flat3 .ge. gclat(i, j)+dy .and. \
                    oned_flon3 .le. gclon(i, j)-dx .and. \
                    oned_flon3 .ge. gclon(i, j)+dx)
      end if
      end if
      end if
      end if
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
