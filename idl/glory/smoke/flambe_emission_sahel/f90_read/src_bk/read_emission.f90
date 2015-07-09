!
! routine to read the fire emissions
!

!now assuming first: the emission rate is constant at 6 hours intervals
! flat, flon : varialbe name
!   farea    : fire size
!   flux     : flux data in FLAME
! ferate     : calculted emission rate, will be used in the RAMS      
! nl         : # of lines
! rlat and rlon  :  RAMS lat, lon for a grid

	character*120 time 
	real gridsize, rlat, rlon
	real ferate
	
	time = '200304290600'
	gridsize = 100
	rlat=19.
	rlon=-101.
	
	call get_emission (gridsize, rlat, rlon, time, ferate)
	print*, 'emission rate = ', ferate
	end

	
	subroutine  get_emission ( gridsize, rlat, rlon, time, ferate)
	parameter (MaxL = 10000)
	real rlat, rlon, gridsize
	character*120 dir, time,  inptf, nouse
	integer nl
	real, dimension(1:MaxL):: flat, flon, farea, flux
	real ferate
	
	dir = '/s1/data/wangjun/s4/Proj/FLAME/data/smoke_goes_'
	inptf = dir(1:len_trim(dir))//time(1:len_trim(time))//'.dat' 

!       read data
	open(1, file = inptf, status = 'old')
	  do i = 1, MaxL
	    read(1, *, end=100) tmplat1, tmplon1, tmplat2, tmplon2, sat,&
	               tmparea, tmpflux, tmppose, nouse
            flat(i) = tmplat1
	    flon(i) = tmplon1
	    farea(i) = tmparea
	    flux(i) = tmpflux
	  enddo  
  100     continue
	    
	    nl = i-1

!	search for the fires that located in the gird size (100X100km) 
	  emission = 0.

	  do i = 1, nl
	     call cal_dis (flat(i), rlat,  flon(i), rlon, dis)
	     if ( dis .lt.  gridsize) then
	       emission = flux(i) * farea(i)+emission
	     endif
	  enddo    
	 
	 print*, 'emission = ', emission
	 ferate = emission/6.

	 end 

	    
