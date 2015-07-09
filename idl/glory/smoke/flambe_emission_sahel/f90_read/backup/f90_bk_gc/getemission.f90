  module getemission
      contains
	subroutine  get_emission ( rnp, rnl, rlat, rlon, time, &
	                          erate, firenum)
	implicit none
	integer, parameter:: MaxL = 10000
	character*120 dir, time,  inptf, other!,stamp1
        character*12 stamp1 
	integer::  nl, i, j, k, rnp, rnl, nh 
	real, dimension(1:MaxL):: flat, flon, farea, flux
	real, pointer:: rlat(:,:), rlon(:,:), erate(:,:), firenum(:,:,:)
        real:: tmplat1, tmplon1, tmplat2, tmplon2, &
	       tmparea, tmpflux, tmpflag !, tmptime 
        integer:: sat,inmin,inmid,inmax,half,tmptime
        real :: carbon,tmp1,tmp2,tmp3	
	dir = '/home/gecui/prairiefire/data/flambe/2006/' 
	inptf = dir(1:len_trim(dir))//time(1:len_trim(time)) 
        print*,'time',time 
!       read data
	open(1, file = inptf, status = 'old')
	  print*, 'file = ', inptf
	  do i = 1, MaxL
!	    read(1, *, end=100) tmplat1, tmplon1, tmplat2, tmplon2, sat,&
!	               tmparea, tmpflux, tmpflag, tmptime, other
            read(1,*, end=100) stamp1,tmplon1, tmplat1, inmin, inmid, inmax, sat,tmparea,&
                               tmpflux, half, carbon, tmp1, tmp2,tmp3

            flat(i) = tmplat1
	    flon(i) = tmplon1
	    farea(i) = tmparea
	    flux(i) = tmpflux
	  enddo  
  100     continue
!  511     format(I12,2f8.3,3I6,I5,2f13.2,I5,2f13.2,3I5)

          close(1)
	   
	  print*, 'read is over'

	  nl = i-1
          
	  do i = 1, rnp-1
	   do j = 1, rnl-1
	       do k = 1, nl
	         if ( flat(k) .ge. rlat(i, j)   .and.  &
		      flat(k) .lt. rlat(i, j+1) .and.  &
		      flon(k) .ge. rlon(i,j)    .and.  &
		      flon(k) .lt. rlon(i+1, j) .and.  &
		      flux(k) .gt. 0 .and. farea(k) .gt.0 ) then
	         !    print*, 'find one fire'
                 !    print*,stamp1
                    
                     read(time(23:26),*) tmptime
!                    write(*,*) tmptime
                     print*,'1111111111'
                     nh = int (tmptime/100)
		     if ( nh .eq. 0 ) nh = 24 
		     print*, 'nh = ', nh, ' tmptime = ' , tmptime
		     erate(i,j) = flux(i) * farea(k)+erate(i,j)
		     firenum(i,j,nh) = firenum(i,j,nh)+1
		 endif
	      enddo    
	    enddo
	 enddo
	 
	 return
	 end subroutine get_emission 
       end module getemission
	    
