!
! routine to read the fire emissions, and composite it
!

! flat, flon : varialbe name
!   farea    : fire size
!   flux     : flux data in FLAME
! ferate     : calculted emission rate, will be used in the RAMS      
! nl         : # of lines
! rlat and rlon  :  RAMS lat, lon for a grid

! now do a area averaged.
        use getemission
        implicit none
	character*120 time, inputf
	real:: LatB = -15, LatT = 35, LonL = -25, LonR = 45 
	real:: GSize = 1
	
! define box range that we're interested in
	real:: BLatB = -15, BLatT = 35, BLonL = -25, BLonR = 45
        integer:: bnp1, bnp2, bnl1, bnl2
	
        integer:: np, nl, i, j, k, nh  ! # of hours
        real, pointer:: GLat(:,:), GLon(:,:), &
	                Emission(:,:),	FireNum(:,:,:)
	real ferate

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
	allocate(FireNum(np, nl, nh))
        
	do i = 1, NP
	  do j = 1, NL
	     GLat(i,j) = j*Gsize + LatB
	     GLon(i,j) = i*Gsize + LonL
	     Emission(i,j) = 0.0
	     do k = 1, nh
	      FireNum(i,j,k) = 0
	     enddo 
	  enddo
	enddo

	print*, 'NP = ', NP, 'NL= ', nL
! start to sum total emissions  
        inputf = "../../../data/figure_01/figure_01a/raw_data/flambe_filelist"
	open(2, file = inputf, status = 'old')
          do i = 1, 5000  
	    read(2, *, end=200) time
	    print*, 'time is ', time
	    call get_emission(np, nl, Glat, GLon, time, emission, FireNum)
!	    print*, ' I = ', i
	  enddo
 200      continue
         close(2)

! output
        open(1, file = "Flambe_Emission.dat", access='direct', recl=Np*Nl*4)
	write(1, rec=1) Emission
	close(1)

        open(1, file = "Flambe_lat.dat", access='direct', recl=Np*Nl*4)
	write(1, rec=1) Glat 
	close(1)

        open(1, file = "Flambe_lon.dat", access='direct', recl=Np*Nl*4)
	write(1, rec=1) Glon 
	close(1)

        open(1, file = "FIRE_Num.dat", access='direct', recl=Np*Nl*4*nh)
	write(1, rec=1) FireNum 
	close(1)
       
           
 open(13,file='emission_in.txt')
    do i=1,NP
      do j=1,Nl
!      if ((Glon(i,1).gt.70).and.(Glon(i,1).lt.90).and.(Glat(1,j).gt.0).and.(Glat(1,j).lt.50)) then
      if (Emission(i,j).gt.0) then
      write(13,*) Emission(i,j),Glon(i,1),Glat(1,j)
      endif
    enddo
   enddo

        print*, 'file size = ', Np*nl*4

! summ all emissions
        open(24,file='sum_emission.txt')
        write(24,*) 'sum emissions for region 2 (unit,g)',sum(Emission(bnp1:bnp2, bnl1:bnl2))
        write(24,*) 'sum emissions for region 1 (unit,g)',sum(Emission(1:np,1:nl))
        close(24)
        print*, 'sum emissions = ', sum(Emission(bnp1:bnp2, bnl1:bnl2))
    
    end

