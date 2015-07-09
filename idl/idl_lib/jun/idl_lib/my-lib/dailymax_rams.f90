!
! This program using read_rams_module to read temperature output, 
! calcualte avg. temp with and without aerosols, and their relationship 
! with smoke AOT
!

      program read_rams_temp 
      use read_rams_module
      implicit none

! specify gird information
      integer:: np,  & ! # of grids in x-direction
                nl,  & ! # of grids in y-direction
		nz0, & ! # of grids in z-direction (needed) 
		nt , & ! # of times for all files
		nzmax  ! # of grids in z-direction (specified in revu)
      
      character*150 :: filename, &    ! input filename
                       varname        ! var name, AOT, smoke, etc.

!output
      real, pointer::   tmptime(:, :), &      ! time array (nt, nz)
		        tmpheight(:,:),&      ! height array(nt, nz)
                        varon(:, :, :, :), &  ! var array(np, nl, nt, nz)
                        varoff(:, :, :, :),&  ! var array(np, nl, nt, nz)
                        lat(:, :, :, :), &    ! var array(np, nl, nt, nz)
                        lon(:, :, :, :)       ! var array(np, nl, nt, nz)

!			
    real, allocatable:: DailyMax(:,:,:), &    ! Daily Max
			DailyMin(:,:,:), &    ! Daily Mean
			MaxDiff(:,:,:),  &    ! Difference of Max 
			MinDiff(:,:,:),  &    ! Difference of Min 
			MaxAvgDiff(:,:),     &    ! Avg of Max
			MinAvgDiff(:,:)           ! Avg of Min 

     real:: LatT, LatB, LonL, lonR                 ! grid box we're  interested in    
     integer:: nt1, nt2, nz2, nz1                     ! time and layer of  interest    
     integer:: i, j, ktt,kt, k                     ! loop index 
     real:: SumN, SumMaxDiff, SumMinDiff 
     integer:: nzlat0, nzlatmax
     integer:: TimeChange = 19
     
! argument for command line
     character*150 tmpvar, diron, diroff, &
                   fileon, fileoff, tmpfile, &
		   outputsurfix                    ! dirname and varname      
     character*5  tmpchar 

! initialize values, read lat and lon 
      np  = 48 
      nl  = 48
      nzmax = 1

! specify interest region and time and layer
      LatT = 60.
      LatB = -15.
      LonL = -130.
      LonR = -40.
     
! get var from command line
  ! get correct filename
      call getarg(1, diron) 
      call getarg(2, diroff) 
      call getarg(3, varname)
      fileon = trim(adjustl(diron)) // trim(adjustl(varname)) // '.dmp'
      fileoff = trim(adjustl(diroff)) // trim(adjustl(varname)) // '.dmp'
  
  ! get nz and nzmax
      call getarg(4, tmpchar)
      read(tmpchar, *) nz0 
      call getarg(5, tmpchar)
      read(tmpchar, *) nzmax 
     
  ! get time and height invervals
      call getarg(6, tmpchar)
      read(tmpchar, 'I4') nt1
      call getarg(7, tmpchar)
      read(tmpchar, 'I4') nt2
      call getarg(8, tmpchar)
      read(tmpchar, 'I4') nz1
      call getarg(9, tmpchar)
      read(tmpchar, 'I4') nz2
  
  ! get output surfix
      call getarg(10, OutPutSurfix)
      print*, 'nt1 nt2 = ', nt1, nt2,  'nz1, nz2 = ', nz1, nz2

  ! read var
      call read_rams(fileon, varname, tmptime, varon, tmpheight, &
                   nt, nz0, np, nl, nzmax )
      call read_rams(fileoff, varname, tmptime, varoff, tmpheight, &
                   nt, nz0, np, nl, nzmax )
		   
  ! read lat and lon
       nzlat0 = 1
       nzlatmax =1 
       tmpfile = trim(adjustl(diron)) // 'LAT.dmp'
       tmpvar = 'LAT'
      call read_rams(tmpfile, tmpvar, tmptime, lat, tmpheight, &
                   nt, nz0, np, nl, nzlatmax )
      tmpfile = trim(adjustl(diron)) // 'LON.dmp' 
       tmpvar = 'LON'
      call read_rams(tmpfile, tmpvar, tmptime, lon, tmpheight, &
                   nt, nzlat0, np, nl, nzlatmax )
  
  ! seach regions
     allocate(DailyMax(np,nl, nt2-nt1+1))
     allocate(DailyMin(np,nl, nt2-nt1+1))
     allocate(MaxDiff(np,nl, nt2-nt1+1))
     allocate(MinDiff(np,nl, nt2-nt1+1))
     allocate(MaxAvgDiff(np,nl))
     allocate(MinAvgDiff(np,nl))
      
      do i = 1, np 
        do j = 1, nl
          SumN = 0.0
	  SumMaxDiff = 0.0
	  SumMinDiff = 0.0
	  MaxAvgDiff(i,j) = 0.0
	  MinAvgDiff(i,j) = 0.0

	  
          if ( lat(i,j) .lt. LatT .and. lat(i,j) .gt. LatB .and. &
	      lon(i,j) .lt. LonR .and. lon(i,j) .gt. LonL ) then
	    
	    do kt = nt1, nt2
!Diff values	  
!	       DailyMax(i,j, kt-nt1+1) = 0.0
!	       DailyMin(i,j, kt-nt1+1) = 0.0
!	       MaxDiff(i,j, kt-nt1+1) = 0.0
!	       MinDiff(i,j, kt-nt1+1) = 0.0
	      
	      do k =  nz1, nz2
	         DailyMax(i,j, kt-nt1+1) = maxval(varon(i,j, kt*24+TimeChange: (kt+1)*24+TimeChange, k))
	         DailyMin(i,j, kt-nt1+1) = minval(varon(i,j, kt*24+TimeChange: (kt+1)*24+TimeChange, k)) 
	         MaxDiff(i,j, kt-nt1+1) = DailyMax(i,j, kt-nt1+1) - &
		                          maxval(varoff(i,j, kt*24+TimeChange: (kt+1)*24+TimeChange, k))
		 MinDiff(i,j, kt-nt1+1) = DailyMin(i,j, kt-nt1+1) - &
		                          minval(varoff(i,j, kt*24+TimeChange: (kt+1)*24+TimeChange, k))
                 SumMaxDiff = MaxDiff(i,j, kt-nt1+1) + SumMaxDiff
		 SumMinDiff = MinDiff(i,j, kt-nt1+1) + SumMinDiff
		 
	         SumN = SumN+1
	      enddo
	    enddo  
	  endif

	  MaxAvgDiff (i,j) = SumMaxDiff/SumN 
	  MinAvgDiff (i,j) = SumMinDiff/SumN 
	 enddo
	enddo 

! output files
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_DailyMaxon.dat'        
	call outputF(tmpfile, np, nl, nt2-nt1+1, DailyMax)
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_DailyMaxdiff.dat'        
	call outputF(tmpfile, np, nl, nt2-nt1+1, MaxDiff)
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_DailyMindiff.dat'        
	call outputF(tmpfile, np, nl, nt2-nt1+1, MinDiff)
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_AvgMaxDiff.dat'        
	call outputF(tmpfile, np, nl, nt1-nt1+1, MaxAvgDiff)
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_AvgMinDiff.dat'        
	call outputF(tmpfile, np, nl, nt1-nt1+1, MinAvgDiff)

END

      
