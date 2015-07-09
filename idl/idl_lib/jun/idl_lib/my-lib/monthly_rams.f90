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
      real, pointer::   tmptime(:, :), &       ! time array (nt, nz)
		        tmpheight(:,:),&       ! height array(nt, nz)
                        varon(:, :, :, :), &  ! var array(np, nl, nt, nz)
                        varoff(:, :, :, :),&  ! var array(np, nl, nt, nz)
                        lat(:, :, :, :),&  ! var array(np, nl, nt, nz)
                        lon(:, :, :, :)  ! var array(np, nl, nt, nz)

! post processing information
     real, allocatable:: VarMeanon(:,:), &
             VarMeanOff(:,:),  VarDiff(:,:)        ! AOT distribution   
     real:: LatT, LatB, LonL, lonR                 ! grid box we're  interested in    
     real:: nt1, nt2, nz2, nz1                     ! time and layer of  interest    
     integer:: i, j, ktt,kt, k                     ! loop index 
     real:: SumN, SumVarOn, SumVarOff, SumVarDiff
     integer:: nzlat0, nzlatmax
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
      read(tmpchar, *) nt1
      call getarg(7, tmpchar)
      read(tmpchar, *) nt2
      call getarg(8, tmpchar)
      read(tmpchar, *) nz1
      call getarg(9, tmpchar)
      read(tmpchar, *) nz2
  
  ! get output surfix
      call getarg(10, OutputSurfix)
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
     allocate(VarMeanOn(np,nl))
     allocate(VarMeanOff(np,nl))
     allocate(VarDiff(np,nl))
      
      do i = 1, np 
        do j = 1, nl
          SumVarOn = 0.0
          SumVarOff = 0.0
          SumVarDiff = 0.0
          SumN = 0.0

!Diff values	  
	  VarMeanOn(i,j) = 0.0
	  VarMeanOff(i,j) = 0.0
	  VarDiff(i,j) = 0.0
	  
          if ( lat(i,j) .lt. LatT .and. lat(i,j) .gt. LatB .and. &
	      lon(i,j) .lt. LonR .and. lon(i,j) .gt. LonL ) then
	    do kt = nt1, nt2
	      ktt = kt
	      do k =  nz1, nz2 
	        SumVarDiff = varon(i,j, ktt, k) - varoff(i,j, ktt, k)+SumVardiff  
	        SumVarOn = varon(i,j, ktt, k) +SumVarOn  
	        SumVarOff = varoff(i,j, ktt, k) +SumVarOff  
	        SumN = SumN+1
	      enddo
	    enddo  
	  endif
	  VarMeanOn (i,j) = SumVaron/SumN 
	  VarMeanOff (i,j) = SumVaroff/SumN 
	  VarDiff (i,j) = SumVarDiff/SumN 
	 enddo
	enddo 

! output files
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_on.dat'        
	call outputF(tmpfile, np, nl, 1,VarMeanOn)
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_diff.dat'        
	call outputF(tmpfile, np, nl, 1,VarDiff)
        tmpfile = trim(adjustl(OutputSurfix))//trim(adjustl(varname))//'_off.dat'        
	call outputF(tmpfile, np, nl, 1, VarMeanOff)

END

      
