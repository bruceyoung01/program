!
! routine to read the fire emissions, and composite it
!

! flat, flon : varialbe name
!   farea    : fire size
!   flux     : flux data in FLAME
! ferate     : calculted emission rate, will be used in the RAMS      
! nl         : # of lines
! rlat and rlon  :  RAMS lat, lon for a grid

! now do a area averaged, and into the daily basis.
        use dailyemission
        implicit none
	character*120 time, inputf
	real:: LatB = -35, LatT = 60, LonL = -120, LonR = -50 
	real:: GSize = 0.5
	
! define box range that we're interested in
	real:: BLatB = 8, BLatT = 25, BLonL = -120, BLonR = -75 
        integer:: bnp1, bnp2, bnl1, bnl2
	
        integer:: np, nl, i, j, k, nh  ! # of hours
        real, pointer:: GLat(:,:), GLon(:,:), &
	                Emission(:,:),	FireNum(:,:,:)
	real ferate
	character*100 day, mon 
	character*100 day0, mon0, outf

        NL = (LatT-LatB)/GSize + 1
	NP = (LonR-LonL)/GSize + 1
        BNL1 = (BLatB - LatB)/Gsize + 1
	BNL2 = (BLatT - LatB)/Gsize + 1
	BNP1 = (BLonL - LonL)/Gsize + 1
        BNP2 = (BLonR - LonL)/Gsize + 1 
	
	nh = 24
	allocate(Glat(Np,nl))
	allocate(Glon(Np,nl))
	allocate(Emission(np, nl))
!	allocate(FireNum(np, nl, nh))
        
	do i = 1, NP
	  do j = 1, NL
	     GLat(i,j) = j*Gsize + LatB
	     GLon(i,j) = i*Gsize + LonL
	     Emission(i,j) = 0.0
	  enddo
	enddo

	print*, 'NP = ', NP, 'NL= ', nL
! start to sum total emissions  
        inputf = "FileName.txt"
	day0 = '01'
	mon0 = '04'
	
	open(2, file = inputf, status = 'old')
          do i = 1, 5000  
	    read(2, *, end=200) time
!	    print*, 'time is ', time
            mon(1:2) = time(16:17)
	    day = time(18:19)
	    
	    ! judge if the file on the same date
	    if ( day0 .ne. day .or. mon0 .ne.  mon ) then
	      outf = time(1:15) // mon0(1:2) // day0(1:len_trim(day))//'.dat'
              print*, 'out file is ', outf
	      open(1, file = outf, access='direct', recl=Np*Nl*4)
 	      write(1, rec=1) Emission
	      close(1)
	      mon0 = mon
	      day0 = day
	      emission(1:NP, 1:NL) = 0.0
	    endif  
	      
	    call daily_emission(np, nl, Glat, GLon, time, emission)
!	    print*, ' I = ', i
	  enddo
 200      continue
         close(2)

!        open(1, file = "Flambe_Emission.dat", access='direct', recl=Np*Nl*4)
!	write(1, rec=1) Emission
!	close(1)

        open(1, file = "Flambe_lat.dat", access='direct', recl=Np*Nl*4)
	write(1, rec=1) Glat 
	close(1)

        open(1, file = "Flambe_lon.dat", access='direct', recl=Np*Nl*4)
	write(1, rec=1) Glon 
	close(1)

!        open(1, file = "FIRE_Num.dat", access='direct', recl=Np*Nl*4*nh)
!	write(1, rec=1) FireNum 
!	close(1)


        print*, 'file size = ', Np*nl*4

! summ all emissions
        print*, 'sum emissions = ', sum(Emission(bnp1:bnp2, bnl1:bnl2))
    
    end

