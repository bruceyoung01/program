  module dailyemission
      contains
	subroutine  daily_emission ( rnp, rnl, rlat, rlon, time, &
	                          erate)
	implicit none
	integer, parameter:: MaxL = 10000
	character*120 dir, time,  inptf, other 
	integer::  nl, i, j, k, rnp, rnl, nh 
	real, dimension(1:MaxL):: flat, flon, farea, flux
	real, pointer:: rlat(:,:), rlon(:,:), erate(:,:)
        real:: tmplat1, tmplon1, tmplat2, tmplon2, sat, &
	       tmparea, tmpflux, tmpflag, tmptime 
	
	dir = '/s1/data/wangjun/s4/Proj/FLAME/data/'
	inptf = dir(1:len_trim(dir))//time(1:len_trim(time)) 

!       read data
	open(1, file = inptf, status = 'old')
!	  print*, 'file = ', inptf
	  do i = 1, MaxL
	    read(1, *, end=100) tmplat1, tmplon1, tmplat2, tmplon2, sat,&
	               tmparea, tmpflux, tmpflag, tmptime, other
            flat(i) = tmplat1
	    flon(i) = tmplon1
	    farea(i) = tmparea
	    flux(i) = tmpflux
	  enddo  
  100     continue
          close(1)
	   
!	  print*, 'read is over'

	  nl = i-1
          
	  do i = 1, rnp-1
	   do j = 1, rnl-1
	       do k = 1, nl
	         if ( flat(k) .ge. rlat(i, j)   .and.  &
		      flat(k) .lt. rlat(i, j+1) .and.  &
		      flon(k) .ge. rlon(i,j)    .and.  &
		      flon(k) .lt. rlon(i+1, j) .and.  &
		      flux(k) .gt. 0 .and. farea(k) .gt.0 ) then
		     
		        erate(i,j) = flux(i) * farea(k) + erate(i,j)
		 endif
	      enddo    
	    enddo
	 enddo
	 
	 return
	 end subroutine daily_emission 
       end module dailyemission
	    
